-- =============================================================================
-- KrakkApp — ALLT í einni keyrslu (handvirkt í Supabase SQL Editor)
-- Nýtt / tómt verkefni: límdu inn og keyrðu einu sinni.
-- Sama innihald og skrárnar 01 → 02 → 03 → 04 í röð.
-- ATH: Hægt að keyra aftur á grunni sem er þegar til (IF NOT EXISTS / DROP … IF EXISTS).
-- =============================================================================

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


-- ########## SKREF 2: indexes + RLS (02_indexes_og_oryggi.sql) ##########

-- ╔═══════════════════════════════════════════════════════════════╗
-- ║  KrakkApp — Skref 2: Indexes og Row Level Security          ║
-- ║  Keyrðu EFTIR 01_toflur.sql                                 ║
-- ╚═══════════════════════════════════════════════════════════════╝


-- ─────────────────────────────────────────────────────────────
-- INDEXES — Hraðar fyrirspurnir
-- ─────────────────────────────────────────────────────────────
-- Án þessara væri gagnagrunnurinn hægur þegar gögn stækka.

CREATE INDEX IF NOT EXISTS idx_children_parent_id                ON children(parent_id);
CREATE INDEX IF NOT EXISTS idx_tasks_child_id                    ON tasks(child_id);
CREATE INDEX IF NOT EXISTS idx_tasks_parent_id                   ON tasks(parent_id);
CREATE INDEX IF NOT EXISTS idx_tasks_status                      ON tasks(status);
CREATE INDEX IF NOT EXISTS idx_math_sessions_child_id            ON math_sessions(child_id);
CREATE INDEX IF NOT EXISTS idx_math_sessions_status              ON math_sessions(status);
CREATE INDEX IF NOT EXISTS idx_math_session_questions_session_id  ON math_session_questions(math_session_id);
CREATE INDEX IF NOT EXISTS idx_reading_sessions_child_id         ON reading_sessions(child_id);
CREATE INDEX IF NOT EXISTS idx_reading_sessions_status           ON reading_sessions(status);
CREATE INDEX IF NOT EXISTS idx_reading_sessions_text_id          ON reading_sessions(reading_text_id);
CREATE INDEX IF NOT EXISTS idx_points_ledger_child_id            ON points_ledger(child_id);
CREATE INDEX IF NOT EXISTS idx_points_ledger_source_type         ON points_ledger(source_type);
CREATE INDEX IF NOT EXISTS idx_points_ledger_created_at          ON points_ledger(created_at);
CREATE INDEX IF NOT EXISTS idx_point_multipliers_child_id        ON point_multipliers(child_id);
CREATE INDEX IF NOT EXISTS idx_point_multipliers_ends_at         ON point_multipliers(ends_at);
CREATE INDEX IF NOT EXISTS idx_reward_redemptions_child_id       ON reward_redemptions(child_id);
CREATE INDEX IF NOT EXISTS idx_reward_redemptions_status         ON reward_redemptions(status);


-- ─────────────────────────────────────────────────────────────
-- ROW LEVEL SECURITY (RLS) — Kveikt á öllum töflum
-- ─────────────────────────────────────────────────────────────
-- Þetta tryggir að foreldri A sér ALDREI gögn foreldris B.
-- Supabase þarf RLS til að vera öruggt.

ALTER TABLE profiles               ENABLE ROW LEVEL SECURITY;
ALTER TABLE children                ENABLE ROW LEVEL SECURITY;
ALTER TABLE child_settings          ENABLE ROW LEVEL SECURITY;
ALTER TABLE child_math_settings     ENABLE ROW LEVEL SECURITY;
ALTER TABLE child_reading_settings  ENABLE ROW LEVEL SECURITY;
ALTER TABLE tasks                   ENABLE ROW LEVEL SECURITY;
ALTER TABLE math_sessions           ENABLE ROW LEVEL SECURITY;
ALTER TABLE math_session_questions  ENABLE ROW LEVEL SECURITY;
ALTER TABLE reading_texts           ENABLE ROW LEVEL SECURITY;
ALTER TABLE child_favorite_texts    ENABLE ROW LEVEL SECURITY;
ALTER TABLE reading_sessions        ENABLE ROW LEVEL SECURITY;
ALTER TABLE point_multipliers       ENABLE ROW LEVEL SECURITY;
ALTER TABLE points_ledger           ENABLE ROW LEVEL SECURITY;
ALTER TABLE rewards                 ENABLE ROW LEVEL SECURITY;
ALTER TABLE reward_redemptions      ENABLE ROW LEVEL SECURITY;
ALTER TABLE child_daily_stats       ENABLE ROW LEVEL SECURITY;
ALTER TABLE child_weekly_stats      ENABLE ROW LEVEL SECURITY;


-- ─────────────────────────────────────────────────────────────
-- HJÁLPARFALL: Er notandinn foreldri þessa barns?
-- ─────────────────────────────────────────────────────────────
-- Notað af RLS policies hér að neðan

CREATE OR REPLACE FUNCTION is_parent_of(p_child_id UUID)
RETURNS BOOLEAN AS $$
    SELECT EXISTS (
        SELECT 1 FROM children
        WHERE id = p_child_id AND parent_id = auth.uid()
    );
$$ LANGUAGE sql SECURITY DEFINER STABLE;


-- ─────────────────────────────────────────────────────────────
-- RLS POLICIES — Reglur um hver má sjá/breyta hverju
-- ─────────────────────────────────────────────────────────────
-- Endurkeyrsla: fjarlægja eldri policy með sama nafni á undan
DROP POLICY IF EXISTS "Users can view own profile" ON profiles;
DROP POLICY IF EXISTS "Users can update own profile" ON profiles;
DROP POLICY IF EXISTS "Parents can view own children" ON children;
DROP POLICY IF EXISTS "Parents can insert own children" ON children;
DROP POLICY IF EXISTS "Parents can update own children" ON children;
DROP POLICY IF EXISTS "Parents can view child settings" ON child_settings;
DROP POLICY IF EXISTS "Parents can insert child settings" ON child_settings;
DROP POLICY IF EXISTS "Parents can update child settings" ON child_settings;
DROP POLICY IF EXISTS "Parents can view math settings" ON child_math_settings;
DROP POLICY IF EXISTS "Parents can insert math settings" ON child_math_settings;
DROP POLICY IF EXISTS "Parents can update math settings" ON child_math_settings;
DROP POLICY IF EXISTS "Parents can view reading settings" ON child_reading_settings;
DROP POLICY IF EXISTS "Parents can insert reading settings" ON child_reading_settings;
DROP POLICY IF EXISTS "Parents can update reading settings" ON child_reading_settings;
DROP POLICY IF EXISTS "Parents can view own tasks" ON tasks;
DROP POLICY IF EXISTS "Parents can insert own tasks" ON tasks;
DROP POLICY IF EXISTS "Parents can update own tasks" ON tasks;
DROP POLICY IF EXISTS "Parents can view child math sessions" ON math_sessions;
DROP POLICY IF EXISTS "Parents can insert child math sessions" ON math_sessions;
DROP POLICY IF EXISTS "Parents can update child math sessions" ON math_sessions;
DROP POLICY IF EXISTS "Parents can view child math questions" ON math_session_questions;
DROP POLICY IF EXISTS "Parents can insert child math questions" ON math_session_questions;
DROP POLICY IF EXISTS "Anyone can view active system texts" ON reading_texts;
DROP POLICY IF EXISTS "Parents can view own custom texts" ON reading_texts;
DROP POLICY IF EXISTS "Parents can insert custom texts" ON reading_texts;
DROP POLICY IF EXISTS "Parents can update own custom texts" ON reading_texts;
DROP POLICY IF EXISTS "Parents can view child favorites" ON child_favorite_texts;
DROP POLICY IF EXISTS "Parents can insert child favorites" ON child_favorite_texts;
DROP POLICY IF EXISTS "Parents can delete child favorites" ON child_favorite_texts;
DROP POLICY IF EXISTS "Parents can view child reading sessions" ON reading_sessions;
DROP POLICY IF EXISTS "Parents can insert child reading sessions" ON reading_sessions;
DROP POLICY IF EXISTS "Parents can update child reading sessions" ON reading_sessions;
DROP POLICY IF EXISTS "Parents can view own multipliers" ON point_multipliers;
DROP POLICY IF EXISTS "Parents can insert own multipliers" ON point_multipliers;
DROP POLICY IF EXISTS "Parents can update own multipliers" ON point_multipliers;
DROP POLICY IF EXISTS "Parents can delete own multipliers" ON point_multipliers;
DROP POLICY IF EXISTS "Parents can view child ledger" ON points_ledger;
DROP POLICY IF EXISTS "Parents can insert child ledger" ON points_ledger;
DROP POLICY IF EXISTS "Parents can view own rewards" ON rewards;
DROP POLICY IF EXISTS "Parents can insert own rewards" ON rewards;
DROP POLICY IF EXISTS "Parents can update own rewards" ON rewards;
DROP POLICY IF EXISTS "Parents can view child redemptions" ON reward_redemptions;
DROP POLICY IF EXISTS "Parents can insert child redemptions" ON reward_redemptions;
DROP POLICY IF EXISTS "Parents can update child redemptions" ON reward_redemptions;
DROP POLICY IF EXISTS "Parents can view child daily stats" ON child_daily_stats;
DROP POLICY IF EXISTS "Parents can insert child daily stats" ON child_daily_stats;
DROP POLICY IF EXISTS "Parents can update child daily stats" ON child_daily_stats;
DROP POLICY IF EXISTS "Parents can view child weekly stats" ON child_weekly_stats;
DROP POLICY IF EXISTS "Parents can insert child weekly stats" ON child_weekly_stats;
DROP POLICY IF EXISTS "Parents can update child weekly stats" ON child_weekly_stats;

-- profiles: Notandi sér aðeins eigin prófíl
CREATE POLICY "Users can view own profile"    ON profiles FOR SELECT USING (id = auth.uid());
CREATE POLICY "Users can update own profile"  ON profiles FOR UPDATE USING (id = auth.uid());

-- children: Foreldri sér/breytir aðeins eigin börnum
CREATE POLICY "Parents can view own children"   ON children FOR SELECT USING (parent_id = auth.uid());
CREATE POLICY "Parents can insert own children" ON children FOR INSERT WITH CHECK (parent_id = auth.uid());
CREATE POLICY "Parents can update own children" ON children FOR UPDATE USING (parent_id = auth.uid());

-- child_settings
CREATE POLICY "Parents can view child settings"   ON child_settings FOR SELECT USING (is_parent_of(child_id));
CREATE POLICY "Parents can insert child settings"  ON child_settings FOR INSERT WITH CHECK (is_parent_of(child_id));
CREATE POLICY "Parents can update child settings"  ON child_settings FOR UPDATE USING (is_parent_of(child_id));

-- child_math_settings
CREATE POLICY "Parents can view math settings"   ON child_math_settings FOR SELECT USING (is_parent_of(child_id));
CREATE POLICY "Parents can insert math settings"  ON child_math_settings FOR INSERT WITH CHECK (is_parent_of(child_id));
CREATE POLICY "Parents can update math settings"  ON child_math_settings FOR UPDATE USING (is_parent_of(child_id));

-- child_reading_settings
CREATE POLICY "Parents can view reading settings"   ON child_reading_settings FOR SELECT USING (is_parent_of(child_id));
CREATE POLICY "Parents can insert reading settings"  ON child_reading_settings FOR INSERT WITH CHECK (is_parent_of(child_id));
CREATE POLICY "Parents can update reading settings"  ON child_reading_settings FOR UPDATE USING (is_parent_of(child_id));

-- tasks
CREATE POLICY "Parents can view own tasks"   ON tasks FOR SELECT USING (parent_id = auth.uid());
CREATE POLICY "Parents can insert own tasks" ON tasks FOR INSERT WITH CHECK (parent_id = auth.uid());
CREATE POLICY "Parents can update own tasks" ON tasks FOR UPDATE USING (parent_id = auth.uid());

-- math_sessions
CREATE POLICY "Parents can view child math sessions"   ON math_sessions FOR SELECT USING (is_parent_of(child_id));
CREATE POLICY "Parents can insert child math sessions"  ON math_sessions FOR INSERT WITH CHECK (is_parent_of(child_id));
CREATE POLICY "Parents can update child math sessions"  ON math_sessions FOR UPDATE USING (is_parent_of(child_id));

-- math_session_questions (tengist lotu, ekki barni beint)
CREATE POLICY "Parents can view child math questions" ON math_session_questions FOR SELECT
    USING (EXISTS (SELECT 1 FROM math_sessions ms WHERE ms.id = math_session_questions.math_session_id AND is_parent_of(ms.child_id)));
CREATE POLICY "Parents can insert child math questions" ON math_session_questions FOR INSERT
    WITH CHECK (EXISTS (SELECT 1 FROM math_sessions ms WHERE ms.id = math_session_questions.math_session_id AND is_parent_of(ms.child_id)));

-- reading_texts (kerfi textar sjást af öllum, eigin textar aðeins af eiganda)
CREATE POLICY "Anyone can view active system texts" ON reading_texts FOR SELECT
    USING (is_system_text = true AND is_active = true);
CREATE POLICY "Parents can view own custom texts" ON reading_texts FOR SELECT
    USING (created_by_parent_id = auth.uid());
CREATE POLICY "Parents can insert custom texts" ON reading_texts FOR INSERT
    WITH CHECK (created_by_parent_id = auth.uid() AND is_system_text = false);
CREATE POLICY "Parents can update own custom texts" ON reading_texts FOR UPDATE
    USING (created_by_parent_id = auth.uid() AND is_system_text = false);

-- child_favorite_texts
CREATE POLICY "Parents can view child favorites"  ON child_favorite_texts FOR SELECT USING (is_parent_of(child_id));
CREATE POLICY "Parents can insert child favorites" ON child_favorite_texts FOR INSERT WITH CHECK (is_parent_of(child_id));
CREATE POLICY "Parents can delete child favorites" ON child_favorite_texts FOR DELETE USING (is_parent_of(child_id));

-- reading_sessions
CREATE POLICY "Parents can view child reading sessions"   ON reading_sessions FOR SELECT USING (is_parent_of(child_id));
CREATE POLICY "Parents can insert child reading sessions"  ON reading_sessions FOR INSERT WITH CHECK (is_parent_of(child_id));
CREATE POLICY "Parents can update child reading sessions"  ON reading_sessions FOR UPDATE USING (is_parent_of(child_id));

-- point_multipliers
CREATE POLICY "Parents can view own multipliers"   ON point_multipliers FOR SELECT USING (parent_id = auth.uid());
CREATE POLICY "Parents can insert own multipliers"  ON point_multipliers FOR INSERT WITH CHECK (parent_id = auth.uid());
CREATE POLICY "Parents can update own multipliers"  ON point_multipliers FOR UPDATE USING (parent_id = auth.uid());
CREATE POLICY "Parents can delete own multipliers"  ON point_multipliers FOR DELETE USING (parent_id = auth.uid());

-- points_ledger (aðeins SELECT og INSERT — engin UPDATE/DELETE, bókhaldið er óbreytanlegt)
CREATE POLICY "Parents can view child ledger"  ON points_ledger FOR SELECT USING (is_parent_of(child_id));
CREATE POLICY "Parents can insert child ledger" ON points_ledger FOR INSERT WITH CHECK (is_parent_of(child_id));

-- rewards
CREATE POLICY "Parents can view own rewards"   ON rewards FOR SELECT USING (parent_id = auth.uid());
CREATE POLICY "Parents can insert own rewards"  ON rewards FOR INSERT WITH CHECK (parent_id = auth.uid());
CREATE POLICY "Parents can update own rewards"  ON rewards FOR UPDATE USING (parent_id = auth.uid());

-- reward_redemptions
CREATE POLICY "Parents can view child redemptions"   ON reward_redemptions FOR SELECT USING (is_parent_of(child_id));
CREATE POLICY "Parents can insert child redemptions"  ON reward_redemptions FOR INSERT WITH CHECK (is_parent_of(child_id));
CREATE POLICY "Parents can update child redemptions"  ON reward_redemptions FOR UPDATE USING (is_parent_of(child_id));

-- child_daily_stats
CREATE POLICY "Parents can view child daily stats"   ON child_daily_stats FOR SELECT USING (is_parent_of(child_id));
CREATE POLICY "Parents can insert child daily stats"  ON child_daily_stats FOR INSERT WITH CHECK (is_parent_of(child_id));
CREATE POLICY "Parents can update child daily stats"  ON child_daily_stats FOR UPDATE USING (is_parent_of(child_id));

-- child_weekly_stats
CREATE POLICY "Parents can view child weekly stats"   ON child_weekly_stats FOR SELECT USING (is_parent_of(child_id));
CREATE POLICY "Parents can insert child weekly stats"  ON child_weekly_stats FOR INSERT WITH CHECK (is_parent_of(child_id));
CREATE POLICY "Parents can update child weekly stats"  ON child_weekly_stats FOR UPDATE USING (is_parent_of(child_id));


-- ═════════════════════════════════════════════════════════════
-- BÚIÐ! Keyrðu næst: 03_triggers_og_sjoalfvirkt.sql
-- ═════════════════════════════════════════════════════════════


-- ########## SKREF 3: triggers (03_triggers_og_sjoalfvirkt.sql) ##########

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

DROP TRIGGER IF EXISTS trg_on_auth_user_created ON auth.users;
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

DROP TRIGGER IF EXISTS trg_child_create_defaults ON children;
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

DROP TRIGGER IF EXISTS trg_children_extract_birth_year ON children;
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

DROP TRIGGER IF EXISTS trg_points_ledger_update_child ON points_ledger;
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

DROP TRIGGER IF EXISTS trg_task_status_change ON tasks;
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

DROP TRIGGER IF EXISTS trg_math_session_completed ON math_sessions;
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

DROP TRIGGER IF EXISTS trg_reading_session_completed ON reading_sessions;
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

DROP TRIGGER IF EXISTS trg_ledger_daily_stats ON points_ledger;
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

DROP TRIGGER IF EXISTS trg_daily_stats_streak ON child_daily_stats;
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

DROP TRIGGER IF EXISTS trg_daily_stats_goal_check ON child_daily_stats;
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

DROP TRIGGER IF EXISTS trg_reading_session_text_usage ON reading_sessions;
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


-- ########## SKREF 4: barna innskráning (04_barna_innskraning.sql) ##########

-- ╔═══════════════════════════════════════════════════════════════╗
-- ║  KrakkApp — Skref 4: Barna innskráning + session             ║
-- ║  Keyrðu EFTIR 03_triggers_og_sjoalfvirkt.sql                 ║
-- ║  GILDANDI handkeyrsluskrá: breyttu OG keyrðu hér í þessari    ║
-- ║  möppu (SQL sem er inná supabase).                            ║
-- ╚═══════════════════════════════════════════════════════════════╝
--
-- Þetta skref:
-- 1) Kveikir á pgcrypto (bcrypt hash fyrir barna-lykilorð)
-- 2) Bætir við dálkum: children.login_username, children.password_hash
-- 3) Býr til child_auth_sessions (token eftir innskráningu)
-- 4) krakkapp_child_login(notendanafn, lykilorð) — fyrir anon (barn)
-- 5) krakkapp_parent_create_child(nafn, notendanafn, lykilorð [, birtingarnafn] [, fæðingardagur]) — authenticated
-- 6) krakkapp_child_session_profile + krakkapp_child_logout
--
-- Ef þú áttir eldri útgáfu með UUID+PIN: keyrðu þessa skrá — hún DROPpar
-- gamla krakkapp_child_login(uuid,text) og setur nýja föll.

CREATE EXTENSION IF NOT EXISTS pgcrypto;

-- ─────────────────────────────────────────────────────────────
-- A) Dálkar á children
-- ─────────────────────────────────────────────────────────────
ALTER TABLE public.children
  ADD COLUMN IF NOT EXISTS login_username TEXT;

ALTER TABLE public.children
  ADD COLUMN IF NOT EXISTS password_hash TEXT;

CREATE UNIQUE INDEX IF NOT EXISTS idx_children_login_username_lower
  ON public.children (lower(login_username))
  WHERE login_username IS NOT NULL;

-- ─────────────────────────────────────────────────────────────
-- B) Session tafla
-- ─────────────────────────────────────────────────────────────
CREATE TABLE IF NOT EXISTS public.child_auth_sessions (
  id          UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  child_id    UUID NOT NULL REFERENCES public.children(id) ON DELETE CASCADE,
  token       TEXT NOT NULL UNIQUE,
  expires_at  TIMESTAMPTZ NOT NULL,
  created_at  TIMESTAMPTZ NOT NULL DEFAULT now()
);

CREATE INDEX IF NOT EXISTS idx_child_auth_sessions_token
  ON public.child_auth_sessions(token);

CREATE INDEX IF NOT EXISTS idx_child_auth_sessions_expires
  ON public.child_auth_sessions(expires_at);

ALTER TABLE public.child_auth_sessions ENABLE ROW LEVEL SECURITY;

-- ─────────────────────────────────────────────────────────────
-- C) Fjarlægja gömul login-föll (UUID + PIN) ef til
-- ─────────────────────────────────────────────────────────────
DROP FUNCTION IF EXISTS public.krakkapp_child_login(UUID, TEXT);

-- ─────────────────────────────────────────────────────────────
-- D) Barn skráir sig inn: notendanafn + lykilorð
-- ─────────────────────────────────────────────────────────────
CREATE OR REPLACE FUNCTION public.krakkapp_child_login(p_username TEXT, p_password TEXT)
RETURNS JSONB
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
DECLARE
  v_child public.children%ROWTYPE;
  v_token TEXT;
BEGIN
  IF p_username IS NULL OR length(trim(p_username)) < 2 THEN
    RETURN jsonb_build_object('ok', false, 'error', 'invalid_username');
  END IF;

  IF p_password IS NULL OR length(trim(p_password)) < 1 THEN
    RETURN jsonb_build_object('ok', false, 'error', 'invalid_password');
  END IF;

  SELECT * INTO v_child
  FROM public.children c
  WHERE lower(trim(c.login_username)) = lower(trim(p_username))
    AND c.is_active = true
    AND c.password_hash IS NOT NULL;

  IF NOT FOUND THEN
    RETURN jsonb_build_object('ok', false, 'error', 'invalid_credentials');
  END IF;

  IF v_child.password_hash <> crypt(trim(p_password), v_child.password_hash) THEN
    RETURN jsonb_build_object('ok', false, 'error', 'invalid_credentials');
  END IF;

  DELETE FROM public.child_auth_sessions WHERE child_id = v_child.id;

  v_token := encode(gen_random_bytes(24), 'hex');

  INSERT INTO public.child_auth_sessions (child_id, token, expires_at)
  VALUES (v_child.id, v_token, now() + interval '30 days');

  RETURN jsonb_build_object(
    'ok', true,
    'token', v_token,
    'child', jsonb_build_object(
      'id', v_child.id,
      'first_name', v_child.first_name,
      'display_name', v_child.display_name,
      'login_username', v_child.login_username,
      'available_points', v_child.available_points,
      'current_streak_days', v_child.current_streak_days
    )
  );
END;
$$;

REVOKE ALL ON FUNCTION public.krakkapp_child_login(TEXT, TEXT) FROM PUBLIC;
GRANT EXECUTE ON FUNCTION public.krakkapp_child_login(TEXT, TEXT) TO anon, authenticated;

-- ─────────────────────────────────────────────────────────────
-- E) Foreldri býr til barn (nafn + notendanafn + lykilorð)
-- ─────────────────────────────────────────────────────────────
-- Nauðsynleg fyrst, valfrjálst síðast (DEFAULT NULL) svo PostgREST geti sleppt lyklum í RPC-kalli.
CREATE OR REPLACE FUNCTION public.krakkapp_parent_create_child(
  p_first_name TEXT,
  p_login_username TEXT,
  p_password TEXT,
  p_display_name TEXT DEFAULT NULL,
  p_birth_date DATE DEFAULT NULL
)
RETURNS JSONB
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
DECLARE
  v_id UUID;
  v_uname TEXT;
BEGIN
  IF auth.uid() IS NULL THEN
    RETURN jsonb_build_object('ok', false, 'error', 'not_authenticated');
  END IF;

  IF p_first_name IS NULL OR length(trim(p_first_name)) < 1 THEN
    RETURN jsonb_build_object('ok', false, 'error', 'missing_name');
  END IF;

  v_uname := lower(trim(p_login_username));
  IF length(v_uname) < 3 THEN
    RETURN jsonb_build_object('ok', false, 'error', 'username_too_short');
  END IF;

  IF p_password IS NULL OR length(trim(p_password)) < 6 THEN
    RETURN jsonb_build_object('ok', false, 'error', 'password_too_short');
  END IF;

  INSERT INTO public.children (
    parent_id,
    first_name,
    display_name,
    login_username,
    password_hash,
    birth_date,
    pin_code
  )
  VALUES (
    auth.uid(),
    trim(p_first_name),
    CASE
      WHEN p_display_name IS NULL THEN NULL
      ELSE NULLIF(trim(p_display_name), '')
    END,
    v_uname,
    crypt(trim(p_password), gen_salt('bf')),
    p_birth_date,
    NULL
  )
  RETURNING id INTO v_id;

  RETURN jsonb_build_object('ok', true, 'child_id', v_id);
EXCEPTION
  WHEN unique_violation THEN
    RETURN jsonb_build_object('ok', false, 'error', 'username_taken');
END;
$$;

REVOKE ALL ON FUNCTION public.krakkapp_parent_create_child(TEXT, TEXT, TEXT, TEXT, DATE) FROM PUBLIC;
GRANT EXECUTE ON FUNCTION public.krakkapp_parent_create_child(TEXT, TEXT, TEXT, TEXT, DATE) TO authenticated;

-- ─────────────────────────────────────────────────────────────
-- F) Session profile (óbreytt)
-- ─────────────────────────────────────────────────────────────
CREATE OR REPLACE FUNCTION public.krakkapp_child_session_profile(p_token TEXT)
RETURNS JSONB
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
DECLARE
  v_child public.children%ROWTYPE;
BEGIN
  IF p_token IS NULL OR length(p_token) < 16 THEN
    RETURN jsonb_build_object('ok', false);
  END IF;

  SELECT c.* INTO v_child
  FROM public.children c
  INNER JOIN public.child_auth_sessions s ON s.child_id = c.id
  WHERE s.token = p_token
    AND s.expires_at > now()
    AND c.is_active = true;

  IF NOT FOUND THEN
    RETURN jsonb_build_object('ok', false);
  END IF;

  RETURN jsonb_build_object(
    'ok', true,
    'child', jsonb_build_object(
      'id', v_child.id,
      'first_name', v_child.first_name,
      'display_name', v_child.display_name,
      'login_username', v_child.login_username,
      'available_points', v_child.available_points,
      'current_streak_days', v_child.current_streak_days
    )
  );
END;
$$;

REVOKE ALL ON FUNCTION public.krakkapp_child_session_profile(TEXT) FROM PUBLIC;
GRANT EXECUTE ON FUNCTION public.krakkapp_child_session_profile(TEXT) TO anon, authenticated;

-- ─────────────────────────────────────────────────────────────
-- G) Logout
-- ─────────────────────────────────────────────────────────────
CREATE OR REPLACE FUNCTION public.krakkapp_child_logout(p_token TEXT)
RETURNS JSONB
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
BEGIN
  DELETE FROM public.child_auth_sessions WHERE token = p_token;
  RETURN jsonb_build_object('ok', true);
END;
$$;

REVOKE ALL ON FUNCTION public.krakkapp_child_logout(TEXT) FROM PUBLIC;
GRANT EXECUTE ON FUNCTION public.krakkapp_child_logout(TEXT) TO anon, authenticated;
