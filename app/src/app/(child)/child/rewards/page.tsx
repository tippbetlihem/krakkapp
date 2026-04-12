import { Gift } from "lucide-react";

export default function ChildRewardsPage() {
  return (
    <div className="text-center space-y-6">
      <div className="w-16 h-16 rounded-2xl bg-gold-50 mx-auto flex items-center justify-center">
        <Gift size={32} className="text-gold-500" />
      </div>
      <h1 className="text-2xl font-bold text-neutral-900">Verðlaun</h1>
      <div className="bg-white rounded-2xl shadow-md p-8">
        <p className="text-neutral-500">Kemur bráðlega</p>
      </div>
    </div>
  );
}
