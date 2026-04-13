"use client";

import { useState } from "react";
import Link from "next/link";
import { createClient } from "@/lib/supabase/client";
import { Mail } from "lucide-react";

export default function ForgotPasswordPage() {
  const [email, setEmail] = useState("");
  const [sent, setSent] = useState(false);
  const [error, setError] = useState("");
  const [loading, setLoading] = useState(false);

  async function handleSubmit(e: React.FormEvent) {
    e.preventDefault();
    setError("");
    setLoading(true);

    const supabase = createClient();
    const { error } = await supabase.auth.resetPasswordForEmail(email, {
      redirectTo: `${window.location.origin}/login`,
    });

    if (error) {
      setError("Villa kom upp. Reyndu aftur.");
      setLoading(false);
      return;
    }

    setSent(true);
    setLoading(false);
  }

  if (sent) {
    return (
      <div className="text-center space-y-4">
        <div className="w-14 h-14 bg-mint-200 rounded-full flex items-center justify-center mx-auto">
          <Mail size={24} className="text-success" />
        </div>
        <h2 className="text-xl font-bold text-neutral-900">Tölvupóstur sendur</h2>
        <p className="text-sm text-neutral-500">
          Ef reikningur er til með þessu netfangi færðu tölvupóst með
          leiðbeiningum til að endurstilla lykilorðið þitt.
        </p>
        <Link
          href="/login"
          className="inline-block text-sm text-evergreen-500 font-bold hover:text-gold-500 transition-colors"
        >
          Til baka í innskráningu
        </Link>
      </div>
    );
  }

  return (
    <form onSubmit={handleSubmit} className="space-y-6">
      <div>
        <h2 className="text-2xl font-extrabold text-neutral-900">Gleymt lykilorð</h2>
        <p className="text-sm text-neutral-500 mt-1">
          Sláðu inn netfangið þitt og við sendum þér tengil til að endurstilla lykilorðið.
        </p>
      </div>

      {error && (
        <div className="bg-error-light text-error text-sm px-4 py-3 rounded-2xl">
          {error}
        </div>
      )}

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

      <button
        type="submit"
        disabled={loading}
        className="w-full bg-evergreen-500 text-white rounded-2xl px-4 py-4 font-bold text-base
                   hover:bg-evergreen-600 active:translate-y-px
                   disabled:opacity-50 disabled:cursor-not-allowed
                   flex items-center justify-center gap-2 transition-all"
      >
        <Mail size={18} />
        {loading ? "Sendi..." : "Senda endurstillingartengil"}
      </button>

      <p className="text-center text-sm text-neutral-500">
        <Link
          href="/login"
          className="text-evergreen-500 font-bold hover:text-gold-500 transition-colors"
        >
          Til baka í innskráningu
        </Link>
      </p>
    </form>
  );
}
