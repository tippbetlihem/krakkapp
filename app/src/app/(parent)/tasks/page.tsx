import { ClipboardCheck, ListTodo, RefreshCw } from "lucide-react";

export default function TasksPage() {
  return (
    <div className="space-y-5">
      <section className="rounded-3xl bg-white border border-neutral-200/80 p-5 sm:p-6">
        <div className="flex items-center gap-3 mb-1">
          <div className="grid place-items-center h-9 w-9 rounded-xl bg-evergreen-50 text-evergreen-600">
            <ClipboardCheck size={18} />
          </div>
          <h1 className="text-xl font-extrabold text-neutral-900">Verkefni</h1>
        </div>
        <p className="text-sm text-neutral-500 leading-relaxed">
          Skipuleggðu verkefni barna, skiladaga og framvindu á einum stað.
        </p>
      </section>

      <div className="grid gap-4 sm:grid-cols-2">
        <PlaceholderCard icon={ListTodo} title="Verkefnalisti" text="Listi og staða verkefna birtist hér." />
        <PlaceholderCard icon={RefreshCw} title="Endurtekningar" text="Reglur, áminningar og setningar koma hér." />
      </div>
    </div>
  );
}

function PlaceholderCard({ icon: Icon, title, text }: { icon: typeof ClipboardCheck; title: string; text: string }) {
  return (
    <div className="rounded-2xl border border-neutral-200/80 bg-white p-5">
      <div className="mb-2 flex items-center gap-2">
        <Icon size={15} className="text-neutral-400" />
        <p className="text-xs font-semibold text-neutral-700">{title}</p>
      </div>
      <p className="text-sm text-neutral-500">{text}</p>
    </div>
  );
}
