"use server";

import { revalidatePath } from "next/cache";
import { createClient } from "@/lib/supabase/server";

export type CreateChildState = {
  error?: string;
  success?: boolean;
};

export async function createChild(
  _prevState: CreateChildState,
  formData: FormData
): Promise<CreateChildState> {
  const firstName = String(formData.get("first_name") ?? "").trim();
  const displayName = String(formData.get("display_name") ?? "").trim();
  const pin = String(formData.get("pin_code") ?? "").trim();
  const birthDateRaw = String(formData.get("birth_date") ?? "").trim();

  if (!firstName) {
    return { error: "Fornafn vantar." };
  }
  if (pin.length < 4) {
    return { error: "PIN verður að vera a.m.k. 4 stafir (fyrir barnainnskráningu)." };
  }

  const supabase = await createClient();
  const {
    data: { user },
  } = await supabase.auth.getUser();

  if (!user) {
    return { error: "Þú ert ekki innskráð/ur." };
  }

  const insert: Record<string, unknown> = {
    parent_id: user.id,
    first_name: firstName,
    display_name: displayName || null,
    pin_code: pin,
  };

  if (birthDateRaw) {
    insert.birth_date = birthDateRaw;
  }

  const { error } = await supabase.from("children").insert(insert);

  if (error) {
    return { error: error.message || "Ekki tókst að búa til barn." };
  }

  revalidatePath("/children");
  revalidatePath("/dashboard");
  return { success: true };
}
