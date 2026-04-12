import type { ChildDailyStats } from "@/types/database";

const ICELAND_TZ = "Atlantic/Reykjavik";

/** Dagsetning YYYY-MM-DD í íslenskum tíma (foreldragreiningar). */
export function icelandDateString(date: Date = new Date()): string {
  return date.toLocaleDateString("en-CA", { timeZone: ICELAND_TZ });
}

/** Fyrsti dagur 7 daga glugga (í dag + 6 fyrri daga), sem YYYY-MM-DD. */
export function sevenDayWindowStartIso(): string {
  const today = icelandDateString();
  const [y, m, d] = today.split("-").map(Number);
  const t = Date.UTC(y, m - 1, d - 6);
  return new Date(t).toISOString().slice(0, 10);
}

function num(v: unknown): number {
  if (typeof v === "number" && !Number.isNaN(v)) return v;
  if (typeof v === "string") {
    const n = parseFloat(v);
    return Number.isFinite(n) ? n : 0;
  }
  return 0;
}

export type SevenDayRollup = {
  pointsEarned: number;
  activeMinutes: number;
  mathSessions: number;
  mathAccuracy: number | null;
  readingSessions: number;
  readingAccuracy: number | null;
  tasksCompleted: number;
  activeDays: number;
  hasAnyRow: boolean;
};

export function rollupSevenDay(rows: ChildDailyStats[]): SevenDayRollup {
  if (!rows.length) {
    return {
      pointsEarned: 0,
      activeMinutes: 0,
      mathSessions: 0,
      mathAccuracy: null,
      readingSessions: 0,
      readingAccuracy: null,
      tasksCompleted: 0,
      activeDays: 0,
      hasAnyRow: false,
    };
  }

  let pointsEarned = 0;
  let activeMinutes = 0;
  let mathSessions = 0;
  let mathAccWeighted = 0;
  let readingSessions = 0;
  let readingAccWeighted = 0;
  let tasksCompleted = 0;
  let activeDays = 0;

  for (const r of rows) {
    const pe = num(r.points_earned);
    const am = num(r.active_minutes);
    const ms = num(r.math_sessions_completed);
    const rs = num(r.reading_sessions_completed);
    const tc = num(r.tasks_completed);

    pointsEarned += pe;
    activeMinutes += am;
    mathSessions += ms;
    readingSessions += rs;
    tasksCompleted += tc;

    if (ms > 0) {
      mathAccWeighted += num(r.math_avg_accuracy) * ms;
    }
    if (rs > 0) {
      readingAccWeighted += num(r.reading_avg_accuracy) * rs;
    }

    if (
      pe > 0 ||
      ms > 0 ||
      rs > 0 ||
      tc > 0 ||
      num(r.reading_words_correct) > 0
    ) {
      activeDays += 1;
    }
  }

  return {
    pointsEarned,
    activeMinutes,
    mathSessions,
    mathAccuracy: mathSessions > 0 ? mathAccWeighted / mathSessions : null,
    readingSessions,
    readingAccuracy:
      readingSessions > 0 ? readingAccWeighted / readingSessions : null,
    tasksCompleted,
    activeDays,
    hasAnyRow: true,
  };
}

export function formatPercent(value: number | null): string {
  if (value === null || Number.isNaN(value)) return "—";
  const rounded = Math.round(value * 10) / 10;
  return Number.isInteger(rounded)
    ? `${rounded} %`
    : `${rounded.toFixed(1)} %`;
}
