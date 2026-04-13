import { ClipboardCheck } from "lucide-react";

export default function TasksPage() {
  return (
    <div className="space-y-5">
      <div className="rounded-3xl bg-white border border-neutral-200 p-6 shadow-sm">
        <div className="flex items-center gap-3 mb-2">
        <ClipboardCheck size={24} className="text-evergreen-500" />
        <h1 className="text-2xl font-bold text-neutral-900">Verkefni</h1>
        </div>
        <p className="text-sm text-neutral-500">
          Skipuleggðu verkefni barna, skiladaga og framvindu á einum stað.
        </p>
      </div>

      <div className="grid gap-4 lg:grid-cols-2">
        <div className="rounded-2xl border border-neutral-200 bg-white p-6 text-neutral-500">
          Verkefnalisti og staða verkefna birtist hér.
        </div>
        <div className="rounded-2xl border border-neutral-200 bg-white p-6 text-neutral-500">
          Reglur, áminningar og endurtekningasetningar koma hér.
        </div>
      </div>
    </div>
  );
}
