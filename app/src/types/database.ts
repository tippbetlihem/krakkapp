export type Profile = {
  id: string;
  email: string;
  full_name: string | null;
  avatar_url: string | null;
  role: string;
  created_at: string;
  updated_at: string;
  last_login_at: string | null;
};

export type Child = {
  id: string;
  parent_id: string;
  first_name: string;
  display_name: string | null;
  birth_year: number | null;
  birth_date: string | null;
  avatar_url: string | null;
  pin_code: string | null;
  login_username: string | null;
  password_hash: string | null;
  is_active: boolean;
  created_at: string;
  updated_at: string;
  total_points: number;
  available_points: number;
  lifetime_points: number;
  completed_tasks_count: number;
  completed_math_sessions_count: number;
  completed_reading_sessions_count: number;
  last_activity_at: string | null;
  current_streak_days: number;
  longest_streak_days: number;
};

export type ChildSettings = {
  id: string;
  child_id: string;
  daily_points_goal: number | null;
  weekly_points_goal: number | null;
  math_enabled: boolean;
  reading_enabled: boolean;
  tasks_enabled: boolean;
  rewards_enabled: boolean;
  created_at: string;
  updated_at: string;
};

export type ChildMathSettings = {
  id: string;
  child_id: string;
  difficulty_label: "easy" | "medium" | "hard" | "custom";
  min_number: number;
  max_number: number;
  question_count: number;
  allow_addition: boolean;
  allow_subtraction: boolean;
  allow_multiplication: boolean;
  allow_division: boolean;
  division_whole_numbers_only: boolean;
  time_limit_seconds: number | null;
  points_per_correct_answer: number;
  points_per_wrong_answer: number;
  show_timer_to_child: boolean;
  created_at: string;
  updated_at: string;
};

export type ChildReadingSettings = {
  id: string;
  child_id: string;
  difficulty_level: "beginner" | "elementary" | "intermediate" | "advanced";
  min_word_count: number | null;
  max_word_count: number | null;
  points_per_session: number;
  accuracy_threshold_percent: number;
  show_accuracy_to_child: boolean;
  created_at: string;
  updated_at: string;
};

export type Task = {
  id: string;
  parent_id: string;
  child_id: string;
  title: string;
  description: string | null;
  category: "cleaning" | "routine" | "school" | "custom";
  status: "pending" | "submitted" | "approved" | "rejected" | "cancelled";
  points_value: number;
  due_date: string | null;
  is_recurring: boolean;
  recurrence_type: "daily" | "weekly" | null;
  created_at: string;
  updated_at: string;
  submitted_at: string | null;
  approved_at: string | null;
  approved_by: string | null;
  requires_photo_proof: boolean;
  proof_image_url: string | null;
  parent_feedback: string | null;
  completion_time_seconds: number | null;
};

export type MathSession = {
  id: string;
  child_id: string;
  settings_snapshot: Record<string, unknown>;
  question_count: number;
  correct_answers: number;
  wrong_answers: number;
  skipped_answers: number;
  accuracy_percent: number | null;
  base_points_earned: number;
  bonus_multiplier: number;
  final_points_earned: number;
  started_at: string;
  completed_at: string | null;
  duration_seconds: number | null;
  status: "started" | "completed" | "abandoned";
};

export type MathSessionQuestion = {
  id: string;
  math_session_id: string;
  question_order: number;
  operand_1: number;
  operand_2: number;
  operator: "+" | "-" | "*" | "/";
  correct_answer: number;
  child_answer: number | null;
  is_correct: boolean | null;
  is_skipped: boolean;
  points_earned: number;
  response_time_ms: number | null;
  attempt_number: number;
  created_at: string;
};

export type PointsLedgerEntry = {
  id: string;
  child_id: string;
  source_type:
    | "math_session"
    | "reading_session"
    | "task"
    | "reward_redemption"
    | "manual_adjustment"
    | "bonus";
  source_id: string | null;
  base_points: number;
  multiplier_applied: number;
  bonus_points: number;
  final_points: number;
  direction: "credit" | "debit";
  description: string;
  created_at: string;
  created_by_parent_id: string | null;
};

export type Reward = {
  id: string;
  parent_id: string;
  child_id: string | null;
  title: string;
  description: string | null;
  points_cost: number;
  image_url: string | null;
  is_active: boolean;
  is_one_time: boolean;
  created_at: string;
  updated_at: string;
};

export type RewardRedemption = {
  id: string;
  reward_id: string;
  child_id: string;
  points_spent: number;
  status: "requested" | "approved" | "rejected" | "fulfilled";
  requested_at: string;
  reviewed_at: string | null;
  reviewed_by: string | null;
  parent_note: string | null;
};

/** Dagleg samantekt — rökfræði í gagnagrunninum */
export type ChildDailyStats = {
  id: string;
  child_id: string;
  stat_date: string;
  points_earned: number;
  points_spent: number;
  bonus_points_earned: number;
  tasks_completed: number;
  tasks_rejected: number;
  math_sessions_completed: number;
  math_sessions_abandoned: number;
  math_correct_answers: number;
  math_wrong_answers: number;
  math_skipped_answers: number;
  math_avg_accuracy: number;
  math_avg_response_time_ms: number;
  reading_sessions_completed: number;
  reading_sessions_abandoned: number;
  reading_avg_accuracy: number;
  reading_words_correct: number;
  reading_words_incorrect: number;
  active_minutes: number;
  daily_goal_reached: boolean;
  is_streak_day: boolean;
  created_at: string;
  updated_at: string;
};

export type ChildWeeklyStats = {
  id: string;
  child_id: string;
  week_start_date: string;
  week_end_date: string;
  points_earned: number;
  points_spent: number;
  bonus_points_earned: number;
  tasks_completed: number;
  tasks_rejected: number;
  math_sessions_completed: number;
  math_sessions_abandoned: number;
  math_avg_accuracy: number;
  math_avg_response_time_ms: number;
  reading_sessions_completed: number;
  reading_sessions_abandoned: number;
  reading_avg_accuracy: number;
  active_days_count: number;
  weekly_goal_reached: boolean;
  best_day_points: number;
  best_math_accuracy: number;
  best_reading_accuracy: number;
  most_used_activity: "math" | "reading" | "task" | null;
  created_at: string;
  updated_at: string;
};
