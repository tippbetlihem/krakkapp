import Image from "next/image";

export default function AuthLayout({
  children,
}: {
  children: React.ReactNode;
}) {
  return (
    <div className="min-h-full flex items-center justify-center bg-cream px-4 py-8">
      <div className="w-full max-w-[920px] flex rounded-3xl shadow-[0_20px_60px_rgba(0,0,0,0.08)] overflow-visible bg-white relative">
        {/* Left — Form */}
        <div className="flex-1 flex flex-col justify-center px-8 py-10 sm:px-12 min-w-0 relative z-20">
          <div className="mb-6">
            <h1 className="text-2xl font-extrabold text-evergreen-500 tracking-tight">
              Krakk<span className="text-gold-400">App</span>
            </h1>
          </div>
          {children}
        </div>

        {/* Right — Mascot hero panel */}
        <div className="hidden md:block w-[400px] flex-shrink-0 relative overflow-visible rounded-r-3xl">
          {/* Gradient background — clipped to panel */}
          <div className="absolute inset-0 bg-gradient-to-br from-evergreen-500 via-evergreen-600 to-evergreen-900 rounded-r-3xl" />

          {/* Soft glow circles */}
          <div className="absolute w-64 h-64 rounded-full bg-gold-400 opacity-15 -top-20 -right-20 blur-2xl" />
          <div className="absolute w-48 h-48 rounded-full bg-mint-300 opacity-12 bottom-12 -left-16 blur-xl" />
          <div className="absolute w-32 h-32 rounded-full bg-citrus-400 opacity-10 top-1/3 right-8 blur-lg" />

          {/* Content */}
          <div className="relative z-10 h-full flex flex-col justify-between p-8">
            {/* Top text */}
            <div>
              <p className="text-gold-300 text-xs font-bold uppercase tracking-widest mb-2">
                Fyrir börn og foreldra
              </p>
              {/*<h2 className="text-white text-2xl font-extrabold leading-snug">
                Læra, vinna<br />
                og hafa gaman.
              </h2>*/}
            </div>

            {/* Spacer */}
            <div className="flex-1" />

            {/* Bottom tagline */}
            <div className="flex items-center gap-3">
              <div className="flex -space-x-2">
                <div className="w-7 h-7 rounded-full bg-gold-400 border-2 border-evergreen-600" />
                <div className="w-7 h-7 rounded-full bg-citrus-400 border-2 border-evergreen-600" />
                <div className="w-7 h-7 rounded-full bg-mint-300 border-2 border-evergreen-600" />
              </div>
              <p className="text-evergreen-200 text-xs">
                Stærðfræði · Lestur · Verkefni · Verðlaun
              </p>
            </div>
          </div>

          {/* Mascots — overflow into white area, above tagline */}
          {/* Green mascot — slightly behind */}
          <div className="absolute -bottom-6 -left-36 z-20 w-[480px] h-[480px] animate-[float2_8s_ease-in-out_infinite]">
            <Image
              src="/mascots/green.png"
              alt="KrakkApp mascot"
              fill
              style={{ inset: "-89px 0px 0px 17px", height: "430px" }}
              className="object-contain drop-shadow-[0_12px_32px_rgba(0,0,0,0.25)]"
            />
          </div>
          {/* Orange mascot — in front */}
          <div className="absolute -bottom-2 left-24 z-30 w-[360px] h-[360px] animate-[float1_7s_ease-in-out_infinite]">
            <Image
              src="/mascots/orange.png"
              alt="KrakkApp mascot"
              fill
              style={{ inset: "-47px 0px 0px -5px" }}
              className="object-contain drop-shadow-[0_12px_32px_rgba(0,0,0,0.25)]"
            />
          </div>
        </div>
      </div>
    </div>
  );
}
