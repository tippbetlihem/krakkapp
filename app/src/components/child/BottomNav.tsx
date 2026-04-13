"use client";

import { usePathname } from "next/navigation";
import Link from "next/link";
import { Home, Calculator, BookOpen, ClipboardCheck, Gift } from "lucide-react";

const tabs = [
  { href: "/child/home", label: "Heim", icon: Home },
  { href: "/child/math", label: "Stærðfræði", icon: Calculator },
  { href: "/child/reading", label: "Lestur", icon: BookOpen },
  { href: "/child/tasks", label: "Verkefni", icon: ClipboardCheck },
  { href: "/child/rewards", label: "Verðlaun", icon: Gift },
];

export function BottomNav() {
  const pathname = usePathname();

  return (
    <nav className="fixed bottom-0 inset-x-0 z-40 border-t border-neutral-200 bg-white">
      <div className="mx-auto flex max-w-md">
        {tabs.map((tab) => {
          const isActive = pathname.startsWith(tab.href);
          return (
            <Link
              key={tab.href}
              href={tab.href}
              className={`
                flex-1 flex flex-col items-center gap-0.5 py-2.5 text-xs font-semibold transition-colors
                ${
                  isActive
                    ? "text-evergreen-500 border-t-2 border-gold-400"
                    : "text-neutral-400 border-t-2 border-transparent"
                }
              `}
            >
              <tab.icon size={20} />
              {tab.label}
            </Link>
          );
        })}
      </div>
    </nav>
  );
}
