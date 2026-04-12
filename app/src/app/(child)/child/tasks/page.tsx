import { ClipboardCheck } from "lucide-react";

export default function ChildTasksPage() {
  return (
    <div className="text-center space-y-6">
      <div className="w-16 h-16 rounded-2xl bg-navy-50 mx-auto flex items-center justify-center">
        <ClipboardCheck size={32} className="text-navy-500" />
      </div>
      <h1 className="text-2xl font-bold text-neutral-900">Verkefni</h1>
      <div className="bg-white rounded-2xl shadow-md p-8">
        <p className="text-neutral-500">Kemur bráðlega</p>
      </div>
    </div>
  );
}
