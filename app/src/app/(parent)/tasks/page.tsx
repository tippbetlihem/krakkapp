import { ClipboardCheck } from "lucide-react";

export default function TasksPage() {
  return (
    <div className="space-y-4">
      <div className="p-1">
        <div className="flex items-center gap-3 mb-2">
          <ClipboardCheck size={24} className="text-evergreen-500" />
          <h1 className="text-2xl font-bold text-neutral-900">Verkefni</h1>
        </div>
        <p className="text-sm text-neutral-500">
          Skipuleggðu verkefni barna, skiladaga og framvindu á einum stað.
        </p>
      </div>
      <p className="text-sm text-neutral-500">Verkefnalisti og staða verkefna birtist hér.</p>
    </div>
  );
}
