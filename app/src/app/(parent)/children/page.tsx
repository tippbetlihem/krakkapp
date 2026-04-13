import { Users } from "lucide-react";

export default function ChildrenPage() {
  return (
    <div className="space-y-4">
      <div className="p-1">
        <div className="flex items-center gap-3 mb-2">
          <Users size={24} className="text-evergreen-500" />
          <h1 className="text-2xl font-bold text-neutral-900">Börn</h1>
        </div>
        <p className="text-sm text-neutral-500">
          Hér birtast upplýsingar um prófíla barna, stöðu og umsjón.
        </p>
      </div>
      <p className="text-sm text-neutral-500">Börn í fjölskyldu birtast hér.</p>
    </div>
  );
}
