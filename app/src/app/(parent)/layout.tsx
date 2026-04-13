import { redirect } from "next/navigation";
import { createClient } from "@/lib/supabase/server";
import { Sidebar } from "@/components/parent/Sidebar";
import { TopBar } from "@/components/parent/TopBar";

export default async function ParentLayout({
  children,
}: {
  children: React.ReactNode;
}) {
  const supabase = await createClient();
  const {
    data: { user },
  } = await supabase.auth.getUser();

  if (!user) {
    redirect("/login");
  }

  return (
    <div className="min-h-dvh bg-[#a7d8c8] lg:p-4">
      <div className="relative flex min-h-dvh lg:min-h-[calc(100dvh-32px)] lg:rounded-[28px] bg-[#f7f5f2] lg:border lg:border-white/70 overflow-hidden">
        <Sidebar />
        <div className="flex-1 flex flex-col min-w-0">
          <TopBar email={user.email} />
          <main className="flex-1 overflow-y-auto px-4 pb-8 pt-2 sm:px-6 lg:px-8">
            <div className="mx-auto w-full max-w-7xl">{children}</div>
          </main>
        </div>
      </div>
    </div>
  );
}
