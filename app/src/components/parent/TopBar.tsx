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
    <header className="h-14 bg-navy-500 text-white flex items-center justify-between px-5 lg:px-8">
      <div className="lg:hidden w-8" /> {/* spacer for mobile menu button */}
      <div className="hidden lg:block" />
      <div className="flex items-center gap-4">
        {email && (
          <span className="text-sm text-navy-200 flex items-center gap-1.5">
            <User size={14} />
            {email}
          </span>
        )}
        <button
          onClick={handleLogout}
          className="text-sm text-navy-200 hover:text-white flex items-center gap-1.5 transition-colors"
        >
          <LogOut size={14} />
          Útskrá
        </button>
      </div>
    </header>
  );
}
