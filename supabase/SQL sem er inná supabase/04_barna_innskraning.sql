-- ╔═══════════════════════════════════════════════════════════════╗
-- ║  KrakkApp — Skref 4: Barna innskráning (PIN + session token) ║
-- ║  Keyrðu EFTIR 03_triggers_og_sjoalfvirkt.sql                 ║
-- ╚═══════════════════════════════════════════════════════════════╝

-- Hvað þetta skref gerir:
-- 1) Býr til töflu fyrir barna-session token (child_auth_sessions)
-- 2) Bætir við SECURITY DEFINER föllum fyrir login/profile/logout
-- 3) Veitir execute réttindi á föllin fyrir anon/authenticated
--
-- ATH:
-- - Þetta skref notar children.pin_code eins og hann er geymdur í dag.
-- - PIN er því borinn saman beint við gildi í children.pin_code.
-- - Seinna er hægt að færa þetta yfir í hashed PIN ef óskað er.

-- ─────────────────────────────────────────────────────────────
-- A) Session tafla fyrir börn
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

-- Engar direct RLS policies: aðgangur er í gegnum föllin hér fyrir neðan.


-- ─────────────────────────────────────────────────────────────
-- B) Login fall: staðfestir child_id + pin og býr til session token
-- ─────────────────────────────────────────────────────────────
CREATE OR REPLACE FUNCTION public.krakkapp_child_login(p_child_id UUID, p_pin TEXT)
RETURNS JSONB
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
DECLARE
    v_child public.children%ROWTYPE;
    v_token TEXT;
BEGIN
    IF p_pin IS NULL OR length(trim(p_pin)) < 4 THEN
        RETURN jsonb_build_object('ok', false, 'error', 'invalid_pin');
    END IF;

    SELECT * INTO v_child
    FROM public.children c
    WHERE c.id = p_child_id
      AND c.is_active = true
      AND c.pin_code IS NOT NULL
      AND length(trim(c.pin_code)) >= 4
      AND c.pin_code = p_pin;

    IF NOT FOUND THEN
        RETURN jsonb_build_object('ok', false, 'error', 'invalid_credentials');
    END IF;

    -- Hreinsum eldri session fyrir sama barn
    DELETE FROM public.child_auth_sessions
    WHERE child_id = v_child.id;

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
            'available_points', v_child.available_points,
            'current_streak_days', v_child.current_streak_days
        )
    );
END;
$$;

REVOKE ALL ON FUNCTION public.krakkapp_child_login(UUID, TEXT) FROM PUBLIC;
GRANT EXECUTE ON FUNCTION public.krakkapp_child_login(UUID, TEXT) TO anon, authenticated;


-- ─────────────────────────────────────────────────────────────
-- C) Session profile fall: skilar barni út frá token
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
            'available_points', v_child.available_points,
            'current_streak_days', v_child.current_streak_days
        )
    );
END;
$$;

REVOKE ALL ON FUNCTION public.krakkapp_child_session_profile(TEXT) FROM PUBLIC;
GRANT EXECUTE ON FUNCTION public.krakkapp_child_session_profile(TEXT) TO anon, authenticated;


-- ─────────────────────────────────────────────────────────────
-- D) Logout fall: eyðir session token
-- ─────────────────────────────────────────────────────────────
CREATE OR REPLACE FUNCTION public.krakkapp_child_logout(p_token TEXT)
RETURNS JSONB
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
BEGIN
    DELETE FROM public.child_auth_sessions
    WHERE token = p_token;

    RETURN jsonb_build_object('ok', true);
END;
$$;

REVOKE ALL ON FUNCTION public.krakkapp_child_logout(TEXT) FROM PUBLIC;
GRANT EXECUTE ON FUNCTION public.krakkapp_child_logout(TEXT) TO anon, authenticated;

