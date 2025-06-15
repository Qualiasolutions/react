-- VUET MIGRATION: DJANGO TO SUPABASE SCHEMA - PHASE 1 ESSENTIALS
-- Execute this SQL in your Supabase SQL Editor to set up the core database structure

-- Enable necessary extensions
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- =============================================================================
-- PROFILES & USER SETTINGS
-- =============================================================================

-- Create profiles table (extends auth.users)
CREATE TABLE IF NOT EXISTS profiles (
  id UUID PRIMARY KEY REFERENCES auth.users ON DELETE CASCADE,
  full_name TEXT,
  avatar_url TEXT,
  phone_number TEXT,
  created_at TIMESTAMPTZ DEFAULT now(),
  updated_at TIMESTAMPTZ DEFAULT now(),
  last_active_at TIMESTAMPTZ DEFAULT now()
);

-- User settings for task preferences
CREATE TABLE IF NOT EXISTS user_settings (
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
CREATE TABLE IF NOT EXISTS categories (
  id SMALLINT PRIMARY KEY,
  name TEXT NOT NULL UNIQUE,
  readable_name TEXT NOT NULL,
  is_premium BOOLEAN DEFAULT false,
  is_enabled BOOLEAN DEFAULT true
);

-- Professional categories (user-defined) - Essential for Phase 1 as it's a core category type
CREATE TABLE IF NOT EXISTS professional_categories (
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
(7, 'HEALTH_BEAUTY', 'Health & Beauty', true, true),
(8, 'HOME', 'Home', true, true),
(9, 'GARDEN', 'Garden', true, true),
(10, 'FOOD', 'Food', true, true),
(11, 'LAUNDRY', 'Laundry', true, true),
(12, 'FINANCE', 'Finance', true, true),
(13, 'TRANSPORT', 'Transport', true, true)
ON CONFLICT (id) DO NOTHING;

-- =============================================================================
-- STORAGE SETUP
-- =============================================================================

-- Create storage buckets for entities and avatars
INSERT INTO storage.buckets (id, name, public) VALUES 
('entities', 'Entity Images', true),
('avatars', 'User Avatars', true)
ON CONFLICT (id) DO NOTHING;

-- Storage policies for entity images
CREATE POLICY "Entity images are publicly accessible"
  ON storage.objects FOR SELECT
  USING (bucket_id = 'entities');

CREATE POLICY "Authenticated users can upload entity images"
  ON storage.objects FOR INSERT
  WITH CHECK (bucket_id = 'entities' AND auth.role() = 'authenticated');

CREATE POLICY "Users can update their own entity images"
  ON storage.objects FOR UPDATE
  USING (bucket_id = 'entities' AND auth.uid() = owner);

CREATE POLICY "Users can delete their own entity images"
  ON storage.objects FOR DELETE
  USING (bucket_id = 'entities' AND auth.uid() = owner);

-- Storage policies for avatars
CREATE POLICY "Avatars are publicly accessible"
  ON storage.objects FOR SELECT
  USING (bucket_id = 'avatars');

CREATE POLICY "Authenticated users can upload avatars"
  ON storage.objects FOR INSERT
  WITH CHECK (bucket_id = 'avatars' AND auth.role() = 'authenticated');

CREATE POLICY "Users can update their own avatars"
  ON storage.objects FOR UPDATE
  USING (bucket_id = 'avatars' AND auth.uid() = owner);

CREATE POLICY "Users can delete their own avatars"
  ON storage.objects FOR DELETE
  USING (bucket_id = 'avatars' AND auth.uid() = owner);

-- =============================================================================
-- REALTIME SETUP (for profiles and categories)
-- =============================================================================

-- Enable realtime for key tables
ALTER PUBLICATION supabase_realtime ADD TABLE profiles;
ALTER PUBLICATION supabase_realtime ADD TABLE categories;
ALTER PUBLICATION supabase_realtime ADD TABLE professional_categories;

-- =============================================================================
-- SETUP COMPLETION TRACKING
-- =============================================================================

-- Track setup completion for different features
CREATE TABLE IF NOT EXISTS references_setup_completion (
  id UUID PRIMARY KEY REFERENCES auth.users ON DELETE CASCADE,
  completed BOOLEAN DEFAULT false,
  completed_at TIMESTAMPTZ DEFAULT now()
);

CREATE TABLE IF NOT EXISTS tag_setup_completion (
  id UUID PRIMARY KEY REFERENCES auth.users ON DELETE CASCADE,
  completed BOOLEAN DEFAULT false,
  completed_at TIMESTAMPTZ DEFAULT now()
);

CREATE TABLE IF NOT EXISTS entity_type_setup_completion (
  id UUID REFERENCES auth.users ON DELETE CASCADE,
  entity_type TEXT NOT NULL,
  completed BOOLEAN DEFAULT false,
  completed_at TIMESTAMPTZ DEFAULT now(),
  PRIMARY KEY (id, entity_type)
);

-- RLS for setup completion tables
ALTER TABLE references_setup_completion ENABLE ROW LEVEL SECURITY;
CREATE POLICY "Users can view own setup completion" 
  ON references_setup_completion FOR SELECT USING (auth.uid() = id);
CREATE POLICY "Users can update own setup completion" 
  ON references_setup_completion FOR UPDATE USING (auth.uid() = id);
CREATE POLICY "Users can insert own setup completion" 
  ON references_setup_completion FOR INSERT WITH CHECK (auth.uid() = id);

ALTER TABLE tag_setup_completion ENABLE ROW LEVEL SECURITY;
CREATE POLICY "Users can view own tag setup completion" 
  ON tag_setup_completion FOR SELECT USING (auth.uid() = id);
CREATE POLICY "Users can update own tag setup completion" 
  ON tag_setup_completion FOR UPDATE USING (auth.uid() = id);
CREATE POLICY "Users can insert own tag setup completion" 
  ON tag_setup_completion FOR INSERT WITH CHECK (auth.uid() = id);

ALTER TABLE entity_type_setup_completion ENABLE ROW LEVEL SECURITY;
CREATE POLICY "Users can view own entity type setup completion" 
  ON entity_type_setup_completion FOR SELECT USING (auth.uid() = id);
CREATE POLICY "Users can update own entity type setup completion" 
  ON entity_type_setup_completion FOR UPDATE USING (auth.uid() = id);
CREATE POLICY "Users can insert own entity type setup completion" 
  ON entity_type_setup_completion FOR INSERT WITH CHECK (auth.uid() = id);

-- =============================================================================
-- ERROR LOGGING
-- =============================================================================

-- Error logging table for tracking client-side errors
CREATE TABLE IF NOT EXISTS error_logs (
  id BIGSERIAL PRIMARY KEY,
  user_id UUID REFERENCES auth.users ON DELETE SET NULL,
  message TEXT NOT NULL,
  error TEXT NOT NULL,
  created_at TIMESTAMPTZ DEFAULT now(),
  app_version TEXT,
  platform TEXT
);

-- RLS for error logs
ALTER TABLE error_logs ENABLE ROW LEVEL SECURITY;
CREATE POLICY "Users can insert error logs" 
  ON error_logs FOR INSERT WITH CHECK (true);
CREATE POLICY "Users can view own error logs" 
  ON error_logs FOR SELECT USING (auth.uid() = user_id OR auth.uid() IS NULL);
