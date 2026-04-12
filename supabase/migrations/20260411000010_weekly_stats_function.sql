-- =============================================================
-- KrakkApp Migration 010: Weekly Stats Aggregation
-- Called at end of week or on-demand to roll up daily → weekly
-- =============================================================

CREATE OR REPLACE FUNCTION fn_aggregate_weekly_stats(
    p_child_id UUID,
    p_week_start DATE
)
RETURNS VOID AS $$
DECLARE
    v_week_end DATE := p_week_start + INTERVAL '6 days';
BEGIN
    INSERT INTO child_weekly_stats (
        child_id, week_start_date, week_end_date,
        points_earned, points_spent, bonus_points_earned,
        tasks_completed, tasks_rejected,
        math_sessions_completed, math_sessions_abandoned,
        math_avg_accuracy, math_avg_response_time_ms,
        reading_sessions_completed, reading_sessions_abandoned,
        reading_avg_accuracy,
        active_days_count, weekly_goal_reached,
        best_day_points, best_math_accuracy, best_reading_accuracy,
        most_used_activity
    )
    SELECT
        p_child_id,
        p_week_start,
        v_week_end,
        COALESCE(SUM(d.points_earned), 0),
        COALESCE(SUM(d.points_spent), 0),
        COALESCE(SUM(d.bonus_points_earned), 0),
        COALESCE(SUM(d.tasks_completed), 0),
        COALESCE(SUM(d.tasks_rejected), 0),
        COALESCE(SUM(d.math_sessions_completed), 0),
        COALESCE(SUM(d.math_sessions_abandoned), 0),
        CASE WHEN SUM(d.math_sessions_completed) > 0
             THEN SUM(d.math_avg_accuracy * d.math_sessions_completed) / SUM(d.math_sessions_completed)
             ELSE 0 END,
        CASE WHEN SUM(d.math_sessions_completed) > 0
             THEN (SUM(d.math_avg_response_time_ms * d.math_sessions_completed) / SUM(d.math_sessions_completed))::INTEGER
             ELSE 0 END,
        COALESCE(SUM(d.reading_sessions_completed), 0),
        COALESCE(SUM(d.reading_sessions_abandoned), 0),
        CASE WHEN SUM(d.reading_sessions_completed) > 0
             THEN SUM(d.reading_avg_accuracy * d.reading_sessions_completed) / SUM(d.reading_sessions_completed)
             ELSE 0 END,
        COUNT(*) FILTER (WHERE d.is_streak_day),
        -- weekly_goal_reached: check against child_settings
        COALESCE((
            SELECT SUM(d2.points_earned) >= cs.weekly_points_goal
            FROM child_settings cs,
                 LATERAL (SELECT SUM(points_earned) AS points_earned
                          FROM child_daily_stats
                          WHERE child_id = p_child_id
                            AND stat_date BETWEEN p_week_start AND v_week_end) d2
            WHERE cs.child_id = p_child_id
              AND cs.weekly_points_goal IS NOT NULL
        ), false),
        COALESCE(MAX(d.points_earned), 0),
        COALESCE(MAX(d.math_avg_accuracy), 0),
        COALESCE(MAX(d.reading_avg_accuracy), 0),
        -- most_used_activity
        CASE
            WHEN SUM(d.math_sessions_completed) >= SUM(d.reading_sessions_completed)
                 AND SUM(d.math_sessions_completed) >= SUM(d.tasks_completed) THEN 'math'
            WHEN SUM(d.reading_sessions_completed) >= SUM(d.math_sessions_completed)
                 AND SUM(d.reading_sessions_completed) >= SUM(d.tasks_completed) THEN 'reading'
            WHEN SUM(d.tasks_completed) > 0 THEN 'task'
            ELSE NULL
        END
    FROM child_daily_stats d
    WHERE d.child_id = p_child_id
      AND d.stat_date BETWEEN p_week_start AND v_week_end
    ON CONFLICT (child_id, week_start_date)
    DO UPDATE SET
        points_earned              = EXCLUDED.points_earned,
        points_spent               = EXCLUDED.points_spent,
        bonus_points_earned        = EXCLUDED.bonus_points_earned,
        tasks_completed            = EXCLUDED.tasks_completed,
        tasks_rejected             = EXCLUDED.tasks_rejected,
        math_sessions_completed    = EXCLUDED.math_sessions_completed,
        math_sessions_abandoned    = EXCLUDED.math_sessions_abandoned,
        math_avg_accuracy          = EXCLUDED.math_avg_accuracy,
        math_avg_response_time_ms  = EXCLUDED.math_avg_response_time_ms,
        reading_sessions_completed = EXCLUDED.reading_sessions_completed,
        reading_sessions_abandoned = EXCLUDED.reading_sessions_abandoned,
        reading_avg_accuracy       = EXCLUDED.reading_avg_accuracy,
        active_days_count          = EXCLUDED.active_days_count,
        weekly_goal_reached        = EXCLUDED.weekly_goal_reached,
        best_day_points            = EXCLUDED.best_day_points,
        best_math_accuracy         = EXCLUDED.best_math_accuracy,
        best_reading_accuracy      = EXCLUDED.best_reading_accuracy,
        most_used_activity         = EXCLUDED.most_used_activity,
        updated_at                 = now();
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Helper: aggregate weekly stats for ALL active children
-- Intended to be called by a Supabase cron job (pg_cron) every Sunday night
CREATE OR REPLACE FUNCTION fn_aggregate_all_weekly_stats()
RETURNS VOID AS $$
DECLARE
    v_child RECORD;
    v_week_start DATE;
BEGIN
    -- Calculate Monday of the current week
    v_week_start := date_trunc('week', CURRENT_DATE)::DATE;

    FOR v_child IN SELECT id FROM children WHERE is_active = true LOOP
        PERFORM fn_aggregate_weekly_stats(v_child.id, v_week_start);
    END LOOP;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;
