import { BottomNav } from "@/components/child/BottomNav";

export default function ChildLayout({
  children,
}: {
  children: React.ReactNode;
}) {
  return (
    <div className="flex flex-col min-h-full bg-gold-50">
      <main className="flex-1 pb-16">
        <div className="max-w-md mx-auto px-4 py-6">{children}</div>
      </main>
      <BottomNav />
    </div>
  );
}
