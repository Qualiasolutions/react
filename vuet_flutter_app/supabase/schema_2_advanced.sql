-- Schema 2: Advanced Schema for Vuet Flutter App
-- This schema adds advanced features on top of Schema 1 (Core)
-- Run this AFTER applying schema_1_core.sql

-- =============================================================================
-- FAMILIES & SHARING
-- =============================================================================
-- Families table
CREATE TABLE public.families (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  name TEXT NOT NULL,
  owner_id UUID REFERENCES auth.users(id) ON DELETE CASCADE,
  created_at TIMESTAMPTZ DEFAULT now(),
  updated_at TIMESTAMPTZ DEFAULT now()
);

-- Family members
CREATE TABLE public.family_members (
  family_id UUID REFERENCES families(id) ON DELETE CASCADE,
  user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE,
  role TEXT DEFAULT 'MEMBER', -- OWNER, MEMBER, ADMIN
  created_at TIMESTAMPTZ DEFAULT now(),
  PRIMARY KEY (family_id, user_id)
);

-- Family invites
CREATE TABLE public.family_invites (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  family_id UUID REFERENCES families(id) ON DELETE CASCADE,
  email TEXT,
  phone TEXT,
  status TEXT DEFAULT 'PENDING', -- PENDING, ACCEPTED, REJECTED
  created_at TIMESTAMPTZ DEFAULT now(),
  updated_at TIMESTAMPTZ DEFAULT now(),
  expires_at TIMESTAMPTZ DEFAULT (now() + INTERVAL '7 days'),
  CONSTRAINT email_or_phone_required CHECK (email IS NOT NULL OR phone IS NOT NULL)
);

-- =============================================================================
-- REFERENCES
-- =============================================================================
-- Reference groups
CREATE TABLE public.reference_groups (
  id BIGSERIAL PRIMARY KEY,
  created_by UUID REFERENCES auth.users(id) ON DELETE CASCADE,
  name TEXT NOT NULL,
  tags TEXT[] DEFAULT '{}',
  created_at TIMESTAMPTZ DEFAULT now()
);

-- Entity reference groups (many-to-many)
CREATE TABLE public.entity_reference_groups (
  entity_id UUID REFERENCES entities(id) ON DELETE CASCADE,
  group_id BIGINT REFERENCES reference_groups(id) ON DELETE CASCADE,
  PRIMARY KEY (entity_id, group_id)
);

-- References
CREATE TABLE public.references (
  id BIGSERIAL PRIMARY KEY,
  created_by UUID REFERENCES auth.users(id) ON DELETE CASCADE,
  name TEXT NOT NULL,
  value TEXT NOT NULL,
  type TEXT NOT NULL, -- NAME, ACCOUNT_NUMBER, USERNAME, PASSWORD, etc.
  group_id BIGINT REFERENCES reference_groups(id) ON DELETE CASCADE,
  created_at TIMESTAMPTZ DEFAULT now()
);

-- =============================================================================
-- LISTS
-- =============================================================================
-- Lists (shopping, todo, etc.)
CREATE TABLE public.lists (
  id BIGSERIAL PRIMARY KEY,
  entity_id UUID REFERENCES entities(id) ON DELETE CASCADE,
  name TEXT NOT NULL,
  type TEXT NOT NULL, -- SHOPPING, TODO, etc.
  created_at TIMESTAMPTZ DEFAULT now(),
  updated_at TIMESTAMPTZ DEFAULT now()
);

-- List items
CREATE TABLE public.list_items (
  id BIGSERIAL PRIMARY KEY,
  list_id BIGINT REFERENCES lists(id) ON DELETE CASCADE,
  name TEXT NOT NULL,
  description TEXT,
  quantity INTEGER DEFAULT 1,
  is_completed BOOLEAN DEFAULT FALSE,
  position INTEGER DEFAULT 0,
  created_at TIMESTAMPTZ DEFAULT now(),
  updated_at TIMESTAMPTZ DEFAULT now()
);

-- =============================================================================
-- MESSAGES
-- =============================================================================
-- Message threads
CREATE TABLE public.message_threads (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  name TEXT,
  created_at TIMESTAMPTZ DEFAULT now(),
  updated_at TIMESTAMPTZ DEFAULT now()
);

-- Thread participants
CREATE TABLE public.thread_participants (
  thread_id UUID REFERENCES message_threads(id) ON DELETE CASCADE,
  user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE,
  created_at TIMESTAMPTZ DEFAULT now(),
  PRIMARY KEY (thread_id, user_id)
);

-- Messages
CREATE TABLE public.messages (
  id BIGSERIAL PRIMARY KEY,
  thread_id UUID REFERENCES message_threads(id) ON DELETE CASCADE,
  sender_id UUID REFERENCES auth.users(id) ON DELETE SET NULL,
  content TEXT NOT NULL,
  attachment_path TEXT,
  created_at TIMESTAMPTZ DEFAULT now()
);

-- =============================================================================
-- NOTIFICATIONS
-- =============================================================================
-- Push tokens
CREATE TABLE public.push_tokens (
  id BIGSERIAL PRIMARY KEY,
  user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE,
  token TEXT NOT NULL UNIQUE,
  device_type TEXT NOT NULL, -- ios, android, web
  active BOOLEAN DEFAULT TRUE,
  created_at TIMESTAMPTZ DEFAULT now(),
  updated_at TIMESTAMPTZ DEFAULT now()
);

-- Notifications
CREATE TABLE public.notifications (
  id BIGSERIAL PRIMARY KEY,
  user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE,
  title TEXT NOT NULL,
  body TEXT NOT NULL,
  data JSONB DEFAULT '{}'::JSONB,
  is_read BOOLEAN DEFAULT FALSE,
  created_at TIMESTAMPTZ DEFAULT now()
);

-- =============================================================================
-- ROUTINES & TIMEBLOCKS
-- =============================================================================
-- Routines
CREATE TABLE public.routines (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  owner_id UUID REFERENCES auth.users(id) ON DELETE CASCADE,
  name TEXT NOT NULL,
  description TEXT,
  created_at TIMESTAMPTZ DEFAULT now(),
  updated_at TIMESTAMPTZ DEFAULT now()
);

-- Routine members
CREATE TABLE public.routine_members (
  routine_id UUID REFERENCES routines(id) ON DELETE CASCADE,
  member_id UUID REFERENCES auth.users(id) ON DELETE CASCADE,
  created_at TIMESTAMPTZ DEFAULT now(),
  PRIMARY KEY (routine_id, member_id)
);

-- Timeblocks
CREATE TABLE public.timeblocks (
  id BIGSERIAL PRIMARY KEY,
  routine_id UUID REFERENCES routines(id) ON DELETE CASCADE,
  name TEXT NOT NULL,
  day_of_week INTEGER, -- 0 = Sunday, 6 = Saturday
  start_time TIME NOT NULL,
  end_time TIME NOT NULL,
  created_at TIMESTAMPTZ DEFAULT now(),
  updated_at TIMESTAMPTZ DEFAULT now()
);

-- =============================================================================
-- TASK ACTIONS & OVERRIDES
-- =============================================================================
-- Task actions (e.g., "1 day before", "2 hours after")
CREATE TABLE public.task_actions (
  id BIGSERIAL PRIMARY KEY,
  task_id UUID REFERENCES tasks(id) ON DELETE CASCADE,
  action_timedelta INTERVAL NOT NULL DEFAULT INTERVAL '1 day',
  created_at TIMESTAMPTZ DEFAULT now()
);

-- Task tags
CREATE TABLE public.tags (
  id BIGSERIAL PRIMARY KEY,
  name TEXT NOT NULL UNIQUE,
  created_at TIMESTAMPTZ DEFAULT now()
);

CREATE TABLE public.task_tags (
  task_id UUID REFERENCES tasks(id) ON DELETE CASCADE,
  tag_id BIGINT REFERENCES tags(id) ON DELETE CASCADE,
  PRIMARY KEY (task_id, tag_id)
);

-- Recurrent task overwrites
CREATE TABLE public.recurrent_task_overwrites (
  id BIGSERIAL PRIMARY KEY,
  base_task_id UUID REFERENCES tasks(id) ON DELETE CASCADE,
  recurrence_id BIGINT REFERENCES recurrences(id) ON DELETE CASCADE,
  recurrence_index INTEGER NOT NULL,
  overwrite_task_id UUID REFERENCES tasks(id) ON DELETE SET NULL,
  is_deleted BOOLEAN DEFAULT FALSE,
  created_at TIMESTAMPTZ DEFAULT now(),
  UNIQUE(base_task_id, recurrence_index)
);

-- =============================================================================
-- ADDITIONAL STORAGE BUCKETS
-- =============================================================================
-- Create additional storage buckets
INSERT INTO storage.buckets (id, name, public) VALUES
  ('lists', 'List attachments', true),
  ('messages', 'Message attachments', true);

-- =============================================================================
-- ADDITIONAL INDEXES
-- =============================================================================
-- Add additional indexes for performance
CREATE INDEX family_members_user_idx ON family_members(user_id);
CREATE INDEX family_invites_email_idx ON family_invites(email);
CREATE INDEX family_invites_phone_idx ON family_invites(phone);
CREATE INDEX messages_thread_idx ON messages(thread_id);
CREATE INDEX messages_sender_idx ON messages(sender_id);
CREATE INDEX push_tokens_user_idx ON push_tokens(user_id);
CREATE INDEX notifications_user_idx ON notifications(user_id);
CREATE INDEX reference_groups_created_by_idx ON reference_groups(created_by);
CREATE INDEX references_group_idx ON references(group_id);
CREATE INDEX list_items_list_idx ON list_items(list_id);
CREATE INDEX task_actions_task_idx ON task_actions(task_id);
CREATE INDEX task_tags_task_idx ON task_tags(task_id);

-- =============================================================================
-- ADDITIONAL RLS POLICIES
-- =============================================================================
-- Enable RLS on all new tables
ALTER TABLE public.families ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.family_members ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.family_invites ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.reference_groups ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.entity_reference_groups ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.references ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.lists ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.list_items ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.message_threads ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.thread_participants ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.messages ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.push_tokens ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.notifications ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.routines ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.routine_members ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.timeblocks ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.task_actions ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.tags ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.task_tags ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.recurrent_task_overwrites ENABLE ROW LEVEL SECURITY;

-- Family policies
CREATE POLICY "Users can view their own families"
  ON public.families FOR SELECT
  USING (
    owner_id = auth.uid() OR
    EXISTS (
      SELECT 1 FROM family_members
      WHERE family_members.family_id = id
      AND family_members.user_id = auth.uid()
    )
  );

CREATE POLICY "Users can create their own families"
  ON public.families FOR INSERT
  WITH CHECK (owner_id = auth.uid());

CREATE POLICY "Family owners can update families"
  ON public.families FOR UPDATE
  USING (owner_id = auth.uid());

CREATE POLICY "Family owners can delete families"
  ON public.families FOR DELETE
  USING (owner_id = auth.uid());

-- Family members policies
CREATE POLICY "Users can view members of their families"
  ON public.family_members FOR SELECT
  USING (
    user_id = auth.uid() OR
    EXISTS (
      SELECT 1 FROM family_members fm
      WHERE fm.family_id = family_id
      AND fm.user_id = auth.uid()
    )
  );

CREATE POLICY "Family owners can manage members"
  ON public.family_members
  USING (
    EXISTS (
      SELECT 1 FROM families
      WHERE families.id = family_id
      AND families.owner_id = auth.uid()
    )
  );

-- Family invites policies
CREATE POLICY "Users can view invites for their families"
  ON public.family_invites FOR SELECT
  USING (
    EXISTS (
      SELECT 1 FROM families
      WHERE families.id = family_id
      AND families.owner_id = auth.uid()
    )
  );

CREATE POLICY "Users can create invites for their families"
  ON public.family_invites FOR INSERT
  WITH CHECK (
    EXISTS (
      SELECT 1 FROM families
      WHERE families.id = family_id
      AND families.owner_id = auth.uid()
    )
  );

-- Reference policies
CREATE POLICY "Users can view references they created"
  ON public.references FOR SELECT
  USING (created_by = auth.uid());

CREATE POLICY "Users can create their own references"
  ON public.references FOR INSERT
  WITH CHECK (created_by = auth.uid());

CREATE POLICY "Users can update their own references"
  ON public.references FOR UPDATE
  USING (created_by = auth.uid());

CREATE POLICY "Users can delete their own references"
  ON public.references FOR DELETE
  USING (created_by = auth.uid());

-- Reference groups policies
CREATE POLICY "Users can view reference groups they created"
  ON public.reference_groups FOR SELECT
  USING (created_by = auth.uid());

CREATE POLICY "Users can create their own reference groups"
  ON public.reference_groups FOR INSERT
  WITH CHECK (created_by = auth.uid());

CREATE POLICY "Users can update their own reference groups"
  ON public.reference_groups FOR UPDATE
  USING (created_by = auth.uid());

CREATE POLICY "Users can delete their own reference groups"
  ON public.reference_groups FOR DELETE
  USING (created_by = auth.uid());

-- Lists policies
CREATE POLICY "Users can view lists for entities they own or are members of"
  ON public.lists FOR SELECT
  USING (
    EXISTS (
      SELECT 1 FROM entities
      WHERE entities.id = entity_id
      AND (
        entities.owner_id = auth.uid() OR
        EXISTS (
          SELECT 1 FROM entity_members
          WHERE entity_members.entity_id = entities.id
          AND entity_members.member_id = auth.uid()
        )
      )
    )
  );

CREATE POLICY "Users can create lists for entities they own"
  ON public.lists FOR INSERT
  WITH CHECK (
    EXISTS (
      SELECT 1 FROM entities
      WHERE entities.id = entity_id
      AND entities.owner_id = auth.uid()
    )
  );

-- List items policies
CREATE POLICY "Users can view list items for lists they can access"
  ON public.list_items FOR SELECT
  USING (
    EXISTS (
      SELECT 1 FROM lists
      JOIN entities ON lists.entity_id = entities.id
      WHERE lists.id = list_id
      AND (
        entities.owner_id = auth.uid() OR
        EXISTS (
          SELECT 1 FROM entity_members
          WHERE entity_members.entity_id = entities.id
          AND entity_members.member_id = auth.uid()
        )
      )
    )
  );

-- Messages policies
CREATE POLICY "Users can view messages in threads they participate in"
  ON public.messages FOR SELECT
  USING (
    EXISTS (
      SELECT 1 FROM thread_participants
      WHERE thread_participants.thread_id = thread_id
      AND thread_participants.user_id = auth.uid()
    )
  );

CREATE POLICY "Users can send messages to threads they participate in"
  ON public.messages FOR INSERT
  WITH CHECK (
    sender_id = auth.uid() AND
    EXISTS (
      SELECT 1 FROM thread_participants
      WHERE thread_participants.thread_id = thread_id
      AND thread_participants.user_id = auth.uid()
    )
  );

-- Thread participants policies
CREATE POLICY "Users can view participants of threads they participate in"
  ON public.thread_participants FOR SELECT
  USING (
    user_id = auth.uid() OR
    EXISTS (
      SELECT 1 FROM thread_participants tp
      WHERE tp.thread_id = thread_id
      AND tp.user_id = auth.uid()
    )
  );

-- Notifications policies
CREATE POLICY "Users can view their own notifications"
  ON public.notifications FOR SELECT
  USING (user_id = auth.uid());

CREATE POLICY "Users can update their own notifications"
  ON public.notifications FOR UPDATE
  USING (user_id = auth.uid());

-- Push tokens policies
CREATE POLICY "Users can manage their own push tokens"
  ON public.push_tokens
  USING (user_id = auth.uid());

-- Routines policies
CREATE POLICY "Users can view routines they own or are members of"
  ON public.routines FOR SELECT
  USING (
    owner_id = auth.uid() OR
    EXISTS (
      SELECT 1 FROM routine_members
      WHERE routine_members.routine_id = id
      AND routine_members.member_id = auth.uid()
    )
  );

CREATE POLICY "Users can create their own routines"
  ON public.routines FOR INSERT
  WITH CHECK (owner_id = auth.uid());

CREATE POLICY "Routine owners can update routines"
  ON public.routines FOR UPDATE
  USING (owner_id = auth.uid());

CREATE POLICY "Routine owners can delete routines"
  ON public.routines FOR DELETE
  USING (owner_id = auth.uid());

-- Timeblocks policies
CREATE POLICY "Users can view timeblocks for routines they can access"
  ON public.timeblocks FOR SELECT
  USING (
    EXISTS (
      SELECT 1 FROM routines
      WHERE routines.id = routine_id
      AND (
        routines.owner_id = auth.uid() OR
        EXISTS (
          SELECT 1 FROM routine_members
          WHERE routine_members.routine_id = routines.id
          AND routine_members.member_id = auth.uid()
        )
      )
    )
  );

-- Task actions policies
CREATE POLICY "Users can view task actions for tasks they are members of"
  ON public.task_actions FOR SELECT
  USING (
    EXISTS (
      SELECT 1 FROM task_members
      WHERE task_members.task_id = task_id
      AND task_members.member_id = auth.uid()
    )
  );

CREATE POLICY "Task owners can manage task actions"
  ON public.task_actions
  USING (
    EXISTS (
      SELECT 1 FROM task_members
      WHERE task_members.task_id = task_id
      AND task_members.member_id = auth.uid()
      AND task_members.is_owner = true
    )
  );

-- Tags policies (public read)
CREATE POLICY "Tags are readable by all users"
  ON public.tags FOR SELECT
  USING (true);

-- Task tags policies
CREATE POLICY "Users can view task tags for tasks they are members of"
  ON public.task_tags FOR SELECT
  USING (
    EXISTS (
      SELECT 1 FROM task_members
      WHERE task_members.task_id = task_id
      AND task_members.member_id = auth.uid()
    )
  );

CREATE POLICY "Task owners can manage task tags"
  ON public.task_tags
  USING (
    EXISTS (
      SELECT 1 FROM task_members
      WHERE task_members.task_id = task_id
      AND task_members.member_id = auth.uid()
      AND task_members.is_owner = true
    )
  );

-- Recurrent task overwrites policies
CREATE POLICY "Users can view task overwrites for tasks they are members of"
  ON public.recurrent_task_overwrites FOR SELECT
  USING (
    EXISTS (
      SELECT 1 FROM task_members
      WHERE task_members.task_id = base_task_id
      AND task_members.member_id = auth.uid()
    )
  );

CREATE POLICY "Task owners can manage task overwrites"
  ON public.recurrent_task_overwrites
  USING (
    EXISTS (
      SELECT 1 FROM task_members
      WHERE task_members.task_id = base_task_id
      AND task_members.member_id = auth.uid()
      AND task_members.is_owner = true
    )
  );

-- =============================================================================
-- ADDITIONAL STORAGE POLICIES
-- =============================================================================
-- List attachments policies
CREATE POLICY "List attachment access"
  ON storage.objects FOR SELECT
  USING (
    bucket_id = 'lists' AND
    EXISTS (
      SELECT 1 FROM lists
      JOIN entities ON lists.entity_id = entities.id
      WHERE lists.id::text = (storage.foldername(name))[1]
      AND (
        entities.owner_id = auth.uid() OR
        EXISTS (
          SELECT 1 FROM entity_members
          WHERE entity_members.entity_id = entities.id
          AND entity_members.member_id = auth.uid()
        )
      )
    )
  );

CREATE POLICY "List owners can upload"
  ON storage.objects FOR INSERT
  WITH CHECK (
    bucket_id = 'lists' AND
    EXISTS (
      SELECT 1 FROM lists
      JOIN entities ON lists.entity_id = entities.id
      WHERE lists.id::text = (storage.foldername(name))[1]
      AND entities.owner_id = auth.uid()
    )
  );

-- Message attachments policies
CREATE POLICY "Message attachment access"
  ON storage.objects FOR SELECT
  USING (
    bucket_id = 'messages' AND
    EXISTS (
      SELECT 1 FROM thread_participants
      WHERE thread_participants.thread_id::text = (storage.foldername(name))[1]
      AND thread_participants.user_id = auth.uid()
    )
  );

CREATE POLICY "Message senders can upload"
  ON storage.objects FOR INSERT
  WITH CHECK (
    bucket_id = 'messages' AND
    EXISTS (
      SELECT 1 FROM thread_participants
      WHERE thread_participants.thread_id::text = (storage.foldername(name))[1]
      AND thread_participants.user_id = auth.uid()
    )
  );

-- =============================================================================
-- ADDITIONAL TRIGGERS
-- =============================================================================
-- Apply updated_at triggers to additional tables
CREATE TRIGGER update_families_updated_at
BEFORE UPDATE ON families
FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_family_invites_updated_at
BEFORE UPDATE ON family_invites
FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_lists_updated_at
BEFORE UPDATE ON lists
FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_list_items_updated_at
BEFORE UPDATE ON list_items
FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_message_threads_updated_at
BEFORE UPDATE ON message_threads
FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_push_tokens_updated_at
BEFORE UPDATE ON push_tokens
FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_routines_updated_at
BEFORE UPDATE ON routines
FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

-- =============================================================================
-- SEED DATA
-- =============================================================================
-- Seed common tags
INSERT INTO public.tags (name) VALUES
  ('Important'),
  ('Urgent'),
  ('Personal'),
  ('Work'),
  ('Family'),
  ('Health'),
  ('Finance'),
  ('Travel'),
  ('Education');
