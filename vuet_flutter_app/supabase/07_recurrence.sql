-- 07_recurrence.sql
-- Task recurrence tables and a simple view for recurring tasks.
-- Essential for calendar functionality and recurring events.

-- =============================================================================
-- RECURRENCES
-- =============================================================================
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

-- Apply updated_at trigger
CREATE TRIGGER update_recurrences_updated_at
BEFORE UPDATE ON recurrences
FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

-- =============================================================================
-- TASK REMINDERS
-- =============================================================================
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
-- This view generates all occurrences for recurring tasks within a certain range.
CREATE MATERIALIZED VIEW scheduled_tasks AS
WITH recurring_task_occurrences AS (
  SELECT
    t.id AS task_id,
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
    ) AS occurrence_date
  FROM public.tasks t
  JOIN public.recurrences r ON t.id = r.task_id
  WHERE COALESCE(t.start_datetime, t.start_date::timestamp, t.due_date::timestamp) IS NOT NULL
)
SELECT
  rto.task_id AS id,
  rto.title,
  rto.type,
  rto.hidden_tag,
  rto.notes,
  rto.location,
  rto.contact_name,
  rto.contact_email,
  rto.contact_phone,
  rto.duration,
  rto.start_datetime,
  rto.end_datetime,
  rto.start_date,
  rto.end_date,
  rto.created_at,
  rto.updated_at,
  rto.recurrence_id,
  rto.recurrence,
  rto.interval_length,
  rto.occurrence_date,
  -- Calculate recurrence index using row_number() on the CTE result
  (row_number() OVER (PARTITION BY rto.task_id ORDER BY rto.occurrence_date) - 1)::integer AS recurrence_index
FROM recurring_task_occurrences rto
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
FROM public.tasks t
LEFT JOIN public.recurrences r ON t.id = r.task_id
WHERE r.id IS NULL; -- Select only non-recurring tasks

-- =============================================================================
-- TRIGGERS FOR SCHEDULED TASKS VIEW
-- =============================================================================
-- Function to refresh scheduled_tasks materialized view
CREATE OR REPLACE FUNCTION refresh_scheduled_tasks_view()
RETURNS TRIGGER AS $$
BEGIN
  REFRESH MATERIALIZED VIEW scheduled_tasks;
  RETURN NULL;
END;
$$ LANGUAGE plpgsql;

-- Trigger to refresh scheduled_tasks when tasks or recurrences change
CREATE TRIGGER refresh_scheduled_tasks_on_task_change
AFTER INSERT OR UPDATE OR DELETE ON public.tasks
FOR EACH STATEMENT EXECUTE FUNCTION refresh_scheduled_tasks_view();

CREATE TRIGGER refresh_scheduled_tasks_on_recurrence_change
AFTER INSERT OR UPDATE OR DELETE ON public.recurrences
FOR EACH STATEMENT EXECUTE FUNCTION refresh_scheduled_tasks_view();

-- =============================================================================
-- RLS POLICIES
-- =============================================================================
ALTER TABLE public.recurrences ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.task_reminders ENABLE ROW LEVEL SECURITY;

-- Recurrences policies
CREATE POLICY "Users can view recurrences for their tasks"
  ON public.recurrences FOR SELECT
  USING (
    EXISTS (
      SELECT 1 FROM public.task_members
      WHERE task_members.task_id = task_id
      AND task_members.member_id = auth.uid()
    )
  );

CREATE POLICY "Users can manage recurrences for their tasks"
  ON public.recurrences FOR ALL
  USING (
    EXISTS (
      SELECT 1 FROM public.task_members
      WHERE task_members.task_id = task_id
      AND task_members.member_id = auth.uid()
      AND task_members.is_owner = true
    )
  );

-- Task reminders policies
CREATE POLICY "Users can view reminders for their tasks"
  ON public.task_reminders FOR SELECT
  USING (
    EXISTS (
      SELECT 1 FROM public.task_members
      WHERE task_members.task_id = task_id
      AND task_members.member_id = auth.uid()
    )
  );

CREATE POLICY "Users can manage reminders for their tasks"
  ON public.task_reminders FOR ALL
  USING (
    EXISTS (
      SELECT 1 FROM public.task_members
      WHERE task_members.task_id = task_id
      AND task_members.member_id = auth.uid()
      AND task_members.is_owner = true
    )
  );

-- Scheduled tasks view policies (read-only)

-- =============================================================================
-- INDEXES
-- =============================================================================
CREATE INDEX recurrences_task_idx ON public.recurrences(task_id);
CREATE INDEX task_reminders_task_idx ON public.task_reminders(task_id);
