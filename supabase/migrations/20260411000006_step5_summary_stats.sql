-- =============================================================
-- KrakkApp Migration 006: Summary & Stats
-- Tables: child_daily_stats, child_weekly_stats
-- =============================================================

-- ----- child_daily_stats -----
CREATE TABLE child_daily_stats (
    id                          UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    child_id                    UUID NOT NULL REFERENCES children(id) ON DELETE RESTRICT,
    stat_date                   DATE NOT NULL,
    points_earned               INTEGER NOT NULL DEFAULT 0,
    points_spent                INTEGER NOT NULL DEFAULT 0,
    bonus_points_earned         INTEGER NOT NULL DEFAULT 0,
    tasks_completed             INTEGER NOT NULL DEFAULT 0,
    tasks_rejected              INTEGER NOT NULL DEFAULT 0,
    math_sessions_completed     INTEGER NOT NULL DEFAULT 0,
    math_sessions_abandoned     INTEGER NOT NULL DEFAULT 0,
    math_correct_answers        INTEGER NOT NULL DEFAULT 0,
    math_wrong_answers          INTEGER NOT NULL DEFAULT 0,
    math_skipped_answers        INTEGER NOT NULL DEFAULT 0,
    math_avg_accuracy           NUMERIC(5,2) NOT NULL DEFAULT 0,
    math_avg_response_time_ms   INTEGER NOT NULL DEFAULT 0,
    reading_sessions_completed  INTEGER NOT NULL DEFAULT 0,
    reading_sessions_abandoned  INTEGER NOT NULL DEFAULT 0,
    reading_avg_accuracy        NUMERIC(5,2) NOT NULL DEFAULT 0,
    reading_words_correct       INTEGER NOT NULL DEFAULT 0,
    reading_words_incorrect     INTEGER NOT NULL DEFAULT 0,
    active_minutes              INTEGER NOT NULL DEFAULT 0,
    daily_goal_reached          BOOLEAN NOT NULL DEFAULT false,
    is_streak_day               BOOLEAN NOT NULL DEFAULT false,
    created_at                  TIMESTAMPTZ NOT NULL DEFAULT now(),
    updated_at                  TIMESTAMPTZ NOT NULL DEFAULT now(),

    UNIQUE (child_id, stat_date)
);

CREATE TRIGGER trg_child_daily_stats_updated_at
    BEFORE UPDATE ON child_daily_stats
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

-- ----- child_weekly_stats -----
CREATE TABLE child_weekly_stats (
    id                          UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    child_id                    UUID NOT NULL REFERENCES children(id) ON DELETE RESTRICT,
    week_start_date             DATE NOT NULL,
    week_end_date               DATE NOT NULL,
    points_earned               INTEGER NOT NULL DEFAULT 0,
    points_spent                INTEGER NOT NULL DEFAULT 0,
    bonus_points_earned         INTEGER NOT NULL DEFAULT 0,
    tasks_completed             INTEGER NOT NULL DEFAULT 0,
    tasks_rejected              INTEGER NOT NULL DEFAULT 0,
    math_sessions_completed     INTEGER NOT NULL DEFAULT 0,
    math_sessions_abandoned     INTEGER NOT NULL DEFAULT 0,
    math_avg_accuracy           NUMERIC(5,2) NOT NULL DEFAULT 0,
    math_avg_response_time_ms   INTEGER NOT NULL DEFAULT 0,
    reading_sessions_completed  INTEGER NOT NULL DEFAULT 0,
    reading_sessions_abandoned  INTEGER NOT NULL DEFAULT 0,
    reading_avg_accuracy        NUMERIC(5,2) NOT NULL DEFAULT 0,
    active_days_count           INTEGER NOT NULL DEFAULT 0,
    weekly_goal_reached         BOOLEAN NOT NULL DEFAULT false,
    best_day_points             INTEGER NOT NULL DEFAULT 0,
    best_math_accuracy          NUMERIC(5,2) NOT NULL DEFAULT 0,
    best_reading_accuracy       NUMERIC(5,2) NOT NULL DEFAULT 0,
    most_used_activity          TEXT CHECK (most_used_activity IN ('math', 'reading', 'task')),
    created_at                  TIMESTAMPTZ NOT NULL DEFAULT now(),
    updated_at                  TIMESTAMPTZ NOT NULL DEFAULT now(),

    UNIQUE (child_id, week_start_date),
    CONSTRAINT chk_week_range CHECK (week_end_date = week_start_date + INTERVAL '6 days')
);

CREATE TRIGGER trg_child_weekly_stats_updated_at
    BEFORE UPDATE ON child_weekly_stats
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
