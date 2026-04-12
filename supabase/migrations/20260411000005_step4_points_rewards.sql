-- =============================================================
-- KrakkApp Migration 005: Points & Rewards
-- Tables: point_multipliers, points_ledger, rewards,
--         reward_redemptions
-- Triggers: points_ledger → update children point counters
-- =============================================================

-- ----- point_multipliers -----
CREATE TABLE point_multipliers (
    id               UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    parent_id        UUID NOT NULL REFERENCES profiles(id) ON DELETE RESTRICT,
    child_id         UUID REFERENCES children(id) ON DELETE RESTRICT,
    activity_type    TEXT NOT NULL DEFAULT 'all'
                         CHECK (activity_type IN ('math', 'reading', 'task', 'all')),
    multiplier_value NUMERIC(4,2) NOT NULL,
    title            TEXT NOT NULL,
    reason           TEXT,
    starts_at        TIMESTAMPTZ NOT NULL,
    ends_at          TIMESTAMPTZ NOT NULL,
    is_active        BOOLEAN NOT NULL DEFAULT true,
    created_at       TIMESTAMPTZ NOT NULL DEFAULT now(),

    CONSTRAINT chk_multiplier_date_range CHECK (starts_at < ends_at),
    CONSTRAINT chk_multiplier_positive CHECK (multiplier_value > 0)
);

-- ----- points_ledger -----
CREATE TABLE points_ledger (
    id                  UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    child_id            UUID NOT NULL REFERENCES children(id) ON DELETE RESTRICT,
    source_type         TEXT NOT NULL
                            CHECK (source_type IN (
                                'math_session', 'reading_session', 'task',
                                'reward_redemption', 'manual_adjustment', 'bonus'
                            )),
    source_id           UUID,
    base_points         INTEGER NOT NULL,
    multiplier_applied  NUMERIC(4,2) NOT NULL DEFAULT 1.0,
    bonus_points        INTEGER NOT NULL DEFAULT 0,
    final_points        INTEGER NOT NULL,
    direction           TEXT NOT NULL CHECK (direction IN ('credit', 'debit')),
    description         TEXT NOT NULL,
    created_at          TIMESTAMPTZ NOT NULL DEFAULT now(),
    created_by_parent_id UUID REFERENCES profiles(id)
);

-- Immutable ledger: disallow UPDATE and DELETE via rule
CREATE RULE rule_points_ledger_no_update AS
    ON UPDATE TO points_ledger DO INSTEAD NOTHING;

CREATE RULE rule_points_ledger_no_delete AS
    ON DELETE TO points_ledger DO INSTEAD NOTHING;

-- Trigger: update children point counters after ledger insert
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

-- ----- rewards -----
CREATE TABLE rewards (
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

CREATE TRIGGER trg_rewards_updated_at
    BEFORE UPDATE ON rewards
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

-- ----- reward_redemptions -----
CREATE TABLE reward_redemptions (
    id            UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    reward_id     UUID NOT NULL REFERENCES rewards(id) ON DELETE RESTRICT,
    child_id      UUID NOT NULL REFERENCES children(id) ON DELETE RESTRICT,
    points_spent  INTEGER NOT NULL,
    status        TEXT NOT NULL DEFAULT 'requested'
                      CHECK (status IN ('requested', 'approved', 'rejected', 'fulfilled')),
    requested_at  TIMESTAMPTZ NOT NULL DEFAULT now(),
    reviewed_at   TIMESTAMPTZ,
    reviewed_by   UUID REFERENCES profiles(id),
    parent_note   TEXT
);
