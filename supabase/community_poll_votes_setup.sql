-- Community poll votes migration.
-- One selectable poll option per user per poll post.

create table if not exists public.community_poll_votes (
  id           uuid primary key default gen_random_uuid(),
  post_id      uuid not null references public.community_posts(id) on delete cascade,
  user_id      uuid not null references auth.users(id) on delete cascade,
  option_index integer not null check (option_index >= 0),
  created_at   timestamptz default now(),
  updated_at   timestamptz default now(),
  unique(post_id, user_id)
);

create index if not exists idx_community_poll_votes_post
  on public.community_poll_votes(post_id);

alter table public.community_poll_votes enable row level security;

drop policy if exists "poll_votes_read" on public.community_poll_votes;
drop policy if exists "poll_votes_insert" on public.community_poll_votes;
drop policy if exists "poll_votes_update" on public.community_poll_votes;
drop policy if exists "poll_votes_delete" on public.community_poll_votes;

create policy "poll_votes_read"
  on public.community_poll_votes for select
  using (true);

create policy "poll_votes_insert"
  on public.community_poll_votes for insert
  with check (auth.uid() = user_id);

create policy "poll_votes_update"
  on public.community_poll_votes for update
  using (auth.uid() = user_id)
  with check (auth.uid() = user_id);

create policy "poll_votes_delete"
  on public.community_poll_votes for delete
  using (auth.uid() = user_id);
