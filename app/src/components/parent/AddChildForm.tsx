"use client";

import { useActionState, useEffect } from "react";
import { UserPlus } from "lucide-react";
import { createChild, type CreateChildState } from "@/lib/parent/child-actions";

const initial: CreateChildState = {};

export function AddChildForm() {
  const [state, formAction, pending] = useActionState(createChild, initial);

  useEffect(() => {
    if (state.success) {
      const form = document.getElementById("add-child-form") as HTMLFormElement | null;
      form?.reset();
    }
  }, [state.success]);

  return (
    <section
      id="skra-barn"
      className="rounded-3xl border-2 border-evergreen-200/80 bg-white p-5 shadow-sm sm:p-6"
    >
      <div className="mb-5 flex items-center gap-3">
        <div className="grid h-10 w-10 place-items-center rounded-xl bg-gold-50 text-gold-600">
          <UserPlus size={20} />
        </div>
        <div>
          <h2 className="text-lg font-extrabold text-neutral-900">Skrá nýtt barn</h2>
          <p className="text-xs text-neutral-500">
            Fylltu út nafn og aldur hér; síðan notendanafn og lykilorð sem barnið notar við innskráningu.
          </p>
        </div>
      </div>

      {state.error && (
        <p className="mb-4 rounded-xl bg-error-light px-3 py-2 text-sm text-error">{state.error}</p>
      )}
      {state.success && (
        <p className="mb-4 rounded-xl bg-mint-100 px-3 py-2 text-sm font-medium text-evergreen-700">
          Barn skráð. Farðu á aðalsíðu og veldu „Ég er barn“ til að prófa innskráningu.
        </p>
      )}

      <form id="add-child-form" action={formAction} className="space-y-8">
        <fieldset className="space-y-4 border-0 p-0">
          <legend className="mb-1 text-xs font-bold uppercase tracking-wide text-evergreen-700">
            Upplýsingar um barn
          </legend>

          <div>
            <label htmlFor="first_name" className="mb-1 block text-xs font-semibold text-neutral-600">
              Nafn <span className="text-error">*</span>
            </label>
            <input
              id="first_name"
              name="first_name"
              required
              autoComplete="name"
              placeholder="t.d. Anna Jónsdóttir"
              className="w-full rounded-xl border border-neutral-200 bg-neutral-50 px-3 py-2.5 text-sm outline-none focus:border-evergreen-400 focus:ring-2 focus:ring-evergreen-100"
            />
            <p className="mt-1 text-[11px] text-neutral-400">Kennilegt nafn (skráð í kerfinu).</p>
          </div>

          <div>
            <label htmlFor="display_name" className="mb-1 block text-xs font-semibold text-neutral-600">
              Birtingarnafn í appi <span className="font-normal text-neutral-400">(valfrjálst)</span>
            </label>
            <input
              id="display_name"
              name="display_name"
              autoComplete="nickname"
              placeholder="t.d. Anna — ef autt birtist sama og nafn hér að ofan"
              className="w-full rounded-xl border border-neutral-200 bg-neutral-50 px-3 py-2.5 text-sm outline-none focus:border-evergreen-400 focus:ring-2 focus:ring-evergreen-100"
            />
          </div>

          <div>
            <label htmlFor="birth_date" className="mb-1 block text-xs font-semibold text-neutral-600">
              Fæðingardagur <span className="font-normal text-neutral-400">(valfrjálst)</span>
            </label>
            <input
              id="birth_date"
              name="birth_date"
              type="date"
              className="w-full max-w-xs rounded-xl border border-neutral-200 bg-neutral-50 px-3 py-2.5 text-sm outline-none focus:border-evergreen-400 focus:ring-2 focus:ring-evergreen-100"
            />
            <p className="mt-1 text-[11px] text-neutral-400">
              Notað til aldurs og tölfræði (kerfið reiknar aldur úr dagsetningu).
            </p>
          </div>
        </fieldset>

        <fieldset className="space-y-4 border-0 border-t border-neutral-100 pt-6">
          <legend className="mb-1 text-xs font-bold uppercase tracking-wide text-evergreen-700">
            Innskráning barnsins
          </legend>
          <p className="text-[11px] text-neutral-500">
            Barnið slær þetta inn á barnasíðunni — veldu eitthvað sem barnið mannst eftir.
          </p>

          <div>
            <label htmlFor="login_username" className="mb-1 block text-xs font-semibold text-neutral-600">
              Notendanafn <span className="text-error">*</span>
            </label>
            <input
              id="login_username"
              name="login_username"
              required
              minLength={3}
              autoComplete="off"
              spellCheck={false}
              placeholder="t.d. anna_krakki"
              className="w-full rounded-xl border border-neutral-200 bg-neutral-50 px-3 py-2.5 font-mono text-sm outline-none focus:border-evergreen-400 focus:ring-2 focus:ring-evergreen-100"
            />
            <p className="mt-1 text-[11px] text-neutral-400">Verður að vera einstakt innan kerfisins.</p>
          </div>

          <div className="grid gap-4 sm:grid-cols-2">
            <div>
              <label htmlFor="password" className="mb-1 block text-xs font-semibold text-neutral-600">
                Lykilorð <span className="text-error">*</span>
              </label>
              <input
                id="password"
                name="password"
                type="password"
                required
                minLength={6}
                autoComplete="new-password"
                placeholder="A.m.k. 6 stafir"
                className="w-full rounded-xl border border-neutral-200 bg-neutral-50 px-3 py-2.5 text-sm outline-none focus:border-evergreen-400 focus:ring-2 focus:ring-evergreen-100"
              />
            </div>

            <div>
              <label htmlFor="password_confirm" className="mb-1 block text-xs font-semibold text-neutral-600">
                Staðfesta lykilorð <span className="text-error">*</span>
              </label>
              <input
                id="password_confirm"
                name="password_confirm"
                type="password"
                required
                minLength={6}
                autoComplete="new-password"
                placeholder="Sama og hér við hliðina"
                className="w-full rounded-xl border border-neutral-200 bg-neutral-50 px-3 py-2.5 text-sm outline-none focus:border-evergreen-400 focus:ring-2 focus:ring-evergreen-100"
              />
            </div>
          </div>
        </fieldset>

        <div>
          <button
            type="submit"
            disabled={pending}
            className="w-full rounded-2xl bg-evergreen-500 py-3.5 text-sm font-bold text-white shadow-sm transition-colors hover:bg-evergreen-600 disabled:cursor-not-allowed disabled:opacity-50 sm:w-auto sm:min-w-[200px] sm:px-10"
          >
            {pending ? "Vista…" : "Skrá barn"}
          </button>
        </div>
      </form>
    </section>
  );
}
