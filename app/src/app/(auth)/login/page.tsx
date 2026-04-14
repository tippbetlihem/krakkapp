"use client";

import { useState, useEffect, Suspense } from "react";
import Link from "next/link";
import Image from "next/image";
import { useRouter, useSearchParams } from "next/navigation";
import { createClient } from "@/lib/supabase/client";
import { LogIn, Sparkles, ChevronRight } from "lucide-react";

function LoginPageInner() {
  const router = useRouter();
  const searchParams = useSearchParams();
  const [mode, setMode] = useState<"parent" | "child">(
    searchParams.get("mode") === "child" ? "child" : "parent"
  );

  // Parent state
  const [email, setEmail] = useState("");
  const [password, setPassword] = useState("");

  // Child state
  const [username, setUsername] = useState("");
  const [childPassword, setChildPassword] = useState("");

  const [error, setError] = useState("");
  const [loading, setLoading] = useState(false);

  useEffect(() => {
    const u = searchParams.get("u");
    if (u) {
      setUsername(u.trim());
      setMode("child");
    }
  }, [searchParams]);

  async function handleParentLogin(e: React.FormEvent) {
    e.preventDefault();
    setError("");
    setLoading(true);
    const supabase = createClient();
    const { error } = await supabase.auth.signInWithPassword({ email, password });
    if (error) {
      setError("Rangt netfang eda lykilord");
      setLoading(false);
      return;
    }
    router.push("/dashboard");
  }

  async function handleChildLogin(e: React.FormEvent) {
    e.preventDefault();
    setError("");
    const u = username.trim();
    if (u.length < 2) { setError("Slaou inn notendanafn."); return; }
    if (!childPassword) { setError("Slaou inn lykilord."); return; }
    setLoading(true);
    const res = await fetch("/api/child/login", {
      method: "POST",
      headers: { "Content-Type": "application/json" },
      body: JSON.stringify({ username: u, password: childPassword }),
    });
    setLoading(false);
    if (!res.ok) {
      const body = (await res.json().catch(() => ({}))) as { error?: string };
      if (body.error === "invalid_credentials" || body.error === "invalid_username") {
        setError("Rangt notendanafn eda lykilord.");
      } else {
        setError("Ekki tokst ad skra inn. Reyndu aftur.");
      }
      return;
    }
    router.push("/child/home");
    router.refresh();
  }

  function switchMode(newMode: "parent" | "child") {
    setError("");
    setMode(newMode);
  }

  return (
    <div className="min-h-full flex items-center justify-center bg-cream px-4 py-8">
      <div className="w-full max-w-[960px] flex rounded-3xl shadow-[0_20px_60px_rgba(0,0,0,0.08)] overflow-visible bg-white relative">

        {/* Left — Forms */}
        <div className="flex-1 flex flex-col justify-center px-8 py-10 sm:px-12 min-w-0 relative z-20">
          {/* Logo */}
          <div className="mb-8">
            <h1 className="text-2xl font-extrabold text-evergreen-500 tracking-tight">
              Krakk<span className="text-gold-400">App</span>
            </h1>
          </div>

          {/* Mode toggle */}
          <div className="relative mb-8 flex rounded-2xl bg-neutral-100 p-1">
            {/* Sliding indicator */}
            <div
              className={`absolute top-1 bottom-1 w-[calc(50%-4px)] rounded-xl transition-all duration-300 ease-out
                ${mode === "parent"
                  ? "left-1 bg-evergreen-500 shadow-md"
                  : "left-[calc(50%+2px)] bg-gold-400 shadow-md"
                }`}
            />
            <button
              type="button"
              onClick={() => switchMode("parent")}
              className={`relative z-10 flex-1 py-3 text-sm font-bold rounded-xl transition-colors duration-200
                ${mode === "parent" ? "text-white" : "text-neutral-500"}`}
            >
              Foreldri
            </button>
            <button
              type="button"
              onClick={() => switchMode("child")}
              className={`relative z-10 flex-1 py-3 text-sm font-bold rounded-xl transition-colors duration-200
                ${mode === "child" ? "text-neutral-900" : "text-neutral-500"}`}
            >
              Barn
            </button>
          </div>

          {/* Forms container with slide animation */}
          <div className="relative overflow-hidden">
            <div
              className={`flex transition-transform duration-400 ease-out
                ${mode === "child" ? "-translate-x-1/2" : "translate-x-0"}`}
              style={{ width: "200%" }}
            >
              {/* Parent form */}
              <div className="w-1/2 px-1">
                <form onSubmit={handleParentLogin} className="space-y-5">
                  <div>
                    <h2 className="text-xl font-extrabold text-neutral-900">Velkomin!</h2>
                    <p className="text-sm text-neutral-500 mt-1">Skraou thig inn sem foreldri</p>
                  </div>

                  {error && mode === "parent" && (
                    <div className="bg-error-light text-error text-sm px-4 py-3 rounded-2xl">{error}</div>
                  )}

                  <div>
                    <label className="block text-sm font-semibold text-neutral-700 mb-2">Netfang</label>
                    <input
                      type="email" value={email} onChange={(e) => setEmail(e.target.value)}
                      placeholder="netfang@daemi.is" required
                      className="w-full px-4 py-3.5 border-2 border-neutral-200 rounded-2xl text-base bg-neutral-50
                        placeholder:text-neutral-400 focus:border-evergreen-300 focus:bg-white
                        focus:ring-4 focus:ring-evergreen-50 outline-none transition"
                    />
                  </div>
                  <div>
                    <label className="block text-sm font-semibold text-neutral-700 mb-2">Lykilord</label>
                    <input
                      type="password" value={password} onChange={(e) => setPassword(e.target.value)}
                      placeholder="--------" required
                      className="w-full px-4 py-3.5 border-2 border-neutral-200 rounded-2xl text-base bg-neutral-50
                        placeholder:text-neutral-400 focus:border-evergreen-300 focus:bg-white
                        focus:ring-4 focus:ring-evergreen-50 outline-none transition"
                    />
                  </div>

                  <button type="submit" disabled={loading}
                    className="w-full bg-evergreen-500 text-white rounded-2xl px-4 py-4 font-bold text-base
                      hover:bg-evergreen-600 active:translate-y-px disabled:opacity-50
                      flex items-center justify-center gap-2 transition-all">
                    <LogIn size={18} />
                    {loading ? "Skrai inn..." : "Skra inn"}
                  </button>

                  <div className="flex items-center justify-between text-sm">
                    <Link href="/forgot-password" className="text-evergreen-400 hover:text-evergreen-500 font-semibold">
                      Gleymt lykilord?
                    </Link>
                    <Link href="/signup" className="text-evergreen-500 font-bold hover:text-gold-500 flex items-center gap-1">
                      Nyskra <ChevronRight size={14} />
                    </Link>
                  </div>
                </form>
              </div>

              {/* Child form */}
              <div className="w-1/2 px-1">
                <form onSubmit={handleChildLogin} className="space-y-5">
                  <div>
                    <h2 className="text-xl font-extrabold text-neutral-900 flex items-center gap-2">
                      <Sparkles size={20} className="text-gold-400" /> Hae!
                    </h2>
                    <p className="text-sm text-neutral-500 mt-1">Skraou thig inn med notendanafni</p>
                  </div>

                  {error && mode === "child" && (
                    <div className="bg-error-light text-error text-sm px-4 py-3 rounded-2xl">{error}</div>
                  )}

                  <div>
                    <label className="block text-sm font-semibold text-neutral-700 mb-2">Notendanafn</label>
                    <input
                      type="text" value={username} onChange={(e) => setUsername(e.target.value)}
                      placeholder="t.d. anna_krakki" required autoComplete="username" spellCheck={false}
                      className="w-full px-4 py-3.5 border-2 border-neutral-200 rounded-2xl text-base bg-gold-50
                        placeholder:text-neutral-400 focus:border-gold-300 focus:bg-white
                        focus:ring-4 focus:ring-gold-100 outline-none transition font-mono"
                    />
                  </div>
                  <div>
                    <label className="block text-sm font-semibold text-neutral-700 mb-2">Lykilord</label>
                    <input
                      type="password" value={childPassword} onChange={(e) => setChildPassword(e.target.value)}
                      placeholder="--------" required autoComplete="current-password"
                      className="w-full px-4 py-3.5 border-2 border-neutral-200 rounded-2xl text-base bg-gold-50
                        placeholder:text-neutral-400 focus:border-gold-300 focus:bg-white
                        focus:ring-4 focus:ring-gold-100 outline-none transition"
                    />
                  </div>

                  <button type="submit" disabled={loading}
                    className="w-full bg-gold-400 text-neutral-900 rounded-2xl px-4 py-4 font-bold text-base
                      hover:bg-gold-500 active:translate-y-px disabled:opacity-50
                      flex items-center justify-center gap-2 transition-all shadow-sm">
                    <Sparkles size={18} />
                    {loading ? "Skrai inn..." : "Skra inn"}
                  </button>
                </form>
              </div>
            </div>
          </div>
        </div>

        {/* Right — Mascot panel (changes color based on mode) */}
        <div className="hidden md:block w-[400px] flex-shrink-0 relative overflow-visible rounded-r-3xl">
          {/* Gradient background — transitions with mode */}
          <div className={`absolute inset-0 rounded-r-3xl transition-all duration-500
            ${mode === "parent"
              ? "bg-gradient-to-br from-evergreen-500 via-evergreen-600 to-evergreen-900"
              : "bg-gradient-to-br from-gold-300 via-citrus-400 to-citrus-500"
            }`}
          />

          {/* Soft glow circles */}
          <div className={`absolute w-64 h-64 rounded-full opacity-15 -top-20 -right-20 blur-2xl transition-colors duration-500
            ${mode === "parent" ? "bg-gold-400" : "bg-white"}`} />
          <div className={`absolute w-48 h-48 rounded-full opacity-12 bottom-12 -left-16 blur-xl transition-colors duration-500
            ${mode === "parent" ? "bg-mint-300" : "bg-gold-100"}`} />

          {/* Content */}
          <div className="relative z-10 h-full flex flex-col justify-between p-8">
            <div>
              <p className={`text-xs font-bold uppercase tracking-widest mb-2 transition-colors duration-500
                ${mode === "parent" ? "text-gold-300" : "text-white/70"}`}>
                {mode === "parent" ? "Fyrir foreldra" : "Fyrir born"}
              </p>
              <h2 className="text-white text-2xl font-extrabold leading-snug">
                {mode === "parent" ? (
                  <>Fylgstu med<br />framforunum.</>
                ) : (
                  <>Laera, vinna<br />og hafa gaman!</>
                )}
              </h2>
            </div>

            <div className="flex-1" />

            <div className="flex items-center gap-3">
              <div className="flex -space-x-2">
                <div className={`w-7 h-7 rounded-full border-2 transition-colors duration-500
                  ${mode === "parent" ? "bg-gold-400 border-evergreen-600" : "bg-white border-citrus-500"}`} />
                <div className={`w-7 h-7 rounded-full border-2 transition-colors duration-500
                  ${mode === "parent" ? "bg-citrus-400 border-evergreen-600" : "bg-gold-400 border-citrus-500"}`} />
                <div className={`w-7 h-7 rounded-full border-2 transition-colors duration-500
                  ${mode === "parent" ? "bg-mint-300 border-evergreen-600" : "bg-evergreen-400 border-citrus-500"}`} />
              </div>
              <p className={`text-xs transition-colors duration-500
                ${mode === "parent" ? "text-evergreen-200" : "text-white/60"}`}>
                Staerdfraedi · Lestur · Verkefni · Verdlaun
              </p>
            </div>
          </div>

          {/* Mascots — active mode mascot is larger and in front */}
          <div className={`absolute transition-all duration-500 ease-out
            ${mode === "parent"
              ? "-bottom-24 -left-28 z-30 w-[430px] h-[430px] opacity-100 translate-y-0"
              : "-bottom-16 -left-18 z-20 w-[340px] h-[340px] opacity-75 translate-y-3"
            }`}>
            <Image src="/mascots/green.png" alt="" fill
              className="object-contain drop-shadow-[0_12px_32px_rgba(0,0,0,0.25)]" />
          </div>
          <div className={`absolute transition-all duration-500 ease-out
            ${mode === "child"
              ? "-bottom-12 left-16 z-30 w-[390px] h-[390px] opacity-100 translate-y-0"
              : "-bottom-10 left-26 z-20 w-[300px] h-[300px] opacity-75 translate-y-3"
            }`}>
            <Image src="/mascots/orange.png" alt="" fill
              className="object-contain drop-shadow-[0_12px_32px_rgba(0,0,0,0.25)]" />
          </div>
        </div>
      </div>
    </div>
  );
}

export default function LoginPage() {
  return (
    <Suspense fallback={
      <div className="min-h-full flex items-center justify-center bg-cream">
        <div className="w-96 h-96 animate-pulse rounded-3xl bg-white/60" />
      </div>
    }>
      <LoginPageInner />
    </Suspense>
  );
}
