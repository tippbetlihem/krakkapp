"use client";

import { useState } from "react";
import Link from "next/link";
import { useRouter } from "next/navigation";
import { createClient } from "@/lib/supabase/client";
import { LogIn } from "lucide-react";

export default function LoginPage() {
  const router = useRouter();
  const [email, setEmail] = useState("");
  const [password, setPassword] = useState("");
  const [error, setError] = useState("");
  const [loading, setLoading] = useState(false);

  async function handleSubmit(e: React.FormEvent) {
    e.preventDefault();
    setError("");
    setLoading(true);

    const supabase = createClient();
    const { error } = await supabase.auth.signInWithPassword({
      email,
      password,
    });

    if (error) {
      setError("Rangt netfang eða lykilorð");
      setLoading(false);
      return;
    }

    router.push("/dashboard");
  }

  return (
    <form onSubmit={handleSubmit} className="space-y-6">
      <div>
        <h2 className="text-2xl font-extrabold text-neutral-900">Velkomin/n!</h2>
        <p className="text-sm text-neutral-500 mt-1">Skráðu þig inn til að halda áfram</p>
      </div>

      {error && (
        <div className="bg-error-light text-error text-sm px-4 py-3 rounded-2xl">
          {error}
        </div>
      )}

      <div className="space-y-4">
        <div>
          <label className="block text-sm font-semibold text-neutral-700 mb-2">
            Netfang
          </label>
          <input
            type="email"
            value={email}
            onChange={(e) => setEmail(e.target.value)}
            placeholder="netfang@daemi.is"
            required
            className="w-full px-4 py-3.5 border-2 border-neutral-200 rounded-2xl text-base bg-neutral-50
                       placeholder:text-neutral-400
                       focus:border-evergreen-300 focus:bg-white focus:ring-4 focus:ring-evergreen-50
                       outline-none transition"
          />
        </div>

        <div>
          <label className="block text-sm font-semibold text-neutral-700 mb-2">
            Lykilorð
          </label>
          <input
            type="password"
            value={password}
            onChange={(e) => setPassword(e.target.value)}
            placeholder="••••••••"
            required
            className="w-full px-4 py-3.5 border-2 border-neutral-200 rounded-2xl text-base bg-neutral-50
                       placeholder:text-neutral-400
                       focus:border-evergreen-300 focus:bg-white focus:ring-4 focus:ring-evergreen-50
                       outline-none transition"
          />
        </div>
      </div>

      <button
        type="submit"
        disabled={loading}
        className="w-full bg-evergreen-500 text-white rounded-2xl px-4 py-4 font-bold text-base
                   hover:bg-evergreen-600 active:translate-y-px
                   disabled:opacity-50 disabled:cursor-not-allowed
                   flex items-center justify-center gap-2 transition-all"
      >
        <LogIn size={18} />
        {loading ? "Skrái inn..." : "Skrá inn"}
      </button>

      <div className="text-center">
        <Link
          href="/forgot-password"
          className="text-sm text-evergreen-400 hover:text-evergreen-500 font-semibold transition-colors"
        >
          Gleymt lykilorð?
        </Link>
      </div>

      <div className="flex items-center gap-3 text-neutral-400 text-xs">
        <div className="flex-1 h-px bg-neutral-200" />
        <span>eða</span>
        <div className="flex-1 h-px bg-neutral-200" />
      </div>

      <p className="text-center text-sm text-neutral-500">
        Ekki með reikning?{" "}
        <Link
          href="/signup"
          className="text-evergreen-500 font-bold hover:text-gold-500 transition-colors"
        >
          Nýskrá &rarr;
        </Link>
      </p>
    </form>
  );
}
