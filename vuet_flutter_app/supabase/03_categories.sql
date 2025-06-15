-- 03_categories.sql
-- Categories tables (core and professional) with data seeding and RLS policies

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

-- Apply updated_at trigger
CREATE TRIGGER update_professional_categories_updated_at
BEFORE UPDATE ON professional_categories
FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

-- =============================================================================
-- RLS POLICIES FOR CATEGORIES
-- =============================================================================
ALTER TABLE public.categories ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.professional_categories ENABLE ROW LEVEL SECURITY;

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
