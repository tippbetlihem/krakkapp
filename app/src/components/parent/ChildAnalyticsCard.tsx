import type { ReactNode } from "react";
import type { Child, ChildDailyStats, ChildSettings, ChildWeeklyStats } from "@/types/database";
import {
  formatPercent,
  type SevenDayRollup,
} from "@/lib/parent/aggregate-child-stats";
import { Calculator, BookOpen, ClipboardCheck, Flame, TrendingUp } from "lucide-react";

function activityLabel(
  a: ChildWeeklyStats["most_used_activity"]
): string | null {
  if (a === "math") return "Stærðfræði";
  if (a === "reading") return "Lestur";
  if (a === "task") return "Verkefni";
  return null;
}

type Props = {
  child: Child;
  settings: ChildSettings | undefined;
  today: ChildDailyStats | undefined;
  rollup7: SevenDayRollup;
  latestWeekly: ChildWeeklyStats | undefined;
};

export function ChildAnalyticsCard({
  child,
  settings,
  today,
  rollup7,
  latestWeekly,
}: Props) {
  const name = child.display_name || child.first_name;
  const dailyGoal = settings?.daily_points_goal ?? null;
  const todayPoints = today ? Number(today.points_earned) || 0 : 0;
  const goalPct =
    dailyGoal && dailyGoal > 0
      ? Math.min(100, Math.round((todayPoints / dailyGoal) * 100))
      : null;
  const weeklyProgress = latestWeekly?.weekly_goal_reached
    ? 100
    : Math.min(100, rollup7.activeDays * 14);

  return (
    <div className="rounded-3xl border border-neutral-200/80 bg-white p-5 sm:p-6">
      {/* Header */}
      <div className="mb-4 flex justify-between items-start gap-3">
        <div className="min-w-0">
          <h3 className="text-base font-extrabold text-neutral-900 truncate">{name}</h3>
          {child.last_activity_at && (
            <p className="text-[11px] text-neutral-400 mt-0.5">
              Síðast virkt:{" "}
              {new Date(child.last_activity_at).toLocaleString("is-IS", {
                dateStyle: "medium",
                timeStyle: "short",
              })}
            </p>
          )}
        </div>
        <span className="shrink-0 bg-success-light text-success text-[11px] font-semibold px-2 py-0.5 rounded-full">
          Virk/ur
        </span>
      </div>

      {/* Mini stats — wraps on tiny screens */}
      <div className="grid grid-cols-3 gap-2 text-center mb-4">
        <MiniStat value={String(child.available_points)} label="Stig í pússi" className="text-evergreen-500" />
        <MiniStat
          value={String(child.current_streak_days)}
          label="Röð"
          className="text-info"
          icon={<Flame size={11} className="text-gold-500" />}
        />
        <MiniStat value={String(child.completed_tasks_count)} label="Verkefni" className="text-neutral-700" />
      </div>

      {/* Daily goal progress */}
      {dailyGoal != null && dailyGoal > 0 && (
        <div className="mb-4 rounded-2xl bg-neutral-50 border border-neutral-200/60 p-3">
          <div className="flex justify-between text-[11px] text-neutral-600 mb-1.5">
            <span className="font-medium">Markmið dagsins</span>
            <span className="tabular-nums">{todayPoints} / {dailyGoal} stig</span>
          </div>
          <div className="h-2 bg-neutral-200/80 rounded-full overflow-hidden">
            <div
              className="h-full bg-gold-400 rounded-full transition-[width] duration-500"
              style={{ width: `${goalPct ?? 0}%` }}
            />
          </div>
        </div>
      )}

      {/* 7-day rollup */}
      <div className="border-t border-neutral-100 pt-4 mb-4">
        <div className="flex items-center gap-2 text-xs font-bold text-neutral-800 mb-2.5">
          <TrendingUp size={15} className="text-evergreen-500" />
          Síðustu 7 dagar
        </div>
        {!rollup7.hasAnyRow ? (
          <p className="text-xs text-neutral-500 leading-relaxed">
            Engin dagleg gögn ennþá. Þegar barnið notar appið birtast stig,
            nákvæmni og tími hér.
          </p>
        ) : (
          <div className="grid gap-2 grid-cols-2 sm:grid-cols-3">
            <StatChip label="Stig" value={`${rollup7.pointsEarned}`} sub="á 7 dögum" />
            <StatChip label="Virkir dagar" value={`${rollup7.activeDays}`} sub="af 7" />
            <StatChip
              label="Stærðfræði"
              value={`${rollup7.mathSessions} lotur`}
              sub={rollup7.mathAccuracy != null ? formatPercent(rollup7.mathAccuracy) : "—"}
              icon={<Calculator size={12} className="text-evergreen-500" />}
            />
            <StatChip
              label="Lestur"
              value={`${rollup7.readingSessions} lotur`}
              sub={rollup7.readingAccuracy != null ? formatPercent(rollup7.readingAccuracy) : "—"}
              icon={<BookOpen size={12} className="text-evergreen-500" />}
            />
            <StatChip
              label="Verkefni"
              value={`${rollup7.tasksCompleted}`}
              sub="á 7 dögum"
              icon={<ClipboardCheck size={12} className="text-evergreen-500" />}
            />
            <StatChip
              label="Tími"
              value={rollup7.activeMinutes > 0 ? `~${rollup7.activeMinutes} mín` : "—"}
              sub="skráður"
            />
          </div>
        )}
      </div>

      {/* Progress circles */}
      <div className="mb-4 grid grid-cols-2 gap-2">
        <ProgressCircle
          label="Daglegt markmið"
          value={goalPct ?? 0}
          sub={`${todayPoints}/${dailyGoal ?? 0} stig`}
          tone="gold"
        />
        <ProgressCircle
          label="Vikutaktur"
          value={weeklyProgress}
          sub={`${rollup7.activeDays} virkir dagar`}
          tone="evergreen"
        />
      </div>

      {/* Lifetime footer */}
      <div className="border-t border-neutral-100 pt-3 text-[11px] text-neutral-500 space-y-0.5">
        <p>
          Ævistig:{" "}
          <span className="font-semibold text-neutral-700 tabular-nums">{child.lifetime_points}</span>
          {" · "}
          Langsta röð:{" "}
          <span className="font-semibold text-neutral-700 tabular-nums">{child.longest_streak_days}</span> dagar
        </p>
        <p>
          Lotur — stærðfr:{" "}
          <span className="tabular-nums font-medium text-neutral-700">{child.completed_math_sessions_count}</span>
          , lestur:{" "}
          <span className="tabular-nums font-medium text-neutral-700">{child.completed_reading_sessions_count}</span>
        </p>
      </div>

      {/* Latest weekly summary */}
      {latestWeekly && (
        <div className="mt-3 rounded-2xl bg-evergreen-50 border border-evergreen-100 px-3 py-2 text-[11px] text-neutral-700">
          <p className="font-semibold text-evergreen-600 mb-0.5">Síðasta vika</p>
          <p>
            {new Date(latestWeekly.week_start_date).toLocaleDateString("is-IS")}
            {" — "}
            {new Date(latestWeekly.week_end_date).toLocaleDateString("is-IS")}
            :{" "}
            <span className="tabular-nums font-medium">{latestWeekly.points_earned} stig</span>
            ,{" "}
            <span className="tabular-nums">{latestWeekly.active_days_count} virkir dagar</span>
            {activityLabel(latestWeekly.most_used_activity) && (
              <> · mest: {activityLabel(latestWeekly.most_used_activity)}</>
            )}
            {latestWeekly.weekly_goal_reached && (
              <span className="text-success font-medium"> · Markmið náð</span>
            )}
          </p>
        </div>
      )}
    </div>
  );
}

/* ── Helper components ── */

function MiniStat({
  value,
  label,
  className,
  icon,
}: {
  value: string;
  label: string;
  className?: string;
  icon?: ReactNode;
}) {
  return (
    <div className="rounded-2xl bg-neutral-50 p-2.5">
      <p className={`text-lg font-extrabold tabular-nums leading-none ${className ?? "text-neutral-700"}`}>
        {value}
      </p>
      <p className="mt-1 text-[10px] text-neutral-500 flex items-center justify-center gap-0.5">
        {icon}
        {label}
      </p>
    </div>
  );
}

function StatChip({
  label,
  value,
  sub,
  icon,
}: {
  label: string;
  value: string;
  sub: string;
  icon?: ReactNode;
}) {
  return (
    <div className="rounded-xl bg-neutral-50 border border-neutral-100/80 px-2.5 py-2">
      <div className="flex items-center gap-1 text-[10px] font-semibold uppercase tracking-wide text-neutral-400">
        {icon}
        {label}
      </div>
      <p className="text-sm font-bold text-neutral-900 tabular-nums mt-0.5">{value}</p>
      <p className="text-[10px] text-neutral-500">{sub}</p>
    </div>
  );
}

function ProgressCircle({
  label,
  value,
  sub,
  tone,
}: {
  label: string;
  value: number;
  sub: string;
  tone: "gold" | "evergreen";
}) {
  const normalized = Math.max(0, Math.min(100, value));
  const radius = 22;
  const circumference = 2 * Math.PI * radius;
  const offset = circumference - (normalized / 100) * circumference;
  const stroke = tone === "gold" ? "#FFD746" : "#324F44";

  return (
    <div className="rounded-2xl border border-neutral-200/60 bg-white p-3">
      <div className="flex items-center gap-2.5">
        <svg className="h-14 w-14 shrink-0 -rotate-90" viewBox="0 0 56 56" aria-hidden="true">
          <circle cx="28" cy="28" r={radius} fill="none" stroke="#ece8de" strokeWidth="6" />
          <circle
            cx="28"
            cy="28"
            r={radius}
            fill="none"
            stroke={stroke}
            strokeWidth="6"
            strokeLinecap="round"
            strokeDasharray={circumference}
            strokeDashoffset={offset}
            className="transition-[stroke-dashoffset] duration-500"
          />
        </svg>
        <div className="min-w-0">
          <p className="text-[10px] font-semibold uppercase tracking-wide text-neutral-400">{label}</p>
          <p className="text-base font-extrabold text-neutral-900 tabular-nums leading-tight">{normalized}%</p>
          <p className="text-[10px] text-neutral-500 truncate">{sub}</p>
        </div>
      </div>
    </div>
  );
}
