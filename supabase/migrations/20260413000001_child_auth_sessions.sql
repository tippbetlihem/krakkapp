-- =============================================================
-- Barna-innskráning: session token í gagnagrunni (án service role)
-- PIN samanburður við children.pin_code
-- =============================================================

CREATE TABLE public.child_auth_sessions (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  child_id uuid NOT NULL REFERENCES public.children(id) ON DELETE CASCADE,
  token text NOT NULL UNIQUE,
  expires_at timestamptz NOT NULL,
  created_at timestamptz NOT NULL DEFAULT now()
);

CREATE INDEX idx_child_auth_sessions_token ON public.child_auth_sessions(token);
CREATE INDEX idx_child_auth_sessions_expires ON public.child_auth_sessions(expires_at);

ALTER TABLE public.child_auth_sessions ENABLE ROW LEVEL SECURITY;

-- Engar policies: enginn beinn aðgangur nema í gegnum SECURITY DEFINER föll

CREATE OR REPLACE FUNCTION public.krakkapp_child_login(p_child_id uuid, p_pin text)
RETURNS jsonb
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
DECLARE
  v_child public.children%ROWTYPE;
  v_token text;
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
      'available_points', v_child.available_points,
      'current_streak_days', v_child.current_streak_days
    )
  );
END;
$$;

REVOKE ALL ON FUNCTION public.krakkapp_child_login(uuid, text) FROM PUBLIC;
GRANT EXECUTE ON FUNCTION public.krakkapp_child_login(uuid, text) TO anon, authenticated;

CREATE OR REPLACE FUNCTION public.krakkapp_child_session_profile(p_token text)
RETURNS jsonb
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

REVOKE ALL ON FUNCTION public.krakkapp_child_session_profile(text) FROM PUBLIC;
GRANT EXECUTE ON FUNCTION public.krakkapp_child_session_profile(text) TO anon, authenticated;

CREATE OR REPLACE FUNCTION public.krakkapp_child_logout(p_token text)
RETURNS jsonb
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
BEGIN
  DELETE FROM public.child_auth_sessions WHERE token = p_token;
  RETURN jsonb_build_object('ok', true);
END;
$$;

REVOKE ALL ON FUNCTION public.krakkapp_child_logout(text) FROM PUBLIC;
GRANT EXECUTE ON FUNCTION public.krakkapp_child_logout(text) TO anon, authenticated;
