import { Gift } from "lucide-react";

export default function RewardsPage() {
  return (
    <div className="space-y-4">
      <div className="p-1">
        <div className="flex items-center gap-3 mb-2">
          <Gift size={24} className="text-evergreen-500" />
          <h1 className="text-2xl font-bold text-neutral-900">Verðlaun</h1>
        </div>
        <p className="text-sm text-neutral-500">
          Stjórnaðu verðlaunum og innlausnarreglum út frá stigasöfnun barna.
        </p>
      </div>
      <p className="text-sm text-neutral-500">Verðlaunaval og innlausnarsaga birtast hér.</p>
    </div>
  );
}
