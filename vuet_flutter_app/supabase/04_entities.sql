-- 04_entities.sql
-- Entities tables and related membership/mapping tables with RLS policies

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

-- Apply updated_at trigger
CREATE TRIGGER update_entities_updated_at
BEFORE UPDATE ON entities
FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

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
-- RLS POLICIES FOR ENTITIES
-- =============================================================================
ALTER TABLE public.entities ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.entity_members ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.professional_entity_category_mapping ENABLE ROW LEVEL SECURITY;

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

-- Professional entity category mapping policies
CREATE POLICY "Users can view their own professional entity mappings"
  ON public.professional_entity_category_mapping FOR SELECT
  USING (auth.uid() = user_id);

CREATE POLICY "Users can create their own professional entity mappings"
  ON public.professional_entity_category_mapping FOR INSERT
  WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can update their own professional entity mappings"
  ON public.professional_entity_category_mapping FOR UPDATE
  USING (auth.uid() = user_id);

CREATE POLICY "Users can delete their own professional entity mappings"
  ON public.professional_entity_category_mapping FOR DELETE
  USING (auth.uid() = user_id);

-- =============================================================================
-- INDEXES FOR ENTITIES
-- =============================================================================
CREATE INDEX entities_owner_idx ON entities(owner_id);
CREATE INDEX entities_category_idx ON entities(category_id);
CREATE INDEX entities_type_idx ON entities(type);
CREATE INDEX entities_parent_idx ON entities(parent_id);
