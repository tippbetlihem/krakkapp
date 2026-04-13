"use client";

import { usePathname } from "next/navigation";
import Link from "next/link";
import {
  LayoutDashboard,
  Users,
  ClipboardCheck,
  Gift,
  Settings,
  Menu,
  X,
} from "lucide-react";
import { useState } from "react";

const navItems = [
  { href: "/dashboard", label: "Yfirlit", icon: LayoutDashboard },
  { href: "/children", label: "Börn", icon: Users },
  { href: "/tasks", label: "Verkefni", icon: ClipboardCheck },
  { href: "/rewards", label: "Verðlaun", icon: Gift },
  { href: "/settings", label: "Stillingar", icon: Settings },
];

export function Sidebar() {
  const pathname = usePathname();
  const [open, setOpen] = useState(false);

  return (
    <>
      {/* Mobile toggle */}
      <button
        onClick={() => setOpen(!open)}
        className="lg:hidden fixed top-3 left-3 z-50 p-2 rounded-xl bg-white shadow-md text-evergreen-500"
        aria-label="Toggle menu"
      >
        {open ? <X size={20} /> : <Menu size={20} />}
      </button>

      {/* Backdrop */}
      {open && (
        <div
          className="lg:hidden fixed inset-0 z-30 bg-black/20"
          onClick={() => setOpen(false)}
        />
      )}

      {/* Sidebar */}
      <aside
        className={`
          fixed top-0 left-0 z-40 h-full w-64 bg-white border-r border-neutral-200/70
          flex flex-col transition-transform duration-200 shadow-sm
          lg:translate-x-0 lg:static lg:z-auto
          ${open ? "translate-x-0" : "-translate-x-full"}
        `}
      >
        <div className="h-20 flex items-center px-6 border-b border-neutral-200/70">
          <Link href="/dashboard" className="text-2xl font-extrabold text-evergreen-600">
            Krakk<span className="text-gold-400">App</span>
          </Link>
        </div>

        <nav className="flex-1 py-5 px-4 space-y-1.5">
          {navItems.map((item) => {
            const isActive = pathname.startsWith(item.href);
            return (
              <Link
                key={item.href}
                href={item.href}
                onClick={() => setOpen(false)}
                className={`
                  flex items-center gap-3 px-3.5 py-2.5 rounded-xl text-sm font-semibold transition-all
                  ${
                    isActive
                      ? "bg-evergreen-500 text-white shadow-sm"
                      : "text-neutral-500 hover:bg-neutral-100 hover:text-neutral-700"
                  }
                `}
              >
                <item.icon size={18} />
                {item.label}
              </Link>
            );
          })}
        </nav>
      </aside>
    </>
  );
}
