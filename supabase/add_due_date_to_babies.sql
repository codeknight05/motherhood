-- Add due_date to babies table for pregnant users
alter table public.babies
  add column if not exists due_date date;

-- Make birth_date nullable (pregnant users don't have it yet)
alter table public.babies
  alter column birth_date drop not null;
