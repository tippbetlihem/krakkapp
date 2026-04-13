-- ╔═══════════════════════════════════════════════════════════════╗
-- ║  KrakkApp — Skref 1: Allar töflur                          ║
-- ║  Keyrðu þetta FYRST í Supabase SQL Editor                  ║
-- ║  ATH: CREATE TABLE IF NOT EXISTS — hægt að keyra aftur ef                ║
-- ║  grunnur er þegar til (sleppur töflum sem eru til).         ║
-- ╚═══════════════════════════════════════════════════════════════╝


-- ─────────────────────────────────────────────────────────────
-- HJÁLPARFALL: Uppfærir updated_at sjálfkrafa þegar röð breytist
-- Notað af mörgum töflum hér að neðan
-- ─────────────────────────────────────────────────────────────
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = now();
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;


-- ═════════════════════════════════════════════════════════════
-- 1. PROFILES — Foreldraprófíll, tengist Supabase Auth
-- ═════════════════════════════════════════════════════════════
-- Þegar notandi skráir sig búum við til röð hér sjálfkrafa (trigger í skref 3)

CREATE TABLE IF NOT EXISTS profiles (
    id            UUID PRIMARY KEY REFERENCES auth.users(id) ON DELETE RESTRICT,
    email         TEXT NOT NULL UNIQUE,
    full_name     TEXT,
    avatar_url    TEXT,
    role          TEXT NOT NULL DEFAULT 'parent',
    created_at    TIMESTAMPTZ NOT NULL DEFAULT now(),
    updated_at    TIMESTAMPTZ NOT NULL DEFAULT now(),
    last_login_at TIMESTAMPTZ
);

DROP TRIGGER IF EXISTS trg_profiles_updated_at ON profiles;
CREATE TRIGGER trg_profiles_updated_at
    BEFORE UPDATE ON profiles
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();


-- ═════════════════════════════════════════════════════════════
-- 2. CHILDREN — Barnið, miðja alls skemans
-- ═════════════════════════════════════════════════════════════
-- Hvert barn tilheyrir foreldri. Stig, streak og teljarar eru hér.
-- is_active = false í stað þess að eyða barni.

CREATE TABLE IF NOT EXISTS children (
    id                               UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    parent_id                        UUID NOT NULL REFERENCES profiles(id) ON DELETE RESTRICT,
    first_name                       TEXT NOT NULL,
    display_name                     TEXT,                -- gælunafn
    birth_year                       SMALLINT,            -- fyllt sjálfkrafa úr birth_date
    birth_date                       DATE,
    avatar_url                       TEXT,
    pin_code                         TEXT,                -- hashað PIN (4 tölustafir)
    is_active                        BOOLEAN NOT NULL DEFAULT true,
    created_at                       TIMESTAMPTZ NOT NULL DEFAULT now(),
    updated_at                       TIMESTAMPTZ NOT NULL DEFAULT now(),
    total_points                     INTEGER NOT NULL DEFAULT 0,
    available_points                 INTEGER NOT NULL DEFAULT 0,   -- lækkar þegar barn eyðir
    lifetime_points                  INTEGER NOT NULL DEFAULT 0,   -- hækkar aldrei niður
    completed_tasks_count            INTEGER NOT NULL DEFAULT 0,
    completed_math_sessions_count    INTEGER NOT NULL DEFAULT 0,
    completed_reading_sessions_count INTEGER NOT NULL DEFAULT 0,
    last_activity_at                 TIMESTAMPTZ,
    current_streak_days              INTEGER NOT NULL DEFAULT 0,
    longest_streak_days              INTEGER NOT NULL DEFAULT 0
);

DROP TRIGGER IF EXISTS trg_children_updated_at ON children;
CREATE TRIGGER trg_children_updated_at
    BEFORE UPDATE ON children
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();


-- ═════════════════════════════════════════════════════════════
-- 3. CHILD_SETTINGS — Almennir stillingar per barn
-- ═════════════════════════════════════════════════════════════
-- Ein röð per barn. Búin til sjálfkrafa þegar barn bætist við (trigger í skref 3)

CREATE TABLE IF NOT EXISTS child_settings (
    id                 UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    child_id           UUID NOT NULL UNIQUE REFERENCES children(id) ON DELETE RESTRICT,
    daily_points_goal  INTEGER,          -- dagmarkmið (valfrjálst)
    weekly_points_goal INTEGER,          -- vikumarkmið (valfrjálst)
    math_enabled       BOOLEAN NOT NULL DEFAULT true,
    reading_enabled    BOOLEAN NOT NULL DEFAULT true,
    tasks_enabled      BOOLEAN NOT NULL DEFAULT true,
    rewards_enabled    BOOLEAN NOT NULL DEFAULT true,
    created_at         TIMESTAMPTZ NOT NULL DEFAULT now(),
    updated_at         TIMESTAMPTZ NOT NULL DEFAULT now()
);

DROP TRIGGER IF EXISTS trg_child_settings_updated_at ON child_settings;
CREATE TRIGGER trg_child_settings_updated_at
    BEFORE UPDATE ON child_settings
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();


-- ═════════════════════════════════════════════════════════════
-- 4. CHILD_MATH_SETTINGS — Stærðfræðistillingar per barn
-- ═════════════════════════════════════════════════════════════
-- Foreldri velur erfiðleikastig, leyfðar aðgerðir, talnabil o.s.frv.

CREATE TABLE IF NOT EXISTS child_math_settings (
    id                          UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    child_id                    UUID NOT NULL UNIQUE REFERENCES children(id) ON DELETE RESTRICT,
    difficulty_label            TEXT NOT NULL DEFAULT 'easy'
                                    CHECK (difficulty_label IN ('easy', 'medium', 'hard', 'custom')),
    min_number                  INTEGER NOT NULL DEFAULT 1,
    max_number                  INTEGER NOT NULL DEFAULT 10,
    question_count              INTEGER NOT NULL DEFAULT 10,
    allow_addition              BOOLEAN NOT NULL DEFAULT true,
    allow_subtraction           BOOLEAN NOT NULL DEFAULT true,
    allow_multiplication        BOOLEAN NOT NULL DEFAULT false,
    allow_division              BOOLEAN NOT NULL DEFAULT false,
    division_whole_numbers_only BOOLEAN NOT NULL DEFAULT true,
    time_limit_seconds          INTEGER,                         -- null = enginn tímamælir
    points_per_correct_answer   INTEGER NOT NULL DEFAULT 1,
    points_per_wrong_answer     INTEGER NOT NULL DEFAULT 0,      -- getur verið neikvætt
    show_timer_to_child         BOOLEAN NOT NULL DEFAULT false,
    created_at                  TIMESTAMPTZ NOT NULL DEFAULT now(),
    updated_at                  TIMESTAMPTZ NOT NULL DEFAULT now(),
    CONSTRAINT chk_math_number_range   CHECK (min_number <= max_number),
    CONSTRAINT chk_math_question_count CHECK (question_count > 0)
);

DROP TRIGGER IF EXISTS trg_child_math_settings_updated_at ON child_math_settings;
CREATE TRIGGER trg_child_math_settings_updated_at
    BEFORE UPDATE ON child_math_settings
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();


-- ═════════════════════════════════════════════════════════════
-- 5. CHILD_READING_SETTINGS — Upplestursstillingar per barn
-- ═════════════════════════════════════════════════════════════
-- Barnið fær full stig ef nákvæmni er yfir threshold, annars 0.

CREATE TABLE IF NOT EXISTS child_reading_settings (
    id                         UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    child_id                   UUID NOT NULL UNIQUE REFERENCES children(id) ON DELETE RESTRICT,
    difficulty_level           TEXT NOT NULL DEFAULT 'beginner'
                                   CHECK (difficulty_level IN ('beginner', 'elementary', 'intermediate', 'advanced')),
    min_word_count             INTEGER,
    max_word_count             INTEGER,
    points_per_session         INTEGER NOT NULL DEFAULT 10,
    accuracy_threshold_percent INTEGER NOT NULL DEFAULT 80
                                   CHECK (accuracy_threshold_percent BETWEEN 0 AND 100),
    show_accuracy_to_child     BOOLEAN NOT NULL DEFAULT false,
    created_at                 TIMESTAMPTZ NOT NULL DEFAULT now(),
    updated_at                 TIMESTAMPTZ NOT NULL DEFAULT now()
);

DROP TRIGGER IF EXISTS trg_child_reading_settings_updated_at ON child_reading_settings;
CREATE TRIGGER trg_child_reading_settings_updated_at
    BEFORE UPDATE ON child_reading_settings
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();


-- ═════════════════════════════════════════════════════════════
-- 6. TASKS — Heimilisstörf búin til af foreldri
-- ═════════════════════════════════════════════════════════════
-- Flæði: pending → submitted (barn skilar) → approved/rejected (foreldri)
-- Rejected fer aftur í pending.

CREATE TABLE IF NOT EXISTS tasks (
    id                      UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    parent_id               UUID NOT NULL REFERENCES profiles(id) ON DELETE RESTRICT,
    child_id                UUID NOT NULL REFERENCES children(id) ON DELETE RESTRICT,
    title                   TEXT NOT NULL,
    description             TEXT,
    category                TEXT NOT NULL DEFAULT 'custom'
                                CHECK (category IN ('cleaning', 'routine', 'school', 'custom')),
    status                  TEXT NOT NULL DEFAULT 'pending'
                                CHECK (status IN ('pending', 'submitted', 'approved', 'rejected', 'cancelled')),
    points_value            INTEGER NOT NULL DEFAULT 5,
    due_date                DATE,
    is_recurring            BOOLEAN NOT NULL DEFAULT false,
    recurrence_type         TEXT CHECK (recurrence_type IN ('daily', 'weekly')),
    created_at              TIMESTAMPTZ NOT NULL DEFAULT now(),
    updated_at              TIMESTAMPTZ NOT NULL DEFAULT now(),
    submitted_at            TIMESTAMPTZ,
    approved_at             TIMESTAMPTZ,
    approved_by             UUID REFERENCES profiles(id),
    requires_photo_proof    BOOLEAN NOT NULL DEFAULT false,
    proof_image_url         TEXT,
    parent_feedback         TEXT,             -- foreldri skrifar athugasemd
    completion_time_seconds INTEGER
);

DROP TRIGGER IF EXISTS trg_tasks_updated_at ON tasks;
CREATE TRIGGER trg_tasks_updated_at
    BEFORE UPDATE ON tasks
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();


-- ═════════════════════════════════════════════════════════════
-- 7. MATH_SESSIONS — Stærðfræðilota
-- ═════════════════════════════════════════════════════════════
-- settings_snapshot geymir afrit af stillingum þegar lota byrjar.

CREATE TABLE IF NOT EXISTS math_sessions (
    id                  UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    child_id            UUID NOT NULL REFERENCES children(id) ON DELETE RESTRICT,
    settings_snapshot   JSONB NOT NULL,     -- afrit af math_settings við byrjun
    question_count      INTEGER NOT NULL,
    correct_answers     INTEGER NOT NULL DEFAULT 0,
    wrong_answers       INTEGER NOT NULL DEFAULT 0,
    skipped_answers     INTEGER NOT NULL DEFAULT 0,
    accuracy_percent    NUMERIC(5,2),
    base_points_earned  INTEGER NOT NULL DEFAULT 0,
    bonus_multiplier    NUMERIC(4,2) NOT NULL DEFAULT 1.0,
    final_points_earned INTEGER NOT NULL DEFAULT 0,
    started_at          TIMESTAMPTZ NOT NULL DEFAULT now(),
    completed_at        TIMESTAMPTZ,
    duration_seconds    INTEGER,
    status              TEXT NOT NULL DEFAULT 'started'
                            CHECK (status IN ('started', 'completed', 'abandoned'))
);


-- ═════════════════════════════════════════════════════════════
-- 8. MATH_SESSION_QUESTIONS — Hvert dæmi í stærðfræðilotu
-- ═════════════════════════════════════════════════════════════
-- CASCADE eyðing: ef lota eyðist, eyðast spurningarnar líka.

CREATE TABLE IF NOT EXISTS math_session_questions (
    id               UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    math_session_id  UUID NOT NULL REFERENCES math_sessions(id) ON DELETE CASCADE,
    question_order   INTEGER NOT NULL,
    operand_1        INTEGER NOT NULL,
    operand_2        INTEGER NOT NULL,
    operator         TEXT NOT NULL CHECK (operator IN ('+', '-', '*', '/')),
    correct_answer   NUMERIC(10,4) NOT NULL,
    child_answer     NUMERIC(10,4),          -- null ef ekki svarað
    is_correct       BOOLEAN,
    is_skipped       BOOLEAN NOT NULL DEFAULT false,
    points_earned    INTEGER NOT NULL DEFAULT 0,
    response_time_ms INTEGER,                -- svartími í millisekúndum
    attempt_number   INTEGER NOT NULL DEFAULT 1,
    created_at       TIMESTAMPTZ NOT NULL DEFAULT now()
);


-- ═════════════════════════════════════════════════════════════
-- 9. READING_TEXTS — Safn lestrartexta
-- ═════════════════════════════════════════════════════════════
-- is_system_text = true: texti sem kemur með appinu
-- is_system_text = false: texti sem foreldri bjó til

CREATE TABLE IF NOT EXISTS reading_texts (
    id                   UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    title                TEXT NOT NULL,
    text_content         TEXT NOT NULL,
    language             TEXT NOT NULL DEFAULT 'is',
    difficulty_level     TEXT NOT NULL DEFAULT 'beginner'
                             CHECK (difficulty_level IN ('beginner', 'elementary', 'intermediate', 'advanced')),
    word_count           INTEGER NOT NULL,
    age_min              INTEGER,
    age_max              INTEGER,
    topic                TEXT,
    is_system_text       BOOLEAN NOT NULL DEFAULT true,
    is_active            BOOLEAN NOT NULL DEFAULT true,
    created_by_parent_id UUID REFERENCES profiles(id),
    times_used           INTEGER NOT NULL DEFAULT 0,
    created_at           TIMESTAMPTZ NOT NULL DEFAULT now(),
    updated_at           TIMESTAMPTZ NOT NULL DEFAULT now()
);

DROP TRIGGER IF EXISTS trg_reading_texts_updated_at ON reading_texts;
CREATE TRIGGER trg_reading_texts_updated_at
    BEFORE UPDATE ON reading_texts
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();


-- ═════════════════════════════════════════════════════════════
-- 10. CHILD_FAVORITE_TEXTS — Uppáhalds textar per barn
-- ═════════════════════════════════════════════════════════════

CREATE TABLE IF NOT EXISTS child_favorite_texts (
    id                   UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    child_id             UUID NOT NULL REFERENCES children(id) ON DELETE RESTRICT,
    reading_text_id      UUID NOT NULL REFERENCES reading_texts(id) ON DELETE RESTRICT,
    created_by_parent_id UUID NOT NULL REFERENCES profiles(id),
    created_at           TIMESTAMPTZ NOT NULL DEFAULT now(),
    UNIQUE (child_id, reading_text_id)
);


-- ═════════════════════════════════════════════════════════════
-- 11. READING_SESSIONS — Upplestur lota
-- ═════════════════════════════════════════════════════════════
-- Barn les texta upphátt. Appið metur nákvæmni.
-- threshold_met = true ef nákvæmni ≥ threshold → fær stig.

CREATE TABLE IF NOT EXISTS reading_sessions (
    id                     UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    child_id               UUID NOT NULL REFERENCES children(id) ON DELETE RESTRICT,
    reading_text_id        UUID NOT NULL REFERENCES reading_texts(id) ON DELETE RESTRICT,
    assigned_text_snapshot TEXT NOT NULL,     -- afrit af texta
    spoken_text            TEXT,              -- hvað barnið sagði
    word_count             INTEGER NOT NULL,
    words_correct_count    INTEGER NOT NULL DEFAULT 0,
    words_incorrect_count  INTEGER NOT NULL DEFAULT 0,
    words_skipped_count    INTEGER NOT NULL DEFAULT 0,
    accuracy_percent       NUMERIC(5,2),
    threshold_met          BOOLEAN NOT NULL DEFAULT false,
    base_points_earned     INTEGER NOT NULL DEFAULT 0,
    bonus_multiplier       NUMERIC(4,2) NOT NULL DEFAULT 1.0,
    final_points_earned    INTEGER NOT NULL DEFAULT 0,
    started_at             TIMESTAMPTZ NOT NULL DEFAULT now(),
    completed_at           TIMESTAMPTZ,
    duration_seconds       INTEGER,
    status                 TEXT NOT NULL DEFAULT 'started'
                               CHECK (status IN ('started', 'completed', 'abandoned', 'review_needed')),
    settings_snapshot      JSONB NOT NULL,
    audio_file_url         TEXT,
    speech_engine          TEXT,
    review_notes           TEXT,
    parent_reviewed        BOOLEAN NOT NULL DEFAULT false
);


-- ═════════════════════════════════════════════════════════════
-- 12. POINT_MULTIPLIERS — Tímabundnir bónusar
-- ═════════════════════════════════════════════════════════════
-- Foreldri býr til bónus (t.d. "Helgarbónus! 2x stig")
-- child_id = null → gildir fyrir öll börn

CREATE TABLE IF NOT EXISTS point_multipliers (
    id               UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    parent_id        UUID NOT NULL REFERENCES profiles(id) ON DELETE RESTRICT,
    child_id         UUID REFERENCES children(id) ON DELETE RESTRICT,
    activity_type    TEXT NOT NULL DEFAULT 'all'
                         CHECK (activity_type IN ('math', 'reading', 'task', 'all')),
    multiplier_value NUMERIC(4,2) NOT NULL,
    title            TEXT NOT NULL,              -- barnið sér þetta
    reason           TEXT,                       -- foreldri sér þetta
    starts_at        TIMESTAMPTZ NOT NULL,
    ends_at          TIMESTAMPTZ NOT NULL,
    is_active        BOOLEAN NOT NULL DEFAULT true,
    created_at       TIMESTAMPTZ NOT NULL DEFAULT now(),
    CONSTRAINT chk_multiplier_date_range CHECK (starts_at < ends_at),
    CONSTRAINT chk_multiplier_positive   CHECK (multiplier_value > 0)
);


-- ═════════════════════════════════════════════════════════════
-- 13. POINTS_LEDGER — Stigabókhald (ÓBREYTANLEGT)
-- ═════════════════════════════════════════════════════════════
-- Hver einasta stigafærsla. Credit = fær stig, Debit = eyðir stigum.
-- ENGIN uppfærsla eða eyðing leyfð (tryggð með rules).

CREATE TABLE IF NOT EXISTS points_ledger (
    id                   UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    child_id             UUID NOT NULL REFERENCES children(id) ON DELETE RESTRICT,
    source_type          TEXT NOT NULL
                             CHECK (source_type IN (
                                 'math_session', 'reading_session', 'task',
                                 'reward_redemption', 'manual_adjustment', 'bonus'
                             )),
    source_id            UUID,               -- ID á lotu/verkefni/verðlauni
    base_points          INTEGER NOT NULL,
    multiplier_applied   NUMERIC(4,2) NOT NULL DEFAULT 1.0,
    bonus_points         INTEGER NOT NULL DEFAULT 0,
    final_points         INTEGER NOT NULL,
    direction            TEXT NOT NULL CHECK (direction IN ('credit', 'debit')),
    description          TEXT NOT NULL,       -- á íslensku
    created_at           TIMESTAMPTZ NOT NULL DEFAULT now(),
    created_by_parent_id UUID REFERENCES profiles(id)
);

-- Loka á UPDATE og DELETE — stigabókhaldið er óbreytanlegt
DROP RULE IF EXISTS rule_points_ledger_no_update ON points_ledger;
DROP RULE IF EXISTS rule_points_ledger_no_delete ON points_ledger;
CREATE RULE rule_points_ledger_no_update AS
    ON UPDATE TO points_ledger DO INSTEAD NOTHING;
CREATE RULE rule_points_ledger_no_delete AS
    ON DELETE TO points_ledger DO INSTEAD NOTHING;


-- ═════════════════════════════════════════════════════════════
-- 14. REWARDS — Verðlaun sem foreldri býr til
-- ═════════════════════════════════════════════════════════════
-- child_id = null → öll börn sjá verðlaunin

CREATE TABLE IF NOT EXISTS rewards (
    id          UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    parent_id   UUID NOT NULL REFERENCES profiles(id) ON DELETE RESTRICT,
    child_id    UUID REFERENCES children(id) ON DELETE RESTRICT,
    title       TEXT NOT NULL,
    description TEXT,
    points_cost INTEGER NOT NULL CHECK (points_cost > 0),
    image_url   TEXT,
    is_active   BOOLEAN NOT NULL DEFAULT true,
    is_one_time BOOLEAN NOT NULL DEFAULT false,
    created_at  TIMESTAMPTZ NOT NULL DEFAULT now(),
    updated_at  TIMESTAMPTZ NOT NULL DEFAULT now()
);

DROP TRIGGER IF EXISTS trg_rewards_updated_at ON rewards;
CREATE TRIGGER trg_rewards_updated_at
    BEFORE UPDATE ON rewards
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();


-- ═════════════════════════════════════════════════════════════
-- 15. REWARD_REDEMPTIONS — Innlausn verðlauna
-- ═════════════════════════════════════════════════════════════
-- Barn biður um verðlaun → foreldri samþykkir/hafnar/uppfyllir
-- Ef hafnað → stig skilað til baka

CREATE TABLE IF NOT EXISTS reward_redemptions (
    id           UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    reward_id    UUID NOT NULL REFERENCES rewards(id) ON DELETE RESTRICT,
    child_id     UUID NOT NULL REFERENCES children(id) ON DELETE RESTRICT,
    points_spent INTEGER NOT NULL,
    status       TEXT NOT NULL DEFAULT 'requested'
                     CHECK (status IN ('requested', 'approved', 'rejected', 'fulfilled')),
    requested_at TIMESTAMPTZ NOT NULL DEFAULT now(),
    reviewed_at  TIMESTAMPTZ,
    reviewed_by  UUID REFERENCES profiles(id),
    parent_note  TEXT
);


-- ═════════════════════════════════════════════════════════════
-- 16. CHILD_DAILY_STATS — Dagleg samantekt per barn
-- ═════════════════════════════════════════════════════════════
-- Ein röð per barn per dag. Uppfærð sjálfkrafa af triggers (skref 3).

CREATE TABLE IF NOT EXISTS child_daily_stats (
    id                         UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    child_id                   UUID NOT NULL REFERENCES children(id) ON DELETE RESTRICT,
    stat_date                  DATE NOT NULL,
    points_earned              INTEGER NOT NULL DEFAULT 0,
    points_spent               INTEGER NOT NULL DEFAULT 0,
    bonus_points_earned        INTEGER NOT NULL DEFAULT 0,
    tasks_completed            INTEGER NOT NULL DEFAULT 0,
    tasks_rejected             INTEGER NOT NULL DEFAULT 0,
    math_sessions_completed    INTEGER NOT NULL DEFAULT 0,
    math_sessions_abandoned    INTEGER NOT NULL DEFAULT 0,
    math_correct_answers       INTEGER NOT NULL DEFAULT 0,
    math_wrong_answers         INTEGER NOT NULL DEFAULT 0,
    math_skipped_answers       INTEGER NOT NULL DEFAULT 0,
    math_avg_accuracy          NUMERIC(5,2) NOT NULL DEFAULT 0,
    math_avg_response_time_ms  INTEGER NOT NULL DEFAULT 0,
    reading_sessions_completed INTEGER NOT NULL DEFAULT 0,
    reading_sessions_abandoned INTEGER NOT NULL DEFAULT 0,
    reading_avg_accuracy       NUMERIC(5,2) NOT NULL DEFAULT 0,
    reading_words_correct      INTEGER NOT NULL DEFAULT 0,
    reading_words_incorrect    INTEGER NOT NULL DEFAULT 0,
    active_minutes             INTEGER NOT NULL DEFAULT 0,
    daily_goal_reached         BOOLEAN NOT NULL DEFAULT false,
    is_streak_day              BOOLEAN NOT NULL DEFAULT false,
    created_at                 TIMESTAMPTZ NOT NULL DEFAULT now(),
    updated_at                 TIMESTAMPTZ NOT NULL DEFAULT now(),
    UNIQUE (child_id, stat_date)
);

DROP TRIGGER IF EXISTS trg_child_daily_stats_updated_at ON child_daily_stats;
CREATE TRIGGER trg_child_daily_stats_updated_at
    BEFORE UPDATE ON child_daily_stats
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();


-- ═════════════════════════════════════════════════════════════
-- 17. CHILD_WEEKLY_STATS — Vikuleg samantekt per barn
-- ═════════════════════════════════════════════════════════════
-- Rúllað saman úr daily_stats, annað hvort sjálfkrafa eða með cron.

CREATE TABLE IF NOT EXISTS child_weekly_stats (
    id                         UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    child_id                   UUID NOT NULL REFERENCES children(id) ON DELETE RESTRICT,
    week_start_date            DATE NOT NULL,       -- alltaf mánudagur
    week_end_date              DATE NOT NULL,       -- alltaf sunnudagur
    points_earned              INTEGER NOT NULL DEFAULT 0,
    points_spent               INTEGER NOT NULL DEFAULT 0,
    bonus_points_earned        INTEGER NOT NULL DEFAULT 0,
    tasks_completed            INTEGER NOT NULL DEFAULT 0,
    tasks_rejected             INTEGER NOT NULL DEFAULT 0,
    math_sessions_completed    INTEGER NOT NULL DEFAULT 0,
    math_sessions_abandoned    INTEGER NOT NULL DEFAULT 0,
    math_avg_accuracy          NUMERIC(5,2) NOT NULL DEFAULT 0,
    math_avg_response_time_ms  INTEGER NOT NULL DEFAULT 0,
    reading_sessions_completed INTEGER NOT NULL DEFAULT 0,
    reading_sessions_abandoned INTEGER NOT NULL DEFAULT 0,
    reading_avg_accuracy       NUMERIC(5,2) NOT NULL DEFAULT 0,
    active_days_count          INTEGER NOT NULL DEFAULT 0,
    weekly_goal_reached        BOOLEAN NOT NULL DEFAULT false,
    best_day_points            INTEGER NOT NULL DEFAULT 0,
    best_math_accuracy         NUMERIC(5,2) NOT NULL DEFAULT 0,
    best_reading_accuracy      NUMERIC(5,2) NOT NULL DEFAULT 0,
    most_used_activity         TEXT CHECK (most_used_activity IN ('math', 'reading', 'task')),
    created_at                 TIMESTAMPTZ NOT NULL DEFAULT now(),
    updated_at                 TIMESTAMPTZ NOT NULL DEFAULT now(),
    UNIQUE (child_id, week_start_date),
    CONSTRAINT chk_week_range CHECK (week_end_date = week_start_date + INTERVAL '6 days')
);

DROP TRIGGER IF EXISTS trg_child_weekly_stats_updated_at ON child_weekly_stats;
CREATE TRIGGER trg_child_weekly_stats_updated_at
    BEFORE UPDATE ON child_weekly_stats
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();


-- ═════════════════════════════════════════════════════════════
-- BÚIÐ! Keyrðu næst: 02_indexes_og_oryggi.sql
-- ═════════════════════════════════════════════════════════════
