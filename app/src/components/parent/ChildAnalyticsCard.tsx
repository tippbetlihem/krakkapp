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

  return (
    <div className="bg-white rounded-2xl shadow-sm p-6">
      <div className="flex justify-between items-start mb-4">
        <div>
          <h3 className="text-lg font-semibold text-neutral-900">{name}</h3>
          {child.last_activity_at && (
            <p className="text-xs text-neutral-400">
              Síðast virkt:{" "}
              {new Date(child.last_activity_at).toLocaleString("is-IS", {
                dateStyle: "medium",
                timeStyle: "short",
              })}
            </p>
          )}
        </div>
        <span className="bg-success-light text-success text-xs font-medium px-2 py-0.5 rounded-full">
          Virk/ur
        </span>
      </div>

      <div className="grid grid-cols-3 gap-4 text-center mb-5">
        <div>
          <p className="text-xl font-bold text-evergreen-500 tabular-nums">
            {child.available_points}
          </p>
          <p className="text-xs text-neutral-500">Stig í pússi</p>
        </div>
        <div>
          <p className="text-xl font-bold text-info tabular-nums">
            {child.current_streak_days}
          </p>
          <p className="text-xs text-neutral-500 flex items-center justify-center gap-0.5">
            <Flame size={12} className="text-gold-500 shrink-0" />
            Röð í dag
          </p>
        </div>
        <div>
          <p className="text-xl font-bold text-neutral-700 tabular-nums">
            {child.completed_tasks_count}
          </p>
          <p className="text-xs text-neutral-500">Verkefni (alls)</p>
        </div>
      </div>

      {dailyGoal != null && dailyGoal > 0 && (
        <div className="mb-5">
          <div className="flex justify-between text-xs text-neutral-600 mb-1">
            <span className="font-medium">Markmið dagsins</span>
            <span className="tabular-nums">
              {todayPoints} / {dailyGoal} stig
            </span>
          </div>
          <div className="h-2 bg-neutral-200 rounded-full overflow-hidden">
            <div
              className="h-full bg-gold-400 rounded-full transition-[width]"
              style={{ width: `${goalPct ?? 0}%` }}
            />
          </div>
        </div>
      )}

      <div className="border-t border-neutral-100 pt-4 mb-4">
        <div className="flex items-center gap-2 text-sm font-bold text-neutral-800 mb-3">
          <TrendingUp size={18} className="text-evergreen-500" />
          Síðustu 7 dagar
        </div>
        {!rollup7.hasAnyRow ? (
          <p className="text-sm text-neutral-500">
            Engin dagleg gögn ennþá fyrir þetta tímabil. Þegar barnið notar appið
            birtast stig, nákvæmni og tími hér.
          </p>
        ) : (
          <div className="grid gap-3 sm:grid-cols-2">
            <StatChip
              label="Stig safnað"
              value={`${rollup7.pointsEarned}`}
              sub="á 7 dögum"
            />
            <StatChip
              label="Virkir dagar"
              value={`${rollup7.activeDays}`}
              sub="af 7"
            />
            <StatChip
              label="Stærðfræði"
              value={`${rollup7.mathSessions} lotur`}
              sub={
                rollup7.mathAccuracy != null
                  ? `Meðalnákvæmni ${formatPercent(rollup7.mathAccuracy)}`
                  : "Engar lotur"
              }
              icon={<Calculator size={14} className="text-evergreen-500" />}
            />
            <StatChip
              label="Lestur"
              value={`${rollup7.readingSessions} lotur`}
              sub={
                rollup7.readingAccuracy != null
                  ? `Meðalnákvæmni ${formatPercent(rollup7.readingAccuracy)}`
                  : "Engar lotur"
              }
              icon={<BookOpen size={14} className="text-evergreen-500" />}
            />
            <StatChip
              label="Verkefni lokið"
              value={`${rollup7.tasksCompleted}`}
              sub="á 7 dögum"
              icon={<ClipboardCheck size={14} className="text-evergreen-500" />}
            />
            <StatChip
              label="Virkni"
              value={
                rollup7.activeMinutes > 0
                  ? `~${rollup7.activeMinutes} mín`
                  : "—"
              }
              sub="skráður tími"
            />
          </div>
        )}
      </div>

      <div className="border-t border-neutral-100 pt-3 text-xs text-neutral-500 space-y-1">
        <p>
          Ævisögustig:{" "}
          <span className="font-semibold text-neutral-700 tabular-nums">
            {child.lifetime_points}
          </span>
          {" · "}
          Langsta röð:{" "}
          <span className="font-semibold text-neutral-700 tabular-nums">
            {child.longest_streak_days}
          </span>{" "}
          dagar
        </p>
        <p>
          Lotur alls — stærðfræði:{" "}
          <span className="tabular-nums font-medium text-neutral-700">
            {child.completed_math_sessions_count}
          </span>
          , lestur:{" "}
          <span className="tabular-nums font-medium text-neutral-700">
            {child.completed_reading_sessions_count}
          </span>
        </p>
      </div>

      {latestWeekly && (
        <div className="mt-4 rounded-md bg-evergreen-50 border border-evergreen-100 px-3 py-2.5 text-xs text-neutral-700">
          <p className="font-semibold text-evergreen-600 mb-1">Síðasta skráða vika</p>
          <p>
            {new Date(latestWeekly.week_start_date).toLocaleDateString("is-IS")}
            {" — "}
            {new Date(latestWeekly.week_end_date).toLocaleDateString("is-IS")}
            :{" "}
            <span className="tabular-nums font-medium">
              {latestWeekly.points_earned} stig
            </span>
            ,{" "}
            <span className="tabular-nums">
              {latestWeekly.active_days_count} virkir dagar
            </span>
            {activityLabel(latestWeekly.most_used_activity) && (
              <>
                {" "}
                · mest:{" "}
                {activityLabel(latestWeekly.most_used_activity)}
              </>
            )}
            {latestWeekly.weekly_goal_reached && (
              <span className="text-success font-medium"> · Viku markmið náð</span>
            )}
          </p>
        </div>
      )}
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
    <div className="rounded-lg bg-neutral-50 border border-neutral-100 px-3 py-2">
      <div className="flex items-center gap-1.5 text-[11px] font-semibold uppercase tracking-wide text-neutral-500">
        {icon}
        {label}
      </div>
      <p className="text-base font-bold text-neutral-900 tabular-nums mt-0.5">
        {value}
      </p>
      <p className="text-[11px] text-neutral-500">{sub}</p>
    </div>
  );
}
