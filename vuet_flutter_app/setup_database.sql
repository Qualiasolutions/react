-- VUET MIGRATION: DJANGO TO SUPABASE SCHEMA - PHASE 1 ESSENTIALS
-- This script sets up the core tables required for authentication and basic categories.

-- Enable necessary extensions
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";
-- CREATE EXTENSION IF NOT EXISTS "pg_trgm"; -- Not essential for Phase 1
-- CREATE EXTENSION IF NOT EXISTS "ltree";   -- Not essential for Phase 1

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

-- Professional categories (user-defined) - Essential for Phase 1 as it's a core category type
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
-- REALTIME SETUP (for profiles and categories if needed for initial sync)
-- =============================================================================

-- Enable realtime for key tables (optional for Phase 1, but good to include for future)
ALTER PUBLICATION supabase_realtime ADD TABLE profiles;
ALTER PUBLICATION supabase_realtime ADD TABLE categories;
ALTER PUBLICATION supabase_realtime ADD TABLE professional_categories;
