"use client";

import { useState } from "react";
import { Copy, Check } from "lucide-react";

export function CopyChildIdButton({ id }: { id: string }) {
  const [done, setDone] = useState(false);

  async function copy() {
    try {
      await navigator.clipboard.writeText(id);
      setDone(true);
      setTimeout(() => setDone(false), 2000);
    } catch {
      /* ignore */
    }
  }

  return (
    <button
      type="button"
      onClick={copy}
      className="inline-flex items-center gap-1.5 rounded-xl bg-evergreen-500 px-3 py-2 text-xs font-semibold text-white hover:bg-evergreen-600"
    >
      {done ? <Check size={14} /> : <Copy size={14} />}
      {done ? "Afritað!" : "Afrita ID"}
    </button>
  );
}
