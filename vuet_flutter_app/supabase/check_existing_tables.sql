-- Check existing tables in the public schema
SELECT 
    table_name,
    table_schema
FROM 
    information_schema.tables
WHERE 
    table_schema = 'public'
ORDER BY 
    table_name;

-- Check existing tables in the storage schema
SELECT 
    table_name,
    table_schema
FROM 
    information_schema.tables
WHERE 
    table_schema = 'storage'
ORDER BY 
    table_name;

-- Check existing columns in the profiles table
SELECT 
    column_name,
    data_type,
    is_nullable,
    column_default
FROM 
    information_schema.columns
WHERE 
    table_schema = 'public' 
    AND table_name = 'profiles'
ORDER BY 
    ordinal_position;

-- Check for existing RLS policies
SELECT
    n.nspname as schema,
    t.relname as table_name,
    p.polname as policy,
    p.polcmd as command,
    p.polpermissive as permissive,
    CASE WHEN p.polroles = '{0}' THEN 'PUBLIC'
         ELSE pg_catalog.array_to_string(
             ARRAY(
                 SELECT rolname
                 FROM pg_catalog.pg_roles
                 WHERE oid = ANY(p.polroles)
                 ORDER BY 1
             ), ', '
         )
    END AS roles,
    pg_catalog.pg_get_expr(p.polqual, p.polrelid) as "qualifier",
    pg_catalog.pg_get_expr(p.polwithcheck, p.polrelid) as "with_check"
FROM
    pg_catalog.pg_policy p
    JOIN pg_catalog.pg_class t ON (t.oid = p.polrelid)
    LEFT JOIN pg_catalog.pg_namespace n ON n.oid = t.relnamespace
WHERE
    n.nspname = 'public'
ORDER BY
    schema, table_name;

-- Check existing indexes
SELECT
    t.relname as table_name,
    i.relname as index_name,
    a.attname as column_name
FROM
    pg_class t,
    pg_class i,
    pg_index ix,
    pg_attribute a
WHERE
    t.oid = ix.indrelid
    AND i.oid = ix.indexrelid
    AND a.attrelid = t.oid
    AND a.attnum = ANY(ix.indkey)
    AND t.relkind = 'r'
    AND t.relnamespace IN (
        SELECT oid FROM pg_namespace WHERE nspname = 'public'
    )
ORDER BY
    t.relname,
    i.relname;

-- Check existing storage buckets
SELECT * FROM storage.buckets;

-- Check existing Supabase auth config
SELECT * FROM auth.config;
