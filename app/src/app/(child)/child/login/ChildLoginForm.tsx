"use client";

import { useState, useEffect, Suspense } from "react";
import Link from "next/link";
import { useRouter, useSearchParams } from "next/navigation";
import { Sparkles } from "lucide-react";

function ChildLoginFormInner() {
  const router = useRouter();
  const searchParams = useSearchParams();
  const [childId, setChildId] = useState("");
  const [pin, setPin] = useState("");
  const [error, setError] = useState("");
  const [loading, setLoading] = useState(false);

  useEffect(() => {
    const q = searchParams.get("child");
    if (q) setChildId(q.trim());
  }, [searchParams]);

  async function handleSubmit(e: React.FormEvent) {
    e.preventDefault();
    setError("");
    setLoading(true);

    const res = await fetch("/api/child/login", {
      method: "POST",
      headers: { "Content-Type": "application/json" },
      body: JSON.stringify({ childId: childId.trim(), pin: pin.trim() }),
    });

    setLoading(false);

    if (!res.ok) {
      const body = await res.json().catch(() => ({}));
      if (body.error === "invalid_credentials" || body.error === "invalid_pin") {
        setError("Rangt barna-ID eða PIN. Athugaðu með foreldri.");
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
          <label htmlFor="childId" className="mb-1 block text-xs font-semibold text-neutral-600">
            Barna-ID
          </label>
          <input
            id="childId"
            type="text"
            autoComplete="off"
            placeholder="Afritað frá foreldri"
            value={childId}
            onChange={(e) => setChildId(e.target.value)}
            className="w-full rounded-xl border border-neutral-200 bg-neutral-50 px-3 py-2.5 text-sm outline-none focus:border-evergreen-400 focus:ring-2 focus:ring-evergreen-100"
            required
          />
          <p className="mt-1 text-[11px] text-neutral-400">
            Foreldrið sýnir þetta í „Börn“ í foreldragátt.
          </p>
        </div>

        <div>
          <label htmlFor="pin" className="mb-1 block text-xs font-semibold text-neutral-600">
            PIN-númer
          </label>
          <input
            id="pin"
            type="password"
            inputMode="numeric"
            autoComplete="one-time-code"
            placeholder="A.m.k. 4 stafir"
            value={pin}
            onChange={(e) => setPin(e.target.value)}
            className="w-full rounded-xl border border-neutral-200 bg-neutral-50 px-3 py-2.5 text-sm outline-none focus:border-evergreen-400 focus:ring-2 focus:ring-evergreen-100"
            required
            minLength={4}
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
    <Suspense fallback={<div className="mx-auto max-w-sm animate-pulse rounded-3xl bg-white/60 p-6 h-64" />}>
      <ChildLoginFormInner />
    </Suspense>
  );
}
