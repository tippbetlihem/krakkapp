import Link from "next/link";
import { Users, ExternalLink } from "lucide-react";
import { createClient } from "@/lib/supabase/server";
import type { Child } from "@/types/database";
import { CopyChildIdButton } from "@/components/parent/CopyChildIdButton";

export default async function ChildrenPage() {
  const supabase = await createClient();
  const { data: rows } = await supabase
    .from("children")
    .select("id, first_name, display_name, pin_code")
    .eq("is_active", true)
    .order("created_at");

  const children = (rows ?? []) as Pick<Child, "id" | "first_name" | "display_name" | "pin_code">[];

  return (
    <div className="space-y-5">
      <section className="rounded-3xl border border-neutral-200/80 bg-white p-5 sm:p-6">
        <div className="mb-1 flex items-center gap-3">
          <div className="grid h-9 w-9 place-items-center rounded-xl bg-evergreen-50 text-evergreen-600">
            <Users size={18} />
          </div>
          <h1 className="text-xl font-extrabold text-neutral-900">Börn</h1>
        </div>
        <p className="text-sm leading-relaxed text-neutral-500">
          Hér sérðu barna-ID til innskráningar barnsins á{" "}
          <Link href="/child/login" className="font-semibold text-evergreen-600 hover:underline">
            /child/login
          </Link>
          . Settu PIN í gagnagrunninum (reitur{" "}
          <code className="rounded bg-neutral-100 px-1 text-xs">pin_code</code>) eða með SQL / Supabase
          — UI til að breyta PIN kemur síðar.
        </p>
      </section>

      {children.length === 0 ? (
        <div className="rounded-2xl border border-neutral-200/80 bg-white p-8 text-center text-neutral-500">
          Engin börn skráð ennþá.
        </div>
      ) : (
        <ul className="space-y-3">
          {children.map((c) => {
            const name = c.display_name || c.first_name;
            const hasPin = Boolean(c.pin_code && String(c.pin_code).trim().length >= 4);
            const loginUrl = `/child/login?child=${encodeURIComponent(c.id)}`;
            return (
              <li
                key={c.id}
                className="rounded-2xl border border-neutral-200/80 bg-white p-4 sm:p-5"
              >
                <div className="flex flex-col gap-3 sm:flex-row sm:items-start sm:justify-between">
                  <div className="min-w-0">
                    <p className="font-bold text-neutral-900">{name}</p>
                    <p className="mt-1 break-all font-mono text-xs text-neutral-500">{c.id}</p>
                    <p className="mt-2 text-xs text-neutral-400">
                      PIN: {hasPin ? "stilltur ✓" : "vantar — setja þarf a.m.k. 4 stafi"}
                    </p>
                  </div>
                  <div className="flex shrink-0 flex-wrap gap-2">
                    <CopyChildIdButton id={c.id} />
                    <Link
                      href={loginUrl}
                      className="inline-flex items-center gap-1.5 rounded-xl border border-neutral-200 bg-neutral-50 px-3 py-2 text-xs font-semibold text-neutral-700 hover:bg-neutral-100"
                    >
                      <ExternalLink size={14} />
                      Opna barnainnskráningu
                    </Link>
                  </div>
                </div>
              </li>
            );
          })}
        </ul>
      )}
    </div>
  );
}
