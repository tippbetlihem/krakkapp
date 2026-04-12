export default function AuthLayout({
  children,
}: {
  children: React.ReactNode;
}) {
  return (
    <div className="min-h-full flex items-center justify-center bg-neutral-50 px-4 py-12">
      <div className="w-full max-w-sm">
        <div className="text-center mb-8">
          <h1 className="text-3xl font-bold text-navy-500">
            Krakk<span className="text-gold-400">App</span>
          </h1>
          <p className="text-sm text-neutral-500 mt-1">
            Náms- og verðlaunavettvangar fyrir börn
          </p>
        </div>
        {children}
      </div>
    </div>
  );
}
