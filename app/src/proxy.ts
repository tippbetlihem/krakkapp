import { NextResponse, type NextRequest } from "next/server";
import { createServerClient } from "@supabase/ssr";

export async function proxy(request: NextRequest) {
  let supabaseResponse = NextResponse.next({ request });

  const supabase = createServerClient(
    process.env.NEXT_PUBLIC_SUPABASE_URL!,
    process.env.NEXT_PUBLIC_SUPABASE_ANON_KEY!,
    {
      cookies: {
        getAll() {
          return request.cookies.getAll();
        },
        setAll(cookiesToSet) {
          cookiesToSet.forEach(({ name, value }) =>
            request.cookies.set(name, value)
          );
          supabaseResponse = NextResponse.next({ request });
          cookiesToSet.forEach(({ name, value, options }) =>
            supabaseResponse.cookies.set(name, value, options)
          );
        },
      },
    }
  );

  const {
    data: { user },
  } = await supabase.auth.getUser();

  const { pathname } = request.nextUrl;
  const childToken = request.cookies.get("krakkapp_child_token")?.value;
  const hasChildSession = Boolean(childToken && childToken.length >= 16);

  // Aðeins `/child` og `/child/...` — EKKI `/children` (foreldra-síða)
  const isChildAppPath =
    pathname === "/child" || pathname.startsWith("/child/");

  if (pathname === "/child") {
    const url = request.nextUrl.clone();
    url.pathname = hasChildSession ? "/child/home" : "/child/login";
    return NextResponse.redirect(url);
  }

  if (isChildAppPath && !pathname.startsWith("/child/login")) {
    if (!hasChildSession) {
      const url = request.nextUrl.clone();
      url.pathname = "/child/login";
      return NextResponse.redirect(url);
    }
  }

  if (user && ["/login", "/signup", "/forgot-password"].includes(pathname)) {
    const url = request.nextUrl.clone();
    url.pathname = "/dashboard";
    return NextResponse.redirect(url);
  }

  const protectedPrefixes = ["/dashboard", "/children", "/tasks", "/rewards", "/settings"];
  if (!user && protectedPrefixes.some((p) => pathname.startsWith(p))) {
    const url = request.nextUrl.clone();
    url.pathname = "/login";
    return NextResponse.redirect(url);
  }

  return supabaseResponse;
}

export const config = {
  matcher: [
    "/dashboard/:path*",
    "/children",
    "/children/:path*",
    "/tasks/:path*",
    "/rewards/:path*",
    "/settings/:path*",
    "/login",
    "/signup",
    "/forgot-password",
    "/child",
    "/child/:path*",
  ],
};
