-- Community post replies migration.
-- Run this in Supabase SQL Editor if community_setup.sql was already applied.

alter table public.community_posts
  add column if not exists image_url text;

create table if not exists public.community_post_replies (
  id         uuid primary key default gen_random_uuid(),
  post_id    uuid not null references public.community_posts(id) on delete cascade,
  user_id    uuid not null references auth.users(id) on delete cascade,
  content    text not null,
  created_at timestamptz default now()
);

create index if not exists idx_community_post_replies_post
  on public.community_post_replies(post_id, created_at asc);

alter table public.community_post_replies enable row level security;

drop policy if exists "replies_read" on public.community_post_replies;
drop policy if exists "replies_insert" on public.community_post_replies;
drop policy if exists "replies_delete" on public.community_post_replies;

create policy "replies_read"
  on public.community_post_replies for select
  using (true);

create policy "replies_insert"
  on public.community_post_replies for insert
  with check (auth.uid() = user_id);

create policy "replies_delete"
  on public.community_post_replies for delete
  using (auth.uid() = user_id);
