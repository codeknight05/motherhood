-- ============================================================
-- Add audience support to milestone guidance content.
--
-- Existing rows are baby/child milestone content, so they are
-- marked as audience = 'parent'. Future content can use:
--   parent, pregnant, family
-- ============================================================

alter table public.milestone_guidance
  add column if not exists audience text not null default 'parent'
  check (audience in ('parent', 'pregnant', 'family'));

alter table public.milestone_guidance
  drop constraint if exists milestone_guidance_unique;

alter table public.milestone_guidance
  add constraint milestone_guidance_unique
  unique (audience, band_index, category);
