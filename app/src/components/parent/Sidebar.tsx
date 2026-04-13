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
          fixed top-0 left-0 z-40 h-full w-24 bg-[#f3f1ee] border-r border-neutral-200/70
          flex flex-col transition-transform duration-200
          lg:translate-x-0 lg:static lg:z-auto
          ${open ? "translate-x-0" : "-translate-x-full"}
        `}
      >
        <div className="h-20 flex items-center justify-center border-b border-neutral-200/70">
          <Link
            href="/dashboard"
            className="grid place-items-center h-11 w-11 rounded-2xl bg-white text-evergreen-600 shadow-sm"
            aria-label="KrakkApp heim"
          >
            <span className="text-xl font-black">K</span>
          </Link>
        </div>

        <nav className="flex-1 py-5 px-3 space-y-2">
          {navItems.map((item) => {
            const isActive = pathname.startsWith(item.href);
            return (
              <Link
                key={item.href}
                href={item.href}
                onClick={() => setOpen(false)}
                aria-label={item.label}
                className={`
                  flex items-center justify-center px-3 py-3 rounded-2xl text-sm font-semibold transition-all
                  ${
                    isActive
                      ? "bg-neutral-900 text-white shadow-sm"
                      : "text-neutral-500 hover:bg-white hover:text-neutral-700"
                  }
                `}
              >
                <item.icon size={18} />
                <span className="sr-only">{item.label}</span>
              </Link>
            );
          })}
        </nav>
        <div className="px-3 pb-5">
          <div className="mx-auto h-10 w-10 rounded-full bg-gradient-to-br from-evergreen-300 to-evergreen-500" />
        </div>
      </aside>
    </>
  );
}
