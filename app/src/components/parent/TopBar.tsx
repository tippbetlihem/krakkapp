"use client";

import { Bell, LogOut, User } from "lucide-react";
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
    <header className="h-14 lg:h-16 flex items-center justify-between px-4 pl-14 lg:pl-4 lg:px-8 shrink-0">
      {/* Left — page context badge (desktop only) */}
      <div className="hidden md:flex items-center gap-2 rounded-full bg-white/80 px-3.5 py-1.5 border border-neutral-200/60 text-sm">
        <span className="font-semibold text-neutral-700">Foreldra mælaborð</span>
      </div>

      {/* Mobile spacer */}
      <div className="md:hidden" />

      {/* Right — actions */}
      <div className="flex items-center gap-2 sm:gap-3">
        <button
          className="grid h-8 w-8 place-items-center rounded-full bg-white/80 border border-neutral-200/60 text-neutral-500 hover:text-neutral-700 transition-colors"
          aria-label="Tilkynningar"
        >
          <Bell size={15} />
        </button>

        {email && (
          <span className="hidden lg:flex text-xs text-neutral-500 items-center gap-1.5 max-w-[180px] truncate">
            <User size={13} className="text-evergreen-500 shrink-0" />
            {email}
          </span>
        )}

        <button
          onClick={handleLogout}
          className="flex items-center gap-1.5 rounded-full bg-white/80 border border-neutral-200/60 px-3 py-1.5 text-xs font-medium text-neutral-600 hover:text-neutral-900 transition-colors"
        >
          <LogOut size={13} />
          <span className="hidden sm:inline">Útskrá</span>
        </button>
      </div>
    </header>
  );
}
