-- =============================================================
-- KrakkApp Migration 001: Shared utility function
-- Auto-update updated_at column on row modification
-- =============================================================

CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = now();
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;
