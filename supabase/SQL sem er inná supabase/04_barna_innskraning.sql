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
