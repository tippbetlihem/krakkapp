export function AuthCard({ children }: { children: React.ReactNode }) {
  return (
    <div className="min-h-full flex items-center justify-center bg-cream px-4 py-12">
      <div className="w-full max-w-md">
        <div className="text-center mb-8">
          <h1 className="text-3xl font-extrabold text-evergreen-500">
            Krakk<span className="text-gold-400">App</span>
          </h1>
          <p className="text-sm text-neutral-500 mt-1">
            Nams- og verdlaunavettvangar fyrir born
          </p>
        </div>
        <div className="bg-white rounded-3xl shadow-[0_12px_40px_rgba(0,0,0,0.08)] p-8">
          {children}
        </div>
      </div>
    </div>
  );
}
