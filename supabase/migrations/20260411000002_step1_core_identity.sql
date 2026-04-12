-- =============================================================
-- KrakkApp Migration 002: Core Identity & Auth
-- Tables: profiles, children, child_settings
-- =============================================================

-- ----- profiles -----
CREATE TABLE profiles (
    id          UUID PRIMARY KEY REFERENCES auth.users(id) ON DELETE RESTRICT,
    email       TEXT NOT NULL UNIQUE,
    full_name   TEXT,
    avatar_url  TEXT,
    role        TEXT NOT NULL DEFAULT 'parent',
    created_at  TIMESTAMPTZ NOT NULL DEFAULT now(),
    updated_at  TIMESTAMPTZ NOT NULL DEFAULT now(),
    last_login_at TIMESTAMPTZ
);

CREATE TRIGGER trg_profiles_updated_at
    BEFORE UPDATE ON profiles
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

-- ----- children -----
CREATE TABLE children (
    id                              UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    parent_id                       UUID NOT NULL REFERENCES profiles(id) ON DELETE RESTRICT,
    first_name                      TEXT NOT NULL,
    display_name                    TEXT,
    birth_year                      SMALLINT,
    birth_date                      DATE,
    avatar_url                      TEXT,
    pin_code                        TEXT,
    is_active                       BOOLEAN NOT NULL DEFAULT true,
    created_at                      TIMESTAMPTZ NOT NULL DEFAULT now(),
    updated_at                      TIMESTAMPTZ NOT NULL DEFAULT now(),
    total_points                    INTEGER NOT NULL DEFAULT 0,
    available_points                INTEGER NOT NULL DEFAULT 0,
    lifetime_points                 INTEGER NOT NULL DEFAULT 0,
    completed_tasks_count           INTEGER NOT NULL DEFAULT 0,
    completed_math_sessions_count   INTEGER NOT NULL DEFAULT 0,
    completed_reading_sessions_count INTEGER NOT NULL DEFAULT 0,
    last_activity_at                TIMESTAMPTZ,
    current_streak_days             INTEGER NOT NULL DEFAULT 0,
    longest_streak_days             INTEGER NOT NULL DEFAULT 0
);

CREATE TRIGGER trg_children_updated_at
    BEFORE UPDATE ON children
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

-- ----- child_settings -----
CREATE TABLE child_settings (
    id                  UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    child_id            UUID NOT NULL UNIQUE REFERENCES children(id) ON DELETE RESTRICT,
    daily_points_goal   INTEGER,
    weekly_points_goal  INTEGER,
    math_enabled        BOOLEAN NOT NULL DEFAULT true,
    reading_enabled     BOOLEAN NOT NULL DEFAULT true,
    tasks_enabled       BOOLEAN NOT NULL DEFAULT true,
    rewards_enabled     BOOLEAN NOT NULL DEFAULT true,
    created_at          TIMESTAMPTZ NOT NULL DEFAULT now(),
    updated_at          TIMESTAMPTZ NOT NULL DEFAULT now()
);

CREATE TRIGGER trg_child_settings_updated_at
    BEFORE UPDATE ON child_settings
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
