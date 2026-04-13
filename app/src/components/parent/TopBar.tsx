"use client";

import { LogOut, User } from "lucide-react";
import { createClient } from "@/lib/supabase/client";
import { useRouter } from "next/navigation";

export function TopBar({ email }: { email?: string }) {
  const router = useRouter();

  async function handleLogout() {
    const supabase = createClient();
    await supabase.auth.signOut();
    router.push("/login");
  }

  return (
    <header className="h-20 border-b border-neutral-200/80 bg-white flex items-center justify-between px-5 lg:px-8">
      <div className="lg:hidden w-8" />
      <div>
        <p className="text-xs font-semibold uppercase tracking-[0.18em] text-neutral-400">
          Foreldragátt
        </p>
        <h1 className="text-lg font-extrabold text-neutral-900">Yfirlit fjölskyldu</h1>
      </div>
      <div className="flex items-center gap-4">
        {email && (
          <span className="text-sm text-neutral-500 flex items-center gap-1.5">
            <User size={14} className="text-evergreen-500" />
            {email}
          </span>
        )}
        <button
          onClick={handleLogout}
          className="text-sm text-neutral-500 hover:text-neutral-900 flex items-center gap-1.5 transition-colors"
        >
          <LogOut size={14} className="text-evergreen-500" />
          Útskrá
        </button>
      </div>
    </header>
  );
}
