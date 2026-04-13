import { createClient } from "@/lib/supabase/server";
import { LayoutDashboard, Users, Flame, Star } from "lucide-react";
import { ChildAnalyticsCard } from "@/components/parent/ChildAnalyticsCard";
import type { ReactNode } from "react";
import {
  icelandDateString,
  rollupSevenDay,
  sevenDayWindowStartIso,
} from "@/lib/parent/aggregate-child-stats";
import type { ChildDailyStats, ChildSettings, ChildWeeklyStats } from "@/types/database";

function groupDailyByChild(rows: ChildDailyStats[]): Map<string, ChildDailyStats[]> {
  const m = new Map<string, ChildDailyStats[]>();
  for (const r of rows) {
    const list = m.get(r.child_id) ?? [];
    list.push(r);
    m.set(r.child_id, list);
  }
  return m;
}

function latestWeeklyPerChild(
  rows: ChildWeeklyStats[]
): Map<string, ChildWeeklyStats> {
  const m = new Map<string, ChildWeeklyStats>();
  for (const r of rows) {
    const prev = m.get(r.child_id);
    if (!prev || r.week_start_date > prev.week_start_date) {
      m.set(r.child_id, r);
    }
  }
  return m;
}

export default async function DashboardPage() {
  const supabase = await createClient();
  const { data: children } = await supabase
    .from("children")
    .select("*")
    .eq("is_active", true)
    .order("created_at");

  const childIds = (children ?? []).map((c) => c.id);
  const todayStr = icelandDateString();
  const windowStart = sevenDayWindowStartIso();

  let settingsByChild = new Map<string, ChildSettings>();
  let dailyByChild = new Map<string, ChildDailyStats[]>();
  let todayByChild = new Map<string, ChildDailyStats>();
  let weeklyByChild = new Map<string, ChildWeeklyStats>();

  if (childIds.length > 0) {
    const [settingsRes, dailyRes, todayRes, weeklyRes] = await Promise.all([
      supabase.from("child_settings").select("*").in("child_id", childIds),
      supabase
        .from("child_daily_stats")
        .select("*")
        .in("child_id", childIds)
        .gte("stat_date", windowStart)
        .order("stat_date", { ascending: true }),
      supabase
        .from("child_daily_stats")
        .select("*")
        .in("child_id", childIds)
        .eq("stat_date", todayStr),
      supabase
        .from("child_weekly_stats")
        .select("*")
        .in("child_id", childIds)
        .order("week_start_date", { ascending: false }),
    ]);

    settingsByChild = new Map(
      (settingsRes.data as ChildSettings[] | null)?.map((s) => [s.child_id, s]) ??
        []
    );
    dailyByChild = groupDailyByChild(
      (dailyRes.data as ChildDailyStats[] | null) ?? []
    );
    todayByChild = new Map(
      (todayRes.data as ChildDailyStats[] | null)?.map((d) => [d.child_id, d]) ??
        []
    );
    weeklyByChild = latestWeeklyPerChild(
      (weeklyRes.data as ChildWeeklyStats[] | null) ?? []
    );
  }

  const totalPoints = (children ?? []).reduce(
    (sum, child) => sum + (Number(child.available_points) || 0),
    0
  );
  const totalStreak = (children ?? []).reduce(
    (sum, child) => sum + (Number(child.current_streak_days) || 0),
    0
  );
  const totalTasks = (children ?? []).reduce(
    (sum, child) => sum + (Number(child.completed_tasks_count) || 0),
    0
  );
  const activeChildren = (children ?? []).filter((child) => Boolean(child.last_activity_at)).length;

  return (
    <div className="space-y-6">
      <div className="rounded-3xl bg-gradient-to-r from-evergreen-600 to-evergreen-500 px-6 py-6 text-white shadow-[0_12px_30px_rgba(26,40,34,0.18)]">
        <div className="flex items-center gap-3 mb-2">
          <LayoutDashboard size={22} className="text-gold-300" />
          <h2 className="text-xl font-extrabold">Foreldra Dashboard</h2>
        </div>
        <p className="text-sm text-evergreen-100 max-w-2xl">
          Fylgstu með virkni barna þinna, stigum, markmiðum og framförum dags og viku.
        </p>
      </div>

      <div className="grid gap-4 sm:grid-cols-2 xl:grid-cols-4">
        <MetricCard
          label="Virk börn"
          value={String(activeChildren)}
          sub={`${children?.length ?? 0} skráð`}
          icon={<Users size={16} />}
          tone="evergreen"
        />
        <MetricCard
          label="Stig í pússi"
          value={String(totalPoints)}
          sub="samtals núna"
          icon={<Star size={16} />}
          tone="gold"
        />
        <MetricCard
          label="Samanlögð röð"
          value={String(totalStreak)}
          sub="dagar"
          icon={<Flame size={16} />}
          tone="info"
        />
        <MetricCard
          label="Verkefni lokið"
          value={String(totalTasks)}
          sub="alls"
          icon={<LayoutDashboard size={16} />}
          tone="neutral"
        />
      </div>

      {!children || children.length === 0 ? (
        <div className="bg-white rounded-3xl border border-neutral-200 p-8 text-center">
          <p className="text-neutral-500 mb-4">Engin börn skráð ennþá.</p>
          <a
            href="/children"
            className="inline-flex items-center gap-2 bg-evergreen-500 text-white rounded-2xl px-4 py-2 font-semibold text-sm hover:bg-evergreen-600 transition-colors"
          >
            Bæta við barni
          </a>
        </div>
      ) : (
        <div className="space-y-3">
          <h2 className="text-lg font-bold text-neutral-900">Yfirlit eftir barni</h2>
          <div className="grid gap-6 xl:grid-cols-2">
          {children.map((child) => {
            const dailyRows = dailyByChild.get(child.id) ?? [];
            const rollup7 = rollupSevenDay(dailyRows);
            return (
              <ChildAnalyticsCard
                key={child.id}
                child={child}
                settings={settingsByChild.get(child.id)}
                today={todayByChild.get(child.id)}
                rollup7={rollup7}
                latestWeekly={weeklyByChild.get(child.id)}
              />
            );
          })}
          </div>
        </div>
      )}
    </div>
  );
}

function MetricCard({
  label,
  value,
  sub,
  icon,
  tone,
}: {
  label: string;
  value: string;
  sub: string;
  icon: ReactNode;
  tone: "evergreen" | "gold" | "info" | "neutral";
}) {
  const tones = {
    evergreen: "bg-evergreen-50 text-evergreen-600 border-evergreen-100",
    gold: "bg-gold-50 text-gold-600 border-gold-100",
    info: "bg-info-light text-info border-info/10",
    neutral: "bg-neutral-50 text-neutral-700 border-neutral-200",
  };

  return (
    <div className="rounded-2xl border border-neutral-200 bg-white p-4 shadow-sm">
      <div className="mb-3 flex items-center justify-between">
        <p className="text-xs font-semibold uppercase tracking-wide text-neutral-500">{label}</p>
        <span className={`rounded-lg border px-2 py-1 ${tones[tone]}`}>{icon}</span>
      </div>
      <p className="text-2xl font-extrabold text-neutral-900 tabular-nums">{value}</p>
      <p className="text-xs text-neutral-500">{sub}</p>
    </div>
  );
}
