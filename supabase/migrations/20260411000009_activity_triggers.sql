-- =============================================================
-- KrakkApp Migration 009: Activity Completion Triggers
-- - Task approved → update completed_tasks_count
-- - Math session completed → update completed_math_sessions_count
-- - Reading session completed → update completed_reading_sessions_count
-- - Any activity → update last_activity_at
-- - Daily stats upsert on activity completion
-- - Streak calculation
-- =============================================================

-- ===================== TASK APPROVED =====================

CREATE OR REPLACE FUNCTION fn_task_status_change()
RETURNS TRIGGER AS $$
BEGIN
    -- Task approved: increment counter
    IF NEW.status = 'approved' AND (OLD.status IS DISTINCT FROM 'approved') THEN
        UPDATE children
        SET completed_tasks_count = completed_tasks_count + 1,
            last_activity_at = now()
        WHERE id = NEW.child_id;

        -- Update daily stats
        INSERT INTO child_daily_stats (child_id, stat_date, tasks_completed)
        VALUES (NEW.child_id, CURRENT_DATE, 1)
        ON CONFLICT (child_id, stat_date)
        DO UPDATE SET tasks_completed = child_daily_stats.tasks_completed + 1,
                      updated_at = now();
    END IF;

    -- Task rejected: track in daily stats
    IF NEW.status = 'rejected' AND (OLD.status IS DISTINCT FROM 'rejected') THEN
        INSERT INTO child_daily_stats (child_id, stat_date, tasks_rejected)
        VALUES (NEW.child_id, CURRENT_DATE, 1)
        ON CONFLICT (child_id, stat_date)
        DO UPDATE SET tasks_rejected = child_daily_stats.tasks_rejected + 1,
                      updated_at = now();
    END IF;

    RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

CREATE TRIGGER trg_task_status_change
    AFTER UPDATE OF status ON tasks
    FOR EACH ROW EXECUTE FUNCTION fn_task_status_change();

-- ===================== MATH SESSION COMPLETED =====================

CREATE OR REPLACE FUNCTION fn_math_session_completed()
RETURNS TRIGGER AS $$
BEGIN
    IF NEW.status = 'completed' AND (OLD.status IS DISTINCT FROM 'completed') THEN
        UPDATE children
        SET completed_math_sessions_count = completed_math_sessions_count + 1,
            last_activity_at = now()
        WHERE id = NEW.child_id;

        -- Upsert daily stats
        INSERT INTO child_daily_stats (
            child_id, stat_date,
            math_sessions_completed,
            math_correct_answers, math_wrong_answers, math_skipped_answers,
            math_avg_accuracy
        ) VALUES (
            NEW.child_id, CURRENT_DATE,
            1,
            NEW.correct_answers, NEW.wrong_answers, NEW.skipped_answers,
            COALESCE(NEW.accuracy_percent, 0)
        )
        ON CONFLICT (child_id, stat_date)
        DO UPDATE SET
            math_sessions_completed = child_daily_stats.math_sessions_completed + 1,
            math_correct_answers    = child_daily_stats.math_correct_answers + NEW.correct_answers,
            math_wrong_answers      = child_daily_stats.math_wrong_answers + NEW.wrong_answers,
            math_skipped_answers    = child_daily_stats.math_skipped_answers + NEW.skipped_answers,
            math_avg_accuracy       = CASE
                WHEN child_daily_stats.math_sessions_completed > 0 THEN
                    ((child_daily_stats.math_avg_accuracy * child_daily_stats.math_sessions_completed)
                     + COALESCE(NEW.accuracy_percent, 0))
                    / (child_daily_stats.math_sessions_completed + 1)
                ELSE COALESCE(NEW.accuracy_percent, 0)
            END,
            updated_at = now();
    END IF;

    IF NEW.status = 'abandoned' AND (OLD.status IS DISTINCT FROM 'abandoned') THEN
        INSERT INTO child_daily_stats (child_id, stat_date, math_sessions_abandoned)
        VALUES (NEW.child_id, CURRENT_DATE, 1)
        ON CONFLICT (child_id, stat_date)
        DO UPDATE SET math_sessions_abandoned = child_daily_stats.math_sessions_abandoned + 1,
                      updated_at = now();
    END IF;

    RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

CREATE TRIGGER trg_math_session_completed
    AFTER UPDATE OF status ON math_sessions
    FOR EACH ROW EXECUTE FUNCTION fn_math_session_completed();

-- ===================== READING SESSION COMPLETED =====================

CREATE OR REPLACE FUNCTION fn_reading_session_completed()
RETURNS TRIGGER AS $$
BEGIN
    IF NEW.status = 'completed' AND (OLD.status IS DISTINCT FROM 'completed') THEN
        UPDATE children
        SET completed_reading_sessions_count = completed_reading_sessions_count + 1,
            last_activity_at = now()
        WHERE id = NEW.child_id;

        -- Upsert daily stats
        INSERT INTO child_daily_stats (
            child_id, stat_date,
            reading_sessions_completed,
            reading_words_correct, reading_words_incorrect,
            reading_avg_accuracy
        ) VALUES (
            NEW.child_id, CURRENT_DATE,
            1,
            NEW.words_correct_count, NEW.words_incorrect_count,
            COALESCE(NEW.accuracy_percent, 0)
        )
        ON CONFLICT (child_id, stat_date)
        DO UPDATE SET
            reading_sessions_completed = child_daily_stats.reading_sessions_completed + 1,
            reading_words_correct      = child_daily_stats.reading_words_correct + NEW.words_correct_count,
            reading_words_incorrect    = child_daily_stats.reading_words_incorrect + NEW.words_incorrect_count,
            reading_avg_accuracy       = CASE
                WHEN child_daily_stats.reading_sessions_completed > 0 THEN
                    ((child_daily_stats.reading_avg_accuracy * child_daily_stats.reading_sessions_completed)
                     + COALESCE(NEW.accuracy_percent, 0))
                    / (child_daily_stats.reading_sessions_completed + 1)
                ELSE COALESCE(NEW.accuracy_percent, 0)
            END,
            updated_at = now();
    END IF;

    IF NEW.status = 'abandoned' AND (OLD.status IS DISTINCT FROM 'abandoned') THEN
        INSERT INTO child_daily_stats (child_id, stat_date, reading_sessions_abandoned)
        VALUES (NEW.child_id, CURRENT_DATE, 1)
        ON CONFLICT (child_id, stat_date)
        DO UPDATE SET reading_sessions_abandoned = child_daily_stats.reading_sessions_abandoned + 1,
                      updated_at = now();
    END IF;

    RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

CREATE TRIGGER trg_reading_session_completed
    AFTER UPDATE OF status ON reading_sessions
    FOR EACH ROW EXECUTE FUNCTION fn_reading_session_completed();

-- ===================== POINTS LEDGER → DAILY STATS =====================

CREATE OR REPLACE FUNCTION fn_ledger_update_daily_stats()
RETURNS TRIGGER AS $$
BEGIN
    IF NEW.direction = 'credit' THEN
        INSERT INTO child_daily_stats (child_id, stat_date, points_earned, bonus_points_earned)
        VALUES (
            NEW.child_id,
            CURRENT_DATE,
            NEW.final_points,
            NEW.bonus_points
        )
        ON CONFLICT (child_id, stat_date)
        DO UPDATE SET
            points_earned       = child_daily_stats.points_earned + NEW.final_points,
            bonus_points_earned = child_daily_stats.bonus_points_earned + NEW.bonus_points,
            updated_at = now();
    ELSIF NEW.direction = 'debit' THEN
        INSERT INTO child_daily_stats (child_id, stat_date, points_spent)
        VALUES (NEW.child_id, CURRENT_DATE, NEW.final_points)
        ON CONFLICT (child_id, stat_date)
        DO UPDATE SET
            points_spent = child_daily_stats.points_spent + NEW.final_points,
            updated_at = now();
    END IF;

    RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

CREATE TRIGGER trg_ledger_daily_stats
    AFTER INSERT ON points_ledger
    FOR EACH ROW EXECUTE FUNCTION fn_ledger_update_daily_stats();

-- ===================== STREAK CALCULATION =====================

CREATE OR REPLACE FUNCTION fn_update_streak()
RETURNS TRIGGER AS $$
DECLARE
    v_yesterday_active BOOLEAN;
    v_current_streak   INTEGER;
    v_longest_streak   INTEGER;
BEGIN
    -- Only process when points are earned (marks the day as active)
    IF NEW.points_earned > 0 AND NOT NEW.is_streak_day THEN
        -- Mark today as a streak day
        NEW.is_streak_day := true;

        -- Check if yesterday was also a streak day
        SELECT is_streak_day INTO v_yesterday_active
        FROM child_daily_stats
        WHERE child_id = NEW.child_id
          AND stat_date = NEW.stat_date - 1;

        -- Get current streak info
        SELECT current_streak_days, longest_streak_days
        INTO v_current_streak, v_longest_streak
        FROM children
        WHERE id = NEW.child_id;

        IF v_yesterday_active THEN
            v_current_streak := v_current_streak + 1;
        ELSE
            v_current_streak := 1;
        END IF;

        IF v_current_streak > v_longest_streak THEN
            v_longest_streak := v_current_streak;
        END IF;

        UPDATE children
        SET current_streak_days = v_current_streak,
            longest_streak_days = v_longest_streak
        WHERE id = NEW.child_id;
    END IF;

    RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

CREATE TRIGGER trg_daily_stats_streak
    BEFORE INSERT OR UPDATE ON child_daily_stats
    FOR EACH ROW EXECUTE FUNCTION fn_update_streak();

-- ===================== DAILY GOAL CHECK =====================

CREATE OR REPLACE FUNCTION fn_check_daily_goal()
RETURNS TRIGGER AS $$
DECLARE
    v_daily_goal INTEGER;
BEGIN
    SELECT daily_points_goal INTO v_daily_goal
    FROM child_settings
    WHERE child_id = NEW.child_id;

    IF v_daily_goal IS NOT NULL AND NEW.points_earned >= v_daily_goal THEN
        NEW.daily_goal_reached := true;
    END IF;

    RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

CREATE TRIGGER trg_daily_stats_goal_check
    BEFORE INSERT OR UPDATE OF points_earned ON child_daily_stats
    FOR EACH ROW EXECUTE FUNCTION fn_check_daily_goal();

-- ===================== READING_TEXTS USAGE COUNTER =====================

CREATE OR REPLACE FUNCTION fn_increment_text_usage()
RETURNS TRIGGER AS $$
BEGIN
    UPDATE reading_texts
    SET times_used = times_used + 1
    WHERE id = NEW.reading_text_id;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

CREATE TRIGGER trg_reading_session_text_usage
    AFTER INSERT ON reading_sessions
    FOR EACH ROW EXECUTE FUNCTION fn_increment_text_usage();
