import { redirect } from "next/navigation";
import { getChildProfileForRequest } from "@/lib/child/get-profile";
import { ChildLoginForm } from "./ChildLoginForm";

export default async function ChildLoginPage() {
  const profile = await getChildProfileForRequest();
  if (profile) {
    redirect("/child/home");
  }

  return <ChildLoginForm />;
}
