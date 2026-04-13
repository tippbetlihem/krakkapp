import { Settings, Shield, BellRing } from "lucide-react";

export default function SettingsPage() {
  return (
    <div className="space-y-5">
      <section className="rounded-3xl bg-white border border-neutral-200/80 p-5 sm:p-6">
        <div className="flex items-center gap-3 mb-1">
          <div className="grid place-items-center h-9 w-9 rounded-xl bg-neutral-100 text-neutral-600">
            <Settings size={18} />
          </div>
          <h1 className="text-xl font-extrabold text-neutral-900">Stillingar</h1>
        </div>
        <p className="text-sm text-neutral-500 leading-relaxed">
          Hér stillir þú fjölskyldu, öryggi, tilkynningar og app-hegðun.
        </p>
      </section>

      <div className="grid gap-4 sm:grid-cols-2">
        <PlaceholderCard icon={Shield} title="Aðgangsstýring" text="Foreldraheimildir og aðgangur birtist hér." />
        <PlaceholderCard icon={BellRing} title="Tilkynningar" text="Tímamörk og persónuverndarstillingar koma hér." />
      </div>
    </div>
  );
}

function PlaceholderCard({ icon: Icon, title, text }: { icon: typeof Settings; title: string; text: string }) {
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
