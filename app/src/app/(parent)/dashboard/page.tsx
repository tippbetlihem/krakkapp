import { createClient } from "@/lib/supabase/server";
import { LayoutDashboard } from "lucide-react";
import { ChildAnalyticsCard } from "@/components/parent/ChildAnalyticsCard";
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

  return (
    <div>
      <div className="flex items-center gap-3 mb-2">
        <LayoutDashboard size={24} className="text-evergreen-500" />
        <h1 className="text-2xl font-bold text-neutral-900">Yfirlit</h1>
      </div>
      <p className="text-sm text-neutral-500 mb-6 max-w-2xl">
        Yfirlit yfir virkni barna þinna: stig, röð, síðustu sjö dagar og
        markmið. Gögn koma úr daglegri skráningu þegar barnið notar KrakkApp.
      </p>

      {!children || children.length === 0 ? (
        <div className="bg-white rounded-2xl shadow-sm p-8 text-center">
          <p className="text-neutral-500 mb-4">Engin börn skráð ennþá.</p>
          <a
            href="/children"
            className="inline-flex items-center gap-2 bg-evergreen-500 text-white rounded-2xl px-4 py-2 font-semibold text-sm hover:bg-evergreen-600 transition-colors"
          >
            Bæta við barni
          </a>
        </div>
      ) : (
        <div className="grid gap-6 sm:grid-cols-2">
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
      )}
    </div>
  );
}
