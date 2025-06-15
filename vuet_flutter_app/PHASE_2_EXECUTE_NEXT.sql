-- VUET MIGRATION: PHASE 2 - CORE BUSINESS LOGIC
-- This script builds on the Phase 1 foundation to add the core business logic tables
-- Execute this in your Supabase SQL Editor

-- =============================================================================
-- STORAGE BUCKETS SETUP (additional buckets beyond Phase 1)
-- =============================================================================

-- Create additional storage buckets for lists and messages
INSERT INTO storage.buckets (id, name, public) VALUES
('lists', 'List attachments', false),
('messages', 'Message attachments', false)
ON CONFLICT (id) DO NOTHING;

-- Set up additional storage security policies
CREATE POLICY "Users can access their own list attachments"
  ON storage.objects FOR SELECT TO authenticated
  USING (
    bucket_id = 'lists'
    AND (storage.foldername(name))[1] = auth.uid()::text
  );

CREATE POLICY "Users can upload list attachments"
  ON storage.objects FOR INSERT TO authenticated
  WITH CHECK (bucket_id = 'lists');

CREATE POLICY "Users can delete their own list attachments"
  ON storage.objects FOR DELETE TO authenticated
  USING (
    bucket_id = 'lists'
    AND (storage.foldername(name))[1] = auth.uid()::text
  );

-- =============================================================================
-- FAMILIES & SHARING
-- =============================================================================

-- Families table
CREATE TABLE IF NOT EXISTS families (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  name TEXT NOT NULL,
  created_by UUID REFERENCES auth.users NOT NULL,
  created_at TIMESTAMPTZ DEFAULT now()
);

-- Family members
CREATE TABLE IF NOT EXISTS family_members (
  family_id UUID REFERENCES families ON DELETE CASCADE,
  user_id UUID REFERENCES auth.users ON DELETE CASCADE,
  role TEXT NOT NULL DEFAULT 'MEMBER',
  joined_at TIMESTAMPTZ DEFAULT now(),
  PRIMARY KEY (family_id, user_id)
);

-- Family invites
CREATE TABLE IF NOT EXISTS family_invites (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  family_id UUID REFERENCES families ON DELETE CASCADE NOT NULL,
  email TEXT,
  phone TEXT,
  name TEXT,
  invited_by UUID REFERENCES auth.users NOT NULL,
  status TEXT NOT NULL DEFAULT 'PENDING',
  created_at TIMESTAMPTZ DEFAULT now(),
  expires_at TIMESTAMPTZ DEFAULT (now() + interval '7 days'),
  CONSTRAINT email_or_phone_required CHECK (email IS NOT NULL OR phone IS NOT NULL)
);

-- RLS for families
ALTER TABLE families ENABLE ROW LEVEL SECURITY;
CREATE POLICY "Users can view families they belong to" 
  ON families FOR SELECT USING (
    EXISTS (
      SELECT 1 FROM family_members 
      WHERE family_id = id AND user_id = auth.uid()
    )
  );
CREATE POLICY "Users can create families" 
  ON families FOR INSERT WITH CHECK (auth.uid() = created_by);
CREATE POLICY "Family creators can update their families" 
  ON families FOR UPDATE USING (created_by = auth.uid());
CREATE POLICY "Family creators can delete their families" 
  ON families FOR DELETE USING (created_by = auth.uid());

-- RLS for family members
ALTER TABLE family_members ENABLE ROW LEVEL SECURITY;
CREATE POLICY "Users can view members of families they belong to" 
  ON family_members FOR SELECT USING (
    EXISTS (
      SELECT 1 FROM family_members AS fm 
      WHERE fm.family_id = family_id AND fm.user_id = auth.uid()
    )
  );
CREATE POLICY "Family creators can manage members" 
  ON family_members FOR ALL USING (
    EXISTS (
      SELECT 1 FROM families
      WHERE id = family_id AND created_by = auth.uid()
    )
  );

-- RLS for family invites
ALTER TABLE family_invites ENABLE ROW LEVEL SECURITY;
CREATE POLICY "Users can view invites they sent" 
  ON family_invites FOR SELECT USING (invited_by = auth.uid());
CREATE POLICY "Users can create invites for families they belong to" 
  ON family_invites FOR INSERT WITH CHECK (
    EXISTS (
      SELECT 1 FROM family_members 
      WHERE family_id = family_invites.family_id AND user_id = auth.uid()
    )
  );
CREATE POLICY "Users can update invites they sent" 
  ON family_invites FOR UPDATE USING (invited_by = auth.uid());
CREATE POLICY "Users can delete invites they sent" 
  ON family_invites FOR DELETE USING (invited_by = auth.uid());

-- =============================================================================
-- ENTITIES (POLYMORPHIC MODEL)
-- =============================================================================

-- Main entities table - replaces Django's polymorphic model with a single table
CREATE TABLE IF NOT EXISTS entities (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  owner_id UUID REFERENCES auth.users ON DELETE CASCADE,
  category_id SMALLINT REFERENCES categories,
  type TEXT NOT NULL,          -- Entity type (CAR, PET, TRIP, etc.)
  subtype TEXT DEFAULT '',     -- Optional subtype
  name TEXT NOT NULL,
  notes TEXT DEFAULT '',
  image_path TEXT,             -- Storage reference
  hidden BOOLEAN DEFAULT false,
  parent_id UUID REFERENCES entities,
  created_at TIMESTAMPTZ DEFAULT now(),
  updated_at TIMESTAMPTZ DEFAULT now(),
  
  -- Entity-specific fields (JSON columns for specialized entity types)
  -- These replace the need for separate tables per entity type
  dates JSONB DEFAULT NULL,    -- For date-related entities (trips, events)
  contact_info JSONB DEFAULT NULL, -- For entities with contact details
  location JSONB DEFAULT NULL, -- For entities with location info
  metadata JSONB DEFAULT NULL  -- For other entity-specific data
);

-- Entity members (for sharing)
CREATE TABLE IF NOT EXISTS entity_members (
  entity_id UUID REFERENCES entities ON DELETE CASCADE,
  member_id UUID REFERENCES auth.users ON DELETE CASCADE,
  role TEXT DEFAULT 'VIEWER',
  added_at TIMESTAMPTZ DEFAULT now(),
  PRIMARY KEY (entity_id, member_id)
);

-- Professional entity category mapping
CREATE TABLE IF NOT EXISTS professional_entity_category_mapping (
  entity_id UUID REFERENCES entities ON DELETE CASCADE,
  professional_category_id BIGINT REFERENCES professional_categories ON DELETE CASCADE,
  user_id UUID REFERENCES auth.users ON DELETE CASCADE,
  PRIMARY KEY (user_id, entity_id)
);

-- Guest list invites
CREATE TABLE IF NOT EXISTS guest_list_invites (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  entity_id UUID REFERENCES entities ON DELETE CASCADE,
  name TEXT,
  email TEXT,
  phone_number TEXT,
  status TEXT DEFAULT 'PENDING',
  sent BOOLEAN DEFAULT false,
  created_at TIMESTAMPTZ DEFAULT now(),
  CONSTRAINT email_or_phone_required CHECK (email IS NOT NULL OR phone_number IS NOT NULL)
);

-- Indexes for entities
CREATE INDEX IF NOT EXISTS entity_owner_idx ON entities (owner_id);
CREATE INDEX IF NOT EXISTS entity_category_idx ON entities (category_id);
CREATE INDEX IF NOT EXISTS entity_type_idx ON entities (type);
CREATE INDEX IF NOT EXISTS entity_parent_idx ON entities (parent_id);
CREATE INDEX IF NOT EXISTS entity_name_idx ON entities USING gin (name gin_trgm_ops);

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
-- REFERENCES
-- =============================================================================

-- Reference groups
CREATE TABLE IF NOT EXISTS reference_groups (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  created_by UUID REFERENCES auth.users NOT NULL,
  name TEXT NOT NULL,
  tags TEXT[] DEFAULT '{}',
  created_at TIMESTAMPTZ DEFAULT now()
);

-- References (key-value pairs)
CREATE TABLE IF NOT EXISTS references (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  group_id UUID REFERENCES reference_groups ON DELETE CASCADE NOT NULL,
  name TEXT NOT NULL,
  value TEXT NOT NULL,
  type TEXT NOT NULL,
  created_by UUID REFERENCES auth.users,
  created_at TIMESTAMPTZ DEFAULT now()
);

-- Entity reference groups mapping
CREATE TABLE IF NOT EXISTS entity_reference_groups (
  entity_id UUID REFERENCES entities ON DELETE CASCADE,
  reference_group_id UUID REFERENCES reference_groups ON DELETE CASCADE,
  PRIMARY KEY (entity_id, reference_group_id)
);

-- RLS for reference groups
ALTER TABLE reference_groups ENABLE ROW LEVEL SECURITY;
CREATE POLICY "Users can view their reference groups" 
  ON reference_groups FOR SELECT USING (created_by = auth.uid());
CREATE POLICY "Users can create reference groups" 
  ON reference_groups FOR INSERT WITH CHECK (created_by = auth.uid());
CREATE POLICY "Users can update their reference groups" 
  ON reference_groups FOR UPDATE USING (created_by = auth.uid());
CREATE POLICY "Users can delete their reference groups" 
  ON reference_groups FOR DELETE USING (created_by = auth.uid());

-- RLS for references
ALTER TABLE references ENABLE ROW LEVEL SECURITY;
CREATE POLICY "Users can view their references" 
  ON references FOR SELECT USING (
    EXISTS (
      SELECT 1 FROM reference_groups 
      WHERE id = group_id AND created_by = auth.uid()
    )
  );
CREATE POLICY "Users can create references in their groups" 
  ON references FOR INSERT WITH CHECK (
    EXISTS (
      SELECT 1 FROM reference_groups 
      WHERE id = group_id AND created_by = auth.uid()
    )
  );
CREATE POLICY "Users can update their references" 
  ON references FOR UPDATE USING (
    EXISTS (
      SELECT 1 FROM reference_groups 
      WHERE id = group_id AND created_by = auth.uid()
    )
  );
CREATE POLICY "Users can delete their references" 
  ON references FOR DELETE USING (
    EXISTS (
      SELECT 1 FROM reference_groups 
      WHERE id = group_id AND created_by = auth.uid()
    )
  );

-- =============================================================================
-- TASKS
-- =============================================================================

-- Tasks table (combines FixedTask and FlexibleTask)
CREATE TABLE IF NOT EXISTS tasks (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  title TEXT NOT NULL,
  type TEXT NOT NULL DEFAULT 'TASK',
  notes TEXT DEFAULT '',
  location TEXT DEFAULT '',
  contact_name TEXT DEFAULT '',
  contact_email TEXT DEFAULT '',
  contact_phone TEXT DEFAULT '',
  hidden_tag TEXT,
  tags TEXT[] DEFAULT '{}',
  
  -- Fields for fixed tasks
  start_datetime TIMESTAMPTZ,
  end_datetime TIMESTAMPTZ,
  start_timezone TEXT,
  end_timezone TEXT,
  start_date DATE,
  end_date DATE,
  date DATE,
  
  -- Fields for flexible tasks
  earliest_action_date DATE,
  due_date DATE,
  duration INTEGER DEFAULT 30,
  urgency TEXT,
  
  -- Common fields
  routine_id UUID,
  created_at TIMESTAMPTZ DEFAULT now(),
  updated_at TIMESTAMPTZ DEFAULT now(),
  
  -- Constraint to ensure either fixed or flexible task fields are used
  CONSTRAINT valid_task_type CHECK (
    (type IN ('TASK', 'APPOINTMENT', 'DUE_DATE') AND 
     (earliest_action_date IS NOT NULL OR due_date IS NOT NULL)) 
    OR
    (type NOT IN ('TASK', 'APPOINTMENT', 'DUE_DATE') AND
     (start_datetime IS NOT NULL OR end_datetime IS NOT NULL OR 
      start_date IS NOT NULL OR end_date IS NOT NULL OR date IS NOT NULL))
  )
);

-- Task members (for sharing)
CREATE TABLE IF NOT EXISTS task_members (
  task_id UUID REFERENCES tasks ON DELETE CASCADE,
  member_id UUID REFERENCES auth.users ON DELETE CASCADE,
  PRIMARY KEY (task_id, member_id)
);

-- Task viewers
CREATE TABLE IF NOT EXISTS task_viewers (
  task_id UUID REFERENCES tasks ON DELETE CASCADE,
  member_id UUID REFERENCES auth.users ON DELETE CASCADE,
  PRIMARY KEY (task_id, member_id)
);

-- Task entities (many-to-many)
CREATE TABLE IF NOT EXISTS task_entities (
  task_id UUID REFERENCES tasks ON DELETE CASCADE,
  entity_id UUID REFERENCES entities ON DELETE CASCADE,
  PRIMARY KEY (task_id, entity_id)
);

-- Recurrences
CREATE TABLE IF NOT EXISTS recurrences (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  task_id UUID REFERENCES tasks ON DELETE CASCADE UNIQUE,
  recurrence TEXT NOT NULL,
  interval_length INTEGER DEFAULT 1,
  earliest_occurrence TIMESTAMPTZ,
  latest_occurrence TIMESTAMPTZ
);

-- Task actions
CREATE TABLE IF NOT EXISTS task_actions (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  task_id UUID REFERENCES tasks ON DELETE CASCADE,
  action_timedelta INTERVAL NOT NULL DEFAULT '1 day'::INTERVAL
);

-- Task reminders
CREATE TABLE IF NOT EXISTS task_reminders (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  task_id UUID REFERENCES tasks ON DELETE CASCADE,
  timedelta INTERVAL NOT NULL DEFAULT '1 day'::INTERVAL
);

-- Task completion forms
CREATE TABLE IF NOT EXISTS task_completion_forms (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  task_id UUID REFERENCES tasks ON DELETE CASCADE,
  completion_datetime TIMESTAMPTZ DEFAULT now(),
  recurrence_index INTEGER,
  complete BOOLEAN DEFAULT true,
  partial BOOLEAN DEFAULT false
);

-- Task action completion forms
CREATE TABLE IF NOT EXISTS task_action_completion_forms (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  action_id UUID REFERENCES task_actions ON DELETE CASCADE,
  completion_datetime TIMESTAMPTZ DEFAULT now(),
  recurrence_index INTEGER,
  ignore BOOLEAN DEFAULT false,
  complete BOOLEAN DEFAULT true
);

-- Recurrent task overwrites
CREATE TABLE IF NOT EXISTS recurrent_task_overwrites (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  task_id UUID REFERENCES tasks ON DELETE CASCADE,
  recurrence_id UUID REFERENCES recurrences ON DELETE CASCADE,
  recurrence_index INTEGER NOT NULL
);

-- Indexes for tasks
CREATE INDEX IF NOT EXISTS task_type_idx ON tasks (type);
CREATE INDEX IF NOT EXISTS task_due_date_idx ON tasks (due_date);
CREATE INDEX IF NOT EXISTS task_start_datetime_idx ON tasks (start_datetime);
CREATE INDEX IF NOT EXISTS task_date_idx ON tasks (date);
CREATE INDEX IF NOT EXISTS task_title_idx ON tasks USING gin (title gin_trgm_ops);

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
CREATE POLICY "Users can view tasks related to their entities" 
  ON tasks FOR SELECT USING (
    EXISTS (
      SELECT 1 FROM task_entities te
      JOIN entities e ON te.entity_id = e.id
      WHERE te.task_id = id AND e.owner_id = auth.uid()
    )
  );
CREATE POLICY "Users can create tasks" 
  ON tasks FOR INSERT WITH CHECK (true);
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
CREATE POLICY "Users can view task members" 
  ON task_members FOR SELECT USING (
    EXISTS (
      SELECT 1 FROM task_members AS tm
      WHERE tm.task_id = task_id AND tm.member_id = auth.uid()
    )
  );
CREATE POLICY "Users can add task members" 
  ON task_members FOR INSERT WITH CHECK (
    EXISTS (
      SELECT 1 FROM task_members 
      WHERE task_id = task_members.task_id AND member_id = auth.uid()
    ) OR member_id = auth.uid()
  );
CREATE POLICY "Task members can manage members" 
  ON task_members FOR UPDATE USING (
    EXISTS (
      SELECT 1 FROM task_members 
      WHERE task_id = task_id AND member_id = auth.uid()
    )
  );
CREATE POLICY "Task members can remove members" 
  ON task_members FOR DELETE USING (
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
      WHERE task_id = task_entities.task_id AND member_id = auth.uid()
    )
  );
CREATE POLICY "Task members can manage task entities" 
  ON task_entities FOR ALL USING (
    EXISTS (
      SELECT 1 FROM task_members
      WHERE task_id = task_entities.task_id AND member_id = auth.uid()
    )
  );

-- RLS for recurrences
ALTER TABLE recurrences ENABLE ROW LEVEL SECURITY;
CREATE POLICY "Task members can view recurrences" 
  ON recurrences FOR SELECT USING (
    EXISTS (
      SELECT 1 FROM task_members
      WHERE task_id = recurrences.task_id AND member_id = auth.uid()
    )
  );
CREATE POLICY "Task members can manage recurrences" 
  ON recurrences FOR ALL USING (
    EXISTS (
      SELECT 1 FROM task_members
      WHERE task_id = recurrences.task_id AND member_id = auth.uid()
    )
  );

-- RLS for task actions
ALTER TABLE task_actions ENABLE ROW LEVEL SECURITY;
CREATE POLICY "Task members can view task actions" 
  ON task_actions FOR SELECT USING (
    EXISTS (
      SELECT 1 FROM task_members
      WHERE task_id = task_actions.task_id AND member_id = auth.uid()
    )
  );
CREATE POLICY "Task members can manage task actions" 
  ON task_actions FOR ALL USING (
    EXISTS (
      SELECT 1 FROM task_members
      WHERE task_id = task_actions.task_id AND member_id = auth.uid()
    )
  );

-- RLS for task reminders
ALTER TABLE task_reminders ENABLE ROW LEVEL SECURITY;
CREATE POLICY "Task members can view task reminders" 
  ON task_reminders FOR SELECT USING (
    EXISTS (
      SELECT 1 FROM task_members
      WHERE task_id = task_reminders.task_id AND member_id = auth.uid()
    )
  );
CREATE POLICY "Task members can manage task reminders" 
  ON task_reminders FOR ALL USING (
    EXISTS (
      SELECT 1 FROM task_members
      WHERE task_id = task_reminders.task_id AND member_id = auth.uid()
    )
  );

-- RLS for task completion forms
ALTER TABLE task_completion_forms ENABLE ROW LEVEL SECURITY;
CREATE POLICY "Task members can view task completion forms" 
  ON task_completion_forms FOR SELECT USING (
    EXISTS (
      SELECT 1 FROM task_members
      WHERE task_id = task_completion_forms.task_id AND member_id = auth.uid()
    )
  );
CREATE POLICY "Task members can manage task completion forms" 
  ON task_completion_forms FOR ALL USING (
    EXISTS (
      SELECT 1 FROM task_members
      WHERE task_id = task_completion_forms.task_id AND member_id = auth.uid()
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
      WHERE task_id = recurrent_task_overwrites.task_id AND member_id = auth.uid()
    )
  );
CREATE POLICY "Task members can manage recurrent task overwrites" 
  ON recurrent_task_overwrites FOR ALL USING (
    EXISTS (
      SELECT 1 FROM task_members
      WHERE task_id = recurrent_task_overwrites.task_id AND member_id = auth.uid()
    )
  );

-- =============================================================================
-- ROUTINES & TIMEBLOCKS
-- =============================================================================

-- Routines
CREATE TABLE IF NOT EXISTS routines (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  name TEXT NOT NULL,
  owner_id UUID REFERENCES auth.users ON DELETE CASCADE NOT NULL,
  created_at TIMESTAMPTZ DEFAULT now()
);

-- Time blocks
CREATE TABLE IF NOT EXISTS timeblocks (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  name TEXT NOT NULL,
  owner_id UUID REFERENCES auth.users ON DELETE CASCADE NOT NULL,
  start_time TIME NOT NULL,
  end_time TIME NOT NULL,
  days INTEGER[] NOT NULL,  -- 0=Monday, 6=Sunday
  created_at TIMESTAMPTZ DEFAULT now()
);

-- Timeblock members
CREATE TABLE IF NOT EXISTS timeblock_members (
  timeblock_id UUID REFERENCES timeblocks ON DELETE CASCADE,
  member_id UUID REFERENCES auth.users ON DELETE CASCADE,
  PRIMARY KEY (timeblock_id, member_id)
);

-- RLS for routines
ALTER TABLE routines ENABLE ROW LEVEL SECURITY;
CREATE POLICY "Users can view their routines" 
  ON routines FOR SELECT USING (owner_id = auth.uid());
CREATE POLICY "Users can create routines" 
  ON routines FOR INSERT WITH CHECK (owner_id = auth.uid());
CREATE POLICY "Users can update their routines" 
  ON routines FOR UPDATE USING (owner_id = auth.uid());
CREATE POLICY "Users can delete their routines" 
  ON routines FOR DELETE USING (owner_id = auth.uid());

-- RLS for timeblocks
ALTER TABLE timeblocks ENABLE ROW LEVEL SECURITY;
CREATE POLICY "Users can view their timeblocks" 
  ON timeblocks FOR SELECT USING (owner_id = auth.uid());
CREATE POLICY "Users can view timeblocks they are members of" 
  ON timeblocks FOR SELECT USING (
    EXISTS (
      SELECT 1 FROM timeblock_members 
      WHERE timeblock_id = id AND member_id = auth.uid()
    )
  );
CREATE POLICY "Users can create timeblocks" 
  ON timeblocks FOR INSERT WITH CHECK (owner_id = auth.uid());
CREATE POLICY "Users can update their timeblocks" 
  ON timeblocks FOR UPDATE USING (owner_id = auth.uid());
CREATE POLICY "Users can delete their timeblocks" 
  ON timeblocks FOR DELETE USING (owner_id = auth.uid());

-- RLS for timeblock members
ALTER TABLE timeblock_members ENABLE ROW LEVEL SECURITY;
CREATE POLICY "Timeblock owners can manage members" 
  ON timeblock_members FOR ALL USING (
    EXISTS (
      SELECT 1 FROM timeblocks
      WHERE id = timeblock_id AND owner_id = auth.uid()
    )
  );
CREATE POLICY "Users can view timeblock members they belong to" 
  ON timeblock_members FOR SELECT USING (
    EXISTS (
      SELECT 1 FROM timeblock_members AS tm
      WHERE tm.timeblock_id = timeblock_id AND tm.member_id = auth.uid()
    )
  );

-- =============================================================================
-- NOTIFICATIONS & ALERTS
-- =============================================================================

-- Alerts
CREATE TABLE IF NOT EXISTS alerts (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  user_id UUID REFERENCES auth.users ON DELETE CASCADE NOT NULL,
  title TEXT NOT NULL,
  message TEXT NOT NULL,
  link TEXT,
  read BOOLEAN DEFAULT false,
  created_at TIMESTAMPTZ DEFAULT now()
);

-- Action alerts
CREATE TABLE IF NOT EXISTS action_alerts (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  user_id UUID REFERENCES auth.users ON DELETE CASCADE NOT NULL,
  task_id UUID REFERENCES tasks ON DELETE CASCADE,
  action_id UUID REFERENCES task_actions ON DELETE CASCADE,
  title TEXT NOT NULL,
  message TEXT NOT NULL,
  read BOOLEAN DEFAULT false,
  created_at TIMESTAMPTZ DEFAULT now()
);

-- Push notification tokens
CREATE TABLE IF NOT EXISTS push_tokens (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  user_id UUID REFERENCES auth.users ON DELETE CASCADE NOT NULL,
  token TEXT NOT NULL UNIQUE,
  device_id TEXT,
  device_type TEXT,
  created_at TIMESTAMPTZ DEFAULT now(),
  updated_at TIMESTAMPTZ DEFAULT now()
);

-- RLS for alerts
ALTER TABLE alerts ENABLE ROW LEVEL SECURITY;
CREATE POLICY "Users can view their alerts" 
  ON alerts FOR SELECT USING (user_id = auth.uid());
CREATE POLICY "Users can update their alerts" 
  ON alerts FOR UPDATE USING (user_id = auth.uid());

-- RLS for action alerts
ALTER TABLE action_alerts ENABLE ROW LEVEL SECURITY;
CREATE POLICY "Users can view their action alerts" 
  ON action_alerts FOR SELECT USING (user_id = auth.uid());
CREATE POLICY "Users can update their action alerts" 
  ON action_alerts FOR UPDATE USING (user_id = auth.uid());

-- RLS for push tokens
ALTER TABLE push_tokens ENABLE ROW LEVEL SECURITY;
CREATE POLICY "Users can view their push tokens" 
  ON push_tokens FOR SELECT USING (user_id = auth.uid());
CREATE POLICY "Users can create their push tokens" 
  ON push_tokens FOR INSERT WITH CHECK (user_id = auth.uid());
CREATE POLICY "Users can update their push tokens" 
  ON push_tokens FOR UPDATE USING (user_id = auth.uid());
CREATE POLICY "Users can delete their push tokens" 
  ON push_tokens FOR DELETE USING (user_id = auth.uid());

-- =============================================================================
-- MESSAGES
-- =============================================================================

-- Message threads
CREATE TABLE IF NOT EXISTS message_threads (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  created_by UUID REFERENCES auth.users NOT NULL,
  created_at TIMESTAMPTZ DEFAULT now(),
  updated_at TIMESTAMPTZ DEFAULT now()
);

-- Message thread participants
CREATE TABLE IF NOT EXISTS message_thread_participants (
  thread_id UUID REFERENCES message_threads ON DELETE CASCADE,
  user_id UUID REFERENCES auth.users ON DELETE CASCADE,
  joined_at TIMESTAMPTZ DEFAULT now(),
  PRIMARY KEY (thread_id, user_id)
);

-- Messages
CREATE TABLE IF NOT EXISTS messages (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  thread_id UUID REFERENCES message_threads ON DELETE CASCADE NOT NULL,
  sender_id UUID REFERENCES auth.users NOT NULL,
  content TEXT NOT NULL,
  attachment_path TEXT,
  created_at TIMESTAMPTZ DEFAULT now()
);

-- RLS for message threads
ALTER TABLE message_threads ENABLE ROW LEVEL SECURITY;
CREATE POLICY "Users can view threads they participate in" 
  ON message_threads FOR SELECT USING (
    EXISTS (
      SELECT 1 FROM message_thread_participants 
      WHERE thread_id = id AND user_id = auth.uid()
    )
  );
CREATE POLICY "Users can create message threads" 
  ON message_threads FOR INSERT WITH CHECK (created_by = auth.uid());

-- RLS for message thread participants
ALTER TABLE message_thread_participants ENABLE ROW LEVEL SECURITY;
CREATE POLICY "Thread creators can manage participants" 
  ON message_thread_participants FOR ALL USING (
    EXISTS (
      SELECT 1 FROM message_threads
      WHERE id = thread_id AND created_by = auth.uid()
    )
  );
CREATE POLICY "Users can view participants in their threads" 
  ON message_thread_participants FOR SELECT USING (
    EXISTS (
      SELECT 1 FROM message_thread_participants AS mtp
      WHERE mtp.thread_id = thread_id AND mtp.user_id = auth.uid()
    )
  );

-- RLS for messages
ALTER TABLE messages ENABLE ROW LEVEL SECURITY;
CREATE POLICY "Users can view messages in threads they participate in" 
  ON messages FOR SELECT USING (
    EXISTS (
      SELECT 1 FROM message_thread_participants 
      WHERE thread_id = messages.thread_id AND user_id = auth.uid()
    )
  );
CREATE POLICY "Users can send messages to threads they participate in" 
  ON messages FOR INSERT WITH CHECK (
    sender_id = auth.uid() AND
    EXISTS (
      SELECT 1 FROM message_thread_participants 
      WHERE thread_id = messages.thread_id AND user_id = auth.uid()
    )
  );

-- Storage policy for message attachments now that message_threads exists
CREATE POLICY "Message attachments accessible to conversation participants"
  ON storage.objects FOR SELECT TO authenticated
  USING (
    bucket_id = 'messages' AND
    EXISTS (
      SELECT 1 FROM message_threads mt
      JOIN message_thread_participants mtp ON mt.id = mtp.thread_id
      WHERE mtp.user_id = auth.uid() AND
      (storage.foldername(name))[1] = mt.id::text
    )
  );

-- =============================================================================
-- LISTS (SHOPPING, PLANNING)
-- =============================================================================

-- Lists
CREATE TABLE IF NOT EXISTS lists (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  name TEXT NOT NULL,
  type TEXT NOT NULL,  -- SHOPPING, PLANNING
  owner_id UUID REFERENCES auth.users ON DELETE CASCADE NOT NULL,
  is_template BOOLEAN DEFAULT false,
  created_at TIMESTAMPTZ DEFAULT now(),
  updated_at TIMESTAMPTZ DEFAULT now()
);

-- List items
CREATE TABLE IF NOT EXISTS list_items (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  list_id UUID REFERENCES lists ON DELETE CASCADE NOT NULL,
  name TEXT NOT NULL,
  completed BOOLEAN DEFAULT false,
  position INTEGER NOT NULL,
  created_at TIMESTAMPTZ DEFAULT now(),
  updated_at TIMESTAMPTZ DEFAULT now()
);

-- List members
CREATE TABLE IF NOT EXISTS list_members (
  list_id UUID REFERENCES lists ON DELETE CASCADE,
  member_id UUID REFERENCES auth.users ON DELETE CASCADE,
  role TEXT DEFAULT 'VIEWER',
  PRIMARY KEY (list_id, member_id)
);

-- List delegations (for shopping lists)
CREATE TABLE IF NOT EXISTS list_delegations (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  list_id UUID REFERENCES lists ON DELETE CASCADE NOT NULL,
  delegated_to UUID REFERENCES auth.users ON DELETE CASCADE NOT NULL,
  delegated_by UUID REFERENCES auth.users ON DELETE CASCADE NOT NULL,
  status TEXT DEFAULT 'PENDING',
  created_at TIMESTAMPTZ DEFAULT now()
);

-- RLS for lists
ALTER TABLE lists ENABLE ROW LEVEL SECURITY;
CREATE POLICY "Users can view their lists" 
  ON lists FOR SELECT USING (owner_id = auth.uid());
CREATE POLICY "Users can view lists shared with them" 
  ON lists FOR SELECT USING (
    EXISTS (
      SELECT 1 FROM list_members 
      WHERE list_id = id AND member_id = auth.uid()
    )
  );
CREATE POLICY "Users can view lists delegated to them" 
  ON lists FOR SELECT USING (
    EXISTS (
      SELECT 1 FROM list_delegations 
      WHERE list_id = id AND delegated_to = auth.uid()
    )
  );
CREATE POLICY "Users can create lists" 
  ON lists FOR INSERT WITH CHECK (owner_id = auth.uid());
CREATE POLICY "Users can update their lists" 
  ON lists FOR UPDATE USING (owner_id = auth.uid());
CREATE POLICY "Users can delete their lists" 
  ON lists FOR DELETE USING (owner_id = auth.uid());

-- RLS for list items
ALTER TABLE list_items ENABLE ROW LEVEL SECURITY;
CREATE POLICY "Users can view items in their lists" 
  ON list_items FOR SELECT USING (
    EXISTS (
      SELECT 1 FROM lists 
      WHERE id = list_id AND owner_id = auth.uid()
    )
  );
CREATE POLICY "Users can view items in lists shared with them" 
  ON list_items FOR SELECT USING (
    EXISTS (
      SELECT 1 FROM list_members 
      WHERE list_id = list_items.list_id AND member_id = auth.uid()
    )
  );
CREATE POLICY "Users can view items in lists delegated to them" 
  ON list_items FOR SELECT USING (
    EXISTS (
      SELECT 1 FROM list_delegations 
      WHERE list_id = list_items.list_id AND delegated_to = auth.uid()
    )
  );
CREATE POLICY "Users can create items in their lists" 
  ON list_items FOR INSERT WITH CHECK (
    EXISTS (
      SELECT 1 FROM lists 
      WHERE id = list_id AND owner_id = auth.uid()
    )
  );
CREATE POLICY "Users can update items in their lists" 
  ON list_items FOR UPDATE USING (
    EXISTS (
      SELECT 1 FROM lists 
      WHERE id = list_id AND owner_id = auth.uid()
    )
  );
CREATE POLICY "Delegated users can update list items" 
  ON list_items FOR UPDATE USING (
    EXISTS (
      SELECT 1 FROM list_delegations 
      WHERE list_id = list_items.list_id AND delegated_to = auth.uid()
    )
  );
CREATE POLICY "Users can delete items in their lists" 
  ON list_items FOR DELETE USING (
    EXISTS (
      SELECT 1 FROM lists 
      WHERE id = list_id AND owner_id = auth.uid()
    )
  );

-- =============================================================================
-- EXTERNAL CALENDARS
-- =============================================================================

-- iCal integrations
CREATE TABLE IF NOT EXISTS ical_integrations (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  user_id UUID REFERENCES auth.users ON DELETE CASCADE NOT NULL,
  url TEXT NOT NULL,
  ical_name TEXT,
  ical_type TEXT,
  share_type TEXT DEFAULT 'PRIVATE',
  last_synced_at TIMESTAMPTZ,
  created_at TIMESTAMPTZ DEFAULT now()
);

-- iCal events
CREATE TABLE IF NOT EXISTS ical_events (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  integration_id UUID REFERENCES ical_integrations ON DELETE CASCADE NOT NULL,
  uid TEXT NOT NULL,
  summary TEXT,
  description TEXT,
  location TEXT,
  start_time TIMESTAMPTZ,
  end_time TIMESTAMPTZ,
  all_day BOOLEAN DEFAULT false,
  recurrence TEXT,
  created_at TIMESTAMPTZ DEFAULT now(),
  UNIQUE (integration_id, uid)
);

-- RLS for iCal integrations
ALTER TABLE ical_integrations ENABLE ROW LEVEL SECURITY;
CREATE POLICY "Users can view their iCal integrations" 
  ON ical_integrations FOR SELECT USING (user_id = auth.uid());
CREATE POLICY "Users can create iCal integrations" 
  ON ical_integrations FOR INSERT WITH CHECK (user_id = auth.uid());
CREATE POLICY "Users can update their iCal integrations" 
  ON ical_integrations FOR UPDATE USING (user_id = auth.uid());
CREATE POLICY "Users can delete their iCal integrations" 
  ON ical_integrations FOR DELETE USING (user_id = auth.uid());

-- RLS for iCal events
ALTER TABLE ical_events ENABLE ROW LEVEL SECURITY;
CREATE POLICY "Users can view events from their integrations" 
  ON ical_events FOR SELECT USING (
    EXISTS (
      SELECT 1 FROM ical_integrations 
      WHERE id = integration_id AND user_id = auth.uid()
    )
  );

-- =============================================================================
-- VIEWS
-- =============================================================================

-- Last activity view
CREATE OR REPLACE VIEW last_activity_view AS
SELECT 
  u.id AS user_id,
  GREATEST(
    COALESCE(MAX(t.updated_at), '1970-01-01'::timestamptz),
    COALESCE(MAX(e.updated_at), '1970-01-01'::timestamptz),
    COALESCE(MAX(tcf.completion_datetime), '1970-01-01'::timestamptz),
    COALESCE(MAX(m.created_at), '1970-01-01'::timestamptz)
  ) AS last_activity
FROM 
  auth.users u
LEFT JOIN task_members tm ON u.id = tm.member_id
LEFT JOIN tasks t ON tm.task_id = t.id
LEFT JOIN entity_members em ON u.id = em.member_id
LEFT JOIN entities e ON em.entity_id = e.id
LEFT JOIN task_completion_forms tcf ON EXISTS (
  SELECT 1 FROM task_members 
  WHERE member_id = u.id AND task_id = tcf.task_id
)
LEFT JOIN message_thread_participants mtp ON u.id = mtp.user_id
LEFT JOIN messages m ON mtp.thread_id = m.thread_id
GROUP BY u.id;

-- Task occurrences view (for recurring tasks)
CREATE OR REPLACE VIEW task_occurrences AS
SELECT 
  t.id,
  t.title,
  t.type,
  t.notes,
  t.location,
  CASE 
    WHEN t.start_datetime IS NOT NULL THEN t.start_datetime
    WHEN t.date IS NOT NULL THEN t.date::timestamp
    ELSE NULL
  END AS occurrence_start,
  CASE 
    WHEN t.end_datetime IS NOT NULL THEN t.end_datetime
    WHEN t.date IS NOT NULL AND t.duration IS NOT NULL THEN (t.date::timestamp + (t.duration || ' minutes')::interval)
    ELSE NULL
  END AS occurrence_end,
  t.due_date,
  r.recurrence,
  r.interval_length
FROM 
  tasks t
LEFT JOIN recurrences r ON t.id = r.task_id;

-- =============================================================================
-- REALTIME SETUP
-- =============================================================================

-- Enable realtime for key tables
ALTER PUBLICATION supabase_realtime ADD TABLE entities;
ALTER PUBLICATION supabase_realtime ADD TABLE entity_members;
ALTER PUBLICATION supabase_realtime ADD TABLE tasks;
ALTER PUBLICATION supabase_realtime ADD TABLE task_members;
ALTER PUBLICATION supabase_realtime ADD TABLE task_entities;
ALTER PUBLICATION supabase_realtime ADD TABLE task_completion_forms;
ALTER PUBLICATION supabase_realtime ADD TABLE alerts;
ALTER PUBLICATION supabase_realtime ADD TABLE action_alerts;
ALTER PUBLICATION supabase_realtime ADD TABLE messages;
ALTER PUBLICATION supabase_realtime ADD TABLE families;
ALTER PUBLICATION supabase_realtime ADD TABLE family_members;

-- =============================================================================
-- TEXT SEARCH EXTENSIONS
-- =============================================================================

-- Enable trigram extension for text search if not already enabled
CREATE EXTENSION IF NOT EXISTS pg_trgm;

-- Add text search indexes
CREATE INDEX IF NOT EXISTS entity_name_trgm_idx ON entities USING gin (name gin_trgm_ops);
CREATE INDEX IF NOT EXISTS task_title_trgm_idx ON tasks USING gin (title gin_trgm_ops);
CREATE INDEX IF NOT EXISTS task_notes_trgm_idx ON tasks USING gin (notes gin_trgm_ops);
