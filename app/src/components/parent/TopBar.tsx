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
    <header className="h-20 bg-transparent flex items-center justify-between px-5 lg:px-8">
      <div className="lg:hidden w-8" />
      <div className="hidden md:flex items-center gap-2 rounded-full bg-white px-4 py-2 border border-neutral-200 text-sm text-neutral-500">
        <span className="font-semibold text-neutral-700">Foreldra mælaborð</span>
      </div>
      <div className="flex items-center gap-4">
        <button
          className="grid h-9 w-9 place-items-center rounded-full bg-white border border-neutral-200 text-neutral-500 hover:text-neutral-700"
          aria-label="Tilkynningar"
        >
          <Bell size={16} />
        </button>
        {email && (
          <span className="text-sm text-neutral-500 hidden lg:flex items-center gap-1.5">
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
