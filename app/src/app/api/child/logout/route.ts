import { type NextRequest, NextResponse } from "next/server";
import { cookies } from "next/headers";
import { createAnonClient } from "@/lib/supabase/anon";
import { CHILD_SESSION_COOKIE } from "@/lib/child/session";

export async function POST(request: NextRequest) {
  const jar = await cookies();
  const token = jar.get(CHILD_SESSION_COOKIE)?.value;

  if (token) {
    const supabase = createAnonClient();
    await supabase.rpc("krakkapp_child_logout", { p_token: token });
  }

  jar.set(CHILD_SESSION_COOKIE, "", { path: "/", maxAge: 0 });

  return NextResponse.redirect(new URL("/child/login", request.url));
}
