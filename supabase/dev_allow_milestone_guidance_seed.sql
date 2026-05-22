-- ============================================================
-- DEV ONLY: allow the Flutter debug seed screen to upsert
-- milestone guidance rows with a normal authenticated session.
--
-- Use this only while seeding/editing content from the app.
-- Remove these policies before production if content should only
-- be changed from the Supabase dashboard or a service-role backend.
-- ============================================================

alter table public.milestone_guidance enable row level security;

drop policy if exists "Dev authenticated insert milestone guidance"
  on public.milestone_guidance;
drop policy if exists "Dev authenticated update milestone guidance"
  on public.milestone_guidance;

create policy "Dev authenticated insert milestone guidance"
  on public.milestone_guidance
  for insert
  to authenticated
  with check (true);

create policy "Dev authenticated update milestone guidance"
  on public.milestone_guidance
  for update
  to authenticated
  using (true)
  with check (true);
