import { Settings } from "lucide-react";

export default function SettingsPage() {
  return (
    <div className="space-y-4">
      <div className="p-1">
        <div className="flex items-center gap-3 mb-2">
          <Settings size={24} className="text-evergreen-500" />
          <h1 className="text-2xl font-bold text-neutral-900">Stillingar</h1>
        </div>
        <p className="text-sm text-neutral-500">
          Hér stillir þú fjölskyldu, öryggi, tilkynningar og app-hegðun.
        </p>
      </div>
      <p className="text-sm text-neutral-500">
        Aðgangsstýringar, tilkynningar og persónuvernd birtast hér.
      </p>
    </div>
  );
}
