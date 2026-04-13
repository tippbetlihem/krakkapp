import { redirect } from "next/navigation";
import { getChildProfileForRequest } from "@/lib/child/get-profile";

export default async function ProtectedChildLayout({
  children,
}: {
  children: React.ReactNode;
}) {
  const profile = await getChildProfileForRequest();
  if (!profile) {
    redirect("/child/login");
  }
  return <>{children}</>;
}
