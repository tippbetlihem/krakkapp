"use client";

import { usePathname } from "next/navigation";
import { BottomNav } from "@/components/child/BottomNav";

export function ChildAppShell({ children }: { children: React.ReactNode }) {
  const pathname = usePathname();
  const hideNav = pathname.startsWith("/child/login");

  return (
    <div className="flex min-h-dvh flex-col bg-gold-50">
      <main
        className={`flex flex-1 flex-col ${hideNav ? "" : "pb-16"}`}
      >
        <div
          className={
            hideNav
              ? "flex flex-1 flex-col justify-center px-4 py-8"
              : "mx-auto w-full max-w-md px-4 py-6"
          }
        >
          {children}
        </div>
      </main>
      {!hideNav && <BottomNav />}
    </div>
  );
}
