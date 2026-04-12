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
      <div className="bg-white rounded-lg shadow border border-neutral-200 p-6 text-center space-y-3">
        <div className="w-12 h-12 bg-success-light rounded-full flex items-center justify-center mx-auto">
          <Mail size={24} className="text-success" />
        </div>
        <h2 className="text-xl font-semibold text-neutral-900">
          Tölvupóstur sendur
        </h2>
        <p className="text-sm text-neutral-500">
          Ef reikningur er til með þessu netfangi færðu tölvupóst með
          leiðbeiningum til að endurstilla lykilorðið þitt.
        </p>
        <Link
          href="/login"
          className="inline-block text-sm text-navy-500 font-medium hover:text-navy-600 transition-colors"
        >
          Til baka í innskráningu
        </Link>
      </div>
    );
  }

  return (
    <form onSubmit={handleSubmit} className="space-y-4">
      <div className="bg-white rounded-lg shadow border border-neutral-200 p-6 space-y-4">
        <h2 className="text-xl font-semibold text-neutral-900">
          Gleymt lykilorð
        </h2>
        <p className="text-sm text-neutral-500">
          Sláðu inn netfangið þitt og við sendum þér tengil til að endurstilla
          lykilorðið.
        </p>

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

        <button
          type="submit"
          disabled={loading}
          className="w-full bg-navy-500 text-white rounded-md px-4 py-2 font-semibold text-sm
                     hover:bg-navy-600 disabled:opacity-50 disabled:cursor-not-allowed
                     flex items-center justify-center gap-2 transition-colors"
        >
          <Mail size={16} />
          {loading ? "Sendi..." : "Senda endurstillingartengil"}
        </button>
      </div>

      <p className="text-center text-sm text-neutral-500">
        <Link
          href="/login"
          className="text-navy-500 font-medium hover:text-navy-600 transition-colors"
        >
          Til baka í innskráningu
        </Link>
      </p>
    </form>
  );
}
