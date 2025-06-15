-- VUET MIGRATION: DJANGO TO SUPABASE SCHEMA - PHASE 2 ESSENTIALS
-- This script sets up the core tables for Entities and Tasks,
-- including polymorphic support and complex task system.
-- This should be executed AFTER the Phase 1 setup.

-- Enable necessary extensions (if not already enabled in Phase 1)
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";
CREATE EXTENSION IF NOT EXISTS "pg_trgm"; -- For text search capabilities
CREATE EXTENSION IF NOT EXISTS "ltree";   -- For hierarchical data (e.g., parent/child entities)

-- =============================================================================
-- STORAGE BUCKETS SETUP (if not already done in Phase 1)
-- =============================================================================

-- Create storage buckets for entities, lists, and messages
INSERT INTO storage.buckets (id, name, public) VALUES
('entities', 'Entity images and files', true),
('lists', 'List attachments', false),
('messages', 'Message attachments', false)
ON CONFLICT (id) DO NOTHING;

-- Set up storage security policies (ensure 'owner' column exists in relevant tables for RLS)
-- 1) Public read for entity images
DROP POLICY IF EXISTS "Entity images are publicly accessible" ON storage.objects;
CREATE POLICY "Entity images are publicly accessible"
  ON storage.objects
  FOR SELECT
  USING (bucket_id = 'entities');

-- 2) Authenticated upload for entity images
DROP POLICY IF EXISTS "Authenticated users can upload entity images" ON storage.objects;
CREATE POLICY "Authenticated users can upload entity images"
  ON storage.objects
  FOR INSERT TO authenticated
  WITH CHECK (bucket_id = 'entities');

-- 3) Owner-only update for entity images
DROP POLICY IF EXISTS "Users can update their own entity images" ON storage.objects;
CREATE POLICY "Users can update their own entity images"
  ON storage.objects
  FOR UPDATE TO authenticated
  USING (
    bucket_id = 'entities'
    AND (storage.foldername(name))[1] = auth.uid()::text   -- path starts with user id
  );

-- 4) Owner-only delete for entity images
DROP POLICY IF EXISTS "Users can delete their own entity images" ON storage.objects;
CREATE POLICY "Users can delete their own entity images"
  ON storage.objects
  FOR DELETE TO authenticated
  USING (
    bucket_id = 'entities'
    AND (storage.foldername(name))[1] = auth.uid()::text
  );

-- 5) Private read for list attachments (owner only)
DROP POLICY IF EXISTS "Users can access their own list attachments" ON storage.objects;
CREATE POLICY "Users can access their own list attachments"
  ON storage.objects
  FOR SELECT TO authenticated
  USING (
    bucket_id = 'lists'
    AND (storage.foldername(name))[1] = auth.uid()::text
  );

-- 6) Authenticated upload for list attachments
DROP POLICY IF EXISTS "Users can upload list attachments" ON storage.objects;
CREATE POLICY "Users can upload list attachments"
  ON storage.objects
  FOR INSERT TO authenticated
  WITH CHECK (bucket_id = 'lists');

-- Note: Message attachments RLS will depend on message_threads and participants,
-- which are defined later in this script.
-- CREATE POLICY "Message attachments accessible to conversation participants"
--   ON storage.objects FOR SELECT TO authenticated USING (
--     bucket_id = 'messages' AND
--     EXISTS (
--       SELECT 1 FROM message_threads mt
--       JOIN message_thread_participants mtp ON mt.id = mtp.thread_id
--       WHERE mtp.user_id = auth.uid() AND
--       (storage.foldername(name))[1] = mt.id::text
--     )
--   );

-- =============================================================================
-- FAMILY MEMBERS TABLE (must exist BEFORE entity & task RLS policies)
-- =============================================================================

CREATE TABLE IF NOT EXISTS family_members (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  family_id UUID NOT NULL,
  user_id UUID REFERENCES auth.users NOT NULL,
  role TEXT DEFAULT 'MEMBER', -- HEAD, MEMBER
  created_at TIMESTAMPTZ DEFAULT now(),
  UNIQUE (family_id, user_id)
);

-- RLS for family members
ALTER TABLE family_members ENABLE ROW LEVEL SECURITY;
DROP POLICY IF EXISTS "Users can view their own family memberships" ON family_members;
DROP POLICY IF EXISTS "Users can view family members in their families" ON family_members;
DROP POLICY IF EXISTS "Family heads can manage family members" ON family_members;

CREATE POLICY "Users can view their own family memberships"
  ON family_members FOR SELECT USING (user_id = auth.uid());

CREATE POLICY "Users can view family members in their families"
  ON family_members FOR SELECT USING (
    EXISTS (
      SELECT 1 FROM family_members AS fm
      WHERE fm.family_id = family_id AND fm.user_id = auth.uid()
    )
  );

CREATE POLICY "Family heads can manage family members"
  ON family_members FOR ALL USING (
    EXISTS (
      SELECT 1 FROM family_members AS fm
      WHERE fm.family_id = family_id AND fm.user_id = auth.uid() AND fm.role = 'HEAD'
    )
  );

-- =============================================================================
-- ENTITIES (POLYMORPHIC MODEL)
-- =============================================================================

-- Main entities table - replaces Django's polymorphic model with a single table
CREATE TABLE IF NOT EXISTS entities (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  owner_id UUID REFERENCES auth.users ON DELETE CASCADE,
  category_id SMALLINT REFERENCES categories, -- Links to core categories
  type TEXT NOT NULL,          -- Entity type (CAR, PET, TRIP, etc.)
  subtype TEXT DEFAULT '',     -- Optional subtype for finer granularity
  name TEXT NOT NULL,
  notes TEXT DEFAULT '',
  image_path TEXT,             -- Storage reference
  hidden BOOLEAN DEFAULT false,
  parent_id UUID REFERENCES entities, -- For hierarchical entities
  created_at TIMESTAMPTZ DEFAULT now(),
  updated_at TIMESTAMPTZ DEFAULT now(),

  -- JSONB fields for type-specific data, replacing separate tables
  dates JSONB DEFAULT NULL,    -- For date-related entities (trips, events, anniversaries)
  contact_info JSONB DEFAULT NULL, -- For entities with contact details (e.g., health providers, businesses)
  location JSONB DEFAULT NULL, -- For entities with location info (e.g., events, homes)
  metadata JSONB DEFAULT NULL  -- General purpose JSONB for other entity-specific data
);

-- Entity members (for sharing entities with other users/family members)
CREATE TABLE IF NOT EXISTS entity_members (
  entity_id UUID REFERENCES entities ON DELETE CASCADE,
  member_id UUID REFERENCES auth.users ON DELETE CASCADE,
  role TEXT DEFAULT 'VIEWER', -- e.g., 'VIEWER', 'EDITOR'
  added_at TIMESTAMPTZ DEFAULT now(),
  PRIMARY KEY (entity_id, member_id)
);

-- Professional entity category mapping (links professional entities to user-defined categories)
CREATE TABLE IF NOT EXISTS professional_entity_category_mapping (
  entity_id UUID REFERENCES entities ON DELETE CASCADE,
  professional_category_id BIGINT REFERENCES professional_categories ON DELETE CASCADE,
  user_id UUID REFERENCES auth.users ON DELETE CASCADE, -- Denormalized for RLS efficiency
  PRIMARY KEY (user_id, entity_id)
);

-- Guest list invites (for event entities)
CREATE TABLE IF NOT EXISTS guest_list_invites (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  entity_id UUID REFERENCES entities ON DELETE CASCADE,
  name TEXT,
  email TEXT,
  phone_number TEXT,
  status TEXT DEFAULT 'PENDING', -- PENDING, ACCEPTED, DECLINED
  sent BOOLEAN DEFAULT false,
  created_at TIMESTAMPTZ DEFAULT now(),
  CONSTRAINT email_or_phone_required CHECK (email IS NOT NULL OR phone_number IS NOT NULL)
);

-- Indexes for entities to improve query performance
CREATE INDEX IF NOT EXISTS entity_owner_idx ON entities (owner_id);
CREATE INDEX IF NOT EXISTS entity_category_idx ON entities (category_id);
CREATE INDEX IF NOT EXISTS entity_type_idx ON entities (type);
CREATE INDEX IF NOT EXISTS entity_parent_idx ON entities (parent_id);

-- RLS for entities
ALTER TABLE entities ENABLE ROW LEVEL SECURITY;
CREATE POLICY "Users can view their own entities"
  ON entities FOR SELECT USING (owner_id = auth.uid());
CREATE POLICY "Users can view entities shared with them"
  ON entities FOR SELECT USING (
    EXISTS (
      SELECT 1 FROM entity_members
      WHERE entity_id = id AND member_id = auth.uid()
    )
  );
CREATE POLICY "Users can view entities shared with their family"
  ON entities FOR SELECT USING (
    EXISTS (
      SELECT 1 FROM family_members fm
      JOIN entity_members em ON fm.user_id = em.member_id
      WHERE em.entity_id = id AND fm.user_id = auth.uid()
    )
  );
CREATE POLICY "Users can create entities"
  ON entities FOR INSERT WITH CHECK (owner_id = auth.uid());
CREATE POLICY "Users can update their own entities"
  ON entities FOR UPDATE USING (owner_id = auth.uid());
CREATE POLICY "Users can delete their own entities"
  ON entities FOR DELETE USING (owner_id = auth.uid());

-- RLS for entity members
ALTER TABLE entity_members ENABLE ROW LEVEL SECURITY;
CREATE POLICY "Entity owners can manage members"
  ON entity_members FOR ALL USING (
    EXISTS (
      SELECT 1 FROM entities
      WHERE id = entity_id AND owner_id = auth.uid()
    )
  );
CREATE POLICY "Users can view members of entities shared with them"
  ON entity_members FOR SELECT USING (
    EXISTS (
      SELECT 1 FROM entity_members AS em
      WHERE em.entity_id = entity_id AND em.member_id = auth.uid()
    )
  );

-- RLS for professional entity category mapping
ALTER TABLE professional_entity_category_mapping ENABLE ROW LEVEL SECURITY;
CREATE POLICY "Users can view their professional entity mappings"
  ON professional_entity_category_mapping FOR SELECT USING (user_id = auth.uid());
CREATE POLICY "Users can manage their professional entity mappings"
  ON professional_entity_category_mapping FOR ALL USING (user_id = auth.uid());

-- RLS for guest list invites
ALTER TABLE guest_list_invites ENABLE ROW LEVEL SECURITY;
CREATE POLICY "Users can view invites for their entities"
  ON guest_list_invites FOR SELECT USING (
    EXISTS (
      SELECT 1 FROM entities
      WHERE id = entity_id AND owner_id = auth.uid()
    )
  );
CREATE POLICY "Users can manage invites for their entities"
  ON guest_list_invites FOR ALL USING (
    EXISTS (
      SELECT 1 FROM entities
      WHERE id = entity_id AND owner_id = auth.uid()
    )
  );

-- =============================================================================
-- TASKS
-- =============================================================================

-- Tasks table (combines FixedTask and FlexibleTask from Django)
CREATE TABLE IF NOT EXISTS tasks (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  title TEXT NOT NULL,
  type TEXT NOT NULL DEFAULT 'TASK', -- TASK, APPOINTMENT, DUE_DATE, FLIGHT, etc.
  notes TEXT DEFAULT '',
  location TEXT DEFAULT '',
  contact_name TEXT DEFAULT '',
  contact_email TEXT DEFAULT '',
  contact_phone TEXT DEFAULT '',
  hidden_tag TEXT, -- MOT_DUE, INSURANCE_DUE, etc.
  tags TEXT[] DEFAULT '{}', -- Array of tags
  
  -- Fields for fixed tasks (can be NULL for flexible tasks)
  start_datetime TIMESTAMPTZ,
  end_datetime TIMESTAMPTZ,
  start_timezone TEXT,
  end_timezone TEXT,
  start_date DATE,
  end_date DATE,
  date DATE, -- For single-day fixed tasks
  
  -- Fields for flexible tasks (can be NULL for fixed tasks)
  earliest_action_date DATE,
  due_date DATE,
  duration INTEGER DEFAULT 30, -- in minutes
  urgency TEXT, -- LOW, MEDIUM, HIGH
  
  -- Common fields
  routine_id UUID, -- References routines table (defined in a later phase)
  created_at TIMESTAMPTZ DEFAULT now(),
  updated_at TIMESTAMPTZ DEFAULT now(),
  
  -- Constraint to ensure either fixed or flexible task fields are used
  -- This is a simplified version; more complex validation can be done in application logic
  CONSTRAINT valid_task_type_fields CHECK (
    (type IN ('TASK', 'APPOINTMENT', 'DUE_DATE') AND (earliest_action_date IS NOT NULL OR due_date IS NOT NULL))
    OR
    (type NOT IN ('TASK', 'APPOINTMENT', 'DUE_DATE') AND (start_datetime IS NOT NULL OR end_datetime IS NOT NULL OR start_date IS NOT NULL OR end_date IS NOT NULL OR date IS NOT NULL))
    OR
    (type = 'USER_BIRTHDAY' AND date IS NOT NULL) -- Specific case for user birthdays
  )
);

-- Task members (many-to-many relationship between tasks and users)
CREATE TABLE IF NOT EXISTS task_members (
  task_id UUID REFERENCES tasks ON DELETE CASCADE,
  member_id UUID REFERENCES auth.users ON DELETE CASCADE,
  PRIMARY KEY (task_id, member_id)
);

-- Task viewers (users who can view a task but are not direct members)
CREATE TABLE IF NOT EXISTS task_viewers (
  task_id UUID REFERENCES tasks ON DELETE CASCADE,
  member_id UUID REFERENCES auth.users ON DELETE CASCADE,
  PRIMARY KEY (task_id, member_id)
);

-- Task entities (many-to-many relationship between tasks and entities)
CREATE TABLE IF NOT EXISTS task_entities (
  task_id UUID REFERENCES tasks ON DELETE CASCADE,
  entity_id UUID REFERENCES entities ON DELETE CASCADE,
  PRIMARY KEY (task_id, entity_id)
);

-- Recurrences for tasks
CREATE TABLE IF NOT EXISTS recurrences (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  task_id UUID REFERENCES tasks ON DELETE CASCADE UNIQUE, -- One-to-one with task
  recurrence TEXT NOT NULL, -- DAILY, WEEKLY, MONTHLY, YEARLY, etc.
  interval_length INTEGER DEFAULT 1,
  earliest_occurrence TIMESTAMPTZ,
  latest_occurrence TIMESTAMPTZ
);

-- Task actions (e.g., "pay bill 3 days before due date")
CREATE TABLE IF NOT EXISTS task_actions (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  task_id UUID REFERENCES tasks ON DELETE CASCADE,
  action_timedelta INTERVAL NOT NULL DEFAULT '1 day'::INTERVAL, -- e.g., '3 days', '1 hour'
  created_at TIMESTAMPTZ DEFAULT now()
);

-- Task reminders
CREATE TABLE IF NOT EXISTS task_reminders (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  task_id UUID REFERENCES tasks ON DELETE CASCADE,
  timedelta INTERVAL NOT NULL DEFAULT '1 day'::INTERVAL, -- e.g., '1 day', '30 minutes'
  created_at TIMESTAMPTZ DEFAULT now()
);

-- Task completion forms (for tracking completion of tasks, especially recurring ones)
CREATE TABLE IF NOT EXISTS task_completion_forms (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  task_id UUID REFERENCES tasks ON DELETE CASCADE,
  completion_datetime TIMESTAMPTZ DEFAULT now(),
  recurrence_index INTEGER, -- For recurring tasks, which instance was completed
  complete BOOLEAN DEFAULT true,
  partial BOOLEAN DEFAULT false -- For tasks that can be partially completed
);

-- Task action completion forms (for tracking completion of task actions)
CREATE TABLE IF NOT EXISTS task_action_completion_forms (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  action_id UUID REFERENCES task_actions ON DELETE CASCADE,
  completion_datetime TIMESTAMPTZ DEFAULT now(),
  recurrence_index INTEGER, -- For recurring tasks, which instance was completed
  ignore BOOLEAN DEFAULT false,
  complete BOOLEAN DEFAULT true
);

-- Recurrent task overwrites (for modifying specific instances of recurring tasks)
CREATE TABLE IF NOT EXISTS recurrent_task_overwrites (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  task_id UUID REFERENCES tasks ON DELETE CASCADE,
  recurrence_id UUID REFERENCES recurrences ON DELETE CASCADE,
  recurrence_index INTEGER NOT NULL -- Which instance of the recurrence is being overwritten
);

-- Indexes for tasks to improve query performance
CREATE INDEX IF NOT EXISTS task_type_idx ON tasks (type);
CREATE INDEX IF NOT EXISTS task_start_datetime_idx ON tasks (start_datetime) WHERE start_datetime IS NOT NULL;
CREATE INDEX IF NOT EXISTS task_end_datetime_idx ON tasks (end_datetime) WHERE end_datetime IS NOT NULL;
CREATE INDEX IF NOT EXISTS task_date_idx ON tasks (date) WHERE date IS NOT NULL;
CREATE INDEX IF NOT EXISTS task_due_date_idx ON tasks (due_date) WHERE due_date IS NOT NULL;
CREATE INDEX IF NOT EXISTS task_earliest_action_date_idx ON tasks (earliest_action_date) WHERE earliest_action_date IS NOT NULL;

-- RLS for tasks
ALTER TABLE tasks ENABLE ROW LEVEL SECURITY;
CREATE POLICY "Users can view tasks they are members of"
  ON tasks FOR SELECT USING (
    EXISTS (
      SELECT 1 FROM task_members
      WHERE task_id = id AND member_id = auth.uid()
    )
  );
CREATE POLICY "Users can view tasks they are viewers of"
  ON tasks FOR SELECT USING (
    EXISTS (
      SELECT 1 FROM task_viewers
      WHERE task_id = id AND member_id = auth.uid()
    )
  );
CREATE POLICY "Users can view tasks for entities they own or are members of"
  ON tasks FOR SELECT USING (
    EXISTS (
      SELECT 1 FROM task_entities te
      JOIN entities e ON te.entity_id = e.id
      WHERE te.task_id = id AND (
        e.owner_id = auth.uid() OR
        EXISTS (
          SELECT 1 FROM entity_members
          WHERE entity_id = e.id AND member_id = auth.uid()
        )
      )
    )
  );
CREATE POLICY "Users can create tasks"
  ON tasks FOR INSERT WITH CHECK (true); -- Additional checks in application logic
CREATE POLICY "Task members can update tasks"
  ON tasks FOR UPDATE USING (
    EXISTS (
      SELECT 1 FROM task_members
      WHERE task_id = id AND member_id = auth.uid()
    )
  );
CREATE POLICY "Task members can delete tasks"
  ON tasks FOR DELETE USING (
    EXISTS (
      SELECT 1 FROM task_members
      WHERE task_id = id AND member_id = auth.uid()
    )
  );

-- RLS for task members
ALTER TABLE task_members ENABLE ROW LEVEL SECURITY;
CREATE POLICY "Task members can view other members"
  ON task_members FOR SELECT USING (
    EXISTS (
      SELECT 1 FROM task_members AS tm
      WHERE tm.task_id = task_id AND tm.member_id = auth.uid()
    )
  );
CREATE POLICY "Task members can manage members"
  ON task_members FOR ALL USING (
    EXISTS (
      SELECT 1 FROM task_members
      WHERE task_id = task_id AND member_id = auth.uid()
    )
  );

-- RLS for task viewers
ALTER TABLE task_viewers ENABLE ROW LEVEL SECURITY;
CREATE POLICY "Task members can view viewers"
  ON task_viewers FOR SELECT USING (
    EXISTS (
      SELECT 1 FROM task_members
      WHERE task_id = task_id AND member_id = auth.uid()
    )
  );
CREATE POLICY "Task viewers can view other viewers"
  ON task_viewers FOR SELECT USING (
    EXISTS (
      SELECT 1 FROM task_viewers AS tv
      WHERE tv.task_id = task_id AND tv.member_id = auth.uid()
    )
  );
CREATE POLICY "Task members can manage viewers"
  ON task_viewers FOR ALL USING (
    EXISTS (
      SELECT 1 FROM task_members
      WHERE task_id = task_id AND member_id = auth.uid()
    )
  );

-- RLS for task entities
ALTER TABLE task_entities ENABLE ROW LEVEL SECURITY;
CREATE POLICY "Task members can view task entities"
  ON task_entities FOR SELECT USING (
    EXISTS (
      SELECT 1 FROM task_members
      WHERE task_id = task_id AND member_id = auth.uid()
    )
  );
CREATE POLICY "Task viewers can view task entities"
  ON task_entities FOR SELECT USING (
    EXISTS (
      SELECT 1 FROM task_viewers
      WHERE task_id = task_id AND member_id = auth.uid()
    )
  );
CREATE POLICY "Task members can manage task entities"
  ON task_entities FOR ALL USING (
    EXISTS (
      SELECT 1 FROM task_members
      WHERE task_id = task_id AND member_id = auth.uid()
    )
  );

-- RLS for recurrences
ALTER TABLE recurrences ENABLE ROW LEVEL SECURITY;
CREATE POLICY "Task members can view recurrences"
  ON recurrences FOR SELECT USING (
    EXISTS (
      SELECT 1 FROM task_members
      WHERE task_id = task_id AND member_id = auth.uid()
    )
  );
CREATE POLICY "Task members can manage recurrences"
  ON recurrences FOR ALL USING (
    EXISTS (
      SELECT 1 FROM task_members
      WHERE task_id = task_id AND member_id = auth.uid()
    )
  );

-- RLS for task actions
ALTER TABLE task_actions ENABLE ROW LEVEL SECURITY;
CREATE POLICY "Task members can view task actions"
  ON task_actions FOR SELECT USING (
    EXISTS (
      SELECT 1 FROM task_members
      WHERE task_id = task_id AND member_id = auth.uid()
    )
  );
CREATE POLICY "Task members can manage task actions"
  ON task_actions FOR ALL USING (
    EXISTS (
      SELECT 1 FROM task_members
      WHERE task_id = task_id AND member_id = auth.uid()
    )
  );

-- RLS for task reminders
ALTER TABLE task_reminders ENABLE ROW LEVEL SECURITY;
CREATE POLICY "Task members can view task reminders"
  ON task_reminders FOR SELECT USING (
    EXISTS (
      SELECT 1 FROM task_members
      WHERE task_id = task_id AND member_id = auth.uid()
    )
  );
CREATE POLICY "Task members can manage task reminders"
  ON task_reminders FOR ALL USING (
    EXISTS (
      SELECT 1 FROM task_members
      WHERE task_id = task_id AND member_id = auth.uid()
    )
  );

-- RLS for task completion forms
ALTER TABLE task_completion_forms ENABLE ROW LEVEL SECURITY;
CREATE POLICY "Task members can view task completion forms"
  ON task_completion_forms FOR SELECT USING (
    EXISTS (
      SELECT 1 FROM task_members
      WHERE task_id = task_id AND member_id = auth.uid()
    )
  );
CREATE POLICY "Task members can manage task completion forms"
  ON task_completion_forms FOR ALL USING (
    EXISTS (
      SELECT 1 FROM task_members
      WHERE task_id = task_id AND member_id = auth.uid()
    )
  );

-- RLS for task action completion forms
ALTER TABLE task_action_completion_forms ENABLE ROW LEVEL SECURITY;
CREATE POLICY "Task members can view task action completion forms"
  ON task_action_completion_forms FOR SELECT USING (
    EXISTS (
      SELECT 1 FROM task_members tm
      JOIN task_actions ta ON tm.task_id = ta.task_id
      WHERE ta.id = action_id AND tm.member_id = auth.uid()
    )
  );
CREATE POLICY "Task members can manage task action completion forms"
  ON task_action_completion_forms FOR ALL USING (
    EXISTS (
      SELECT 1 FROM task_members tm
      JOIN task_actions ta ON tm.task_id = ta.task_id
      WHERE ta.id = action_id AND tm.member_id = auth.uid()
    )
  );

-- RLS for recurrent task overwrites
ALTER TABLE recurrent_task_overwrites ENABLE ROW LEVEL SECURITY;
CREATE POLICY "Task members can view recurrent task overwrites"
  ON recurrent_task_overwrites FOR SELECT USING (
    EXISTS (
      SELECT 1 FROM task_members
      WHERE task_id = task_id AND member_id = auth.uid()
    )
  );
CREATE POLICY "Task members can manage recurrent task overwrites"
  ON recurrent_task_overwrites FOR ALL USING (
    EXISTS (
      SELECT 1 FROM task_members
      WHERE task_id = task_id AND member_id = auth.uid()
    )
  );

-- =============================================================================
-- REALTIME SETUP
-- =============================================================================

-- Enable realtime for key tables
ALTER PUBLICATION supabase_realtime ADD TABLE entities;
ALTER PUBLICATION supabase_realtime ADD TABLE entity_members;
ALTER PUBLICATION supabase_realtime ADD TABLE professional_entity_category_mapping;
ALTER PUBLICATION supabase_realtime ADD TABLE tasks;
ALTER PUBLICATION supabase_realtime ADD TABLE task_members;
ALTER PUBLICATION supabase_realtime ADD TABLE task_viewers;
ALTER PUBLICATION supabase_realtime ADD TABLE task_entities;
ALTER PUBLICATION supabase_realtime ADD TABLE task_completion_forms;

-- =============================================================================
-- FAMILY MEMBERS TABLE (if not already created in Phase 1)
-- =============================================================================

-- Create family members table if it doesn't exist yet
CREATE TABLE IF NOT EXISTS family_members (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  family_id UUID NOT NULL,
  user_id UUID REFERENCES auth.users NOT NULL,
  role TEXT DEFAULT 'MEMBER', -- HEAD, MEMBER
  created_at TIMESTAMPTZ DEFAULT now(),
  UNIQUE (family_id, user_id)
);

-- RLS for family members
ALTER TABLE family_members ENABLE ROW LEVEL SECURITY;
CREATE POLICY "Users can view their own family memberships"
  ON family_members FOR SELECT USING (user_id = auth.uid());
CREATE POLICY "Users can view family members in their families"
  ON family_members FOR SELECT USING (
    EXISTS (
      SELECT 1 FROM family_members AS fm
      WHERE fm.family_id = family_id AND fm.user_id = auth.uid()
    )
  );
CREATE POLICY "Family heads can manage family members"
  ON family_members FOR ALL USING (
    EXISTS (
      SELECT 1 FROM family_members AS fm
      WHERE fm.family_id = family_id AND fm.user_id = auth.uid() AND fm.role = 'HEAD'
    )
  );
