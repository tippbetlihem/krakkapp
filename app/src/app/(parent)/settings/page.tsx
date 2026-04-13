import { Settings } from "lucide-react";

export default function SettingsPage() {
  return (
    <div className="space-y-5">
      <div className="rounded-3xl bg-white border border-neutral-200 p-6 shadow-sm">
        <div className="flex items-center gap-3 mb-2">
        <Settings size={24} className="text-evergreen-500" />
        <h1 className="text-2xl font-bold text-neutral-900">Stillingar</h1>
        </div>
        <p className="text-sm text-neutral-500">
          Hér stillir þú fjölskyldu, öryggi, tilkynningar og app-hegðun.
        </p>
      </div>

      <div className="grid gap-4 lg:grid-cols-2">
        <div className="rounded-2xl border border-neutral-200 bg-white p-6 text-neutral-500">
          Aðgangsstýringar og foreldraheimildir birtast hér.
        </div>
        <div className="rounded-2xl border border-neutral-200 bg-white p-6 text-neutral-500">
          Tilkynningar, tímamörk og persónuverndarstillingar koma hér.
        </div>
      </div>
    </div>
  );
}
