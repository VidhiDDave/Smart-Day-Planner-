# Supabase Setup

This project uses Supabase as the backend database for user profiles, tasks, calendar blocks, and generated schedules.

## Current Status

The iOS app currently uses local in-memory planner data.

Supabase integration is planned in future PRs.

## Tables

The schema defines four main tables:

### profiles

Stores one row per signed-in user.

Fields:

- id
- email
- full_name
- avatar_url
- created_at

### tasks

Stores tasks created by the user.

Fields:

- id
- user_id
- title
- duration_minutes
- priority
- deadline
- energy_level
- category
- is_completed
- created_at

### calendar_events

Stores fixed calendar blocks that the scheduler cannot overlap.

Fields:

- id
- user_id
- title
- start_date
- end_date
- source
- external_event_id
- created_at

The `source` field can be:

- manual
- google_calendar

### scheduled_tasks

Stores the generated optimized schedule.

Fields:

- id
- user_id
- task_id
- start_date
- end_date
- score
- explanation
- created_at

## Row Level Security

Row Level Security is enabled on all tables.

Each user can only view, insert, update, and delete their own data.

The policies use:

```sql
auth.uid() = user_id
