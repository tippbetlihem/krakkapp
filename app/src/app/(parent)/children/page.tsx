import Link from "next/link";
import { Users, ExternalLink } from "lucide-react";
import { createClient } from "@/lib/supabase/server";
import type { Child } from "@/types/database";
import { AddChildForm } from "@/components/parent/AddChildForm";

export default async function ChildrenPage() {
  const supabase = await createClient();
  const { data: rows } = await supabase
    .from("children")
    .select("id, first_name, display_name, login_username, birth_date, birth_year")
    .eq("is_active", true)
    .order("created_at");

  const children = (rows ?? []) as Pick<
    Child,
    "id" | "first_name" | "display_name" | "login_username" | "birth_date" | "birth_year"
  >[];

  return (
    <div className="space-y-6">
      <header className="rounded-3xl border border-neutral-200/80 bg-white p-5 sm:p-6">
        <div className="mb-2 flex items-center gap-3">
          <div className="grid h-9 w-9 place-items-center rounded-xl bg-evergreen-50 text-evergreen-600">
            <Users size={18} />
          </div>
          <h1 className="text-xl font-extrabold text-neutral-900">Börn</h1>
        </div>
        <p className="text-sm leading-relaxed text-neutral-600">
          <strong className="text-neutral-800">Hér skráir þú börnin:</strong> byrjaðu á forminu{" "}
          <strong>„Skrá nýtt barn“</strong> fyrir neðan (nafn, fæðingardagur, notendanafn, lykilorð).
          Síðan skráir barnið sig inn á{" "}
          <Link href="/login?mode=child" className="font-semibold text-evergreen-600 hover:underline">
            barnainnskráningu
          </Link>
          .
        </p>
      </header>

      <AddChildForm />

      {children.length === 0 ? (
        <div className="rounded-2xl border border-dashed border-neutral-200 bg-neutral-50/80 p-6 text-center text-sm text-neutral-500">
          Engin börn á listanum enn — notaðu formið hér fyrir ofan.
        </div>
      ) : (
        <section>
          <h2 className="mb-3 text-sm font-bold text-neutral-800">Skráð börn</h2>
          <ul className="space-y-3">
            {children.map((c) => {
              const name = c.display_name || c.first_name;
              const uname = c.login_username?.trim();
              const loginUrl = uname
                ? `/login?mode=child&u=${encodeURIComponent(uname)}`
                : "/login?mode=child";
              const ageHint =
                c.birth_year != null
                  ? `Fætt/ur ~${c.birth_year}`
                  : c.birth_date
                    ? `Fæðingardagur: ${c.birth_date}`
                    : null;
              return (
                <li
                  key={c.id}
                  className="rounded-2xl border border-neutral-200/80 bg-white p-4 sm:p-5"
                >
                  <div className="flex flex-col gap-3 sm:flex-row sm:items-start sm:justify-between">
                    <div className="min-w-0">
                      <p className="font-bold text-neutral-900">{name}</p>
                      {ageHint && (
                        <p className="mt-0.5 text-xs text-neutral-500">{ageHint}</p>
                      )}
                      {uname ? (
                        <p className="mt-1 font-mono text-sm text-neutral-600">
                          Innskráning: <span className="font-semibold">{uname}</span>
                        </p>
                      ) : (
                        <p className="mt-1 text-xs text-amber-700">
                          Engin innskráning stillt — uppfærðu gagnagrunn eða búðu barn aftur til.
                        </p>
                      )}
                    </div>
                    <div className="flex shrink-0 flex-wrap gap-2">
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
        </section>
      )}
    </div>
  );
}
