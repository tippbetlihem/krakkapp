import { Users } from "lucide-react";

export default function ChildrenPage() {
  return (
    <div>
      <div className="flex items-center gap-3 mb-6">
        <Users size={24} className="text-evergreen-500" />
        <h1 className="text-2xl font-bold text-neutral-900">Börn</h1>
      </div>
      <div className="bg-white rounded-2xl shadow-sm p-8 text-center text-neutral-500">
        Kemur bráðlega
      </div>
    </div>
  );
}
