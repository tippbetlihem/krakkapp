-- =============================================================
-- KrakkApp Migration 003: Configuration
-- Tables: child_math_settings, child_reading_settings
-- =============================================================

-- ----- child_math_settings -----
CREATE TABLE child_math_settings (
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
    time_limit_seconds          INTEGER,
    points_per_correct_answer   INTEGER NOT NULL DEFAULT 1,
    points_per_wrong_answer     INTEGER NOT NULL DEFAULT 0,
    show_timer_to_child         BOOLEAN NOT NULL DEFAULT false,
    created_at                  TIMESTAMPTZ NOT NULL DEFAULT now(),
    updated_at                  TIMESTAMPTZ NOT NULL DEFAULT now(),

    CONSTRAINT chk_math_number_range CHECK (min_number <= max_number),
    CONSTRAINT chk_math_question_count CHECK (question_count > 0)
);

CREATE TRIGGER trg_child_math_settings_updated_at
    BEFORE UPDATE ON child_math_settings
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

-- ----- child_reading_settings -----
CREATE TABLE child_reading_settings (
    id                          UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    child_id                    UUID NOT NULL UNIQUE REFERENCES children(id) ON DELETE RESTRICT,
    difficulty_level            TEXT NOT NULL DEFAULT 'beginner'
                                    CHECK (difficulty_level IN ('beginner', 'elementary', 'intermediate', 'advanced')),
    min_word_count              INTEGER,
    max_word_count              INTEGER,
    points_per_session          INTEGER NOT NULL DEFAULT 10,
    accuracy_threshold_percent  INTEGER NOT NULL DEFAULT 80
                                    CHECK (accuracy_threshold_percent BETWEEN 0 AND 100),
    show_accuracy_to_child      BOOLEAN NOT NULL DEFAULT false,
    created_at                  TIMESTAMPTZ NOT NULL DEFAULT now(),
    updated_at                  TIMESTAMPTZ NOT NULL DEFAULT now()
);

CREATE TRIGGER trg_child_reading_settings_updated_at
    BEFORE UPDATE ON child_reading_settings
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
