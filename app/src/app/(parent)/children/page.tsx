import Link from "next/link";
import { Users, ExternalLink } from "lucide-react";
import { createClient } from "@/lib/supabase/server";
import type { Child } from "@/types/database";
import { AddChildForm } from "@/components/parent/AddChildForm";

export default async function ChildrenPage() {
  const supabase = await createClient();
  const { data: rows } = await supabase
    .from("children")
    .select("id, first_name, display_name, login_username")
    .eq("is_active", true)
    .order("created_at");

  const children = (rows ?? []) as Pick<
    Child,
    "id" | "first_name" | "display_name" | "login_username"
  >[];

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
          Þegar barn er búið til skráir það sig inn á{" "}
          <Link href="/child/login" className="font-semibold text-evergreen-600 hover:underline">
            barnainnskráningu
          </Link>{" "}
          með sama notendanafni og lykilorði og þú valdir hér.
        </p>
      </section>

      <AddChildForm />

      {children.length === 0 ? (
        <div className="rounded-2xl border border-dashed border-neutral-200 bg-neutral-50/80 p-6 text-center text-sm text-neutral-500">
          Engin börn á listanum enn — búðu til fyrsta barnið með forminu hér fyrir ofan.
        </div>
      ) : (
        <ul className="space-y-3">
          {children.map((c) => {
            const name = c.display_name || c.first_name;
            const uname = c.login_username?.trim();
            const loginUrl = uname
              ? `/child/login?u=${encodeURIComponent(uname)}`
              : "/child/login";
            return (
              <li
                key={c.id}
                className="rounded-2xl border border-neutral-200/80 bg-white p-4 sm:p-5"
              >
                <div className="flex flex-col gap-3 sm:flex-row sm:items-start sm:justify-between">
                  <div className="min-w-0">
                    <p className="font-bold text-neutral-900">{name}</p>
                    {uname ? (
                      <p className="mt-1 font-mono text-sm text-neutral-600">
                        Notendanafn: <span className="font-semibold">{uname}</span>
                      </p>
                    ) : (
                      <p className="mt-1 text-xs text-amber-700">
                        Engin innskráning stillt — bættu við barni aftur eða uppfærðu gagnagrunn.
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
      )}
    </div>
  );
}
