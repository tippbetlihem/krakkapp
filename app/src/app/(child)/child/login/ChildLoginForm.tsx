"use client";

import { useState, useEffect, Suspense } from "react";
import Link from "next/link";
import { useRouter, useSearchParams } from "next/navigation";
import { Sparkles } from "lucide-react";

function ChildLoginFormInner() {
  const router = useRouter();
  const searchParams = useSearchParams();
  const [username, setUsername] = useState("");
  const [password, setPassword] = useState("");
  const [error, setError] = useState("");
  const [loading, setLoading] = useState(false);

  useEffect(() => {
    const u = searchParams.get("u");
    if (u) setUsername(u.trim());
  }, [searchParams]);

  async function handleSubmit(e: React.FormEvent) {
    e.preventDefault();
    setError("");
    const u = username.trim();
    if (u.length < 2) {
      setError("Sláðu inn notendanafn.");
      return;
    }
    if (!password) {
      setError("Sláðu inn lykilorð.");
      return;
    }

    setLoading(true);

    const res = await fetch("/api/child/login", {
      method: "POST",
      headers: { "Content-Type": "application/json" },
      body: JSON.stringify({ username: u, password }),
    });

    setLoading(false);

    if (!res.ok) {
      const body = (await res.json().catch(() => ({}))) as {
        error?: string;
        hint?: string;
        message?: string;
      };
      if (body.error === "invalid_credentials" || body.error === "invalid_username") {
        setError("Rangt notendanafn eða lykilorð.");
      } else if (body.error === "rpc_error") {
        setError(
          body.hint ??
            "Tenging við gagnagrunn virkar ekki. Athugaðu að SQL fyrir barna-innskráningu sé keyrt í Supabase."
        );
      } else {
        setError("Ekki tókst að skrá inn. Reyndu aftur.");
      }
      return;
    }

    router.push("/child/home");
    router.refresh();
  }

  return (
    <div className="mx-auto w-full max-w-sm">
      <div className="mb-8 text-center">
        <div className="mx-auto mb-3 flex h-14 w-14 items-center justify-center rounded-2xl bg-evergreen-500 text-white shadow-md">
          <Sparkles size={28} />
        </div>
        <h1 className="text-2xl font-extrabold text-neutral-900">KrakkApp</h1>
        <p className="mt-1 text-sm text-neutral-500">Innskráning fyrir börn</p>
      </div>

      <form
        onSubmit={handleSubmit}
        className="space-y-4 rounded-3xl border border-neutral-200 bg-white p-6 shadow-sm"
      >
        {error && (
          <p className="rounded-xl bg-error-light px-3 py-2 text-center text-sm text-error">
            {error}
          </p>
        )}

        <div>
          <label htmlFor="child_username" className="mb-1 block text-xs font-semibold text-neutral-600">
            Notendanafn
          </label>
          <input
            id="child_username"
            type="text"
            autoComplete="username"
            placeholder="Sama og foreldrið valdi"
            value={username}
            onChange={(e) => setUsername(e.target.value)}
            className="w-full rounded-xl border border-neutral-200 bg-neutral-50 px-3 py-2.5 font-mono text-sm outline-none focus:border-evergreen-400 focus:ring-2 focus:ring-evergreen-100"
            required
            minLength={2}
            spellCheck={false}
          />
        </div>

        <div>
          <label htmlFor="child_password" className="mb-1 block text-xs font-semibold text-neutral-600">
            Lykilorð
          </label>
          <input
            id="child_password"
            type="password"
            autoComplete="current-password"
            placeholder="Lykilorð barnsins"
            value={password}
            onChange={(e) => setPassword(e.target.value)}
            className="w-full rounded-xl border border-neutral-200 bg-neutral-50 px-3 py-2.5 text-sm outline-none focus:border-evergreen-400 focus:ring-2 focus:ring-evergreen-100"
            required
          />
        </div>

        <button
          type="submit"
          disabled={loading}
          className="w-full rounded-2xl bg-evergreen-500 py-3 text-sm font-bold text-white shadow-sm transition-colors hover:bg-evergreen-600 disabled:cursor-not-allowed disabled:opacity-50"
        >
          {loading ? "Skrái inn…" : "Skrá inn"}
        </button>
      </form>

      <p className="mt-6 text-center text-sm text-neutral-500">
        Foreldri?{" "}
        <Link href="/login" className="font-bold text-evergreen-600 hover:text-evergreen-700">
          Skráðu þig inn hér
        </Link>
      </p>
    </div>
  );
}

export function ChildLoginForm() {
  return (
    <Suspense
      fallback={
        <div className="mx-auto h-64 max-w-sm animate-pulse rounded-3xl bg-white/60 p-6" />
      }
    >
      <ChildLoginFormInner />
    </Suspense>
  );
}
