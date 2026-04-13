-- ╔═══════════════════════════════════════════════════════════════╗
-- ║  KrakkApp — Skref 2: Indexes og Row Level Security          ║
-- ║  Keyrðu EFTIR 01_toflur.sql                                 ║
-- ╚═══════════════════════════════════════════════════════════════╝


-- ─────────────────────────────────────────────────────────────
-- INDEXES — Hraðar fyrirspurnir
-- ─────────────────────────────────────────────────────────────
-- Án þessara væri gagnagrunnurinn hægur þegar gögn stækka.

CREATE INDEX IF NOT EXISTS idx_children_parent_id                ON children(parent_id);
CREATE INDEX IF NOT EXISTS idx_tasks_child_id                    ON tasks(child_id);
CREATE INDEX IF NOT EXISTS idx_tasks_parent_id                   ON tasks(parent_id);
CREATE INDEX IF NOT EXISTS idx_tasks_status                      ON tasks(status);
CREATE INDEX IF NOT EXISTS idx_math_sessions_child_id            ON math_sessions(child_id);
CREATE INDEX IF NOT EXISTS idx_math_sessions_status              ON math_sessions(status);
CREATE INDEX IF NOT EXISTS idx_math_session_questions_session_id  ON math_session_questions(math_session_id);
CREATE INDEX IF NOT EXISTS idx_reading_sessions_child_id         ON reading_sessions(child_id);
CREATE INDEX IF NOT EXISTS idx_reading_sessions_status           ON reading_sessions(status);
CREATE INDEX IF NOT EXISTS idx_reading_sessions_text_id          ON reading_sessions(reading_text_id);
CREATE INDEX IF NOT EXISTS idx_points_ledger_child_id            ON points_ledger(child_id);
CREATE INDEX IF NOT EXISTS idx_points_ledger_source_type         ON points_ledger(source_type);
CREATE INDEX IF NOT EXISTS idx_points_ledger_created_at          ON points_ledger(created_at);
CREATE INDEX IF NOT EXISTS idx_point_multipliers_child_id        ON point_multipliers(child_id);
CREATE INDEX IF NOT EXISTS idx_point_multipliers_ends_at         ON point_multipliers(ends_at);
CREATE INDEX IF NOT EXISTS idx_reward_redemptions_child_id       ON reward_redemptions(child_id);
CREATE INDEX IF NOT EXISTS idx_reward_redemptions_status         ON reward_redemptions(status);


-- ─────────────────────────────────────────────────────────────
-- ROW LEVEL SECURITY (RLS) — Kveikt á öllum töflum
-- ─────────────────────────────────────────────────────────────
-- Þetta tryggir að foreldri A sér ALDREI gögn foreldris B.
-- Supabase þarf RLS til að vera öruggt.

ALTER TABLE profiles               ENABLE ROW LEVEL SECURITY;
ALTER TABLE children                ENABLE ROW LEVEL SECURITY;
ALTER TABLE child_settings          ENABLE ROW LEVEL SECURITY;
ALTER TABLE child_math_settings     ENABLE ROW LEVEL SECURITY;
ALTER TABLE child_reading_settings  ENABLE ROW LEVEL SECURITY;
ALTER TABLE tasks                   ENABLE ROW LEVEL SECURITY;
ALTER TABLE math_sessions           ENABLE ROW LEVEL SECURITY;
ALTER TABLE math_session_questions  ENABLE ROW LEVEL SECURITY;
ALTER TABLE reading_texts           ENABLE ROW LEVEL SECURITY;
ALTER TABLE child_favorite_texts    ENABLE ROW LEVEL SECURITY;
ALTER TABLE reading_sessions        ENABLE ROW LEVEL SECURITY;
ALTER TABLE point_multipliers       ENABLE ROW LEVEL SECURITY;
ALTER TABLE points_ledger           ENABLE ROW LEVEL SECURITY;
ALTER TABLE rewards                 ENABLE ROW LEVEL SECURITY;
ALTER TABLE reward_redemptions      ENABLE ROW LEVEL SECURITY;
ALTER TABLE child_daily_stats       ENABLE ROW LEVEL SECURITY;
ALTER TABLE child_weekly_stats      ENABLE ROW LEVEL SECURITY;


-- ─────────────────────────────────────────────────────────────
-- HJÁLPARFALL: Er notandinn foreldri þessa barns?
-- ─────────────────────────────────────────────────────────────
-- Notað af RLS policies hér að neðan

CREATE OR REPLACE FUNCTION is_parent_of(p_child_id UUID)
RETURNS BOOLEAN AS $$
    SELECT EXISTS (
        SELECT 1 FROM children
        WHERE id = p_child_id AND parent_id = auth.uid()
    );
$$ LANGUAGE sql SECURITY DEFINER STABLE;


-- ─────────────────────────────────────────────────────────────
-- RLS POLICIES — Reglur um hver má sjá/breyta hverju
-- ─────────────────────────────────────────────────────────────
-- Endurkeyrsla: fjarlægja eldri policy með sama nafni á undan
DROP POLICY IF EXISTS "Users can view own profile" ON profiles;
DROP POLICY IF EXISTS "Users can update own profile" ON profiles;
DROP POLICY IF EXISTS "Parents can view own children" ON children;
DROP POLICY IF EXISTS "Parents can insert own children" ON children;
DROP POLICY IF EXISTS "Parents can update own children" ON children;
DROP POLICY IF EXISTS "Parents can view child settings" ON child_settings;
DROP POLICY IF EXISTS "Parents can insert child settings" ON child_settings;
DROP POLICY IF EXISTS "Parents can update child settings" ON child_settings;
DROP POLICY IF EXISTS "Parents can view math settings" ON child_math_settings;
DROP POLICY IF EXISTS "Parents can insert math settings" ON child_math_settings;
DROP POLICY IF EXISTS "Parents can update math settings" ON child_math_settings;
DROP POLICY IF EXISTS "Parents can view reading settings" ON child_reading_settings;
DROP POLICY IF EXISTS "Parents can insert reading settings" ON child_reading_settings;
DROP POLICY IF EXISTS "Parents can update reading settings" ON child_reading_settings;
DROP POLICY IF EXISTS "Parents can view own tasks" ON tasks;
DROP POLICY IF EXISTS "Parents can insert own tasks" ON tasks;
DROP POLICY IF EXISTS "Parents can update own tasks" ON tasks;
DROP POLICY IF EXISTS "Parents can view child math sessions" ON math_sessions;
DROP POLICY IF EXISTS "Parents can insert child math sessions" ON math_sessions;
DROP POLICY IF EXISTS "Parents can update child math sessions" ON math_sessions;
DROP POLICY IF EXISTS "Parents can view child math questions" ON math_session_questions;
DROP POLICY IF EXISTS "Parents can insert child math questions" ON math_session_questions;
DROP POLICY IF EXISTS "Anyone can view active system texts" ON reading_texts;
DROP POLICY IF EXISTS "Parents can view own custom texts" ON reading_texts;
DROP POLICY IF EXISTS "Parents can insert custom texts" ON reading_texts;
DROP POLICY IF EXISTS "Parents can update own custom texts" ON reading_texts;
DROP POLICY IF EXISTS "Parents can view child favorites" ON child_favorite_texts;
DROP POLICY IF EXISTS "Parents can insert child favorites" ON child_favorite_texts;
DROP POLICY IF EXISTS "Parents can delete child favorites" ON child_favorite_texts;
DROP POLICY IF EXISTS "Parents can view child reading sessions" ON reading_sessions;
DROP POLICY IF EXISTS "Parents can insert child reading sessions" ON reading_sessions;
DROP POLICY IF EXISTS "Parents can update child reading sessions" ON reading_sessions;
DROP POLICY IF EXISTS "Parents can view own multipliers" ON point_multipliers;
DROP POLICY IF EXISTS "Parents can insert own multipliers" ON point_multipliers;
DROP POLICY IF EXISTS "Parents can update own multipliers" ON point_multipliers;
DROP POLICY IF EXISTS "Parents can delete own multipliers" ON point_multipliers;
DROP POLICY IF EXISTS "Parents can view child ledger" ON points_ledger;
DROP POLICY IF EXISTS "Parents can insert child ledger" ON points_ledger;
DROP POLICY IF EXISTS "Parents can view own rewards" ON rewards;
DROP POLICY IF EXISTS "Parents can insert own rewards" ON rewards;
DROP POLICY IF EXISTS "Parents can update own rewards" ON rewards;
DROP POLICY IF EXISTS "Parents can view child redemptions" ON reward_redemptions;
DROP POLICY IF EXISTS "Parents can insert child redemptions" ON reward_redemptions;
DROP POLICY IF EXISTS "Parents can update child redemptions" ON reward_redemptions;
DROP POLICY IF EXISTS "Parents can view child daily stats" ON child_daily_stats;
DROP POLICY IF EXISTS "Parents can insert child daily stats" ON child_daily_stats;
DROP POLICY IF EXISTS "Parents can update child daily stats" ON child_daily_stats;
DROP POLICY IF EXISTS "Parents can view child weekly stats" ON child_weekly_stats;
DROP POLICY IF EXISTS "Parents can insert child weekly stats" ON child_weekly_stats;
DROP POLICY IF EXISTS "Parents can update child weekly stats" ON child_weekly_stats;

-- profiles: Notandi sér aðeins eigin prófíl
CREATE POLICY "Users can view own profile"    ON profiles FOR SELECT USING (id = auth.uid());
CREATE POLICY "Users can update own profile"  ON profiles FOR UPDATE USING (id = auth.uid());

-- children: Foreldri sér/breytir aðeins eigin börnum
CREATE POLICY "Parents can view own children"   ON children FOR SELECT USING (parent_id = auth.uid());
CREATE POLICY "Parents can insert own children" ON children FOR INSERT WITH CHECK (parent_id = auth.uid());
CREATE POLICY "Parents can update own children" ON children FOR UPDATE USING (parent_id = auth.uid());

-- child_settings
CREATE POLICY "Parents can view child settings"   ON child_settings FOR SELECT USING (is_parent_of(child_id));
CREATE POLICY "Parents can insert child settings"  ON child_settings FOR INSERT WITH CHECK (is_parent_of(child_id));
CREATE POLICY "Parents can update child settings"  ON child_settings FOR UPDATE USING (is_parent_of(child_id));

-- child_math_settings
CREATE POLICY "Parents can view math settings"   ON child_math_settings FOR SELECT USING (is_parent_of(child_id));
CREATE POLICY "Parents can insert math settings"  ON child_math_settings FOR INSERT WITH CHECK (is_parent_of(child_id));
CREATE POLICY "Parents can update math settings"  ON child_math_settings FOR UPDATE USING (is_parent_of(child_id));

-- child_reading_settings
CREATE POLICY "Parents can view reading settings"   ON child_reading_settings FOR SELECT USING (is_parent_of(child_id));
CREATE POLICY "Parents can insert reading settings"  ON child_reading_settings FOR INSERT WITH CHECK (is_parent_of(child_id));
CREATE POLICY "Parents can update reading settings"  ON child_reading_settings FOR UPDATE USING (is_parent_of(child_id));

-- tasks
CREATE POLICY "Parents can view own tasks"   ON tasks FOR SELECT USING (parent_id = auth.uid());
CREATE POLICY "Parents can insert own tasks" ON tasks FOR INSERT WITH CHECK (parent_id = auth.uid());
CREATE POLICY "Parents can update own tasks" ON tasks FOR UPDATE USING (parent_id = auth.uid());

-- math_sessions
CREATE POLICY "Parents can view child math sessions"   ON math_sessions FOR SELECT USING (is_parent_of(child_id));
CREATE POLICY "Parents can insert child math sessions"  ON math_sessions FOR INSERT WITH CHECK (is_parent_of(child_id));
CREATE POLICY "Parents can update child math sessions"  ON math_sessions FOR UPDATE USING (is_parent_of(child_id));

-- math_session_questions (tengist lotu, ekki barni beint)
CREATE POLICY "Parents can view child math questions" ON math_session_questions FOR SELECT
    USING (EXISTS (SELECT 1 FROM math_sessions ms WHERE ms.id = math_session_questions.math_session_id AND is_parent_of(ms.child_id)));
CREATE POLICY "Parents can insert child math questions" ON math_session_questions FOR INSERT
    WITH CHECK (EXISTS (SELECT 1 FROM math_sessions ms WHERE ms.id = math_session_questions.math_session_id AND is_parent_of(ms.child_id)));

-- reading_texts (kerfi textar sjást af öllum, eigin textar aðeins af eiganda)
CREATE POLICY "Anyone can view active system texts" ON reading_texts FOR SELECT
    USING (is_system_text = true AND is_active = true);
CREATE POLICY "Parents can view own custom texts" ON reading_texts FOR SELECT
    USING (created_by_parent_id = auth.uid());
CREATE POLICY "Parents can insert custom texts" ON reading_texts FOR INSERT
    WITH CHECK (created_by_parent_id = auth.uid() AND is_system_text = false);
CREATE POLICY "Parents can update own custom texts" ON reading_texts FOR UPDATE
    USING (created_by_parent_id = auth.uid() AND is_system_text = false);

-- child_favorite_texts
CREATE POLICY "Parents can view child favorites"  ON child_favorite_texts FOR SELECT USING (is_parent_of(child_id));
CREATE POLICY "Parents can insert child favorites" ON child_favorite_texts FOR INSERT WITH CHECK (is_parent_of(child_id));
CREATE POLICY "Parents can delete child favorites" ON child_favorite_texts FOR DELETE USING (is_parent_of(child_id));

-- reading_sessions
CREATE POLICY "Parents can view child reading sessions"   ON reading_sessions FOR SELECT USING (is_parent_of(child_id));
CREATE POLICY "Parents can insert child reading sessions"  ON reading_sessions FOR INSERT WITH CHECK (is_parent_of(child_id));
CREATE POLICY "Parents can update child reading sessions"  ON reading_sessions FOR UPDATE USING (is_parent_of(child_id));

-- point_multipliers
CREATE POLICY "Parents can view own multipliers"   ON point_multipliers FOR SELECT USING (parent_id = auth.uid());
CREATE POLICY "Parents can insert own multipliers"  ON point_multipliers FOR INSERT WITH CHECK (parent_id = auth.uid());
CREATE POLICY "Parents can update own multipliers"  ON point_multipliers FOR UPDATE USING (parent_id = auth.uid());
CREATE POLICY "Parents can delete own multipliers"  ON point_multipliers FOR DELETE USING (parent_id = auth.uid());

-- points_ledger (aðeins SELECT og INSERT — engin UPDATE/DELETE, bókhaldið er óbreytanlegt)
CREATE POLICY "Parents can view child ledger"  ON points_ledger FOR SELECT USING (is_parent_of(child_id));
CREATE POLICY "Parents can insert child ledger" ON points_ledger FOR INSERT WITH CHECK (is_parent_of(child_id));

-- rewards
CREATE POLICY "Parents can view own rewards"   ON rewards FOR SELECT USING (parent_id = auth.uid());
CREATE POLICY "Parents can insert own rewards"  ON rewards FOR INSERT WITH CHECK (parent_id = auth.uid());
CREATE POLICY "Parents can update own rewards"  ON rewards FOR UPDATE USING (parent_id = auth.uid());

-- reward_redemptions
CREATE POLICY "Parents can view child redemptions"   ON reward_redemptions FOR SELECT USING (is_parent_of(child_id));
CREATE POLICY "Parents can insert child redemptions"  ON reward_redemptions FOR INSERT WITH CHECK (is_parent_of(child_id));
CREATE POLICY "Parents can update child redemptions"  ON reward_redemptions FOR UPDATE USING (is_parent_of(child_id));

-- child_daily_stats
CREATE POLICY "Parents can view child daily stats"   ON child_daily_stats FOR SELECT USING (is_parent_of(child_id));
CREATE POLICY "Parents can insert child daily stats"  ON child_daily_stats FOR INSERT WITH CHECK (is_parent_of(child_id));
CREATE POLICY "Parents can update child daily stats"  ON child_daily_stats FOR UPDATE USING (is_parent_of(child_id));

-- child_weekly_stats
CREATE POLICY "Parents can view child weekly stats"   ON child_weekly_stats FOR SELECT USING (is_parent_of(child_id));
CREATE POLICY "Parents can insert child weekly stats"  ON child_weekly_stats FOR INSERT WITH CHECK (is_parent_of(child_id));
CREATE POLICY "Parents can update child weekly stats"  ON child_weekly_stats FOR UPDATE USING (is_parent_of(child_id));


-- ═════════════════════════════════════════════════════════════
-- BÚIÐ! Keyrðu næst: 03_triggers_og_sjoalfvirkt.sql
-- ═════════════════════════════════════════════════════════════
