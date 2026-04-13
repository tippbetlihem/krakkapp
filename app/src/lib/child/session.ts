import { cookies } from "next/headers";

export const CHILD_SESSION_COOKIE = "krakkapp_child_token";

export async function getChildSessionToken(): Promise<string | undefined> {
  const jar = await cookies();
  return jar.get(CHILD_SESSION_COOKIE)?.value;
}

export type ChildSessionPayload = {
  id: string;
  first_name: string;
  display_name: string | null;
  available_points: number;
  current_streak_days: number;
};
