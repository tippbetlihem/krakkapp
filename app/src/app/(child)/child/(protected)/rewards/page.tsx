import { Gift } from "lucide-react";

export default function ChildRewardsPage() {
  return (
    <div className="space-y-6 text-center">
      <div className="mx-auto flex h-16 w-16 items-center justify-center rounded-2xl bg-gold-50">
        <Gift size={32} className="text-gold-500" />
      </div>
      <h1 className="text-2xl font-bold text-neutral-900">Verðlaun</h1>
      <div className="rounded-2xl bg-white p-8 shadow-md">
        <p className="text-neutral-500">Kemur bráðlega</p>
      </div>
    </div>
  );
}
