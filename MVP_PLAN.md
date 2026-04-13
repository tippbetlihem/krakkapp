# KrakkApp MVP — Framkvæmdaáætlun

Síðast uppfært: 2026-04-13

---

## Staða verkefnis

| Liður | Staða |
|-------|-------|
| SQL gagnagrunnur (17 töflur, triggers, RLS) | Keyrður á Supabase |
| SQL barna auth (04_barna_innskraning.sql) | Skrá til — **vantar að keyra** |
| Foreldra auth (signup, login, forgot-password) | Live á Vercel |
| Foreldra layout (Sidebar, TopBar, Dashboard) | Live á Vercel |
| Barna auth (username/password, session, API) | Kóði tilbúinn |
| Barna layout (BottomNav, AppShell, Home) | Kóði tilbúinn |
| Bæta við barni (AddChildForm + RPC) | Kóði tilbúinn |
| Litapaletta (Fresh and Bright) | Live á Vercel |
| Vercel + GitHub tenging | Virkar |
| Login síða með mascots | Live á Vercel |

---

## FASI 1: Grunnur klár (tenging virkar)

> Markmið: Foreldri getur búið til barn, barn getur skráð sig inn.

- [ ] Keyra `04_barna_innskraning.sql` á Supabase SQL Editor
- [ ] Endurnefna `middleware.ts` → `proxy.ts` (Next.js 16 deprecation)
- [ ] Prófa "Bæta við barni" — foreldri fylli út form, barn birtist á lista
- [ ] Prófa barna login — barn skráir sig inn með notendanafni og lykilorði
- [ ] Prófa barna home page — sér nafn, stig, streak
- [ ] Pusho og deploy-a

---

## FASI 2: Stærðfræði (kjarni appsins)

> Markmið: Barn getur byrjað stærðfræðilotu, svarað dæmum, og fengið stig.

### 2a — Foreldri stillir stærðfræði
- [ ] Stærðfræðistillingar síða (`/children/[id]/math-settings`)
- [ ] Form: erfiðleikastig, leyfðar aðgerðir (+−×÷), talnabil, fjöldi spurninga
- [ ] Vista í `child_math_settings` töflu
- [ ] Stig per rétt/rangt svar stillanlegt

### 2b — Barn leysir stærðfræðilotu
- [ ] Stærðfræði síða (`/child/math`) — "Byrja lotu" takki
- [ ] Sækja stillingar og búa til spurningar (client-side generation)
- [ ] Spurningaskjár: sýna dæmi, input svæði, senda svar
- [ ] Rétt svar → græn glow + stig | Rangt svar → rauð shake
- [ ] Sleppa spurningu möguleiki (skráð sérstaklega)
- [ ] Niðurstöðuskjár: rétt/rangt/sleppt, nákvæmni %, heildarstig
- [ ] Tímamælir (ef foreldri kveikti á honum)

### 2c — Stig skráð
- [ ] Vista `math_session` og `math_session_questions` í gagnagrunn
- [ ] Reikna `accuracy_percent`, `base_points_earned`, `final_points_earned`
- [ ] Athuga virka `point_multipliers` og nota ef til
- [ ] Skrifa í `points_ledger` (trigger uppfærir `children.available_points`)
- [ ] Staðfesta að `child_daily_stats` uppfærist sjálfkrafa (trigger)

---

## FASI 3: Heimilisstörf

> Markmið: Foreldri býr til verkefni, barn skilar, foreldri samþykkir.

### 3a — Foreldri býr til verkefni
- [ ] Verkefnasíða foreldris (`/tasks`) — listi + "Nýtt verkefni" form
- [ ] Form: titill, lýsing, flokkur, stig, skiladagur, endurtekið
- [ ] Velja hvaða barn fær verkefnið
- [ ] Vista í `tasks` töflu

### 3b — Barn sér og skilar verkefni
- [ ] Verkefnasíða barns (`/child/tasks`) — listi (pending, submitted, approved)
- [ ] "Merkja sem lokið" takki → status breytist í `submitted`
- [ ] Ljósmyndaupphleðsla ef `requires_photo_proof = true` (Supabase Storage)

### 3c — Foreldri samþykkir/hafnar
- [ ] Verkefni sem bíða samþykkis á foreldra dashboard og `/tasks`
- [ ] Samþykkja → stig í `points_ledger` | Hafna → aftur í `pending`
- [ ] Skilaboð til barns (`parent_feedback`)

---

## FASI 4: Dashboard með raunverulegum gögnum

> Markmið: Foreldri sér yfirlit, barn sér sína framvindu.

### 4a — Foreldra dashboard
- [ ] Stat cards efst: heildar stig, streak, verkefni lokið, lotur lokið
- [ ] Per barn: circular progress (dagmarkmið), nákvæmni, 7-daga trend
- [ ] Verkefni sem bíða samþykkis (quick actions)
- [ ] Virkasta barn vikunnar

### 4b — Barna dashboard
- [ ] Hero: stig, streak, virkur bónus
- [ ] Framvinda dagsins: circular progress (dagmarkmið)
- [ ] Stærðfræði í dag: rétt/rangt/sleppt tölur
- [ ] Flýtileiðir í stærðfræði, lestur, verkefni, verðlaun

---

## FASI 5: Upplestur

> Markmið: Barn les texta upphátt, foreldri sér nákvæmni.

- [ ] Upplestursstillingar (`/children/[id]/reading-settings`)
- [ ] Textasafn (`reading_texts`) — kerfi textar og eigin textar
- [ ] Upplestur lota (`/child/reading`) — sýna texta, byrja upptöku
- [ ] Speech-to-text (Web Speech API eða annað) — samanburður við texta
- [ ] Nákvæmniútreikningur → ef yfir threshold fær barn stig
- [ ] Stig í `points_ledger`
- [ ] Foreldri getur review-að lotu (`parent_reviewed`, `review_notes`)

---

## FASI 6: Verðlaun og bónusar

> Markmið: Foreldri býr til verðlaun, barn innleysir. Bónusar hvetja.

### 6a — Verðlaun
- [ ] Verðlaunasíða foreldris (`/rewards`) — búa til, breyta, eyða
- [ ] Verðlaunasíða barns (`/child/rewards`) — skoða lista, biðja um innlausn
- [ ] Foreldri samþykkir/hafnar innlausn
- [ ] Stig dregin af í `points_ledger` (debit)
- [ ] Ef hafnað → stig skilað til baka

### 6b — Bónusar / multipliers
- [ ] Foreldri býr til tímabundinn bónus (`point_multipliers`)
- [ ] Titill sem barn sér (t.d. "Helgarbónus! 2x stig")
- [ ] Virkar sjálfkrafa þegar stig eru reiknuð (activity_type + tímabil)
- [ ] Sýna virkan bónus á barna dashboard

---

## FASI 7: Greiningar fyrir foreldra

> Markmið: Foreldri sér ítarlegar greiningar á frammistöðu barns.

Byggt á `krakkapp_greiningar.xlsx` — 20 greiningarhugmyndir í forgangsröð.

### 7a — SQL viðbætur
- [ ] Bæta `misread_words_json` (JSONB) við `reading_sessions`
- [ ] Bæta `error_pattern` (TEXT) við `math_session_questions`
- [ ] Búa til DB views/functions fyrir aggregation per klukkutíma (greining #4)
- [ ] (Seinna) Play time kerfi ef ákveðið

### 7b — Greiningasíða foreldris (`/children/[id]/analytics`)
Forgangur samkvæmt Excel:

| # | Greining | Birtingarform | Staða |
|---|---------|--------------|-------|
| 1 | Heildarstig | Tölukort + línurit 7 daga | [ ] |
| 2 | Virkni síðustu 7 daga | Súlurit per dag | [ ] |
| 3 | Æfingatími | KPI kort | [ ] |
| 4 | Lestrarnákvæmni | Línurit + prósenta | [ ] |
| 5 | Rétt svör í stærðfræði % | Súlurit + hringrit | [ ] |
| 6 | Sterkasta svið | Highlighted kort | [ ] |
| 7 | Veikasta svið | Highlighted kort | [ ] |
| 8 | Streak / dagar í röð | Streak kort + dagatals sýn | [ ] |
| 9 | Lestrahraði | Línurit | [ ] |
| 10 | Stærðfræðihraði | Línurit + KPI | [ ] |
| 11 | Erfiðust dæmi | Tafla + súlurit | [ ] |
| 12 | Endurteknar villur | Listi | [ ] |
| 13 | Erfiðleikastig sem hentar | Status kort | [ ] |
| 14 | Áhrif bónusa | Samanburðarsúlur | [ ] |
| 15 | Verkefni frá foreldri | Checklisti | [ ] |
| 16 | Markmið vikunnar | Progress bar | [ ] |
| 17 | Orð sem valda erfiðleikum | Tag cloud / listi | [ ] |
| 18 | Virkasti tími dags | Hitakort | [ ] |
| 19 | Klúrunarhlutfall | KPI kort | [ ] |
| 20 | Sjálfvirkar innsýnir | AI-textakort | [ ] |

---

## FASI 8: Fínpúss og polish

- [ ] Hreyfingar: glow (rétt svar), shake (rangt), count-up (stig), pulse (streak)
- [ ] Circular progress animation (draw-in, 800ms)
- [ ] Responsive: prófa á síma, spjaldtölvu, skjáborði
- [ ] Error handling: fallback UI, loading states, toast notifications
- [ ] Accessibility: aria-labels, keyboard navigation, color contrast
- [ ] Performance: lazy loading, image optimization, caching
- [ ] Öryggisyfirferð: RLS staðfesting, input validation, CSRF

---

## Tæknistakkur

| Tækni | Notkun |
|-------|--------|
| Next.js 16 | Frontend + API routes |
| TypeScript | Týpu öryggi |
| Tailwind CSS v4 | Stíll |
| Supabase | PostgreSQL + Auth + Storage + RLS |
| Lucide React | Icons |
| Inter | Leturgerð |
| Vercel | Hosting + CI/CD |

---

## Litapaletta — Fresh and Bright

| Litur | Hex | Hlutverk |
|-------|-----|----------|
| Evergreen Mist | `#324F44` | Aðallitur |
| Golden Sun | `#FFD746` | Stig, barna accent |
| Citrus Burst | `#FF9B2E` | Hlýr accent, streak |
| Minted Cream | `#D9E8C1` | Success, blobs |
| Soft Blush | `#F6E1DE` | Hlýr bakgrunnur |
| Vanilla Cream | `#F3EFE6` | Síðubakgrunnur |
