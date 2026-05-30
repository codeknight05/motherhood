-- ═══════════════════════════════════════════════════════════════════════════
-- Community tables — run once in Supabase SQL Editor
-- ═══════════════════════════════════════════════════════════════════════════

-- 1. Communities (fixed 5 — no user creation)
create table if not exists public.communities (
  id          text primary key,
  name        text not null,
  description text not null,
  emoji       text not null,
  color_hex   text not null default '#7C4DFF',
  category    text not null,
  tags        text[] not null default '{}',
  created_at  timestamptz default now()
);

-- 2. Community members (join/leave)
create table if not exists public.community_members (
  id           uuid primary key default gen_random_uuid(),
  community_id text not null references public.communities(id) on delete cascade,
  user_id      uuid not null references auth.users(id) on delete cascade,
  joined_at    timestamptz default now(),
  unique(community_id, user_id)
);

-- 3. Community posts
create table if not exists public.community_posts (
  id           uuid primary key default gen_random_uuid(),
  community_id text not null references public.communities(id) on delete cascade,
  user_id      uuid not null references auth.users(id) on delete cascade,
  content      text not null,
  tag          text,           -- 'Question', 'Win & Milestone', 'Rant & Rave', 'Resource', 'General'
  image_url    text,
  is_pinned    boolean default false,
  created_at   timestamptz default now()
);

alter table public.community_posts
  add column if not exists image_url text;

-- 4. Post likes
create table if not exists public.post_likes (
  id      uuid primary key default gen_random_uuid(),
  post_id uuid not null references public.community_posts(id) on delete cascade,
  user_id uuid not null references auth.users(id) on delete cascade,
  unique(post_id, user_id)
);

-- 5. Replies to community posts
create table if not exists public.community_post_replies (
  id         uuid primary key default gen_random_uuid(),
  post_id    uuid not null references public.community_posts(id) on delete cascade,
  user_id    uuid not null references auth.users(id) on delete cascade,
  content    text not null,
  created_at timestamptz default now()
);

-- ── Indexes ───────────────────────────────────────────────────────────────────
create index if not exists idx_community_posts_community on public.community_posts(community_id, created_at desc);
create index if not exists idx_community_members_user on public.community_members(user_id);
create index if not exists idx_post_likes_post on public.post_likes(post_id);
create index if not exists idx_community_post_replies_post on public.community_post_replies(post_id, created_at asc);

-- ── RLS Policies ──────────────────────────────────────────────────────────────
alter table public.communities enable row level security;
alter table public.community_members enable row level security;
alter table public.community_posts enable row level security;
alter table public.post_likes enable row level security;
alter table public.community_post_replies enable row level security;

-- Communities: anyone can read
create policy "communities_read" on public.communities for select using (true);

-- Members: users can read all, insert/delete their own
create policy "members_read" on public.community_members for select using (true);
create policy "members_insert" on public.community_members for insert with check (auth.uid() = user_id);
create policy "members_delete" on public.community_members for delete using (auth.uid() = user_id);

-- Posts: anyone can read, authenticated users can insert, authors can delete
create policy "posts_read" on public.community_posts for select using (true);
create policy "posts_insert" on public.community_posts for insert with check (auth.uid() = user_id);
create policy "posts_delete" on public.community_posts for delete using (auth.uid() = user_id);

-- Replies: anyone can read, authenticated users can insert/delete their own
create policy "replies_read" on public.community_post_replies for select using (true);
create policy "replies_insert" on public.community_post_replies for insert with check (auth.uid() = user_id);
create policy "replies_delete" on public.community_post_replies for delete using (auth.uid() = user_id);

-- Likes: anyone can read, authenticated users can insert/delete their own
create policy "likes_read" on public.post_likes for select using (true);
create policy "likes_insert" on public.post_likes for insert with check (auth.uid() = user_id);
create policy "likes_delete" on public.post_likes for delete using (auth.uid() = user_id);

-- ── Seed the 5 fixed communities ──────────────────────────────────────────────
insert into public.communities (id, name, description, emoji, color_hex, category, tags) values
  ('expecting_moms',
   'Expecting Moms',
   'A warm, supportive space for moms-to-be. Share your pregnancy journey, ask questions, and connect with others due around the same time.',
   '🤰', '#7C4DFF', 'Pregnancy', array['Pregnancy','Due Date','Support']),

  ('first_time_moms',
   'First-Time Moms',
   'Everything is new and that''s okay! A judgement-free zone for first-time moms to ask anything, share wins, and survive together.',
   '🌸', '#FF80AB', 'Parenting', array['First-Time','Newborn','Support']),

  ('feeding_nutrition',
   'Feeding & Nutrition',
   'Breastfeeding, formula, solids, and everything in between. Get advice, share recipes, and support each other through feeding challenges.',
   '🍼', '#00C853', 'Health', array['Breastfeeding','Solids','Nutrition']),

  ('sleep_routine',
   'Sleep & Routine',
   'Sleep training, nap schedules, bedtime routines — and the 3am solidarity you didn''t know you needed. We''ve all been there.',
   '😴', '#5C6BC0', 'Wellness', array['Sleep','Routine','Newborn']),

  ('working_moms_wellness',
   'Working Moms & Wellness',
   'Balancing career, motherhood, and your own wellbeing. Share strategies, vent freely, and celebrate every small win.',
   '💼', '#FF6D00', 'Lifestyle', array['Career','Wellness','Balance'])

on conflict (id) do nothing;
