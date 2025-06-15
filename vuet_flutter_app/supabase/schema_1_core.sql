-- Schema 1: Core Schema for Vuet Flutter App
-- This schema includes the essential tables and relationships needed for basic functionality

-- Enable necessary extensions
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";
CREATE EXTENSION IF NOT EXISTS "pg_trgm"; -- For text search

-- =============================================================================
-- PROFILES
-- =============================================================================
-- Create profiles table that extends auth.users
CREATE TABLE public.profiles (
  id UUID PRIMARY KEY REFERENCES auth.users(id) ON DELETE CASCADE,
  full_name TEXT,
  avatar_url TEXT,
  email TEXT,
  phone TEXT,
  has_completed_setup BOOLEAN DEFAULT FALSE,
  created_at TIMESTAMPTZ DEFAULT now(),
  updated_at TIMESTAMPTZ DEFAULT now(),
  preferences JSONB DEFAULT '{}'::JSONB
);

-- =============================================================================
-- CATEGORIES
-- =============================================================================
-- Core categories table (13 predefined categories)
CREATE TABLE public.categories (
  id SMALLINT PRIMARY KEY,
  name TEXT NOT NULL UNIQUE,
  readable_name TEXT NOT NULL,
  is_premium BOOLEAN DEFAULT FALSE
);

-- Professional categories (user-defined)
CREATE TABLE public.professional_categories (
  id BIGSERIAL PRIMARY KEY,
  user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE,
  name TEXT NOT NULL,
  created_at TIMESTAMPTZ DEFAULT now(),
  updated_at TIMESTAMPTZ DEFAULT now()
);

-- =============================================================================
-- ENTITIES
-- =============================================================================
-- Base entities table (polymorphic)
CREATE TABLE public.entities (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  owner_id UUID REFERENCES auth.users(id) ON DELETE CASCADE,
  category_id SMALLINT REFERENCES categories(id),
  type TEXT NOT NULL, -- e.g. CAR, PET, TRIP, etc.
  subtype TEXT,       -- free string for fine grained types
  name TEXT NOT NULL,
  notes TEXT DEFAULT '',
  image_path TEXT,    -- storage reference
  hidden BOOLEAN DEFAULT FALSE,
  parent_id UUID REFERENCES entities(id) ON DELETE SET NULL,
  created_at TIMESTAMPTZ DEFAULT now(),
  updated_at TIMESTAMPTZ DEFAULT now(),
  
  -- JSONB fields for type-specific data
  dates JSONB DEFAULT '{}'::JSONB,
  contact_info JSONB DEFAULT '{}'::JSONB,
  location JSONB DEFAULT '{}'::JSONB,
  metadata JSONB DEFAULT '{}'::JSONB
);

-- Entity membership (sharing)
CREATE TABLE public.entity_members (
  id BIGSERIAL PRIMARY KEY,
  entity_id UUID REFERENCES entities(id) ON DELETE CASCADE,
  member_id UUID REFERENCES auth.users(id) ON DELETE CASCADE,
  created_at TIMESTAMPTZ DEFAULT now(),
  UNIQUE(entity_id, member_id)
);

-- Professional entity category mapping
CREATE TABLE public.professional_entity_category_mapping (
  entity_id UUID REFERENCES entities(id) ON DELETE CASCADE,
  professional_category_id BIGINT REFERENCES professional_categories(id) ON DELETE CASCADE,
  user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE,
  PRIMARY KEY (user_id, entity_id)
);

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

-- Recurrences
CREATE TABLE public.recurrences (
  id BIGSERIAL PRIMARY KEY,
  task_id UUID REFERENCES tasks(id) ON DELETE CASCADE UNIQUE,
  recurrence TEXT NOT NULL, -- DAILY, WEEKLY, etc.
  interval_length INTEGER DEFAULT 1,
  earliest_occurrence TIMESTAMPTZ,
  latest_occurrence TIMESTAMPTZ,
  created_at TIMESTAMPTZ DEFAULT now(),
  updated_at TIMESTAMPTZ DEFAULT now()
);

-- Task reminders
CREATE TABLE public.task_reminders (
  id BIGSERIAL PRIMARY KEY,
  task_id UUID REFERENCES tasks(id) ON DELETE CASCADE,
  timedelta INTERVAL NOT NULL DEFAULT INTERVAL '1 day',
  created_at TIMESTAMPTZ DEFAULT now()
);

-- =============================================================================
-- VIEWS
-- =============================================================================
-- Scheduled tasks view (materialized for performance)
CREATE MATERIALIZED VIEW scheduled_tasks AS
WITH recurring_tasks AS (
  SELECT
    t.id,
    t.title,
    t.type,
    t.hidden_tag,
    t.notes,
    t.location,
    t.contact_name,
    t.contact_email,
    t.contact_phone,
    t.duration,
    t.start_datetime,
    t.end_datetime,
    t.start_date,
    t.end_date,
    t.created_at,
    t.updated_at,
    r.id AS recurrence_id,
    r.recurrence,
    r.interval_length,
    generate_series(
      COALESCE(t.start_datetime, t.start_date::timestamp, t.due_date::timestamp),
      COALESCE(r.latest_occurrence, (now() + interval '1 year')::timestamp),
      CASE
        WHEN r.recurrence = 'DAILY' THEN (r.interval_length || ' days')::interval
        WHEN r.recurrence = 'WEEKLY' THEN (r.interval_length || ' weeks')::interval
        WHEN r.recurrence = 'MONTHLY' THEN (r.interval_length || ' months')::interval
        WHEN r.recurrence = 'YEARLY' THEN (r.interval_length || ' years')::interval
        ELSE '1 day'::interval
      END
    ) AS occurrence_date,
    -- Use the aliased column instead of the raw function call
    row_number() OVER (PARTITION BY t.id ORDER BY occurrence_date) - 1 AS recurrence_index
  FROM tasks t
  JOIN recurrences r ON t.id = r.task_id
  WHERE r.recurrence IN ('DAILY', 'WEEKLY', 'MONTHLY', 'YEARLY')
)
SELECT
  id,
  title,
  type,
  hidden_tag,
  notes,
  location,
  contact_name,
  contact_email,
  contact_phone,
  duration,
  start_datetime,
  end_datetime,
  start_date,
  end_date,
  created_at,
  updated_at,
  recurrence_id,
  recurrence,
  interval_length,
  occurrence_date,
  recurrence_index
FROM recurring_tasks
UNION ALL
SELECT
  t.id,
  t.title,
  t.type,
  t.hidden_tag,
  t.notes,
  t.location,
  t.contact_name,
  t.contact_email,
  t.contact_phone,
  t.duration,
  t.start_datetime,
  t.end_datetime,
  t.start_date,
  t.end_date,
  t.created_at,
  t.updated_at,
  NULL AS recurrence_id,
  NULL AS recurrence,
  NULL AS interval_length,
  COALESCE(t.start_datetime, t.start_date::timestamp, t.due_date::timestamp) AS occurrence_date,
  NULL AS recurrence_index
FROM tasks t
LEFT JOIN recurrences r ON t.id = r.task_id
WHERE r.id IS NULL;

-- =============================================================================
-- INDEXES
-- =============================================================================
-- Core indexes for performance
CREATE INDEX entities_owner_idx ON entities(owner_id);
CREATE INDEX entities_category_idx ON entities(category_id);
CREATE INDEX entities_type_idx ON entities(type);
CREATE INDEX entities_parent_idx ON entities(parent_id);
CREATE INDEX tasks_type_idx ON tasks(type);
CREATE INDEX tasks_due_date_idx ON tasks(due_date);
CREATE INDEX tasks_start_datetime_idx ON tasks(start_datetime);
CREATE INDEX scheduled_tasks_occurrence_idx ON scheduled_tasks(occurrence_date);
CREATE INDEX profiles_email_idx ON profiles(email);
CREATE INDEX profiles_phone_idx ON profiles(phone);
CREATE INDEX task_members_member_idx ON task_members(member_id);

-- =============================================================================
-- RLS POLICIES
-- =============================================================================
-- Enable RLS on all tables
ALTER TABLE public.profiles ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.categories ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.professional_categories ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.entities ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.entity_members ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.professional_entity_category_mapping ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.tasks ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.task_members ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.task_entities ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.recurrences ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.task_reminders ENABLE ROW LEVEL SECURITY;

-- Profiles policies
CREATE POLICY "Users can view their own profile"
  ON public.profiles FOR SELECT
  USING (auth.uid() = id);

CREATE POLICY "Users can update their own profile"
  ON public.profiles FOR UPDATE
  USING (auth.uid() = id);

-- Categories policies (public read)
CREATE POLICY "Categories are readable by all users"
  ON public.categories FOR SELECT
  USING (true);

-- Professional categories policies
CREATE POLICY "Users can view their own professional categories"
  ON public.professional_categories FOR SELECT
  USING (auth.uid() = user_id);

CREATE POLICY "Users can create their own professional categories"
  ON public.professional_categories FOR INSERT
  WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can update their own professional categories"
  ON public.professional_categories FOR UPDATE
  USING (auth.uid() = user_id);

CREATE POLICY "Users can delete their own professional categories"
  ON public.professional_categories FOR DELETE
  USING (auth.uid() = user_id);

-- Entities policies
CREATE POLICY "Users can view their own entities"
  ON public.entities FOR SELECT
  USING (auth.uid() = owner_id);

CREATE POLICY "Users can view entities they are members of"
  ON public.entities FOR SELECT
  USING (
    EXISTS (
      SELECT 1 FROM entity_members
      WHERE entity_members.entity_id = id
      AND entity_members.member_id = auth.uid()
    )
  );

CREATE POLICY "Users can create their own entities"
  ON public.entities FOR INSERT
  WITH CHECK (auth.uid() = owner_id);

CREATE POLICY "Users can update their own entities"
  ON public.entities FOR UPDATE
  USING (auth.uid() = owner_id);

CREATE POLICY "Users can delete their own entities"
  ON public.entities FOR DELETE
  USING (auth.uid() = owner_id);

-- Entity members policies
CREATE POLICY "Entity owners can manage members"
  ON public.entity_members
  USING (
    EXISTS (
      SELECT 1 FROM entities
      WHERE entities.id = entity_id
      AND entities.owner_id = auth.uid()
    )
  );

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

-- =============================================================================
-- STORAGE BUCKETS
-- =============================================================================
-- Create storage buckets
INSERT INTO storage.buckets (id, name, public) VALUES
  ('entities', 'Entity images and attachments', true),
  ('profiles', 'Profile avatars', true);

-- Storage RLS policies
CREATE POLICY "Public profiles access"
  ON storage.objects FOR SELECT
  USING (bucket_id = 'profiles');

CREATE POLICY "Avatar uploads"
  ON storage.objects FOR INSERT
  WITH CHECK (
    bucket_id = 'profiles' AND
    auth.uid()::text = (storage.foldername(name))[1]
  );

CREATE POLICY "Entity images access"
  ON storage.objects FOR SELECT
  USING (bucket_id = 'entities');

CREATE POLICY "Entity owners can upload"
  ON storage.objects FOR INSERT
  WITH CHECK (
    bucket_id = 'entities' AND
    EXISTS (
      SELECT 1 FROM entities
      WHERE entities.id::text = (storage.foldername(name))[1]
      AND entities.owner_id = auth.uid()
    )
  );

-- =============================================================================
-- FUNCTIONS & TRIGGERS
-- =============================================================================
-- Function to update 'updated_at' timestamp
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
  NEW.updated_at = now();
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Apply updated_at triggers to relevant tables
CREATE TRIGGER update_entities_updated_at
BEFORE UPDATE ON entities
FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_tasks_updated_at
BEFORE UPDATE ON tasks
FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_profiles_updated_at
BEFORE UPDATE ON profiles
FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

-- Function to refresh scheduled_tasks materialized view
CREATE OR REPLACE FUNCTION refresh_scheduled_tasks()
RETURNS TRIGGER AS $$
BEGIN
  REFRESH MATERIALIZED VIEW scheduled_tasks;
  RETURN NULL;
END;
$$ LANGUAGE plpgsql;

-- Trigger to refresh scheduled_tasks when tasks or recurrences change
CREATE TRIGGER refresh_scheduled_tasks_on_task_change
AFTER INSERT OR UPDATE OR DELETE ON tasks
FOR EACH STATEMENT EXECUTE FUNCTION refresh_scheduled_tasks();

CREATE TRIGGER refresh_scheduled_tasks_on_recurrence_change
AFTER INSERT OR UPDATE OR DELETE ON recurrences
FOR EACH STATEMENT EXECUTE FUNCTION refresh_scheduled_tasks();

-- =============================================================================
-- INITIAL DATA SEEDING
-- =============================================================================
-- Seed core categories
INSERT INTO public.categories (id, name, readable_name, is_premium) VALUES
  (1, 'FAMILY', 'Family', false),
  (2, 'PETS', 'Pets', false),
  (3, 'SOCIAL_INTERESTS', 'Social & Interests', false),
  (4, 'EDUCATION', 'Education', false),
  (5, 'CAREER', 'Career', false),
  (6, 'TRAVEL', 'Travel', false),
  (7, 'HEALTH_BEAUTY', 'Health & Beauty', false),
  (8, 'HOME', 'Home', false),
  (9, 'GARDEN', 'Garden', false),
  (10, 'FOOD', 'Food', false),
  (11, 'LAUNDRY', 'Laundry', false),
  (12, 'FINANCE', 'Finance', true),
  (13, 'TRANSPORT', 'Transport', false);
