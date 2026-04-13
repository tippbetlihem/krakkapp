import Image from "next/image";

export default function AuthLayout({
  children,
}: {
  children: React.ReactNode;
}) {
  return (
    <div className="min-h-full flex items-center justify-center bg-cream px-4 py-8">
      <div className="w-full max-w-4xl flex rounded-3xl shadow-2xl overflow-hidden bg-white">
        {/* Left — Form */}
        <div className="flex-1 flex flex-col justify-center px-8 py-10 sm:px-12">
          <div className="mb-8">
            <h1 className="text-3xl font-extrabold text-evergreen-500">
              Krakk<span className="text-gold-400">App</span>
            </h1>
            <p className="text-sm text-neutral-500 mt-1">
              Náms- og verðlaunavettvangar fyrir börn
            </p>
          </div>
          {children}
        </div>

        {/* Right — Mascots showcase */}
        <div className="hidden md:flex w-[380px] flex-shrink-0 relative bg-gradient-to-br from-mint-100 via-gold-50 to-blush-100 overflow-hidden items-end justify-center">
          {/* Decorative blobs */}
          <div className="absolute w-48 h-48 rounded-full bg-gold-200 opacity-40 -top-12 -right-12" />
          <div className="absolute w-32 h-32 rounded-full bg-mint-200 opacity-50 top-16 -left-8" />
          <div className="absolute w-24 h-24 rounded-full bg-blush-200 opacity-40 bottom-32 -right-6" />
          <div className="absolute w-20 h-20 rounded-full bg-citrus-100 opacity-50 top-1/2 right-12" />

          {/* Mascot grid */}
          <div className="relative z-10 p-6 pb-0">
            {/* Back row */}
            <div className="flex justify-center gap-2 mb-[-12px]">
              <div className="w-24 h-24 relative animate-[float1_6s_ease-in-out_infinite]">
                <Image src="/mascots/row-1-column-3.png" alt="" fill className="object-contain drop-shadow-lg" />
              </div>
              <div className="w-28 h-28 relative animate-[float2_8s_ease-in-out_infinite]">
                <Image src="/mascots/row-2-column-3.png" alt="" fill className="object-contain drop-shadow-lg" />
              </div>
              <div className="w-24 h-24 relative animate-[float3_7s_ease-in-out_infinite]">
                <Image src="/mascots/row-3-column-1.png" alt="" fill className="object-contain drop-shadow-lg" />
              </div>
            </div>
            {/* Front row — larger */}
            <div className="flex justify-center gap-1">
              <div className="w-32 h-32 relative animate-[float2_9s_ease-in-out_infinite_reverse]">
                <Image src="/mascots/row-1-column-1.png" alt="" fill className="object-contain drop-shadow-xl" />
              </div>
              <div className="w-36 h-36 relative animate-[float1_7s_ease-in-out_infinite]">
                <Image src="/mascots/row-2-column-1.png" alt="" fill className="object-contain drop-shadow-xl" />
              </div>
              <div className="w-32 h-32 relative animate-[float3_10s_ease-in-out_infinite]">
                <Image src="/mascots/row-3-column-3.png" alt="" fill className="object-contain drop-shadow-xl" />
              </div>
            </div>
          </div>
        </div>
      </div>
    </div>
  );
}
