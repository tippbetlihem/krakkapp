# KrakkApp – Full Database Schema

Foreldrastýrður náms- og verðlaunavettvangu fyrir börn.
Next.js + TypeScript + Tailwind + Supabase (PostgreSQL).

---

## STEP 1 — Core Identity & Auth

### profiles
Stores the parent user profile. Linked to Supabase auth.users.

| Column | Type | Notes |
|--------|------|-------|
| id | UUID | PK — same as auth.users.id |
| email | TEXT | NOT NULL, UNIQUE |
| full_name | TEXT | nullable |
| avatar_url | TEXT | nullable |
| role | TEXT | default 'parent' |
| created_at | TIMESTAMPTZ | default now() |
| updated_at | TIMESTAMPTZ | default now() |
| last_login_at | TIMESTAMPTZ | nullable |

- No phone number — not needed
- No language/locale — app is Icelandic only
- updated_at uses auto-update trigger

---

### children
Central hub of the entire schema. Every child belongs to a parent.

| Column | Type | Notes |
|--------|------|-------|
| id | UUID | PK |
| parent_id | UUID | FK → profiles.id, NOT NULL |
| first_name | TEXT | NOT NULL |
| display_name | TEXT | nullable |
| birth_year | SMALLINT | nullable |
| birth_date | DATE | nullable |
| avatar_url | TEXT | nullable |
| pin_code | TEXT | nullable — hashed PIN for child login |
| is_active | BOOLEAN | default true |
| created_at | TIMESTAMPTZ | default now() |
| updated_at | TIMESTAMPTZ | default now() |
| total_points | INTEGER | default 0 |
| available_points | INTEGER | default 0 |
| lifetime_points | INTEGER | default 0 |
| completed_tasks_count | INTEGER | default 0 |
| completed_math_sessions_count | INTEGER | default 0 |
| completed_reading_sessions_count | INTEGER | default 0 |
| last_activity_at | TIMESTAMPTZ | nullable |
| current_streak_days | INTEGER | default 0 |
| longest_streak_days | INTEGER | default 0 |

- birth_year extracted from birth_date automatically if full date provided
- pin_code stored as hashed value — never plain text
- available_points decreases when points are spent on rewards
- lifetime_points only ever increases
- is_active = false instead of deleting child

---

### child_settings
General settings per child. One row per child.

| Column | Type | Notes |
|--------|------|-------|
| id | UUID | PK |
| child_id | UUID | FK → children.id, NOT NULL, UNIQUE |
| daily_points_goal | INTEGER | nullable |
| weekly_points_goal | INTEGER | nullable |
| math_enabled | BOOLEAN | default true |
| reading_enabled | BOOLEAN | default true |
| tasks_enabled | BOOLEAN | default true |
| rewards_enabled | BOOLEAN | default true |
| created_at | TIMESTAMPTZ | default now() |
| updated_at | TIMESTAMPTZ | default now() |

---

## STEP 2 — Configuration

### child_math_settings
Per-child math configuration. One row per child.

| Column | Type | Notes |
|--------|------|-------|
| id | UUID | PK |
| child_id | UUID | FK → children.id, NOT NULL, UNIQUE |
| difficulty_label | TEXT | 'easy', 'medium', 'hard', 'custom' |
| min_number | INTEGER | default 1 |
| max_number | INTEGER | default 10 |
| question_count | INTEGER | default 10 |
| allow_addition | BOOLEAN | default true |
| allow_subtraction | BOOLEAN | default true |
| allow_multiplication | BOOLEAN | default false |
| allow_division | BOOLEAN | default false |
| division_whole_numbers_only | BOOLEAN | default true |
| time_limit_seconds | INTEGER | nullable |
| points_per_correct_answer | INTEGER | default 1 |
| points_per_wrong_answer | INTEGER | default 0 — can be negative |
| show_timer_to_child | BOOLEAN | default false |
| created_at | TIMESTAMPTZ | default now() |
| updated_at | TIMESTAMPTZ | default now() |

---

### child_reading_settings
Per-child reading configuration. One row per child.

| Column | Type | Notes |
|--------|------|-------|
| id | UUID | PK |
| child_id | UUID | FK → children.id, NOT NULL, UNIQUE |
| difficulty_level | TEXT | 'beginner', 'elementary', 'intermediate', 'advanced' |
| min_word_count | INTEGER | nullable |
| max_word_count | INTEGER | nullable |
| points_per_session | INTEGER | default 10 |
| accuracy_threshold_percent | INTEGER | default 80 — all or nothing |
| show_accuracy_to_child | BOOLEAN | default false |
| created_at | TIMESTAMPTZ | default now() |
| updated_at | TIMESTAMPTZ | default now() |

- Child earns full points or nothing — no partial points
- Parent can lower threshold if needed

---

## STEP 3 — Activity Tables

### tasks
Household tasks created by parent for each child.

| Column | Type | Notes |
|--------|------|-------|
| id | UUID | PK |
| parent_id | UUID | FK → profiles.id, NOT NULL |
| child_id | UUID | FK → children.id, NOT NULL |
| title | TEXT | NOT NULL |
| description | TEXT | nullable |
| category | TEXT | 'cleaning', 'routine', 'school', 'custom' |
| status | TEXT | 'pending', 'submitted', 'approved', 'rejected', 'cancelled' |
| points_value | INTEGER | NOT NULL, default 5 |
| due_date | DATE | nullable |
| is_recurring | BOOLEAN | default false |
| recurrence_type | TEXT | nullable — 'daily', 'weekly' |
| created_at | TIMESTAMPTZ | default now() |
| updated_at | TIMESTAMPTZ | default now() |
| submitted_at | TIMESTAMPTZ | nullable |
| approved_at | TIMESTAMPTZ | nullable |
| approved_by | UUID | nullable, FK → profiles.id |
| requires_photo_proof | BOOLEAN | default false |
| proof_image_url | TEXT | nullable |
| parent_feedback | TEXT | nullable |
| completion_time_seconds | INTEGER | nullable |

- Status flow: pending → submitted → approved or rejected
- Rejected tasks go back to pending
- No emoji/icon — visual design handles presentation
- parent_feedback covers both approval and rejection notes

---

### math_sessions
Each math session a child completes.

| Column | Type | Notes |
|--------|------|-------|
| id | UUID | PK |
| child_id | UUID | FK → children.id, NOT NULL |
| settings_snapshot | JSONB | copy of math settings at session start |
| question_count | INTEGER | NOT NULL |
| correct_answers | INTEGER | default 0 |
| wrong_answers | INTEGER | default 0 |
| skipped_answers | INTEGER | default 0 |
| accuracy_percent | NUMERIC(5,2) | calculated |
| base_points_earned | INTEGER | default 0 |
| bonus_multiplier | NUMERIC(4,2) | default 1.0 |
| final_points_earned | INTEGER | default 0 |
| started_at | TIMESTAMPTZ | default now() |
| completed_at | TIMESTAMPTZ | nullable |
| duration_seconds | INTEGER | nullable |
| status | TEXT | 'started', 'completed', 'abandoned' |

- settings_snapshot preserves config even if parent changes settings later
- skipped_answers tracked separately from wrong answers

---

### math_session_questions
Each individual question within a math session.

| Column | Type | Notes |
|--------|------|-------|
| id | UUID | PK |
| math_session_id | UUID | FK → math_sessions.id, NOT NULL |
| question_order | INTEGER | NOT NULL |
| operand_1 | INTEGER | NOT NULL |
| operand_2 | INTEGER | NOT NULL |
| operator | TEXT | NOT NULL — '+', '-', '*', '/' |
| correct_answer | NUMERIC(10,4) | NOT NULL |
| child_answer | NUMERIC(10,4) | nullable |
| is_correct | BOOLEAN | nullable |
| is_skipped | BOOLEAN | default false |
| points_earned | INTEGER | default 0 |
| response_time_ms | INTEGER | nullable |
| attempt_number | INTEGER | default 1 |
| created_at | TIMESTAMPTZ | default now() |

Analytics: slowest operation, most skipped, accuracy per operator, hardest number ranges.

---

### reading_texts
Library of reading passages.

| Column | Type | Notes |
|--------|------|-------|
| id | UUID | PK |
| title | TEXT | NOT NULL |
| text_content | TEXT | NOT NULL |
| language | TEXT | default 'is' |
| difficulty_level | TEXT | 'beginner', 'elementary', 'intermediate', 'advanced' |
| word_count | INTEGER | NOT NULL |
| age_min | INTEGER | nullable |
| age_max | INTEGER | nullable |
| topic | TEXT | nullable |
| is_system_text | BOOLEAN | default true |
| is_active | BOOLEAN | default true |
| created_by_parent_id | UUID | nullable, FK → profiles.id |
| times_used | INTEGER | default 0 |
| created_at | TIMESTAMPTZ | default now() |

---

### child_favorite_texts
Texts marked as favourite by parent for a child.

| Column | Type | Notes |
|--------|------|-------|
| id | UUID | PK |
| child_id | UUID | FK → children.id, NOT NULL |
| reading_text_id | UUID | FK → reading_texts.id, NOT NULL |
| created_by_parent_id | UUID | FK → profiles.id, NOT NULL |
| created_at | TIMESTAMPTZ | default now() |

- UNIQUE on (child_id, reading_text_id)

---

### reading_sessions
Each reading aloud attempt by a child.

| Column | Type | Notes |
|--------|------|-------|
| id | UUID | PK |
| child_id | UUID | FK → children.id, NOT NULL |
| reading_text_id | UUID | FK → reading_texts.id, NOT NULL |
| assigned_text_snapshot | TEXT | NOT NULL |
| spoken_text | TEXT | nullable |
| word_count | INTEGER | NOT NULL |
| words_correct_count | INTEGER | default 0 |
| words_incorrect_count | INTEGER | default 0 |
| words_skipped_count | INTEGER | default 0 |
| accuracy_percent | NUMERIC(5,2) | calculated |
| threshold_met | BOOLEAN | default false |
| base_points_earned | INTEGER | default 0 |
| bonus_multiplier | NUMERIC(4,2) | default 1.0 |
| final_points_earned | INTEGER | default 0 |
| started_at | TIMESTAMPTZ | default now() |
| completed_at | TIMESTAMPTZ | nullable |
| duration_seconds | INTEGER | nullable |
| status | TEXT | 'started', 'completed', 'abandoned', 'review_needed' |
| settings_snapshot | JSONB | copy of reading settings at session time |
| audio_file_url | TEXT | nullable |
| speech_engine | TEXT | nullable |
| review_notes | TEXT | nullable |
| parent_reviewed | BOOLEAN | default false |

---

## STEP 4 — Points & Rewards

### point_multipliers
Temporary point boosts set by parent.

| Column | Type | Notes |
|--------|------|-------|
| id | UUID | PK |
| parent_id | UUID | FK → profiles.id, NOT NULL |
| child_id | UUID | nullable, FK → children.id |
| activity_type | TEXT | 'math', 'reading', 'task', 'all' |
| multiplier_value | NUMERIC(4,2) | NOT NULL |
| title | TEXT | NOT NULL — visible to child e.g. "Helgarbónus!" |
| reason | TEXT | nullable — parent-only internal note |
| starts_at | TIMESTAMPTZ | NOT NULL |
| ends_at | TIMESTAMPTZ | NOT NULL |
| is_active | BOOLEAN | default true |
| created_at | TIMESTAMPTZ | default now() |

- child_id null = applies to all children
- title visible to child for motivation
- Multiple overlapping multipliers — system takes highest value

---

### points_ledger
Every single point transaction. Source of truth for all points.

| Column | Type | Notes |
|--------|------|-------|
| id | UUID | PK |
| child_id | UUID | FK → children.id, NOT NULL |
| source_type | TEXT | 'math_session', 'reading_session', 'task', 'reward_redemption', 'manual_adjustment', 'bonus' |
| source_id | UUID | nullable |
| base_points | INTEGER | NOT NULL |
| multiplier_applied | NUMERIC(4,2) | default 1.0 |
| bonus_points | INTEGER | default 0 |
| final_points | INTEGER | NOT NULL |
| direction | TEXT | NOT NULL — 'credit' or 'debit' |
| description | TEXT | NOT NULL — in Icelandic |
| created_at | TIMESTAMPTZ | default now() |
| created_by_parent_id | UUID | nullable, FK → profiles.id |

- Immutable — no UPDATE or DELETE allowed
- Child sees both credit and debit entries
- children.available_points updated by trigger after every insert

---

### rewards
Rewards created by parent that children redeem with points.

| Column | Type | Notes |
|--------|------|-------|
| id | UUID | PK |
| parent_id | UUID | FK → profiles.id, NOT NULL |
| child_id | UUID | nullable, FK → children.id |
| title | TEXT | NOT NULL |
| description | TEXT | nullable |
| points_cost | INTEGER | NOT NULL |
| image_url | TEXT | nullable |
| is_active | BOOLEAN | default true |
| is_one_time | BOOLEAN | default false |
| created_at | TIMESTAMPTZ | default now() |
| updated_at | TIMESTAMPTZ | default now() |

---

### reward_redemptions
Every time a child spends points on a reward.

| Column | Type | Notes |
|--------|------|-------|
| id | UUID | PK |
| reward_id | UUID | FK → rewards.id, NOT NULL |
| child_id | UUID | FK → children.id, NOT NULL |
| points_spent | INTEGER | NOT NULL |
| status | TEXT | 'requested', 'approved', 'rejected', 'fulfilled' |
| requested_at | TIMESTAMPTZ | default now() |
| reviewed_at | TIMESTAMPTZ | nullable |
| reviewed_by | UUID | nullable, FK → profiles.id |
| parent_note | TEXT | nullable |

- points_spent locked at redemption time
- Points returned to child if rejected

---

## STEP 5 — Summary & Stats

### child_daily_stats
Precomputed daily summary. One row per child per day.

| Column | Type | Notes |
|--------|------|-------|
| id | UUID | PK |
| child_id | UUID | FK → children.id, NOT NULL |
| stat_date | DATE | NOT NULL |
| points_earned | INTEGER | default 0 |
| points_spent | INTEGER | default 0 |
| bonus_points_earned | INTEGER | default 0 |
| tasks_completed | INTEGER | default 0 |
| tasks_rejected | INTEGER | default 0 |
| math_sessions_completed | INTEGER | default 0 |
| math_sessions_abandoned | INTEGER | default 0 |
| math_correct_answers | INTEGER | default 0 |
| math_wrong_answers | INTEGER | default 0 |
| math_skipped_answers | INTEGER | default 0 |
| math_avg_accuracy | NUMERIC(5,2) | default 0 |
| math_avg_response_time_ms | INTEGER | default 0 |
| reading_sessions_completed | INTEGER | default 0 |
| reading_sessions_abandoned | INTEGER | default 0 |
| reading_avg_accuracy | NUMERIC(5,2) | default 0 |
| reading_words_correct | INTEGER | default 0 |
| reading_words_incorrect | INTEGER | default 0 |
| active_minutes | INTEGER | default 0 |
| daily_goal_reached | BOOLEAN | default false |
| is_streak_day | BOOLEAN | default false |
| created_at | TIMESTAMPTZ | default now() |
| updated_at | TIMESTAMPTZ | default now() |

- UNIQUE on (child_id, stat_date)
- Updated by triggers as activities complete

---

### child_weekly_stats
Precomputed weekly summary. One row per child per week.

| Column | Type | Notes |
|--------|------|-------|
| id | UUID | PK |
| child_id | UUID | FK → children.id, NOT NULL |
| week_start_date | DATE | NOT NULL — always Monday |
| week_end_date | DATE | NOT NULL — always Sunday |
| points_earned | INTEGER | default 0 |
| points_spent | INTEGER | default 0 |
| bonus_points_earned | INTEGER | default 0 |
| tasks_completed | INTEGER | default 0 |
| tasks_rejected | INTEGER | default 0 |
| math_sessions_completed | INTEGER | default 0 |
| math_sessions_abandoned | INTEGER | default 0 |
| math_avg_accuracy | NUMERIC(5,2) | default 0 |
| math_avg_response_time_ms | INTEGER | default 0 |
| reading_sessions_completed | INTEGER | default 0 |
| reading_sessions_abandoned | INTEGER | default 0 |
| reading_avg_accuracy | NUMERIC(5,2) | default 0 |
| active_days_count | INTEGER | default 0 |
| weekly_goal_reached | BOOLEAN | default false |
| best_day_points | INTEGER | default 0 |
| best_math_accuracy | NUMERIC(5,2) | default 0 |
| best_reading_accuracy | NUMERIC(5,2) | default 0 |
| most_used_activity | TEXT | nullable — 'math', 'reading', or 'task' |
| created_at | TIMESTAMPTZ | default now() |
| updated_at | TIMESTAMPTZ | default now() |

- UNIQUE on (child_id, week_start_date)
- Aggregated from child_daily_stats

---

## STEP 6 — Constraints & Rules

### Cascade Rules
- profiles → children: RESTRICT
- children → all child tables: RESTRICT — use is_active = false instead
- math_sessions → math_session_questions: CASCADE
- rewards → reward_redemptions: RESTRICT
- reading_texts → reading_sessions: RESTRICT

### updated_at Triggers
Auto-update trigger needed on: profiles, children, child_settings, child_math_settings, child_reading_settings, tasks, reading_texts, rewards, child_daily_stats, child_weekly_stats

### Key Indexes
- children(parent_id)
- tasks(child_id), tasks(status), tasks(parent_id)
- math_sessions(child_id), math_sessions(status)
- math_session_questions(math_session_id)
- reading_sessions(child_id), reading_sessions(status), reading_sessions(reading_text_id)
- points_ledger(child_id), points_ledger(source_type), points_ledger(created_at)
- point_multipliers(child_id), point_multipliers(ends_at)
- child_daily_stats(child_id, stat_date)
- child_weekly_stats(child_id, week_start_date)
- reward_redemptions(child_id), reward_redemptions(status)