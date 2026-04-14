"use client";

import { useState } from "react";
import Link from "next/link";
import { useRouter } from "next/navigation";
import { AuthCard } from "@/components/auth/AuthCard";
import { createClient } from "@/lib/supabase/client";
import { UserPlus } from "lucide-react";

export default function SignupPage() {
  const router = useRouter();
  const [fullName, setFullName] = useState("");
  const [email, setEmail] = useState("");
  const [password, setPassword] = useState("");
  const [confirmPassword, setConfirmPassword] = useState("");
  const [error, setError] = useState("");
  const [loading, setLoading] = useState(false);

  async function handleSubmit(e: React.FormEvent) {
    e.preventDefault();
    setError("");

    if (password !== confirmPassword) {
      setError("Lykilorð stemma ekki");
      return;
    }

    if (password.length < 6) {
      setError("Lykilorð þarf að vera a.m.k. 6 stafir");
      return;
    }

    setLoading(true);

    const supabase = createClient();
    const { error } = await supabase.auth.signUp({
      email,
      password,
      options: {
        data: {
          full_name: fullName,
        },
      },
    });

    if (error) {
      setError("Villa við nýskráningu. Reyndu aftur.");
      setLoading(false);
      return;
    }

    router.push("/dashboard");
  }

  return (
    <AuthCard>
    <form onSubmit={handleSubmit} className="space-y-6">
      <div>
        <h2 className="text-2xl font-extrabold text-neutral-900">Nýskráning</h2>
        <p className="text-sm text-neutral-500 mt-1">Búðu til reikning til að byrja</p>
      </div>

      {error && (
        <div className="bg-error-light text-error text-sm px-4 py-3 rounded-2xl">
          {error}
        </div>
      )}

      <div className="space-y-4">
        <div>
          <label className="block text-sm font-semibold text-neutral-700 mb-2">Fullt nafn</label>
          <input
            type="text"
            value={fullName}
            onChange={(e) => setFullName(e.target.value)}
            placeholder="Jón Jónsson"
            className="w-full px-4 py-3.5 border-2 border-neutral-200 rounded-2xl text-base bg-neutral-50
                       placeholder:text-neutral-400
                       focus:border-evergreen-300 focus:bg-white focus:ring-4 focus:ring-evergreen-50
                       outline-none transition"
          />
        </div>

        <div>
          <label className="block text-sm font-semibold text-neutral-700 mb-2">Netfang</label>
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
          <label className="block text-sm font-semibold text-neutral-700 mb-2">Lykilorð</label>
          <input
            type="password"
            value={password}
            onChange={(e) => setPassword(e.target.value)}
            placeholder="A.m.k. 6 stafir"
            required
            className="w-full px-4 py-3.5 border-2 border-neutral-200 rounded-2xl text-base bg-neutral-50
                       placeholder:text-neutral-400
                       focus:border-evergreen-300 focus:bg-white focus:ring-4 focus:ring-evergreen-50
                       outline-none transition"
          />
        </div>

        <div>
          <label className="block text-sm font-semibold text-neutral-700 mb-2">Staðfesta lykilorð</label>
          <input
            type="password"
            value={confirmPassword}
            onChange={(e) => setConfirmPassword(e.target.value)}
            placeholder="Sama lykilorð aftur"
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
        <UserPlus size={18} />
        {loading ? "Skrái..." : "Nýskrá"}
      </button>

      <p className="text-center text-sm text-neutral-500">
        Nú þegar með reikning?{" "}
        <Link
          href="/login"
          className="text-evergreen-500 font-bold hover:text-gold-500 transition-colors"
        >
          Skrá inn
        </Link>
      </p>
    </form>
    </AuthCard>
  );
}
