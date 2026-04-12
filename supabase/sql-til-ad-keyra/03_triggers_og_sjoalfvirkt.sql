-- ╔═══════════════════════════════════════════════════════════════╗
-- ║  KrakkApp — Skref 3: Triggers og sjálfvirk virkni           ║
-- ║  Keyrðu EFTIR 02_indexes_og_oryggi.sql                      ║
-- ╚═══════════════════════════════════════════════════════════════╝


-- ─────────────────────────────────────────────────────────────
-- A) NÝSKRÁNING → sjálfkrafa profiles röð
-- ─────────────────────────────────────────────────────────────
-- Þegar notandi skráir sig í Supabase Auth, búum við sjálfkrafa
-- til röð í profiles töflunni.

CREATE OR REPLACE FUNCTION fn_handle_new_user()
RETURNS TRIGGER AS $$
BEGIN
    INSERT INTO public.profiles (id, email, full_name, avatar_url)
    VALUES (
        NEW.id,
        NEW.email,
        COALESCE(NEW.raw_user_meta_data ->> 'full_name', NULL),
        COALESCE(NEW.raw_user_meta_data ->> 'avatar_url', NULL)
    );
    RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

CREATE TRIGGER trg_on_auth_user_created
    AFTER INSERT ON auth.users
    FOR EACH ROW EXECUTE FUNCTION fn_handle_new_user();


-- ─────────────────────────────────────────────────────────────
-- B) NÝTT BARN → sjálfkrafa default stillingar
-- ─────────────────────────────────────────────────────────────
-- Þegar foreldri bætir við barni, búum við sjálfkrafa til:
--   - child_settings (almennir stillingar)
--   - child_math_settings (stærðfræði defaults)
--   - child_reading_settings (upplestur defaults)

CREATE OR REPLACE FUNCTION fn_create_child_defaults()
RETURNS TRIGGER AS $$
BEGIN
    INSERT INTO child_settings (child_id) VALUES (NEW.id);
    INSERT INTO child_math_settings (child_id) VALUES (NEW.id);
    INSERT INTO child_reading_settings (child_id) VALUES (NEW.id);
    RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

CREATE TRIGGER trg_child_create_defaults
    AFTER INSERT ON children
    FOR EACH ROW EXECUTE FUNCTION fn_create_child_defaults();


-- ─────────────────────────────────────────────────────────────
-- C) FÆÐINGARDAGUR → sjálfkrafa birth_year
-- ─────────────────────────────────────────────────────────────

CREATE OR REPLACE FUNCTION fn_extract_birth_year()
RETURNS TRIGGER AS $$
BEGIN
    IF NEW.birth_date IS NOT NULL THEN
        NEW.birth_year := EXTRACT(YEAR FROM NEW.birth_date)::SMALLINT;
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_children_extract_birth_year
    BEFORE INSERT OR UPDATE OF birth_date ON children
    FOR EACH ROW EXECUTE FUNCTION fn_extract_birth_year();


-- ─────────────────────────────────────────────────────────────
-- D) STIGABÓKHALD → uppfærir stig á barni
-- ─────────────────────────────────────────────────────────────
-- Þegar ný röð bætist í points_ledger, uppfærist children
-- taflan sjálfkrafa (total_points, available_points, lifetime_points)

CREATE OR REPLACE FUNCTION fn_update_child_points()
RETURNS TRIGGER AS $$
BEGIN
    IF NEW.direction = 'credit' THEN
        UPDATE children
        SET total_points     = total_points     + NEW.final_points,
            available_points = available_points + NEW.final_points,
            lifetime_points  = lifetime_points  + NEW.final_points
        WHERE id = NEW.child_id;
    ELSIF NEW.direction = 'debit' THEN
        UPDATE children
        SET total_points     = total_points     - NEW.final_points,
            available_points = available_points - NEW.final_points
        WHERE id = NEW.child_id;
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_points_ledger_update_child
    AFTER INSERT ON points_ledger
    FOR EACH ROW EXECUTE FUNCTION fn_update_child_points();


-- ─────────────────────────────────────────────────────────────
-- E) VERKEFNI SAMÞYKKT/HAFNAÐ → teljarar og dagleg tölfræði
-- ─────────────────────────────────────────────────────────────

CREATE OR REPLACE FUNCTION fn_task_status_change()
RETURNS TRIGGER AS $$
BEGIN
    IF NEW.status = 'approved' AND (OLD.status IS DISTINCT FROM 'approved') THEN
        UPDATE children
        SET completed_tasks_count = completed_tasks_count + 1,
            last_activity_at = now()
        WHERE id = NEW.child_id;

        INSERT INTO child_daily_stats (child_id, stat_date, tasks_completed)
        VALUES (NEW.child_id, CURRENT_DATE, 1)
        ON CONFLICT (child_id, stat_date)
        DO UPDATE SET tasks_completed = child_daily_stats.tasks_completed + 1, updated_at = now();
    END IF;

    IF NEW.status = 'rejected' AND (OLD.status IS DISTINCT FROM 'rejected') THEN
        INSERT INTO child_daily_stats (child_id, stat_date, tasks_rejected)
        VALUES (NEW.child_id, CURRENT_DATE, 1)
        ON CONFLICT (child_id, stat_date)
        DO UPDATE SET tasks_rejected = child_daily_stats.tasks_rejected + 1, updated_at = now();
    END IF;

    RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

CREATE TRIGGER trg_task_status_change
    AFTER UPDATE OF status ON tasks
    FOR EACH ROW EXECUTE FUNCTION fn_task_status_change();


-- ─────────────────────────────────────────────────────────────
-- F) STÆRÐFRÆÐILOTA LOKIÐ → teljarar og dagleg tölfræði
-- ─────────────────────────────────────────────────────────────

CREATE OR REPLACE FUNCTION fn_math_session_completed()
RETURNS TRIGGER AS $$
BEGIN
    IF NEW.status = 'completed' AND (OLD.status IS DISTINCT FROM 'completed') THEN
        UPDATE children
        SET completed_math_sessions_count = completed_math_sessions_count + 1,
            last_activity_at = now()
        WHERE id = NEW.child_id;

        INSERT INTO child_daily_stats (
            child_id, stat_date, math_sessions_completed,
            math_correct_answers, math_wrong_answers, math_skipped_answers, math_avg_accuracy
        ) VALUES (
            NEW.child_id, CURRENT_DATE, 1,
            NEW.correct_answers, NEW.wrong_answers, NEW.skipped_answers, COALESCE(NEW.accuracy_percent, 0)
        )
        ON CONFLICT (child_id, stat_date)
        DO UPDATE SET
            math_sessions_completed = child_daily_stats.math_sessions_completed + 1,
            math_correct_answers    = child_daily_stats.math_correct_answers + NEW.correct_answers,
            math_wrong_answers      = child_daily_stats.math_wrong_answers + NEW.wrong_answers,
            math_skipped_answers    = child_daily_stats.math_skipped_answers + NEW.skipped_answers,
            math_avg_accuracy = CASE
                WHEN child_daily_stats.math_sessions_completed > 0 THEN
                    ((child_daily_stats.math_avg_accuracy * child_daily_stats.math_sessions_completed) + COALESCE(NEW.accuracy_percent, 0))
                    / (child_daily_stats.math_sessions_completed + 1)
                ELSE COALESCE(NEW.accuracy_percent, 0)
            END,
            updated_at = now();
    END IF;

    IF NEW.status = 'abandoned' AND (OLD.status IS DISTINCT FROM 'abandoned') THEN
        INSERT INTO child_daily_stats (child_id, stat_date, math_sessions_abandoned)
        VALUES (NEW.child_id, CURRENT_DATE, 1)
        ON CONFLICT (child_id, stat_date)
        DO UPDATE SET math_sessions_abandoned = child_daily_stats.math_sessions_abandoned + 1, updated_at = now();
    END IF;

    RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

CREATE TRIGGER trg_math_session_completed
    AFTER UPDATE OF status ON math_sessions
    FOR EACH ROW EXECUTE FUNCTION fn_math_session_completed();


-- ─────────────────────────────────────────────────────────────
-- G) UPPLESTUR LOKIÐ → teljarar og dagleg tölfræði
-- ─────────────────────────────────────────────────────────────

CREATE OR REPLACE FUNCTION fn_reading_session_completed()
RETURNS TRIGGER AS $$
BEGIN
    IF NEW.status = 'completed' AND (OLD.status IS DISTINCT FROM 'completed') THEN
        UPDATE children
        SET completed_reading_sessions_count = completed_reading_sessions_count + 1,
            last_activity_at = now()
        WHERE id = NEW.child_id;

        INSERT INTO child_daily_stats (
            child_id, stat_date, reading_sessions_completed,
            reading_words_correct, reading_words_incorrect, reading_avg_accuracy
        ) VALUES (
            NEW.child_id, CURRENT_DATE, 1,
            NEW.words_correct_count, NEW.words_incorrect_count, COALESCE(NEW.accuracy_percent, 0)
        )
        ON CONFLICT (child_id, stat_date)
        DO UPDATE SET
            reading_sessions_completed = child_daily_stats.reading_sessions_completed + 1,
            reading_words_correct      = child_daily_stats.reading_words_correct + NEW.words_correct_count,
            reading_words_incorrect    = child_daily_stats.reading_words_incorrect + NEW.words_incorrect_count,
            reading_avg_accuracy = CASE
                WHEN child_daily_stats.reading_sessions_completed > 0 THEN
                    ((child_daily_stats.reading_avg_accuracy * child_daily_stats.reading_sessions_completed) + COALESCE(NEW.accuracy_percent, 0))
                    / (child_daily_stats.reading_sessions_completed + 1)
                ELSE COALESCE(NEW.accuracy_percent, 0)
            END,
            updated_at = now();
    END IF;

    IF NEW.status = 'abandoned' AND (OLD.status IS DISTINCT FROM 'abandoned') THEN
        INSERT INTO child_daily_stats (child_id, stat_date, reading_sessions_abandoned)
        VALUES (NEW.child_id, CURRENT_DATE, 1)
        ON CONFLICT (child_id, stat_date)
        DO UPDATE SET reading_sessions_abandoned = child_daily_stats.reading_sessions_abandoned + 1, updated_at = now();
    END IF;

    RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

CREATE TRIGGER trg_reading_session_completed
    AFTER UPDATE OF status ON reading_sessions
    FOR EACH ROW EXECUTE FUNCTION fn_reading_session_completed();


-- ─────────────────────────────────────────────────────────────
-- H) STIGABÓKHALD → dagleg tölfræði (stig/eyðsla)
-- ─────────────────────────────────────────────────────────────

CREATE OR REPLACE FUNCTION fn_ledger_update_daily_stats()
RETURNS TRIGGER AS $$
BEGIN
    IF NEW.direction = 'credit' THEN
        INSERT INTO child_daily_stats (child_id, stat_date, points_earned, bonus_points_earned)
        VALUES (NEW.child_id, CURRENT_DATE, NEW.final_points, NEW.bonus_points)
        ON CONFLICT (child_id, stat_date)
        DO UPDATE SET
            points_earned       = child_daily_stats.points_earned + NEW.final_points,
            bonus_points_earned = child_daily_stats.bonus_points_earned + NEW.bonus_points,
            updated_at = now();
    ELSIF NEW.direction = 'debit' THEN
        INSERT INTO child_daily_stats (child_id, stat_date, points_spent)
        VALUES (NEW.child_id, CURRENT_DATE, NEW.final_points)
        ON CONFLICT (child_id, stat_date)
        DO UPDATE SET points_spent = child_daily_stats.points_spent + NEW.final_points, updated_at = now();
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

CREATE TRIGGER trg_ledger_daily_stats
    AFTER INSERT ON points_ledger
    FOR EACH ROW EXECUTE FUNCTION fn_ledger_update_daily_stats();


-- ─────────────────────────────────────────────────────────────
-- I) STREAK — reiknuð sjálfkrafa þegar barn vinnur stig
-- ─────────────────────────────────────────────────────────────

CREATE OR REPLACE FUNCTION fn_update_streak()
RETURNS TRIGGER AS $$
DECLARE
    v_yesterday_active BOOLEAN;
    v_current_streak   INTEGER;
    v_longest_streak   INTEGER;
BEGIN
    IF NEW.points_earned > 0 AND NOT NEW.is_streak_day THEN
        NEW.is_streak_day := true;

        SELECT is_streak_day INTO v_yesterday_active
        FROM child_daily_stats
        WHERE child_id = NEW.child_id AND stat_date = NEW.stat_date - 1;

        SELECT current_streak_days, longest_streak_days
        INTO v_current_streak, v_longest_streak
        FROM children WHERE id = NEW.child_id;

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


-- ─────────────────────────────────────────────────────────────
-- J) DAGMARKMIÐ — athugar sjálfkrafa hvort markmiðið náðist
-- ─────────────────────────────────────────────────────────────

CREATE OR REPLACE FUNCTION fn_check_daily_goal()
RETURNS TRIGGER AS $$
DECLARE
    v_daily_goal INTEGER;
BEGIN
    SELECT daily_points_goal INTO v_daily_goal
    FROM child_settings WHERE child_id = NEW.child_id;

    IF v_daily_goal IS NOT NULL AND NEW.points_earned >= v_daily_goal THEN
        NEW.daily_goal_reached := true;
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

CREATE TRIGGER trg_daily_stats_goal_check
    BEFORE INSERT OR UPDATE OF points_earned ON child_daily_stats
    FOR EACH ROW EXECUTE FUNCTION fn_check_daily_goal();


-- ─────────────────────────────────────────────────────────────
-- K) LESTARTEXTI — times_used telur sjálfkrafa
-- ─────────────────────────────────────────────────────────────

CREATE OR REPLACE FUNCTION fn_increment_text_usage()
RETURNS TRIGGER AS $$
BEGIN
    UPDATE reading_texts SET times_used = times_used + 1 WHERE id = NEW.reading_text_id;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

CREATE TRIGGER trg_reading_session_text_usage
    AFTER INSERT ON reading_sessions
    FOR EACH ROW EXECUTE FUNCTION fn_increment_text_usage();


-- ─────────────────────────────────────────────────────────────
-- L) VIKULEG SAMANTEKT — fall til að kalla á (cron eða handvirkt)
-- ─────────────────────────────────────────────────────────────

CREATE OR REPLACE FUNCTION fn_aggregate_weekly_stats(p_child_id UUID, p_week_start DATE)
RETURNS VOID AS $$
DECLARE
    v_week_end DATE := p_week_start + INTERVAL '6 days';
BEGIN
    INSERT INTO child_weekly_stats (
        child_id, week_start_date, week_end_date,
        points_earned, points_spent, bonus_points_earned,
        tasks_completed, tasks_rejected,
        math_sessions_completed, math_sessions_abandoned, math_avg_accuracy, math_avg_response_time_ms,
        reading_sessions_completed, reading_sessions_abandoned, reading_avg_accuracy,
        active_days_count, weekly_goal_reached,
        best_day_points, best_math_accuracy, best_reading_accuracy, most_used_activity
    )
    SELECT
        p_child_id, p_week_start, v_week_end,
        COALESCE(SUM(d.points_earned), 0),
        COALESCE(SUM(d.points_spent), 0),
        COALESCE(SUM(d.bonus_points_earned), 0),
        COALESCE(SUM(d.tasks_completed), 0),
        COALESCE(SUM(d.tasks_rejected), 0),
        COALESCE(SUM(d.math_sessions_completed), 0),
        COALESCE(SUM(d.math_sessions_abandoned), 0),
        CASE WHEN SUM(d.math_sessions_completed) > 0
             THEN SUM(d.math_avg_accuracy * d.math_sessions_completed) / SUM(d.math_sessions_completed) ELSE 0 END,
        CASE WHEN SUM(d.math_sessions_completed) > 0
             THEN (SUM(d.math_avg_response_time_ms * d.math_sessions_completed) / SUM(d.math_sessions_completed))::INTEGER ELSE 0 END,
        COALESCE(SUM(d.reading_sessions_completed), 0),
        COALESCE(SUM(d.reading_sessions_abandoned), 0),
        CASE WHEN SUM(d.reading_sessions_completed) > 0
             THEN SUM(d.reading_avg_accuracy * d.reading_sessions_completed) / SUM(d.reading_sessions_completed) ELSE 0 END,
        COUNT(*) FILTER (WHERE d.is_streak_day),
        COALESCE((
            SELECT SUM(d2.points_earned) >= cs.weekly_points_goal
            FROM child_settings cs,
                 LATERAL (SELECT SUM(points_earned) AS points_earned FROM child_daily_stats
                          WHERE child_id = p_child_id AND stat_date BETWEEN p_week_start AND v_week_end) d2
            WHERE cs.child_id = p_child_id AND cs.weekly_points_goal IS NOT NULL
        ), false),
        COALESCE(MAX(d.points_earned), 0),
        COALESCE(MAX(d.math_avg_accuracy), 0),
        COALESCE(MAX(d.reading_avg_accuracy), 0),
        CASE
            WHEN SUM(d.math_sessions_completed) >= SUM(d.reading_sessions_completed)
                 AND SUM(d.math_sessions_completed) >= SUM(d.tasks_completed) THEN 'math'
            WHEN SUM(d.reading_sessions_completed) >= SUM(d.math_sessions_completed)
                 AND SUM(d.reading_sessions_completed) >= SUM(d.tasks_completed) THEN 'reading'
            WHEN SUM(d.tasks_completed) > 0 THEN 'task'
            ELSE NULL
        END
    FROM child_daily_stats d
    WHERE d.child_id = p_child_id AND d.stat_date BETWEEN p_week_start AND v_week_end
    ON CONFLICT (child_id, week_start_date)
    DO UPDATE SET
        points_earned = EXCLUDED.points_earned, points_spent = EXCLUDED.points_spent,
        bonus_points_earned = EXCLUDED.bonus_points_earned,
        tasks_completed = EXCLUDED.tasks_completed, tasks_rejected = EXCLUDED.tasks_rejected,
        math_sessions_completed = EXCLUDED.math_sessions_completed, math_sessions_abandoned = EXCLUDED.math_sessions_abandoned,
        math_avg_accuracy = EXCLUDED.math_avg_accuracy, math_avg_response_time_ms = EXCLUDED.math_avg_response_time_ms,
        reading_sessions_completed = EXCLUDED.reading_sessions_completed, reading_sessions_abandoned = EXCLUDED.reading_sessions_abandoned,
        reading_avg_accuracy = EXCLUDED.reading_avg_accuracy,
        active_days_count = EXCLUDED.active_days_count, weekly_goal_reached = EXCLUDED.weekly_goal_reached,
        best_day_points = EXCLUDED.best_day_points, best_math_accuracy = EXCLUDED.best_math_accuracy,
        best_reading_accuracy = EXCLUDED.best_reading_accuracy, most_used_activity = EXCLUDED.most_used_activity,
        updated_at = now();
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Hjálparfall: keyra vikulega samantekt fyrir ÖLL virk börn
CREATE OR REPLACE FUNCTION fn_aggregate_all_weekly_stats()
RETURNS VOID AS $$
DECLARE
    v_child RECORD;
    v_week_start DATE;
BEGIN
    v_week_start := date_trunc('week', CURRENT_DATE)::DATE;
    FOR v_child IN SELECT id FROM children WHERE is_active = true LOOP
        PERFORM fn_aggregate_weekly_stats(v_child.id, v_week_start);
    END LOOP;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;


-- ═════════════════════════════════════════════════════════════
-- ALLT BÚIÐ! Gagnagrunnurinn er tilbúinn.
-- ═════════════════════════════════════════════════════════════
