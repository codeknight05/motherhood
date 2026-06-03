-- ============================================================
-- MotherHood — Supabase Database Schema
-- Run this in: Supabase Dashboard → SQL Editor → New Query
-- ============================================================

-- Enable UUID extension
create extension if not exists "uuid-ossp";

-- ── Profiles ──────────────────────────────────────────────────────────────────
-- One row per auth user. Created automatically on sign-up via trigger.

create table if not exists public.profiles (
  id          uuid primary key references auth.users(id) on delete cascade,
  full_name   text,
  avatar_url  text,
  phone       text,
  created_at  timestamptz default now(),
  updated_at  timestamptz default now()
);

alter table public.profiles enable row level security;

create policy "Users can view own profile"
  on public.profiles for select
  using (auth.uid() = id);

create policy "Users can update own profile"
  on public.profiles for update
  using (auth.uid() = id);

create policy "Users can insert own profile"
  on public.profiles for insert
  with check (auth.uid() = id);

create policy "Users can delete own profile"
  on public.profiles for delete
  using (auth.uid() = id);

-- Auto-create profile on sign-up
create or replace function public.handle_new_user()
returns trigger language plpgsql security definer set search_path = public as $$
begin
  insert into public.profiles (id, full_name, avatar_url)
  values (
    new.id,
    new.raw_user_meta_data->>'full_name',
    new.raw_user_meta_data->>'avatar_url'
  );
  return new;
end;
$$;

drop trigger if exists on_auth_user_created on auth.users;
create trigger on_auth_user_created
  after insert on auth.users
  for each row execute procedure public.handle_new_user();

-- ── Babies ────────────────────────────────────────────────────────────────────

create table if not exists public.babies (
  id          uuid primary key default uuid_generate_v4(),
  user_id     uuid not null references public.profiles(id) on delete cascade,
  name        text not null,
  birth_date  date not null,
  gender      text default 'girl' check (gender in ('girl', 'boy', 'other')),
  height_cm   numeric(5,1),
  weight_kg   numeric(5,2),
  photo_url   text,
  created_at  timestamptz default now(),
  updated_at  timestamptz default now()
);

alter table public.babies enable row level security;

create policy "Users can manage own babies"
  on public.babies for all
  using (auth.uid() = user_id)
  with check (auth.uid() = user_id);

-- ── Milestones ────────────────────────────────────────────────────────────────

create table if not exists public.milestones (
  id           uuid primary key default uuid_generate_v4(),
  baby_id      uuid not null references public.babies(id) on delete cascade,
  category     text not null,
  title        text not null,
  status       text default 'not_started' check (status in ('achieved', 'in_progress', 'not_started')),
  achieved_at  date,
  notes        text,
  created_at   timestamptz default now()
);

alter table public.milestones enable row level security;

create policy "Users can manage milestones for own babies"
  on public.milestones for all
  using (
    exists (
      select 1 from public.babies
      where babies.id = milestones.baby_id
        and babies.user_id = auth.uid()
    )
  )
  with check (
    exists (
      select 1 from public.babies
      where babies.id = milestones.baby_id
        and babies.user_id = auth.uid()
    )
  );

-- ── Memories ──────────────────────────────────────────────────────────────────

create table if not exists public.memories (
  id          uuid primary key default uuid_generate_v4(),
  baby_id     uuid not null references public.babies(id) on delete cascade,
  user_id     uuid not null references public.profiles(id) on delete cascade,
  image_url   text,
  caption     text,
  tag         text default 'everyday',
  age_months  integer,
  memory_date date default current_date,
  created_at  timestamptz default now()
);

alter table public.memories enable row level security;

create policy "Users can manage own memories"
  on public.memories for all
  using (auth.uid() = user_id)
  with check (auth.uid() = user_id);

-- ── Vaccinations ──────────────────────────────────────────────────────────────

create table if not exists public.vaccinations (
  id            uuid primary key default uuid_generate_v4(),
  baby_id       uuid not null references public.babies(id) on delete cascade,
  vaccine_name  text not null,
  due_date      date,
  given_date    date,
  notes         text,
  created_at    timestamptz default now()
);

alter table public.vaccinations enable row level security;

create policy "Users can manage vaccinations for own babies"
  on public.vaccinations for all
  using (
    exists (
      select 1 from public.babies
      where babies.id = vaccinations.baby_id
        and babies.user_id = auth.uid()
    )
  )
  with check (
    exists (
      select 1 from public.babies
      where babies.id = vaccinations.baby_id
        and babies.user_id = auth.uid()
    )
  );

-- ── Storage Buckets ───────────────────────────────────────────────────────────
-- Run these separately in the Supabase Storage UI or via API:
--
-- 1. Create bucket "memories"  — public: true
-- 2. Create bucket "babies"    — public: true  (for avatars)
--
-- Or run:
-- insert into storage.buckets (id, name, public) values ('memories', 'memories', true);
-- insert into storage.buckets (id, name, public) values ('babies', 'babies', true);

insert into storage.buckets (id, name, public)
values ('memories', 'memories', true)
on conflict (id) do nothing;

insert into storage.buckets (id, name, public)
values ('babies', 'babies', true)
on conflict (id) do nothing;

-- Storage policies
create policy "Authenticated users can upload memories"
  on storage.objects for insert
  to authenticated
  with check (bucket_id = 'memories');

create policy "Anyone can view memories"
  on storage.objects for select
  using (bucket_id = 'memories');

create policy "Users can delete own memories"
  on storage.objects for delete
  to authenticated
  using (bucket_id = 'memories' and auth.uid()::text = (storage.foldername(name))[1]);

create policy "Authenticated users can upload baby avatars"
  on storage.objects for insert
  to authenticated
  with check (bucket_id = 'babies');

create policy "Anyone can view baby avatars"
  on storage.objects for select
  using (bucket_id = 'babies');
