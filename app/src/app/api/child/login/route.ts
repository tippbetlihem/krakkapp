import { NextResponse } from "next/server";
import { cookies } from "next/headers";
import { createAnonClient } from "@/lib/supabase/anon";
import { CHILD_SESSION_COOKIE } from "@/lib/child/session";

type LoginRpcResult = {
  ok?: boolean;
  error?: string;
  token?: string;
};

const COOKIE_MAX_AGE = 60 * 60 * 24 * 30;

export async function POST(request: Request) {
  let body: { username?: string; password?: string };
  try {
    body = await request.json();
  } catch {
    return NextResponse.json({ error: "invalid_json" }, { status: 400 });
  }

  const username = typeof body.username === "string" ? body.username.trim() : "";
  const password = typeof body.password === "string" ? body.password : "";

  if (!username || !password) {
    return NextResponse.json({ error: "missing_fields" }, { status: 400 });
  }

  const supabase = createAnonClient();
  const { data, error } = await supabase.rpc("krakkapp_child_login", {
    p_username: username,
    p_password: password,
  });

  if (error) {
    const msg = error.message ?? "";
    const missingFn =
      /function .* does not exist|Could not find the function/i.test(msg) ||
      msg.includes("PGRST202");
    return NextResponse.json(
      {
        error: "rpc_error",
        message: error.message,
        hint: missingFn
          ? "Keyrðu SQL sem er inná supabase/04_barna_innskraning.sql í Supabase (krakkapp_child_login með notendanafni)."
          : undefined,
      },
      { status: 500 }
    );
  }

  const result = data as LoginRpcResult;
  if (!result?.ok || !result.token) {
    return NextResponse.json(
      { error: result?.error ?? "invalid_credentials" },
      { status: 401 }
    );
  }

  const jar = await cookies();
  jar.set(CHILD_SESSION_COOKIE, result.token, {
    httpOnly: true,
    sameSite: "lax",
    secure: process.env.NODE_ENV === "production",
    path: "/",
    maxAge: COOKIE_MAX_AGE,
  });

  return NextResponse.json({ ok: true });
}
