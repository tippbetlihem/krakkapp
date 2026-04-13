-- Samræmi við SQL sem er inná supabase/04_barna_innskraning.sql:
-- krakkapp_parent_create_child með valfrjálsum síðustu tveimur færibreytum (DEFAULT NULL)
-- svo PostgREST finni fallið þegar valfrjálsir lyklar vantar í RPC-kalli.

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
