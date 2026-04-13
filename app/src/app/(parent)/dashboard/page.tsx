import { createClient } from "@/lib/supabase/server";
import { LayoutDashboard, Users, Flame, Star, Bell, Settings } from "lucide-react";
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

const PASTEL_THEMES = [
  { bg: "bg-[#f1cbcf]", border: "border-[#e8b5bb]" },
  { bg: "bg-[#d5ead9]", border: "border-[#b8d9bf]" },
  { bg: "bg-[#ffedc2]", border: "border-[#f5dea0]" },
  { bg: "bg-[#d4dff7]", border: "border-[#bccbeb]" },
] as const;

const WEEKDAY_LABELS = ["Mán", "Þri", "Mið", "Fim", "Fös", "Lau", "Sun"];

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
      (settingsRes.data as ChildSettings[] | null)?.map((s) => [s.child_id, s]) ?? []
    );
    dailyByChild = groupDailyByChild(
      (dailyRes.data as ChildDailyStats[] | null) ?? []
    );
    todayByChild = new Map(
      (todayRes.data as ChildDailyStats[] | null)?.map((d) => [d.child_id, d]) ?? []
    );
    weeklyByChild = latestWeeklyPerChild(
      (weeklyRes.data as ChildWeeklyStats[] | null) ?? []
    );
  }

  const totalPoints = (children ?? []).reduce(
    (sum, c) => sum + (Number(c.available_points) || 0), 0
  );
  const totalStreak = (children ?? []).reduce(
    (sum, c) => sum + (Number(c.current_streak_days) || 0), 0
  );
  const totalTasks = (children ?? []).reduce(
    (sum, c) => sum + (Number(c.completed_tasks_count) || 0), 0
  );
  const activeChildren = (children ?? []).filter((c) => Boolean(c.last_activity_at)).length;
  const totalWeeklyPoints = Array.from(weeklyByChild.values()).reduce(
    (sum, row) => sum + (Number(row.points_earned) || 0), 0
  );

  const dailyPointsByChild = Array.from(dailyByChild.entries()).map(([, rows]) =>
    rows.reduce((s, r) => s + (Number(r.points_earned) || 0), 0)
  );
  const maxDailyPoints = Math.max(1, ...dailyPointsByChild);
  const barHeights = dailyPointsByChild.length > 0
    ? dailyPointsByChild.map((v) => Math.max(8, Math.round((v / maxDailyPoints) * 100)))
    : [20, 35, 25, 50, 40, 55, 70];

  return (
    <div className="grid gap-6 xl:grid-cols-[minmax(0,1fr)_300px]">
      {/* ── Main column ── */}
      <div className="space-y-6 min-w-0">
        {/* Hero */}
        <section className="rounded-3xl bg-white border border-neutral-200/80 px-5 py-6 sm:px-7 sm:py-8">
          <h2 className="text-2xl sm:text-3xl lg:text-4xl font-black tracking-tight text-neutral-900 leading-tight">
            Fylgstu með
            <br />
            framförum barnanna
          </h2>
          <p className="mt-3 max-w-xl text-sm text-neutral-500 leading-relaxed">
            Stig, röð, markmið og greining — allt á einum stað.
          </p>

          {/* KPI row */}
          <div className="mt-6 grid gap-3 grid-cols-2 lg:grid-cols-4">
            <MetricCard label="Virk börn" value={String(activeChildren)} sub={`${children?.length ?? 0} skráð`} icon={<Users size={15} />} tone="evergreen" />
            <MetricCard label="Stig" value={String(totalPoints)} sub="í pússi" icon={<Star size={15} />} tone="gold" />
            <MetricCard label="Röð" value={String(totalStreak)} sub="dagar" icon={<Flame size={15} />} tone="info" />
            <MetricCard label="Verkefni" value={String(totalTasks)} sub="lokið alls" icon={<LayoutDashboard size={15} />} tone="neutral" />
          </div>
        </section>

        {/* Featured children cards */}
        <section>
          <div className="mb-3 flex items-center justify-between">
            <h3 className="text-base font-bold text-neutral-900">Börnin þín</h3>
            <a href="/children" className="text-xs font-semibold text-neutral-400 hover:text-neutral-700 transition-colors">
              Sjá öll &rarr;
            </a>
          </div>

          {!children || children.length === 0 ? (
            <div className="rounded-3xl border border-neutral-200 bg-white p-8 text-center">
              <p className="text-neutral-500 mb-4">Engin börn skráð ennþá.</p>
              <a
                href="/children"
                className="inline-flex items-center gap-2 bg-evergreen-500 text-white rounded-2xl px-4 py-2 font-semibold text-sm hover:bg-evergreen-600 transition-colors"
              >
                Bæta við barni
              </a>
            </div>
          ) : (
            <div className="grid gap-3 sm:grid-cols-2">
              {children.slice(0, 4).map((child, idx) => {
                const theme = PASTEL_THEMES[idx % PASTEL_THEMES.length];
                const points = Number(child.available_points) || 0;
                const streak = Number(child.current_streak_days) || 0;
                const tasks = Number(child.completed_tasks_count) || 0;
                return (
                  <article
                    key={child.id}
                    className={`rounded-3xl border p-5 ${theme.bg} ${theme.border}`}
                  >
                    <div className="mb-4 flex items-center justify-between">
                      <span className="rounded-full bg-white/70 px-2.5 py-1 text-[11px] font-semibold text-neutral-600">
                        {streak > 0 ? `${streak} daga röð` : "Engin röð"}
                      </span>
                      <span className="text-[11px] font-semibold text-neutral-600 tabular-nums">
                        {points} stig
                      </span>
                    </div>
                    <h4 className="text-xl font-extrabold leading-tight text-neutral-900">
                      {child.display_name || child.first_name}
                    </h4>
                    <p className="mt-1.5 text-xs text-neutral-600 tabular-nums">
                      {tasks} verkefni lokið
                    </p>
                  </article>
                );
              })}
            </div>
          )}
        </section>

        {/* Detailed analytics per child */}
        {children && children.length > 0 && (
          <section className="space-y-4">
            <h3 className="text-base font-bold text-neutral-900">Nánari greining</h3>
            <div className="grid gap-5 xl:grid-cols-1 2xl:grid-cols-2">
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

      {/* ── Right aside panel ── */}
      <aside className="space-y-4 xl:sticky xl:top-4 xl:self-start">
        {/* Profile card */}
        <section className="rounded-3xl border border-neutral-200/80 bg-[#efeae6] p-5">
          <div className="mb-3 flex items-center justify-between">
            <Bell size={15} className="text-neutral-500" />
            <Settings size={15} className="text-neutral-500" />
          </div>
          <div className="mb-4 text-center">
            <div className="mx-auto mb-2 h-12 w-12 rounded-full bg-gradient-to-br from-evergreen-300 to-evergreen-500 ring-2 ring-white" />
            <p className="text-sm font-bold text-neutral-900">Foreldri</p>
            <p className="text-[11px] text-neutral-500">{children?.length ?? 0} börn skráð</p>
          </div>

          {/* Weekly activity mini-chart */}
          <div className="rounded-2xl bg-white p-4">
            <div className="flex items-center justify-between mb-1">
              <p className="text-[11px] font-semibold uppercase tracking-wide text-neutral-500">Virkni vikunnar</p>
              <span className="text-[11px] text-neutral-400">Stig</span>
            </div>
            <p className="text-2xl font-black text-neutral-900 tabular-nums">{totalWeeklyPoints}</p>
            <p className="text-[11px] text-neutral-500 mb-4">safnað í þessari viku</p>

            {/* Bar chart — bars grow from bottom */}
            <div className="flex items-end gap-1.5 h-24">
              {barHeights.map((pct, i) => (
                <div key={i} className="flex-1 flex flex-col items-center gap-1">
                  <div className="w-full flex flex-col justify-end h-20 rounded-full bg-neutral-100 overflow-hidden">
                    <div
                      className="w-full rounded-full bg-gradient-to-t from-evergreen-500 to-mint-300 transition-all"
                      style={{ height: `${pct}%` }}
                    />
                  </div>
                  <span className="text-[9px] text-neutral-400 leading-none">
                    {WEEKDAY_LABELS[i % 7]}
                  </span>
                </div>
              ))}
            </div>
          </div>
        </section>

        {/* Quick links */}
        <section className="rounded-3xl border border-neutral-200/80 bg-white p-4">
          <p className="text-[11px] font-semibold uppercase tracking-wide text-neutral-500 mb-3">Flýtileiðir</p>
          <div className="space-y-2">
            {[
              { href: "/children", label: "Bæta við barni", icon: Users },
              { href: "/tasks", label: "Stofna verkefni", icon: LayoutDashboard },
              { href: "/rewards", label: "Verðlaunalisti", icon: Star },
            ].map((link) => (
              <a
                key={link.href}
                href={link.href}
                className="flex items-center gap-2.5 rounded-2xl bg-neutral-50 px-3 py-2.5 text-xs font-medium text-neutral-600 hover:bg-neutral-100 hover:text-neutral-900 transition-colors"
              >
                <link.icon size={14} className="text-evergreen-500 shrink-0" />
                {link.label}
              </a>
            ))}
          </div>
        </section>
      </aside>
    </div>
  );
}

/* ── Local helper components ── */

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
  const iconStyles = {
    evergreen: "bg-evergreen-50 text-evergreen-600",
    gold: "bg-gold-50 text-gold-600",
    info: "bg-info-light text-info",
    neutral: "bg-neutral-100 text-neutral-600",
  };

  return (
    <div className="rounded-2xl border border-neutral-200/70 bg-white/80 p-3.5">
      <div className="mb-2 flex items-center justify-between">
        <p className="text-[11px] font-semibold uppercase tracking-wide text-neutral-400">{label}</p>
        <span className={`grid place-items-center h-7 w-7 rounded-lg ${iconStyles[tone]}`}>{icon}</span>
      </div>
      <p className="text-xl font-extrabold text-neutral-900 tabular-nums leading-none">{value}</p>
      <p className="mt-1 text-[11px] text-neutral-500">{sub}</p>
    </div>
  );
}
