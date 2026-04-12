import { Star, Flame } from "lucide-react";

export default function ChildHomePage() {
  return (
    <div className="text-center space-y-6">
      <div>
        <h1 className="text-2xl font-bold text-neutral-900">Hæ!</h1>
        <p className="text-sm text-neutral-500 mt-1">Velkomin/n aftur</p>
      </div>

      <div className="bg-white rounded-2xl shadow-md p-6 space-y-3">
        <div className="w-16 h-16 rounded-full bg-gold-100 mx-auto flex items-center justify-center">
          <Star size={32} className="text-gold-500" />
        </div>
        <p className="text-4xl font-bold text-gold-500 tabular-nums">0</p>
        <p className="text-sm text-neutral-500">stig til að nota</p>
        <div className="flex justify-center gap-2">
          <span className="bg-info-light text-info text-xs font-semibold px-3 py-1 rounded-full flex items-center gap-1">
            <Flame size={12} /> 0 daga streak
          </span>
        </div>
      </div>

      <p className="text-sm text-neutral-400">
        Veldu stærðfræði, lestur eða verkefni hér að neðan
      </p>
    </div>
  );
}
