import Link from "next/link";
import { redirect } from "next/navigation";
import { Sparkles, Users } from "lucide-react";
import { createClient } from "@/lib/supabase/server";

export default async function Home() {
  const supabase = await createClient();
  const {
    data: { user },
  } = await supabase.auth.getUser();

  if (user) {
    redirect("/dashboard");
  }

  return (
    <div className="flex min-h-[calc(100dvh-0px)] flex-col items-center justify-center bg-gradient-to-b from-evergreen-50/80 to-neutral-50 px-4 py-12">
      <div className="mb-8 text-center">
        <div className="mx-auto mb-4 flex h-16 w-16 items-center justify-center rounded-2xl bg-evergreen-500 text-white shadow-lg">
          <Sparkles size={32} />
        </div>
        <h1 className="text-3xl font-extrabold tracking-tight text-neutral-900">KrakkApp</h1>
        <p className="mt-2 text-sm text-neutral-600">Veldu hvernig þú ætlar að skrá þig inn</p>
      </div>

      <div className="grid w-full max-w-md gap-4 sm:grid-cols-2">
        <Link
          href="/login"
          className="group flex flex-col rounded-3xl border border-neutral-200/80 bg-white p-6 shadow-sm transition hover:border-evergreen-200 hover:shadow-md"
        >
          <div className="mb-3 flex h-11 w-11 items-center justify-center rounded-xl bg-evergreen-50 text-evergreen-600 transition group-hover:bg-evergreen-100">
            <Users size={22} />
          </div>
          <span className="text-lg font-extrabold text-neutral-900">Ég er foreldri</span>
          <span className="mt-1 text-sm text-neutral-500">Netfang og lykilorð aðgangs</span>
        </Link>

        <Link
          href="/child/login"
          className="group flex flex-col rounded-3xl border border-neutral-200/80 bg-white p-6 shadow-sm transition hover:border-gold-200 hover:shadow-md"
        >
          <div className="mb-3 flex h-11 w-11 items-center justify-center rounded-xl bg-gold-50 text-gold-600 transition group-hover:bg-gold-100">
            <Sparkles size={22} />
          </div>
          <span className="text-lg font-extrabold text-neutral-900">Ég er barn</span>
          <span className="mt-1 text-sm text-neutral-500">Notendanafn og lykilorð frá foreldri</span>
        </Link>
      </div>
    </div>
  );
}
