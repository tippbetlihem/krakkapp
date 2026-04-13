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
      {/* Mobile toggle — sits inside the frame */}
      <button
        onClick={() => setOpen(!open)}
        className="lg:hidden fixed top-3 left-3 z-50 p-2.5 rounded-2xl bg-white/90 backdrop-blur shadow-md text-evergreen-600"
        aria-label="Toggle menu"
      >
        {open ? <X size={20} /> : <Menu size={20} />}
      </button>

      {/* Backdrop */}
      {open && (
        <div
          className="lg:hidden fixed inset-0 z-30 bg-black/25 backdrop-blur-sm"
          onClick={() => setOpen(false)}
        />
      )}

      {/* Sidebar — icon-rail on desktop, full drawer on mobile */}
      <aside
        className={`
          fixed inset-y-0 left-0 z-40 w-64 bg-[#f7f5f2] border-r border-neutral-200/70
          flex flex-col transition-transform duration-200 ease-out
          lg:w-56 lg:translate-x-0 lg:static lg:z-auto lg:self-stretch
          ${open ? "translate-x-0" : "-translate-x-full"}
        `}
      >
        {/* Brand */}
        <div className="h-16 flex items-center gap-3 px-4 shrink-0">
          <Link
            href="/dashboard"
            className="grid place-items-center h-10 w-10 rounded-2xl bg-white text-evergreen-600 shadow-sm shrink-0"
            aria-label="KrakkApp heim"
          >
            <span className="text-lg font-black leading-none">K</span>
          </Link>
          <span className="text-lg font-extrabold text-evergreen-600">
            Krakk<span className="text-gold-400">App</span>
          </span>
        </div>

        {/* Nav — text labels always visible (incl. desktop) so „Börn“ is findable */}
        <nav className="flex-1 space-y-1 px-3 py-4">
          {navItems.map((item) => {
            const isActive = pathname.startsWith(item.href);
            return (
              <Link
                key={item.href}
                href={item.href}
                onClick={() => setOpen(false)}
                title={item.label}
                className={`
                  flex items-center gap-3 rounded-2xl px-3 py-2.5 text-sm font-semibold transition-all
                  ${
                    isActive
                      ? "bg-neutral-900 text-white shadow-sm"
                      : "text-neutral-500 hover:bg-white hover:text-neutral-700"
                  }
                `}
              >
                <item.icon size={18} className="shrink-0" />
                <span>{item.label}</span>
              </Link>
            );
          })}
        </nav>

        {/* Avatar placeholder — bottom */}
        <div className="shrink-0 px-3 pb-4">
          <div className="h-9 w-9 rounded-full bg-gradient-to-br from-evergreen-300 to-evergreen-500 ring-2 ring-white" />
        </div>
      </aside>
    </>
  );
}
