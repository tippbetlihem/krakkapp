import { Calculator, BookOpen, ClipboardCheck, Gift } from "lucide-react";

const features = [
  { icon: Calculator, text: "Stærðfræðiæfingar með stigakerfi" },
  { icon: BookOpen, text: "Upplestur og lestrarþjálfun" },
  { icon: ClipboardCheck, text: "Heimilisstörf með samþykktarflæði" },
  { icon: Gift, text: "Verðlaunakerfi sem hvetur börnin" },
];

export default function AuthLayout({
  children,
}: {
  children: React.ReactNode;
}) {
  return (
    <div className="min-h-full flex">
      {/* Left panel — Evergreen + animated blobs */}
      <div className="hidden lg:flex lg:w-1/2 relative overflow-hidden bg-gradient-to-br from-evergreen-500 to-evergreen-900 flex-col justify-center items-center px-12 text-center">
        {/* Blobs */}
        <div className="absolute w-72 h-72 rounded-full bg-gold-400 opacity-10 -top-20 -left-20 animate-[float1_8s_ease-in-out_infinite]" />
        <div className="absolute w-56 h-56 rounded-full bg-gold-300 opacity-8 -bottom-16 -right-10 animate-[float2_10s_ease-in-out_infinite]" />
        <div className="absolute w-40 h-40 rounded-full bg-citrus-300 opacity-10 top-1/2 right-[10%] animate-[float3_12s_ease-in-out_infinite]" />
        <div className="absolute w-24 h-24 rounded-full bg-mint-200 opacity-10 bottom-[20%] left-[15%] animate-[float2_9s_ease-in-out_infinite_reverse]" />

        <div className="relative z-10">
          <h1 className="text-5xl font-extrabold text-white mb-2">
            Krakk<span className="text-gold-400">App</span>
          </h1>
          <p className="text-evergreen-200 text-base mb-10">
            Náms- og verðlaunavettvangar<br />fyrir börn og foreldra
          </p>
          <div className="flex flex-col gap-4 text-left max-w-xs mx-auto">
            {features.map((f) => (
              <div key={f.text} className="flex items-center gap-3 text-white/80 text-sm">
                <div className="w-10 h-10 rounded-xl bg-white/10 flex items-center justify-center flex-shrink-0">
                  <f.icon size={18} className="text-white/90" />
                </div>
                <span>{f.text}</span>
              </div>
            ))}
          </div>
        </div>
      </div>

      {/* Right panel — form */}
      <div className="flex-1 flex flex-col justify-center px-6 py-12 lg:px-16 bg-white">
        <div className="w-full max-w-sm mx-auto">
          {/* Mobile logo */}
          <div className="lg:hidden text-center mb-8">
            <h1 className="text-3xl font-extrabold text-evergreen-500">
              Krakk<span className="text-gold-400">App</span>
            </h1>
            <p className="text-sm text-neutral-500 mt-1">
              Náms- og verðlaunavettvangar fyrir börn
            </p>
          </div>
          {children}
        </div>
      </div>
    </div>
  );
}
