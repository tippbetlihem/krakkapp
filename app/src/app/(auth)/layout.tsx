export default function AuthLayout({
  children,
}: {
  children: React.ReactNode;
}) {
  return (
    <div className="min-h-full flex items-center justify-center bg-gradient-to-br from-evergreen-500 via-evergreen-600 to-evergreen-900 relative overflow-hidden px-4 py-12">
      {/* Floating blobs */}
      <div className="absolute w-80 h-80 rounded-full bg-gold-400 opacity-10 -top-24 -left-24 animate-[float1_8s_ease-in-out_infinite]" />
      <div className="absolute w-64 h-64 rounded-full bg-gold-300 opacity-8 -bottom-20 -right-16 animate-[float2_10s_ease-in-out_infinite]" />
      <div className="absolute w-48 h-48 rounded-full bg-citrus-300 opacity-10 top-1/3 right-[10%] animate-[float3_12s_ease-in-out_infinite]" />
      <div className="absolute w-32 h-32 rounded-full bg-mint-200 opacity-10 bottom-[25%] left-[12%] animate-[float2_9s_ease-in-out_infinite_reverse]" />
      <div className="absolute w-20 h-20 rounded-full bg-blush-100 opacity-15 top-[20%] left-[30%] animate-[float1_7s_ease-in-out_infinite_reverse]" />

      {/* Card */}
      <div className="relative z-10 w-full max-w-md">
        <div className="text-center mb-8">
          <h1 className="text-4xl font-extrabold text-white">
            Krakk<span className="text-gold-400">App</span>
          </h1>
          <p className="text-sm text-evergreen-200 mt-2">
            Náms- og verðlaunavettvangar fyrir börn
          </p>
        </div>
        <div className="bg-white rounded-3xl shadow-2xl p-8">
          {children}
        </div>
      </div>
    </div>
  );
}
