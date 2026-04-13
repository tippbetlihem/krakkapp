"use server";

import { revalidatePath } from "next/cache";
import { createClient } from "@/lib/supabase/server";

export type CreateChildState = {
  error?: string;
  success?: boolean;
};

type CreateChildRpc = {
  ok?: boolean;
  error?: string;
  child_id?: string;
};

export async function createChild(
  _prevState: CreateChildState,
  formData: FormData
): Promise<CreateChildState> {
  const firstName = String(formData.get("first_name") ?? "").trim();
  const displayName = String(formData.get("display_name") ?? "").trim();
  const username = String(formData.get("login_username") ?? "").trim();
  const password = String(formData.get("password") ?? "").trim();
  const password2 = String(formData.get("password_confirm") ?? "").trim();
  const birthDateRaw = String(formData.get("birth_date") ?? "").trim();

  if (!firstName) {
    return { error: "Nafn vantar." };
  }
  if (username.length < 3) {
    return { error: "Notendanafn verður að vera a.m.k. 3 stafir." };
  }
  if (!/^[a-zA-Z0-9._-]+$/.test(username)) {
    return { error: "Notendanafn: aðeins bókstafir, tölustafir, punktur, bandstriki og undirstrik." };
  }
  if (password.length < 6) {
    return { error: "Lykilorð verður að vera a.m.k. 6 stafir." };
  }
  if (password !== password2) {
    return { error: "Lykilorðin stemma ekki." };
  }

  const supabase = await createClient();
  const {
    data: { user },
  } = await supabase.auth.getUser();

  if (!user) {
    return { error: "Þú ert ekki innskráð/ur." };
  }

  const { data, error } = await supabase.rpc("krakkapp_parent_create_child", {
    p_first_name: firstName,
    p_display_name: displayName || null,
    p_login_username: username,
    p_password: password,
    p_birth_date: birthDateRaw ? birthDateRaw : null,
  });

  if (error) {
    const msg = error.message ?? "";
    if (/function .* does not exist|PGRST202/i.test(msg)) {
      return {
        error:
          "Gagnagrunnurinn er ekki uppfærður. Keyrðu supabase/SQL sem er inná supabase/04_barna_innskraning.sql í Supabase.",
      };
    }
    return { error: msg || "Ekki tókst að búa til barn." };
  }

  const result = data as CreateChildRpc;
  if (!result?.ok) {
    if (result?.error === "username_taken") {
      return { error: "Þetta notendanafn er þegar í notkun. Veldu annað." };
    }
    if (result?.error === "password_too_short") {
      return { error: "Lykilorð of stutt." };
    }
    if (result?.error === "username_too_short") {
      return { error: "Notendanafn of stutt." };
    }
    return { error: "Ekki tókst að búa til barn." };
  }

  revalidatePath("/children");
  revalidatePath("/dashboard");
  return { success: true };
}
