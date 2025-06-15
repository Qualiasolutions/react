-- 06_storage.sql
-- Storage buckets and RLS policies for Vuet Flutter app

-- =============================================================================
-- STORAGE BUCKETS
-- =============================================================================
-- Create storage buckets
INSERT INTO storage.buckets (id, name, public) VALUES
  ('entities', 'Entity images and attachments', true),
  ('profiles', 'Profile avatars', true)
ON CONFLICT (id) DO NOTHING; -- Prevents error if buckets already exist

-- =============================================================================
-- STORAGE RLS POLICIES
-- =============================================================================
-- NOTE:
-- Creating RLS policies on the `storage.objects` table requires elevated
-- privileges (the table is owned by Supabase’s service role).  
-- To avoid `must be owner of table objects` errors, we are **omitting** the
-- policy creation here.  
--
-- After the schema is loaded, create the required policies via the Supabase
-- Dashboard (Storage → Policies) using the GUI, or execute the statements in
-- the SQL editor while connected as the `service_role` user.
--
-- Basic buckets are now ready and you can upload files manually. Policies can
-- be added later without affecting existing data.
