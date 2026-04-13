import { Gift, Trophy, History } from "lucide-react";

export default function RewardsPage() {
  return (
    <div className="space-y-5">
      <section className="rounded-3xl bg-white border border-neutral-200/80 p-5 sm:p-6">
        <div className="flex items-center gap-3 mb-1">
          <div className="grid place-items-center h-9 w-9 rounded-xl bg-gold-50 text-gold-600">
            <Gift size={18} />
          </div>
          <h1 className="text-xl font-extrabold text-neutral-900">Verðlaun</h1>
        </div>
        <p className="text-sm text-neutral-500 leading-relaxed">
          Stjórnaðu verðlaunum og innlausnarreglum út frá stigasöfnun barna.
        </p>
      </section>

      <div className="grid gap-4 sm:grid-cols-2">
        <PlaceholderCard icon={Trophy} title="Verðlaunaval" text="Verðlaun og kostnaður í stigum birtist hér." />
        <PlaceholderCard icon={History} title="Innlausnir" text="Saga innlausna og stöður barna birtast hér." />
      </div>
    </div>
  );
}

function PlaceholderCard({ icon: Icon, title, text }: { icon: typeof Gift; title: string; text: string }) {
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
