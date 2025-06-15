-- 05_tasks_basic.sql
-- Basic tasks tables and related RLS policies
-- This schema includes core task management features without complex recurrence or views.

-- =============================================================================
-- TASKS
-- =============================================================================
-- Tasks table (polymorphic - fixed, flexible)
CREATE TABLE public.tasks (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  title TEXT NOT NULL,
  type TEXT NOT NULL, -- TASK, APPOINTMENT, etc.
  hidden_tag TEXT,
  notes TEXT,
  location TEXT,
  contact_name TEXT,
  contact_email TEXT,
  contact_phone TEXT,
  duration INTEGER,   -- minutes (for flexible tasks or fixed when no end)
  
  -- Flexible task fields
  earliest_action_date DATE,
  due_date DATE,
  
  -- Fixed task fields
  start_datetime TIMESTAMPTZ,
  end_datetime TIMESTAMPTZ,
  start_date DATE,
  end_date DATE,
  
  -- Common fields
  created_at TIMESTAMPTZ DEFAULT now(),
  updated_at TIMESTAMPTZ DEFAULT now(),
  
  -- Owner is implicit through task_members
  routine_id UUID, -- For tasks associated with routines
  
  -- JSONB fields for type-specific data
  metadata JSONB DEFAULT '{}'::JSONB
);

-- Apply updated_at trigger
CREATE TRIGGER update_tasks_updated_at
BEFORE UPDATE ON tasks
FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

-- Task members (ownership and sharing)
CREATE TABLE public.task_members (
  task_id UUID REFERENCES tasks(id) ON DELETE CASCADE,
  member_id UUID REFERENCES auth.users(id) ON DELETE CASCADE,
  is_owner BOOLEAN DEFAULT FALSE,
  created_at TIMESTAMPTZ DEFAULT now(),
  PRIMARY KEY (task_id, member_id)
);

-- Task entities (many-to-many relationship)
CREATE TABLE public.task_entities (
  task_id UUID REFERENCES tasks(id) ON DELETE CASCADE,
  entity_id UUID REFERENCES entities(id) ON DELETE CASCADE,
  created_at TIMESTAMPTZ DEFAULT now(),
  PRIMARY KEY (task_id, entity_id)
);

-- =============================================================================
-- RLS POLICIES FOR TASKS
-- =============================================================================
ALTER TABLE public.tasks ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.task_members ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.task_entities ENABLE ROW LEVEL SECURITY;

-- Tasks policies
CREATE POLICY "Users can view tasks they are members of"
  ON public.tasks FOR SELECT
  USING (
    EXISTS (
      SELECT 1 FROM task_members
      WHERE task_members.task_id = id
      AND task_members.member_id = auth.uid()
    )
  );

CREATE POLICY "Users can create tasks"
  ON public.tasks FOR INSERT
  WITH CHECK (true);

CREATE POLICY "Task owners can update tasks"
  ON public.tasks FOR UPDATE
  USING (
    EXISTS (
      SELECT 1 FROM task_members
      WHERE task_members.task_id = id
      AND task_members.member_id = auth.uid()
      AND task_members.is_owner = true
    )
  );

CREATE POLICY "Task owners can delete tasks"
  ON public.tasks FOR DELETE
  USING (
    EXISTS (
      SELECT 1 FROM task_members
      WHERE task_members.task_id = id
      AND task_members.member_id = auth.uid()
      AND task_members.is_owner = true
    )
  );

-- Task members policies
CREATE POLICY "Users can view task members for their tasks"
  ON public.task_members FOR SELECT
  USING (
    member_id = auth.uid() OR
    EXISTS (
      SELECT 1 FROM task_members tm
      WHERE tm.task_id = task_id
      AND tm.member_id = auth.uid()
    )
  );

CREATE POLICY "Task owners can manage task members"
  ON public.task_members
  USING (
    EXISTS (
      SELECT 1 FROM task_members tm
      WHERE tm.task_id = task_id
      AND tm.member_id = auth.uid()
      AND tm.is_owner = true
    )
  );

-- Task entities policies
CREATE POLICY "Users can view task entities for tasks they are members of"
  ON public.task_entities FOR SELECT
  USING (
    EXISTS (
      SELECT 1 FROM task_members
      WHERE task_members.task_id = task_id
      AND task_members.member_id = auth.uid()
    )
  );

CREATE POLICY "Task owners can manage task entities"
  ON public.task_entities FOR ALL
  USING (
    EXISTS (
      SELECT 1 FROM task_members
      WHERE task_members.task_id = task_id
      AND task_members.member_id = auth.uid()
      AND task_members.is_owner = true
    )
  );

-- =============================================================================
-- INDEXES FOR TASKS
-- =============================================================================
CREATE INDEX tasks_type_idx ON tasks(type);
CREATE INDEX tasks_due_date_idx ON tasks(due_date);
CREATE INDEX tasks_start_datetime_idx ON tasks(start_datetime);
CREATE INDEX task_members_member_idx ON task_members(member_id);
CREATE INDEX task_entities_task_idx ON task_entities(task_id);
CREATE INDEX task_entities_entity_idx ON task_entities(entity_id);
