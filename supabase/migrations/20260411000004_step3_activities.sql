-- =============================================================
-- KrakkApp Migration 004: Activity Tables
-- Tables: tasks, math_sessions, math_session_questions,
--         reading_texts, child_favorite_texts, reading_sessions
-- =============================================================

-- ----- tasks -----
CREATE TABLE tasks (
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
    parent_feedback         TEXT,
    completion_time_seconds INTEGER
);

CREATE TRIGGER trg_tasks_updated_at
    BEFORE UPDATE ON tasks
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

-- ----- math_sessions -----
CREATE TABLE math_sessions (
    id                  UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    child_id            UUID NOT NULL REFERENCES children(id) ON DELETE RESTRICT,
    settings_snapshot   JSONB NOT NULL,
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

-- ----- math_session_questions -----
CREATE TABLE math_session_questions (
    id                UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    math_session_id   UUID NOT NULL REFERENCES math_sessions(id) ON DELETE CASCADE,
    question_order    INTEGER NOT NULL,
    operand_1         INTEGER NOT NULL,
    operand_2         INTEGER NOT NULL,
    operator          TEXT NOT NULL CHECK (operator IN ('+', '-', '*', '/')),
    correct_answer    NUMERIC(10,4) NOT NULL,
    child_answer      NUMERIC(10,4),
    is_correct        BOOLEAN,
    is_skipped        BOOLEAN NOT NULL DEFAULT false,
    points_earned     INTEGER NOT NULL DEFAULT 0,
    response_time_ms  INTEGER,
    attempt_number    INTEGER NOT NULL DEFAULT 1,
    created_at        TIMESTAMPTZ NOT NULL DEFAULT now()
);

-- ----- reading_texts -----
CREATE TABLE reading_texts (
    id                  UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    title               TEXT NOT NULL,
    text_content        TEXT NOT NULL,
    language            TEXT NOT NULL DEFAULT 'is',
    difficulty_level    TEXT NOT NULL DEFAULT 'beginner'
                            CHECK (difficulty_level IN ('beginner', 'elementary', 'intermediate', 'advanced')),
    word_count          INTEGER NOT NULL,
    age_min             INTEGER,
    age_max             INTEGER,
    topic               TEXT,
    is_system_text      BOOLEAN NOT NULL DEFAULT true,
    is_active           BOOLEAN NOT NULL DEFAULT true,
    created_by_parent_id UUID REFERENCES profiles(id),
    times_used          INTEGER NOT NULL DEFAULT 0,
    created_at          TIMESTAMPTZ NOT NULL DEFAULT now(),
    updated_at          TIMESTAMPTZ NOT NULL DEFAULT now()
);

-- ----- child_favorite_texts -----
CREATE TABLE child_favorite_texts (
    id                  UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    child_id            UUID NOT NULL REFERENCES children(id) ON DELETE RESTRICT,
    reading_text_id     UUID NOT NULL REFERENCES reading_texts(id) ON DELETE RESTRICT,
    created_by_parent_id UUID NOT NULL REFERENCES profiles(id),
    created_at          TIMESTAMPTZ NOT NULL DEFAULT now(),

    UNIQUE (child_id, reading_text_id)
);

-- ----- reading_sessions -----
CREATE TABLE reading_sessions (
    id                      UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    child_id                UUID NOT NULL REFERENCES children(id) ON DELETE RESTRICT,
    reading_text_id         UUID NOT NULL REFERENCES reading_texts(id) ON DELETE RESTRICT,
    assigned_text_snapshot  TEXT NOT NULL,
    spoken_text             TEXT,
    word_count              INTEGER NOT NULL,
    words_correct_count     INTEGER NOT NULL DEFAULT 0,
    words_incorrect_count   INTEGER NOT NULL DEFAULT 0,
    words_skipped_count     INTEGER NOT NULL DEFAULT 0,
    accuracy_percent        NUMERIC(5,2),
    threshold_met           BOOLEAN NOT NULL DEFAULT false,
    base_points_earned      INTEGER NOT NULL DEFAULT 0,
    bonus_multiplier        NUMERIC(4,2) NOT NULL DEFAULT 1.0,
    final_points_earned     INTEGER NOT NULL DEFAULT 0,
    started_at              TIMESTAMPTZ NOT NULL DEFAULT now(),
    completed_at            TIMESTAMPTZ,
    duration_seconds        INTEGER,
    status                  TEXT NOT NULL DEFAULT 'started'
                                CHECK (status IN ('started', 'completed', 'abandoned', 'review_needed')),
    settings_snapshot       JSONB NOT NULL,
    audio_file_url          TEXT,
    speech_engine           TEXT,
    review_notes            TEXT,
    parent_reviewed         BOOLEAN NOT NULL DEFAULT false
);

CREATE TRIGGER trg_reading_texts_updated_at
    BEFORE UPDATE ON reading_texts
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
