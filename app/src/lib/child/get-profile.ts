import { cache } from "react";
import { createAnonClient } from "@/lib/supabase/anon";
import { getChildSessionToken, type ChildSessionPayload } from "@/lib/child/session";

type RpcSessionResult = {
  ok?: boolean;
  child?: {
    id: string;
    first_name: string;
    display_name: string | null;
    available_points: number;
    current_streak_days: number;
  };
};

export async function fetchChildSessionProfile(
  token: string
): Promise<ChildSessionPayload | null> {
  const supabase = createAnonClient();
  const { data, error } = await supabase.rpc("krakkapp_child_session_profile", {
    p_token: token,
  });
  if (error || data == null) return null;
  const row = data as RpcSessionResult;
  if (!row.ok || !row.child) return null;
  const c = row.child;
  return {
    id: c.id,
    first_name: c.first_name,
    display_name: c.display_name,
    available_points: Number(c.available_points) || 0,
    current_streak_days: Number(c.current_streak_days) || 0,
  };
}

export const getChildProfileForRequest = cache(async (): Promise<ChildSessionPayload | null> => {
  const token = await getChildSessionToken();
  if (!token || token.length < 16) return null;
  return fetchChildSessionProfile(token);
});
