import { ChildAppShell } from "@/components/child/ChildAppShell";

export default function ChildRootLayout({
  children,
}: {
  children: React.ReactNode;
}) {
  return <ChildAppShell>{children}</ChildAppShell>;
}
