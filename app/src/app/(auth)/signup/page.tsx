"use client";

import { useState } from "react";
import Link from "next/link";
import { useRouter } from "next/navigation";
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
    <form onSubmit={handleSubmit} className="space-y-4">
      <div className="bg-white rounded-lg shadow border border-neutral-200 p-6 space-y-4">
        <h2 className="text-xl font-semibold text-neutral-900">Nýskráning</h2>

        {error && (
          <div className="bg-error-light text-error text-sm px-3 py-2 rounded-md">
            {error}
          </div>
        )}

        <div>
          <label className="block text-sm font-medium text-neutral-700 mb-1">
            Fullt nafn
          </label>
          <input
            type="text"
            value={fullName}
            onChange={(e) => setFullName(e.target.value)}
            placeholder="Jón Jónsson"
            className="w-full px-3 py-2 border border-neutral-300 rounded-md text-base
                       placeholder:text-neutral-400
                       focus:border-navy-400 focus:ring-2 focus:ring-navy-50 outline-none transition"
          />
        </div>

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
            placeholder="A.m.k. 6 stafir"
            required
            className="w-full px-3 py-2 border border-neutral-300 rounded-md text-base
                       placeholder:text-neutral-400
                       focus:border-navy-400 focus:ring-2 focus:ring-navy-50 outline-none transition"
          />
        </div>

        <div>
          <label className="block text-sm font-medium text-neutral-700 mb-1">
            Staðfesta lykilorð
          </label>
          <input
            type="password"
            value={confirmPassword}
            onChange={(e) => setConfirmPassword(e.target.value)}
            placeholder="Sama lykilorð aftur"
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
          <UserPlus size={16} />
          {loading ? "Skrái..." : "Nýskrá"}
        </button>
      </div>

      <p className="text-center text-sm text-neutral-500">
        Nú þegar með reikning?{" "}
        <Link
          href="/login"
          className="text-navy-500 font-medium hover:text-navy-600 transition-colors"
        >
          Skrá inn
        </Link>
      </p>
    </form>
  );
}
