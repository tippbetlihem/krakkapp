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
    <form onSubmit={handleSubmit} className="space-y-4">
      <div className="bg-white rounded-lg shadow border border-neutral-200 p-6 space-y-4">
        <h2 className="text-xl font-semibold text-neutral-900">Innskráning</h2>

        {error && (
          <div className="bg-error-light text-error text-sm px-3 py-2 rounded-md">
            {error}
          </div>
        )}

        <div>
          <label className="block text-sm font-medium text-neutral-700 mb-1">
            Netfang
          </label>
          <input
            type="email"
            value={email}
            onChange={(e) => setEmail(e.target.value)}
            placeholder="netfang@dæmi.is"
            required
            className="w-full px-3 py-2 border border-neutral-300 rounded-md text-base
                       placeholder:text-neutral-400
                       focus:border-navy-400 focus:ring-2 focus:ring-navy-50 outline-none transition"
          />
        </div>

        <div>
          <label className="block text-sm font-medium text-neutral-700 mb-1">
            Lykilorð
          </label>
          <input
            type="password"
            value={password}
            onChange={(e) => setPassword(e.target.value)}
            placeholder="••••••••"
            required
            className="w-full px-3 py-2 border border-neutral-300 rounded-md text-base
                       placeholder:text-neutral-400
                       focus:border-navy-400 focus:ring-2 focus:ring-navy-50 outline-none transition"
          />
        </div>

        <button
          type="submit"
          disabled={loading}
          className="w-full bg-navy-500 text-white rounded-md px-4 py-2 font-semibold text-sm
                     hover:bg-navy-600 disabled:opacity-50 disabled:cursor-not-allowed
                     flex items-center justify-center gap-2 transition-colors"
        >
          <LogIn size={16} />
          {loading ? "Skrái inn..." : "Skrá inn"}
        </button>
      </div>

      <div className="text-center space-y-2 text-sm">
        <Link
          href="/forgot-password"
          className="text-navy-400 hover:text-navy-500 transition-colors"
        >
          Gleymt lykilorð?
        </Link>
        <p className="text-neutral-500">
          Ekki með reikning?{" "}
          <Link
            href="/signup"
            className="text-navy-500 font-medium hover:text-navy-600 transition-colors"
          >
            Nýskrá
          </Link>
        </p>
      </div>
    </form>
  );
}
