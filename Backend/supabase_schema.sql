-- Smart Day Planner Supabase Schema
-- This schema supports Google/Supabase-authenticated users, task storage,
-- calendar blocks, and generated schedules.

create extension if not exists "pgcrypto";

-- Profiles
-- One profile per authenticated user.
create table if not exists public.profiles (
    id uuid primary key references auth.users(id) on delete cascade,
    email text not null,
    full_name text,
    avatar_url text,
    created_at timestamptz not null default now()
);

alter table public.profiles enable row level security;

create policy "Users can view their own profile"
on public.profiles
for select
using (auth.uid() = id);

create policy "Users can insert their own profile"
on public.profiles
for insert
with check (auth.uid() = id);

create policy "Users can update their own profile"
on public.profiles
for update
using (auth.uid() = id)
with check (auth.uid() = id);


-- Tasks
-- User-created tasks that need to be scheduled.
create table if not exists public.tasks (
    id uuid primary key default gen_random_uuid(),
    user_id uuid not null references public.profiles(id) on delete cascade,
    title text not null,
    duration_minutes integer not null check (duration_minutes > 0),
    priority integer not null check (priority between 1 and 5),
    deadline timestamptz not null,
    energy_level integer not null check (energy_level between 1 and 5),
    category text not null,
    is_completed boolean not null default false,
    created_at timestamptz not null default now()
);

alter table public.tasks enable row level security;

create policy "Users can view their own tasks"
on public.tasks
for select
using (auth.uid() = user_id);

create policy "Users can insert their own tasks"
on public.tasks
for insert
with check (auth.uid() = user_id);

create policy "Users can update their own tasks"
on public.tasks
for update
using (auth.uid() = user_id)
with check (auth.uid() = user_id);

create policy "Users can delete their own tasks"
on public.tasks
for delete
using (auth.uid() = user_id);


-- Calendar Events
-- Fixed blocks the scheduler should not schedule over.
-- These can be manually added or imported from Google Calendar later.
create table if not exists public.calendar_events (
    id uuid primary key default gen_random_uuid(),
    user_id uuid not null references public.profiles(id) on delete cascade,
    title text not null,
    start_date timestamptz not null,
    end_date timestamptz not null,
    source text not null default 'manual',
    external_event_id text,
    created_at timestamptz not null default now(),
    constraint calendar_event_valid_time check (end_date > start_date)
);

alter table public.calendar_events enable row level security;

create policy "Users can view their own calendar events"
on public.calendar_events
for select
using (auth.uid() = user_id);

create policy "Users can insert their own calendar events"
on public.calendar_events
for insert
with check (auth.uid() = user_id);

create policy "Users can update their own calendar events"
on public.calendar_events
for update
using (auth.uid() = user_id)
with check (auth.uid() = user_id);

create policy "Users can delete their own calendar events"
on public.calendar_events
for delete
using (auth.uid() = user_id);


-- Scheduled Tasks
-- Generated output from the planner.
create table if not exists public.scheduled_tasks (
    id uuid primary key default gen_random_uuid(),
    user_id uuid not null references public.profiles(id) on delete cascade,
    task_id uuid not null references public.tasks(id) on delete cascade,
    start_date timestamptz not null,
    end_date timestamptz not null,
    score double precision not null check (score >= 0 and score <= 1),
    explanation text not null,
    created_at timestamptz not null default now(),
    constraint scheduled_task_valid_time check (end_date > start_date)
);

alter table public.scheduled_tasks enable row level security;

create policy "Users can view their own scheduled tasks"
on public.scheduled_tasks
for select
using (auth.uid() = user_id);

create policy "Users can insert their own scheduled tasks"
on public.scheduled_tasks
for insert
with check (auth.uid() = user_id);

create policy "Users can update their own scheduled tasks"
on public.scheduled_tasks
for update
using (auth.uid() = user_id)
with check (auth.uid() = user_id);

create policy "Users can delete their own scheduled tasks"
on public.scheduled_tasks
for delete
using (auth.uid() = user_id);


-- Helpful indexes
create index if not exists tasks_user_id_idx on public.tasks(user_id);
create index if not exists tasks_deadline_idx on public.tasks(deadline);

create index if not exists calendar_events_user_id_idx on public.calendar_events(user_id);
create index if not exists calendar_events_start_date_idx on public.calendar_events(start_date);

create index if not exists scheduled_tasks_user_id_idx on public.scheduled_tasks(user_id);
create index if not exists scheduled_tasks_start_date_idx on public.scheduled_tasks(start_date);