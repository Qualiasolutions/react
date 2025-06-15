-- VUET MIGRATION: DJANGO TO SUPABASE SCHEMA
-- Complete schema migration for Vuet application
-- This file recreates the entire Django model structure in PostgreSQL/Supabase

-- Enable necessary extensions
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";
CREATE EXTENSION IF NOT EXISTS "pg_trgm";
CREATE EXTENSION IF NOT EXISTS "ltree";

-- =============================================================================
-- STORAGE BUCKETS SETUP
-- =============================================================================

-- Enable storage
INSERT INTO storage.buckets (id, name, public) VALUES ('entities', 'Entity images and files', true);
INSERT INTO storage.buckets (id, name, public) VALUES ('lists', 'List attachments', false);
INSERT INTO storage.buckets (id, name, public) VALUES ('messages', 'Message attachments', false);

-- Set up storage security policies
CREATE POLICY "Entity images are publicly accessible" 
  ON storage.objects FOR SELECT USING (bucket_id = 'entities');

CREATE POLICY "Authenticated users can upload entity images" 
  ON storage.objects FOR INSERT TO authenticated USING (bucket_id = 'entities');

CREATE POLICY "Users can update their own entity images" 
  ON storage.objects FOR UPDATE TO authenticated USING (
    bucket_id = 'entities' AND 
    (storage.foldername(name))[1] = auth.uid()::text
  );

CREATE POLICY "Users can access their own list attachments" 
  ON storage.objects FOR SELECT TO authenticated USING (
    bucket_id = 'lists' AND 
    (storage.foldername(name))[1] = auth.uid()::text
  );

CREATE POLICY "Users can upload list attachments" 
  ON storage.objects FOR INSERT TO authenticated USING (bucket_id = 'lists');

CREATE POLICY "Message attachments accessible to conversation participants" 
  ON storage.objects FOR SELECT TO authenticated USING (
    bucket_id = 'messages' AND 
    EXISTS (
      SELECT 1 FROM message_threads mt 
      JOIN message_thread_participants mtp ON mt.id = mtp.thread_id 
      WHERE mtp.user_id = auth.uid() AND 
      (storage.foldername(name))[1] = mt.id::text
    )
  );

-- =============================================================================
-- PROFILES & USER SETTINGS
-- =============================================================================

-- Create profiles table (extends auth.users)
CREATE TABLE profiles (
  id UUID PRIMARY KEY REFERENCES auth.users ON DELETE CASCADE,
  full_name TEXT,
  avatar_url TEXT,
  phone_number TEXT,
  created_at TIMESTAMPTZ DEFAULT now(),
  updated_at TIMESTAMPTZ DEFAULT now(),
  last_active_at TIMESTAMPTZ DEFAULT now()
);

-- User settings for task preferences
CREATE TABLE user_settings (
  id UUID PRIMARY KEY REFERENCES auth.users ON DELETE CASCADE,
  preferred_days JSONB DEFAULT '[]',
  blocked_days JSONB DEFAULT '[]',
  flexible_task_preferences JSONB DEFAULT '{}'
);

-- RLS for profiles
ALTER TABLE profiles ENABLE ROW LEVEL SECURITY;
CREATE POLICY "Users can view any profile" 
  ON profiles FOR SELECT USING (true);
CREATE POLICY "Users can update own profile" 
  ON profiles FOR UPDATE USING (auth.uid() = id);
CREATE POLICY "Users can insert own profile" 
  ON profiles FOR INSERT WITH CHECK (auth.uid() = id);

-- RLS for user settings
ALTER TABLE user_settings ENABLE ROW LEVEL SECURITY;
CREATE POLICY "Users can view own settings" 
  ON user_settings FOR SELECT USING (auth.uid() = id);
CREATE POLICY "Users can update own settings" 
  ON user_settings FOR UPDATE USING (auth.uid() = id);
CREATE POLICY "Users can insert own settings" 
  ON user_settings FOR INSERT WITH CHECK (auth.uid() = id);

-- Trigger to create profile on signup
CREATE OR REPLACE FUNCTION public.handle_new_user() 
RETURNS TRIGGER AS $$
BEGIN
  INSERT INTO public.profiles (id, full_name)
  VALUES (new.id, new.raw_user_meta_data->>'full_name');
  
  INSERT INTO public.user_settings (id)
  VALUES (new.id);
  
  RETURN new;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

CREATE TRIGGER on_auth_user_created
  AFTER INSERT ON auth.users
  FOR EACH ROW EXECUTE PROCEDURE public.handle_new_user();

-- =============================================================================
-- CATEGORIES
-- =============================================================================

-- Core categories table
CREATE TABLE categories (
  id SMALLINT PRIMARY KEY,
  name TEXT NOT NULL UNIQUE,
  readable_name TEXT NOT NULL,
  is_premium BOOLEAN DEFAULT false,
  is_enabled BOOLEAN DEFAULT true
);

-- Professional categories (user-defined)
CREATE TABLE professional_categories (
  id BIGSERIAL PRIMARY KEY,
  user_id UUID REFERENCES auth.users ON DELETE CASCADE NOT NULL,
  name TEXT NOT NULL,
  created_at TIMESTAMPTZ DEFAULT now(),
  UNIQUE (user_id, name)
);

-- RLS for categories
ALTER TABLE categories ENABLE ROW LEVEL SECURITY;
CREATE POLICY "Categories are viewable by all users" 
  ON categories FOR SELECT USING (true);

-- RLS for professional categories
ALTER TABLE professional_categories ENABLE ROW LEVEL SECURITY;
CREATE POLICY "Users can view their professional categories" 
  ON professional_categories FOR SELECT USING (auth.uid() = user_id);
CREATE POLICY "Users can create their professional categories" 
  ON professional_categories FOR INSERT WITH CHECK (auth.uid() = user_id);
CREATE POLICY "Users can update their professional categories" 
  ON professional_categories FOR UPDATE USING (auth.uid() = user_id);
CREATE POLICY "Users can delete their professional categories" 
  ON professional_categories FOR DELETE USING (auth.uid() = user_id);

-- Seed the 13 core categories
INSERT INTO categories (id, name, readable_name, is_premium, is_enabled) VALUES
(1, 'FAMILY', 'Family', false, true),
(2, 'PETS', 'Pets', false, true),
(3, 'SOCIAL_INTERESTS', 'Social & Interests', false, true),
(4, 'EDUCATION', 'Education', false, true),
(5, 'CAREER', 'Career', false, true),
(6, 'TRAVEL', 'Travel', false, true),
(7, 'HEALTH_BEAUTY', 'Health & Beauty', false, true),
(8, 'HOME', 'Home', false, true),
(9, 'GARDEN', 'Garden', false, true),
(10, 'FOOD', 'Food', false, true),
(11, 'LAUNDRY', 'Laundry', false, true),
(12, 'FINANCE', 'Finance', false, true),
(13, 'TRANSPORT', 'Transport', false, true);

-- =============================================================================
-- FAMILIES & SHARING
-- =============================================================================

-- Families table
CREATE TABLE families (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  name TEXT NOT NULL,
  created_by UUID REFERENCES auth.users NOT NULL,
  created_at TIMESTAMPTZ DEFAULT now()
);

-- Family members
CREATE TABLE family_members (
  family_id UUID REFERENCES families ON DELETE CASCADE,
  user_id UUID REFERENCES auth.users ON DELETE CASCADE,
  role TEXT NOT NULL DEFAULT 'MEMBER',
  joined_at TIMESTAMPTZ DEFAULT now(),
  PRIMARY KEY (family_id, user_id)
);

-- Family invites
CREATE TABLE family_invites (
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

-- RLS for family members
ALTER TABLE family_members ENABLE ROW LEVEL SECURITY;
CREATE POLICY "Users can view members of families they belong to" 
  ON family_members FOR SELECT USING (
    EXISTS (
      SELECT 1 FROM family_members AS fm 
      WHERE fm.family_id = family_id AND fm.user_id = auth.uid()
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

-- =============================================================================
-- ENTITIES (POLYMORPHIC MODEL)
-- =============================================================================

-- Main entities table - replaces Django's polymorphic model with a single table
CREATE TABLE entities (
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
CREATE TABLE entity_members (
  entity_id UUID REFERENCES entities ON DELETE CASCADE,
  member_id UUID REFERENCES auth.users ON DELETE CASCADE,
  role TEXT DEFAULT 'VIEWER',
  added_at TIMESTAMPTZ DEFAULT now(),
  PRIMARY KEY (entity_id, member_id)
);

-- Professional entity category mapping
CREATE TABLE professional_entity_category_mapping (
  entity_id UUID REFERENCES entities ON DELETE CASCADE,
  professional_category_id BIGINT REFERENCES professional_categories ON DELETE CASCADE,
  user_id UUID REFERENCES auth.users ON DELETE CASCADE,
  PRIMARY KEY (user_id, entity_id)
);

-- Guest list invites
CREATE TABLE guest_list_invites (
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
CREATE INDEX entity_owner_idx ON entities (owner_id);
CREATE INDEX entity_category_idx ON entities (category_id);
CREATE INDEX entity_type_idx ON entities (type);
CREATE INDEX entity_parent_idx ON entities (parent_id);

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

-- =============================================================================
-- REFERENCES
-- =============================================================================

-- Reference groups
CREATE TABLE reference_groups (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  created_by UUID REFERENCES auth.users NOT NULL,
  name TEXT NOT NULL,
  tags TEXT[] DEFAULT '{}',
  created_at TIMESTAMPTZ DEFAULT now()
);

-- References (key-value pairs)
CREATE TABLE references (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  group_id UUID REFERENCES reference_groups ON DELETE CASCADE NOT NULL,
  name TEXT NOT NULL,
  value TEXT NOT NULL,
  type TEXT NOT NULL,
  created_by UUID REFERENCES auth.users,
  created_at TIMESTAMPTZ DEFAULT now()
);

-- Entity reference groups mapping
CREATE TABLE entity_reference_groups (
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
CREATE TABLE tasks (
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
CREATE TABLE task_members (
  task_id UUID REFERENCES tasks ON DELETE CASCADE,
  member_id UUID REFERENCES auth.users ON DELETE CASCADE,
  PRIMARY KEY (task_id, member_id)
);

-- Task viewers
CREATE TABLE task_viewers (
  task_id UUID REFERENCES tasks ON DELETE CASCADE,
  member_id UUID REFERENCES auth.users ON DELETE CASCADE,
  PRIMARY KEY (task_id, member_id)
);

-- Task entities (many-to-many)
CREATE TABLE task_entities (
  task_id UUID REFERENCES tasks ON DELETE CASCADE,
  entity_id UUID REFERENCES entities ON DELETE CASCADE,
  PRIMARY KEY (task_id, entity_id)
);

-- Recurrences
CREATE TABLE recurrences (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  task_id UUID REFERENCES tasks ON DELETE CASCADE UNIQUE,
  recurrence TEXT NOT NULL,
  interval_length INTEGER DEFAULT 1,
  earliest_occurrence TIMESTAMPTZ,
  latest_occurrence TIMESTAMPTZ
);

-- Task actions
CREATE TABLE task_actions (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  task_id UUID REFERENCES tasks ON DELETE CASCADE,
  action_timedelta INTERVAL NOT NULL DEFAULT '1 day'::INTERVAL
);

-- Task reminders
CREATE TABLE task_reminders (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  task_id UUID REFERENCES tasks ON DELETE CASCADE,
  timedelta INTERVAL NOT NULL DEFAULT '1 day'::INTERVAL
);

-- Task completion forms
CREATE TABLE task_completion_forms (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  task_id UUID REFERENCES tasks ON DELETE CASCADE,
  completion_datetime TIMESTAMPTZ DEFAULT now(),
  recurrence_index INTEGER,
  complete BOOLEAN DEFAULT true,
  partial BOOLEAN DEFAULT false
);

-- Task action completion forms
CREATE TABLE task_action_completion_forms (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  action_id UUID REFERENCES task_actions ON DELETE CASCADE,
  completion_datetime TIMESTAMPTZ DEFAULT now(),
  recurrence_index INTEGER,
  ignore BOOLEAN DEFAULT false,
  complete BOOLEAN DEFAULT true
);

-- Recurrent task overwrites
CREATE TABLE recurrent_task_overwrites (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  task_id UUID REFERENCES tasks ON DELETE CASCADE,
  recurrence_id UUID REFERENCES recurrences ON DELETE CASCADE,
  recurrence_index INTEGER NOT NULL
);

-- Indexes for tasks
CREATE INDEX task_type_idx ON tasks (type);
CREATE INDEX task_due_date_idx ON tasks (due_date);
CREATE INDEX task_start_datetime_idx ON tasks (start_datetime);
CREATE INDEX task_date_idx ON tasks (date);

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

-- =============================================================================
-- ROUTINES & TIMEBLOCKS
-- =============================================================================

-- Routines
CREATE TABLE routines (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  name TEXT NOT NULL,
  owner_id UUID REFERENCES auth.users ON DELETE CASCADE NOT NULL,
  created_at TIMESTAMPTZ DEFAULT now()
);

-- Time blocks
CREATE TABLE timeblocks (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  name TEXT NOT NULL,
  owner_id UUID REFERENCES auth.users ON DELETE CASCADE NOT NULL,
  start_time TIME NOT NULL,
  end_time TIME NOT NULL,
  days INTEGER[] NOT NULL,  -- 0=Monday, 6=Sunday
  created_at TIMESTAMPTZ DEFAULT now()
);

-- Timeblock members
CREATE TABLE timeblock_members (
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

-- =============================================================================
-- LISTS (SHOPPING, PLANNING)
-- =============================================================================

-- Lists
CREATE TABLE lists (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  name TEXT NOT NULL,
  type TEXT NOT NULL,  -- SHOPPING, PLANNING
  owner_id UUID REFERENCES auth.users ON DELETE CASCADE NOT NULL,
  is_template BOOLEAN DEFAULT false,
  created_at TIMESTAMPTZ DEFAULT now(),
  updated_at TIMESTAMPTZ DEFAULT now()
);

-- List items
CREATE TABLE list_items (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  list_id UUID REFERENCES lists ON DELETE CASCADE NOT NULL,
  name TEXT NOT NULL,
  completed BOOLEAN DEFAULT false,
  position INTEGER NOT NULL,
  created_at TIMESTAMPTZ DEFAULT now(),
  updated_at TIMESTAMPTZ DEFAULT now()
);

-- List members
CREATE TABLE list_members (
  list_id UUID REFERENCES lists ON DELETE CASCADE,
  member_id UUID REFERENCES auth.users ON DELETE CASCADE,
  role TEXT DEFAULT 'VIEWER',
  PRIMARY KEY (list_id, member_id)
);

-- List delegations (for shopping lists)
CREATE TABLE list_delegations (
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
-- MESSAGES
-- =============================================================================

-- Message threads
CREATE TABLE message_threads (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  created_by UUID REFERENCES auth.users NOT NULL,
  created_at TIMESTAMPTZ DEFAULT now(),
  updated_at TIMESTAMPTZ DEFAULT now()
);

-- Message thread participants
CREATE TABLE message_thread_participants (
  thread_id UUID REFERENCES message_threads ON DELETE CASCADE,
  user_id UUID REFERENCES auth.users ON DELETE CASCADE,
  joined_at TIMESTAMPTZ DEFAULT now(),
  PRIMARY KEY (thread_id, user_id)
);

-- Messages
CREATE TABLE messages (
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

-- =============================================================================
-- NOTIFICATIONS & ALERTS
-- =============================================================================

-- Alerts
CREATE TABLE alerts (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  user_id UUID REFERENCES auth.users ON DELETE CASCADE NOT NULL,
  title TEXT NOT NULL,
  message TEXT NOT NULL,
  link TEXT,
  read BOOLEAN DEFAULT false,
  created_at TIMESTAMPTZ DEFAULT now()
);

-- Action alerts
CREATE TABLE action_alerts (
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
CREATE TABLE push_tokens (
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
-- EXTERNAL CALENDARS
-- =============================================================================

-- iCal integrations
CREATE TABLE ical_integrations (
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
CREATE TABLE ical_events (
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
-- REALTIME SETUP
-- =============================================================================

-- Enable realtime for key tables
ALTER PUBLICATION supabase_realtime ADD TABLE tasks;
ALTER PUBLICATION supabase_realtime ADD TABLE alerts;
ALTER PUBLICATION supabase_realtime ADD TABLE action_alerts;
ALTER PUBLICATION supabase_realtime ADD TABLE messages;
ALTER PUBLICATION supabase_realtime ADD TABLE task_completion_forms;

-- =============================================================================
-- EDGE FUNCTIONS
-- =============================================================================

-- Generate task occurrences function (to be implemented as an Edge Function)
COMMENT ON SCHEMA public IS 'Edge Functions to implement:
- generate_task_occurrences: Generates occurrences for recurring tasks
- send_push_notifications: Sends push notifications for tasks and alerts
- process_ical_sync: Syncs external calendars
- send_family_invites: Sends email/SMS invites for family sharing
';

-- =============================================================================
-- SETUP COMPLETION TRACKING
-- =============================================================================

-- Tables to track user setup completion
CREATE TABLE references_setup_completion (
  id UUID PRIMARY KEY REFERENCES auth.users ON DELETE CASCADE,
  completed BOOLEAN DEFAULT false,
  completed_at TIMESTAMPTZ
);

CREATE TABLE entity_type_setup_completion (
  id UUID PRIMARY KEY REFERENCES auth.users ON DELETE CASCADE,
  entity_type TEXT NOT NULL,
  completed BOOLEAN DEFAULT false,
  completed_at TIMESTAMPTZ,
  UNIQUE (id, entity_type)
);

CREATE TABLE tag_setup_completion (
  id UUID PRIMARY KEY REFERENCES auth.users ON DELETE CASCADE,
  completed BOOLEAN DEFAULT false,
  completed_at TIMESTAMPTZ
);

CREATE TABLE link_list_setup_completion (
  id UUID PRIMARY KEY REFERENCES auth.users ON DELETE CASCADE,
  completed BOOLEAN DEFAULT false,
  completed_at TIMESTAMPTZ
);

-- RLS for setup completion tables
ALTER TABLE references_setup_completion ENABLE ROW LEVEL SECURITY;
CREATE POLICY "Users can view their setup completion" 
  ON references_setup_completion FOR SELECT USING (id = auth.uid());
CREATE POLICY "Users can update their setup completion" 
  ON references_setup_completion FOR UPDATE USING (id = auth.uid());
CREATE POLICY "Users can insert their setup completion" 
  ON references_setup_completion FOR INSERT WITH CHECK (id = auth.uid());

ALTER TABLE entity_type_setup_completion ENABLE ROW LEVEL SECURITY;
CREATE POLICY "Users can view their entity type setup completion" 
  ON entity_type_setup_completion FOR SELECT USING (id = auth.uid());
CREATE POLICY "Users can update their entity type setup completion" 
  ON entity_type_setup_completion FOR UPDATE USING (id = auth.uid());
CREATE POLICY "Users can insert their entity type setup completion" 
  ON entity_type_setup_completion FOR INSERT WITH CHECK (id = auth.uid());

ALTER TABLE tag_setup_completion ENABLE ROW LEVEL SECURITY;
CREATE POLICY "Users can view their tag setup completion" 
  ON tag_setup_completion FOR SELECT USING (id = auth.uid());
CREATE POLICY "Users can update their tag setup completion" 
  ON tag_setup_completion FOR UPDATE USING (id = auth.uid());
CREATE POLICY "Users can insert their tag setup completion" 
  ON tag_setup_completion FOR INSERT WITH CHECK (id = auth.uid());

ALTER TABLE link_list_setup_completion ENABLE ROW LEVEL SECURITY;
CREATE POLICY "Users can view their link list setup completion" 
  ON link_list_setup_completion FOR SELECT USING (id = auth.uid());
CREATE POLICY "Users can update their link list setup completion" 
  ON link_list_setup_completion FOR UPDATE USING (id = auth.uid());
CREATE POLICY "Users can insert their link list setup completion" 
  ON link_list_setup_completion FOR INSERT WITH CHECK (id = auth.uid());

-- =============================================================================
-- SUBSCRIPTIONS
-- =============================================================================

-- Subscription plans
CREATE TABLE subscription_plans (
  id TEXT PRIMARY KEY,
  name TEXT NOT NULL,
  description TEXT,
  price NUMERIC(10, 2) NOT NULL,
  currency TEXT NOT NULL DEFAULT 'USD',
  interval TEXT NOT NULL,
  active BOOLEAN DEFAULT true,
  created_at TIMESTAMPTZ DEFAULT now()
);

-- User subscriptions
CREATE TABLE user_subscriptions (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  user_id UUID REFERENCES auth.users ON DELETE CASCADE NOT NULL,
  plan_id TEXT REFERENCES subscription_plans NOT NULL,
  status TEXT NOT NULL,
  current_period_start TIMESTAMPTZ NOT NULL,
  current_period_end TIMESTAMPTZ NOT NULL,
  cancel_at_period_end BOOLEAN DEFAULT false,
  created_at TIMESTAMPTZ DEFAULT now(),
  updated_at TIMESTAMPTZ DEFAULT now()
);

-- RLS for subscriptions
ALTER TABLE subscription_plans ENABLE ROW LEVEL SECURITY;
CREATE POLICY "Anyone can view subscription plans" 
  ON subscription_plans FOR SELECT USING (true);

ALTER TABLE user_subscriptions ENABLE ROW LEVEL SECURITY;
CREATE POLICY "Users can view their subscriptions" 
  ON user_subscriptions FOR SELECT USING (user_id = auth.uid());

-- =============================================================================
-- VIEWS
-- =============================================================================

-- Last activity view
CREATE VIEW last_activity_view AS
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
CREATE VIEW task_occurrences AS
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
