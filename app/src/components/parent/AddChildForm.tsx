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
    <section className="rounded-3xl border border-neutral-200/80 bg-white p-5 sm:p-6">
      <div className="mb-4 flex items-center gap-3">
        <div className="grid h-9 w-9 place-items-center rounded-xl bg-gold-50 text-gold-600">
          <UserPlus size={18} />
        </div>
        <h2 className="text-lg font-extrabold text-neutral-900">Bæta við barni</h2>
      </div>

      {state.error && (
        <p className="mb-4 rounded-xl bg-error-light px-3 py-2 text-sm text-error">{state.error}</p>
      )}
      {state.success && (
        <p className="mb-4 rounded-xl bg-mint-100 px-3 py-2 text-sm font-medium text-evergreen-700">
          Barn búið til. Þú getur nú afritað barna-ID og látið barnið skrá sig inn með PIN.
        </p>
      )}

      <form id="add-child-form" action={formAction} className="grid gap-4 sm:grid-cols-2">
        <div className="sm:col-span-1">
          <label htmlFor="first_name" className="mb-1 block text-xs font-semibold text-neutral-600">
            Fornafn <span className="text-error">*</span>
          </label>
          <input
            id="first_name"
            name="first_name"
            required
            autoComplete="given-name"
            placeholder="t.d. Alla"
            className="w-full rounded-xl border border-neutral-200 bg-neutral-50 px-3 py-2.5 text-sm outline-none focus:border-evergreen-400 focus:ring-2 focus:ring-evergreen-100"
          />
        </div>
        <div className="sm:col-span-1">
          <label htmlFor="display_name" className="mb-1 block text-xs font-semibold text-neutral-600">
            Birtingarnafn (valfrjálst)
          </label>
          <input
            id="display_name"
            name="display_name"
            autoComplete="nickname"
            placeholder="Eins og birtist í appinu"
            className="w-full rounded-xl border border-neutral-200 bg-neutral-50 px-3 py-2.5 text-sm outline-none focus:border-evergreen-400 focus:ring-2 focus:ring-evergreen-100"
          />
        </div>
        <div className="sm:col-span-1">
          <label htmlFor="pin_code" className="mb-1 block text-xs font-semibold text-neutral-600">
            PIN fyrir barnainnskráningu <span className="text-error">*</span>
          </label>
          <input
            id="pin_code"
            name="pin_code"
            type="password"
            required
            minLength={4}
            autoComplete="new-password"
            placeholder="A.m.k. 4 stafir"
            className="w-full rounded-xl border border-neutral-200 bg-neutral-50 px-3 py-2.5 text-sm outline-none focus:border-evergreen-400 focus:ring-2 focus:ring-evergreen-100"
          />
          <p className="mt-1 text-[11px] text-neutral-400">Barnið notar þetta ásamt barna-ID á /child/login</p>
        </div>
        <div className="sm:col-span-1">
          <label htmlFor="birth_date" className="mb-1 block text-xs font-semibold text-neutral-600">
            Fæðingardagur (valfrjálst)
          </label>
          <input
            id="birth_date"
            name="birth_date"
            type="date"
            className="w-full rounded-xl border border-neutral-200 bg-neutral-50 px-3 py-2.5 text-sm outline-none focus:border-evergreen-400 focus:ring-2 focus:ring-evergreen-100"
          />
        </div>
        <div className="sm:col-span-2">
          <button
            type="submit"
            disabled={pending}
            className="w-full rounded-2xl bg-evergreen-500 py-3 text-sm font-bold text-white shadow-sm transition-colors hover:bg-evergreen-600 disabled:cursor-not-allowed disabled:opacity-50 sm:w-auto sm:px-8"
          >
            {pending ? "Vista…" : "Vista barn"}
          </button>
        </div>
      </form>
    </section>
  );
}
