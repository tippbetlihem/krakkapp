-- =============================================================
-- KrakkApp Migration 008: Auto-setup Triggers
-- - Create profile on new auth.users signup
-- - Create child_settings, child_math_settings,
--   child_reading_settings when a child is inserted
-- - Extract birth_year from birth_date automatically
-- =============================================================

-- ===================== NEW USER → PROFILE =====================

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

-- ===================== NEW CHILD → DEFAULT SETTINGS =====================

CREATE OR REPLACE FUNCTION fn_create_child_defaults()
RETURNS TRIGGER AS $$
BEGIN
    INSERT INTO child_settings (child_id)
    VALUES (NEW.id);

    INSERT INTO child_math_settings (child_id)
    VALUES (NEW.id);

    INSERT INTO child_reading_settings (child_id)
    VALUES (NEW.id);

    RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

CREATE TRIGGER trg_child_create_defaults
    AFTER INSERT ON children
    FOR EACH ROW EXECUTE FUNCTION fn_create_child_defaults();

-- ===================== BIRTH_YEAR FROM BIRTH_DATE =====================

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
