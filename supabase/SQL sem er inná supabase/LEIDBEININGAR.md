# KrakkApp — SQL Leiðbeiningar

**Gildandi handkeyrsluskrár** fyrir Supabase liggja í **þessari möppu** (`SQL sem er inná supabase`). Aðrar slóðir í verkefninu geta vísað hingað.

## Hvernig á að keyra

Farðu í **Supabase Dashboard > SQL Editor** og keyrðu skrárnar í þessari röð:

### Skref 1: `01_toflur.sql`
Býr til allar 17 töflurnar og grunn trigger-a.
- profiles (foreldri)
- children (barn)
- child_settings, child_math_settings, child_reading_settings
- tasks (heimilisstörf)
- math_sessions, math_session_questions
- reading_texts, child_favorite_texts, reading_sessions
- point_multipliers, points_ledger
- rewards, reward_redemptions
- child_daily_stats, child_weekly_stats

### Skref 2: `02_indexes_og_oryggi.sql`
- Allir indexes (hraðar fyrirspurnir)
- RLS (Row Level Security) á öllum töflum
- Tryggir að foreldri sér aðeins eigin gögn

### Skref 3: `03_triggers_og_sjoalfvirkt.sql`
- Sjálfvirk profile-stofnun við nýskráningu
- Sjálfvirk settings þegar barn er búið til
- Stig uppfærð sjálfkrafa í children töflu
- Dagleg tölfræði skráð sjálfkrafa
- Streak reiknuð sjálfkrafa
- Vikuleg samantekt (fall til að kalla á)

### Skref 4: `04_barna_innskraning.sql`
- Barna-innskráning með notendanafni og lykilorði (bcrypt)
- `child_auth_sessions`, RPC-föll (`krakkapp_child_login`, `krakkapp_parent_create_child`, o.fl.)
- Keyrðu **eftir** skref 3

## Ef villa kemur upp
- Keyrðu skrárnar í réttri röð (1 → 2 → 3 → 4)
- Ef tafla er nú þegar til, keyrðu `DROP TABLE IF EXISTS <nafn> CASCADE;` fyrst
- Ef þú vilt byrja alveg upp á nýtt, keyrðu þetta:
  ```sql
  DROP SCHEMA public CASCADE;
  CREATE SCHEMA public;
  GRANT ALL ON SCHEMA public TO postgres;
  GRANT ALL ON SCHEMA public TO public;
  ```
  og keyrðu svo allt aftur.
