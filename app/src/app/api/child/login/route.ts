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

const UUID_RE =
  /^[0-9a-f]{8}-[0-9a-f]{4}-[1-5][0-9a-f]{3}-[89ab][0-9a-f]{3}-[0-9a-f]{12}$/i;

function isValidChildUuid(value: string): boolean {
  return UUID_RE.test(value);
}

export async function POST(request: Request) {
  let body: { childId?: string; pin?: string };
  try {
    body = await request.json();
  } catch {
    return NextResponse.json({ error: "invalid_json" }, { status: 400 });
  }

  const childId = typeof body.childId === "string" ? body.childId.trim() : "";
  const pin = typeof body.pin === "string" ? body.pin.trim() : "";

  if (!childId || !pin) {
    return NextResponse.json({ error: "missing_fields" }, { status: 400 });
  }

  if (!isValidChildUuid(childId)) {
    return NextResponse.json(
      {
        error: "invalid_child_id",
        hint: "Notaðu ekki nafn barns — afritaðu langa kóðann (UUID) undir „Börn“ í foreldragátt.",
      },
      { status: 400 }
    );
  }

  const supabase = createAnonClient();
  const { data, error } = await supabase.rpc("krakkapp_child_login", {
    p_child_id: childId,
    p_pin: pin,
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
          ? "Keyrðu SQL-skrána 04_barna_innskraning.sql í Supabase (föllin krakkapp_child_*)."
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
