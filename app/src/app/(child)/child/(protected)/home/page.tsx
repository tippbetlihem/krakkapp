import { Star, Flame, LogOut } from "lucide-react";
import { getChildProfileForRequest } from "@/lib/child/get-profile";

export default async function ChildHomePage() {
  const profile = await getChildProfileForRequest();
  const name = profile?.display_name || profile?.first_name || "Krakki";

  return (
    <div className="space-y-6 text-center">
      <div className="flex items-start justify-end">
        <form action="/api/child/logout" method="POST">
          <button
            type="submit"
            className="inline-flex items-center gap-1.5 rounded-full border border-neutral-200 bg-white px-3 py-1.5 text-xs font-semibold text-neutral-600 hover:bg-neutral-50"
          >
            <LogOut size={14} />
            Útskrá
          </button>
        </form>
      </div>

      <div>
        <h1 className="text-2xl font-bold text-neutral-900">Hæ, {name}!</h1>
        <p className="mt-1 text-sm text-neutral-500">Velkomin/n aftur</p>
      </div>

      <div className="space-y-3 rounded-2xl bg-white p-6 shadow-md">
        <div className="mx-auto flex h-16 w-16 items-center justify-center rounded-full bg-gold-100">
          <Star size={32} className="text-gold-500" />
        </div>
        <p className="text-4xl font-bold tabular-nums text-gold-500">
          {profile?.available_points ?? 0}
        </p>
        <p className="text-sm text-neutral-500">stig til að nota</p>
        <div className="flex justify-center gap-2">
          <span className="flex items-center gap-1 rounded-full bg-info-light px-3 py-1 text-xs font-semibold text-info">
            <Flame size={12} />
            {profile?.current_streak_days ?? 0} daga streak
          </span>
        </div>
      </div>

      <p className="text-sm text-neutral-400">
        Veldu stærðfræði, lestur eða verkefni hér að neðan
      </p>
    </div>
  );
}
