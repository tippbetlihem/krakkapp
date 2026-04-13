import { createClient } from "@/lib/supabase/server";
import { LayoutDashboard, Users, Flame, Star, Bell, Sparkles } from "lucide-react";
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
  const totalWeeklyPoints = Array.from(weeklyByChild.values()).reduce(
    (sum, row) => sum + (Number(row.points_earned) || 0),
    0
  );
  const featuredChildren = (children ?? []).slice(0, 4);

  return (
    <div className="grid gap-6 xl:grid-cols-[1fr_320px]">
      <div className="space-y-6">
        <section className="rounded-[28px] bg-white border border-neutral-200 px-6 py-7">
          <h2 className="text-5xl font-black tracking-tight text-neutral-900 leading-[0.95]">
            Fjárfestu í
            <br />
            menntun barnsins
          </h2>
          <p className="mt-4 max-w-2xl text-sm text-neutral-500">
            Mjúkt yfirlit yfir virkni, markmið og framfarir, innblásið af nýja
            dashboard stílnum.
          </p>
          <div className="mt-6 grid gap-3 sm:grid-cols-2 xl:grid-cols-4">
            <MetricCard label="Virk börn" value={String(activeChildren)} sub={`${children?.length ?? 0} skráð`} icon={<Users size={16} />} tone="evergreen" />
            <MetricCard label="Stig í pússi" value={String(totalPoints)} sub="samtals núna" icon={<Star size={16} />} tone="gold" />
            <MetricCard label="Samanlögð röð" value={String(totalStreak)} sub="dagar" icon={<Flame size={16} />} tone="info" />
            <MetricCard label="Verkefni lokið" value={String(totalTasks)} sub="alls" icon={<LayoutDashboard size={16} />} tone="neutral" />
          </div>
        </section>

        <section>
          <div className="mb-3 flex items-center justify-between">
            <h3 className="text-lg font-extrabold text-neutral-900">Mest notað</h3>
            <button className="text-sm font-semibold text-neutral-500 hover:text-neutral-800">Sjá allt</button>
          </div>
          {featuredChildren.length === 0 ? (
            <div className="bg-white rounded-3xl border border-neutral-200 p-8 text-center">
              <p className="text-neutral-500 mb-4">Engin börn skráð ennþá.</p>
              <a href="/children" className="inline-flex items-center gap-2 bg-evergreen-500 text-white rounded-2xl px-4 py-2 font-semibold text-sm hover:bg-evergreen-600 transition-colors">Bæta við barni</a>
            </div>
          ) : (
            <div className="grid gap-4 md:grid-cols-2">
              {featuredChildren.map((child, idx) => (
                <FeaturedChildCard
                  key={child.id}
                  childName={child.display_name || child.first_name}
                  students={Number(child.completed_tasks_count) || 0}
                  badge={idx % 2 === 0 ? "Top 10" : "Vinsælt"}
                  theme={idx % 2 === 0 ? "rose" : "mint"}
                />
              ))}
            </div>
          )}
        </section>

        {children && children.length > 0 && (
          <section className="space-y-3">
            <h3 className="text-lg font-bold text-neutral-900">Nánari greining</h3>
            <div className="grid gap-6 2xl:grid-cols-2">
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
          </section>
        )}
      </div>

      <aside className="space-y-4">
        <section className="rounded-[26px] border border-neutral-200 bg-[#efebe8] p-5">
          <div className="mb-4 flex items-center justify-between">
            <Bell size={16} className="text-neutral-600" />
            <Sparkles size={16} className="text-neutral-600" />
          </div>
          <div className="mb-4 text-center">
            <div className="mx-auto mb-2 h-14 w-14 rounded-full bg-gradient-to-br from-evergreen-300 to-evergreen-500" />
            <p className="text-lg font-bold text-neutral-900">Foreldra aðgangur</p>
          </div>
          <div className="rounded-2xl bg-white p-3">
            <p className="text-xs font-semibold uppercase tracking-wide text-neutral-500">Virkni vikunnar</p>
            <p className="mt-1 text-3xl font-black text-neutral-900 tabular-nums">{totalWeeklyPoints}</p>
            <p className="text-xs text-neutral-500">stig safnað í þessari viku</p>
            <div className="mt-4 flex items-end gap-1.5">
              {[42, 58, 49, 67, 54, 62, 76].map((v, i) => (
                <div key={i} className="h-20 flex-1 rounded-full bg-neutral-100 p-0.5">
                  <div className="w-full rounded-full bg-gradient-to-t from-evergreen-500 to-mint-300" style={{ height: `${v}%` }} />
                </div>
              ))}
            </div>
          </div>
        </section>
      </aside>
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

function FeaturedChildCard({
  childName,
  students,
  badge,
  theme,
}: {
  childName: string;
  students: number;
  badge: string;
  theme: "rose" | "mint";
}) {
  const shell =
    theme === "rose"
      ? "bg-[#f1cbcf] border-[#efbcc2]"
      : "bg-[#d5ead9] border-[#bcdcc4]";

  return (
    <article className={`rounded-3xl border p-5 ${shell}`}>
      <div className="mb-6 flex items-center justify-between">
        <span className="rounded-full bg-white/80 px-2.5 py-1 text-xs font-semibold text-neutral-700">
          {badge}
        </span>
        <span className="text-xs font-semibold text-neutral-600">⭐ 4.9</span>
      </div>
      <h4 className="text-2xl font-extrabold leading-tight text-neutral-900">{childName}</h4>
      <p className="mt-2 text-sm text-neutral-600 tabular-nums">{students} verkefni</p>
    </article>
  );
}
