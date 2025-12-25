-- Create goals table
CREATE TABLE IF NOT EXISTS goals (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  title TEXT NOT NULL,
  description TEXT,
  category TEXT NOT NULL DEFAULT 'other' CHECK (category IN ('health', 'career', 'finance', 'education', 'personal', 'relationship', 'other')),
  target_date DATE,
  is_completed BOOLEAN DEFAULT FALSE,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Create sub_goals table
CREATE TABLE IF NOT EXISTS sub_goals (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  goal_id UUID NOT NULL REFERENCES goals(id) ON DELETE CASCADE,
  title TEXT NOT NULL,
  description TEXT,
  is_completed BOOLEAN DEFAULT FALSE,
  "order" INTEGER DEFAULT 0,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Create indexes for faster queries
CREATE INDEX IF NOT EXISTS idx_goals_user_id ON goals(user_id);
CREATE INDEX IF NOT EXISTS idx_goals_category ON goals(category);
CREATE INDEX IF NOT EXISTS idx_goals_is_completed ON goals(is_completed);
CREATE INDEX IF NOT EXISTS idx_sub_goals_goal_id ON sub_goals(goal_id);
CREATE INDEX IF NOT EXISTS idx_sub_goals_order ON sub_goals("order");

-- Enable Row Level Security
ALTER TABLE goals ENABLE ROW LEVEL SECURITY;
ALTER TABLE sub_goals ENABLE ROW LEVEL SECURITY;

-- RLS Policies for goals
-- Users can only see their own goals
CREATE POLICY "Users can view their own goals"
  ON goals FOR SELECT
  USING (auth.uid() = user_id);

-- Users can insert their own goals
CREATE POLICY "Users can insert their own goals"
  ON goals FOR INSERT
  WITH CHECK (auth.uid() = user_id);

-- Users can update their own goals
CREATE POLICY "Users can update their own goals"
  ON goals FOR UPDATE
  USING (auth.uid() = user_id)
  WITH CHECK (auth.uid() = user_id);

-- Users can delete their own goals
CREATE POLICY "Users can delete their own goals"
  ON goals FOR DELETE
  USING (auth.uid() = user_id);

-- RLS Policies for sub_goals
-- Users can only see sub-goals of their own goals
CREATE POLICY "Users can view sub-goals of their goals"
  ON sub_goals FOR SELECT
  USING (
    EXISTS (
      SELECT 1 FROM goals
      WHERE goals.id = sub_goals.goal_id
      AND goals.user_id = auth.uid()
    )
  );

-- Users can insert sub-goals for their own goals
CREATE POLICY "Users can insert sub-goals for their goals"
  ON sub_goals FOR INSERT
  WITH CHECK (
    EXISTS (
      SELECT 1 FROM goals
      WHERE goals.id = sub_goals.goal_id
      AND goals.user_id = auth.uid()
    )
  );

-- Users can update sub-goals of their own goals
CREATE POLICY "Users can update sub-goals of their goals"
  ON sub_goals FOR UPDATE
  USING (
    EXISTS (
      SELECT 1 FROM goals
      WHERE goals.id = sub_goals.goal_id
      AND goals.user_id = auth.uid()
    )
  )
  WITH CHECK (
    EXISTS (
      SELECT 1 FROM goals
      WHERE goals.id = sub_goals.goal_id
      AND goals.user_id = auth.uid()
    )
  );

-- Users can delete sub-goals of their own goals
CREATE POLICY "Users can delete sub-goals of their goals"
  ON sub_goals FOR DELETE
  USING (
    EXISTS (
      SELECT 1 FROM goals
      WHERE goals.id = sub_goals.goal_id
      AND goals.user_id = auth.uid()
    )
  );

-- Function to update updated_at timestamp for goals
CREATE OR REPLACE FUNCTION update_goals_updated_at()
RETURNS TRIGGER AS $$
BEGIN
  NEW.updated_at = NOW();
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Function to update updated_at timestamp for sub_goals
CREATE OR REPLACE FUNCTION update_sub_goals_updated_at()
RETURNS TRIGGER AS $$
BEGIN
  NEW.updated_at = NOW();
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Trigger to automatically update updated_at for goals
CREATE TRIGGER update_goals_updated_at
  BEFORE UPDATE ON goals
  FOR EACH ROW
  EXECUTE FUNCTION update_goals_updated_at();

-- Trigger to automatically update updated_at for sub_goals
CREATE TRIGGER update_sub_goals_updated_at
  BEFORE UPDATE ON sub_goals
  FOR EACH ROW
  EXECUTE FUNCTION update_sub_goals_updated_at();

-- Function to auto-update goal completion status based on sub-goals
CREATE OR REPLACE FUNCTION update_goal_completion_status()
RETURNS TRIGGER AS $$
DECLARE
  total_sub_goals INTEGER;
  completed_sub_goals INTEGER;
BEGIN
  -- Count total and completed sub-goals
  SELECT COUNT(*), COUNT(*) FILTER (WHERE is_completed = TRUE)
  INTO total_sub_goals, completed_sub_goals
  FROM sub_goals
  WHERE goal_id = COALESCE(NEW.goal_id, OLD.goal_id);
  
  -- Update goal completion status
  -- Goal is completed if all sub-goals are completed and there's at least one sub-goal
  UPDATE goals
  SET is_completed = (total_sub_goals > 0 AND completed_sub_goals = total_sub_goals)
  WHERE id = COALESCE(NEW.goal_id, OLD.goal_id);
  
  RETURN COALESCE(NEW, OLD);
END;
$$ LANGUAGE plpgsql;

-- Trigger to auto-update goal completion when sub-goal changes
CREATE TRIGGER update_goal_on_sub_goal_change
  AFTER INSERT OR UPDATE OR DELETE ON sub_goals
  FOR EACH ROW
  EXECUTE FUNCTION update_goal_completion_status();

