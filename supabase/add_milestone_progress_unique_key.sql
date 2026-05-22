-- ============================================================
-- Persist milestone progress by stable content identity.
--
-- The app's local milestone ids are content ids like "w1_gm1",
-- while public.milestones.id is a UUID. Progress must therefore
-- upsert by baby + category + title.
-- ============================================================

alter table public.milestones
  add constraint milestones_baby_category_title_unique
  unique (baby_id, category, title);
