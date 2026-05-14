-- ============================================================
-- Milestone seed data + auto-populate function
-- Run this in: Supabase Dashboard → SQL Editor → New Query
-- ============================================================

-- Master milestone definitions (age-based templates)
create table if not exists public.milestone_definitions (
  id          uuid primary key default uuid_generate_v4(),
  category    text not null,
  title       text not null,
  description text,
  age_min_months integer not null,  -- earliest age this milestone applies
  age_max_months integer not null,  -- latest age this milestone applies
  sort_order  integer default 0
);

-- Disable RLS on definitions (read-only reference data, public)
alter table public.milestone_definitions enable row level security;
create policy "Anyone can read milestone definitions"
  on public.milestone_definitions for select using (true);

-- ── Seed milestone definitions ────────────────────────────────────────────────

insert into public.milestone_definitions
  (category, title, description, age_min_months, age_max_months, sort_order)
values
  -- 0–3 Months
  ('gross_motor',       'Lifts head briefly during tummy time',     'Can raise head 45° when on stomach',                    0, 3, 1),
  ('gross_motor',       'Holds head steady when supported',         'Head control improving when held upright',              1, 3, 2),
  ('fine_motor',        'Opens and closes hands',                   'Reflexive grasping becoming intentional',               0, 3, 1),
  ('fine_motor',        'Brings hands to mouth',                    'Hand-mouth coordination developing',                    1, 3, 2),
  ('language',          'Makes cooing sounds',                      'Soft vowel sounds like "ooh" and "aah"',                1, 3, 1),
  ('language',          'Responds to voices',                       'Turns head toward familiar voices',                     1, 3, 2),
  ('social_emotional',  'Social smile',                             'Smiles in response to your smile',                      1, 3, 1),
  ('social_emotional',  'Makes eye contact',                        'Holds eye contact for several seconds',                 0, 3, 2),
  ('cognitive',         'Follows moving objects with eyes',         'Tracks objects moving side to side',                    1, 3, 1),
  ('cognitive',         'Recognises familiar faces',                'Shows preference for parents over strangers',           2, 3, 2),

  -- 4–6 Months
  ('gross_motor',       'Rolls from tummy to back',                 'Can roll over in one direction',                        3, 6, 1),
  ('gross_motor',       'Sits with support',                        'Can sit when propped with pillows',                     4, 6, 2),
  ('gross_motor',       'Bears weight on legs when held standing',  'Pushes down with feet when held upright',               4, 6, 3),
  ('fine_motor',        'Reaches for and grasps objects',           'Intentionally reaches for toys',                        3, 6, 1),
  ('fine_motor',        'Transfers objects between hands',          'Passes toy from one hand to the other',                 5, 6, 2),
  ('language',          'Laughs and squeals',                       'Expresses delight with laughter',                       3, 6, 1),
  ('language',          'Babbles with consonants',                  'Sounds like "ba", "ma", "da"',                          4, 6, 2),
  ('social_emotional',  'Recognises own name',                      'Turns when name is called',                             4, 6, 1),
  ('social_emotional',  'Shows excitement with familiar people',    'Kicks and waves arms when seeing parents',              3, 6, 2),
  ('cognitive',         'Explores objects with mouth',              'Puts everything in mouth to explore',                   3, 6, 1),
  ('cognitive',         'Looks for dropped objects',                'Searches for toy that falls out of sight',              5, 6, 2),

  -- 7–9 Months
  ('gross_motor',       'Sits without support',                     'Sits independently for several minutes',                6, 9, 1),
  ('gross_motor',       'Rolls both ways',                          'Rolls from back to tummy and tummy to back',            6, 9, 2),
  ('gross_motor',       'Starts crawling',                          'Moves forward on hands and knees',                      7, 9, 3),
  ('gross_motor',       'Pulls to stand',                           'Uses furniture to pull up to standing',                 8, 9, 4),
  ('fine_motor',        'Bangs objects together',                   'Claps two objects together deliberately',               6, 9, 1),
  ('fine_motor',        'Pincer grasp developing',                  'Uses thumb and forefinger to pick up small items',      8, 9, 2),
  ('language',          'Responds to "no"',                         'Pauses activity when told no',                          7, 9, 1),
  ('language',          'Says mama/dada (non-specifically)',         'Uses mama/dada sounds without meaning',                 7, 9, 2),
  ('social_emotional',  'Shows stranger anxiety',                   'Cries or clings with unfamiliar people',                6, 9, 1),
  ('social_emotional',  'Plays peek-a-boo',                         'Enjoys and anticipates peek-a-boo game',                7, 9, 2),
  ('cognitive',         'Looks for hidden objects',                 'Searches for toy hidden under cloth',                   7, 9, 1),
  ('cognitive',         'Understands cause and effect',             'Shakes rattle to make noise intentionally',             7, 9, 2),

  -- 10–12 Months
  ('gross_motor',       'Cruises along furniture',                  'Walks sideways holding onto furniture',                 9, 12, 1),
  ('gross_motor',       'Stands alone briefly',                     'Stands without support for a few seconds',              10, 12, 2),
  ('gross_motor',       'Takes first steps',                        'Walks 2–3 steps independently',                         11, 12, 3),
  ('fine_motor',        'Neat pincer grasp',                        'Picks up small objects with precision',                 9, 12, 1),
  ('fine_motor',        'Puts objects in containers',               'Places blocks or toys into a box',                      9, 12, 2),
  ('language',          'Says first word with meaning',             'Uses "mama" or "dada" for the right parent',            10, 12, 1),
  ('language',          'Understands simple instructions',          'Follows "give me" or "come here"',                      10, 12, 2),
  ('social_emotional',  'Waves bye-bye',                            'Waves hand to say goodbye',                             9, 12, 1),
  ('social_emotional',  'Shows affection',                          'Hugs or kisses familiar people',                        10, 12, 2),
  ('cognitive',         'Imitates actions',                         'Copies clapping, waving, or banging',                   9, 12, 1),
  ('cognitive',         'Uses objects correctly',                   'Holds phone to ear, spoon to mouth',                    10, 12, 2),

  -- 13–18 Months
  ('gross_motor',       'Walks independently',                      'Walks well without support',                            12, 18, 1),
  ('gross_motor',       'Climbs onto furniture',                    'Climbs onto low chairs or sofas',                       14, 18, 2),
  ('fine_motor',        'Scribbles with crayon',                    'Makes marks on paper with crayon',                      12, 18, 1),
  ('fine_motor',        'Stacks 2–3 blocks',                        'Builds a small tower of blocks',                        13, 18, 2),
  ('language',          'Says 5–10 words',                          'Uses several words with meaning',                       12, 18, 1),
  ('language',          'Points to body parts',                     'Points to nose, eyes, ears when asked',                 14, 18, 2),
  ('social_emotional',  'Plays alongside other children',           'Parallel play — plays near but not with others',        12, 18, 1),
  ('social_emotional',  'Shows empathy',                            'Comforts others who are upset',                         15, 18, 2),
  ('cognitive',         'Pretend play begins',                      'Pretends to feed doll or talk on phone',                12, 18, 1),
  ('cognitive',         'Sorts shapes and colours',                 'Matches basic shapes in a sorter',                      15, 18, 2),

  -- 19–24 Months
  ('gross_motor',       'Runs steadily',                            'Runs without falling frequently',                       18, 24, 1),
  ('gross_motor',       'Kicks a ball',                             'Kicks ball forward intentionally',                      18, 24, 2),
  ('fine_motor',        'Turns pages of a book',                    'Turns one page at a time',                              18, 24, 1),
  ('fine_motor',        'Stacks 6+ blocks',                         'Builds a tall tower before knocking it down',           20, 24, 2),
  ('language',          'Uses 2-word phrases',                      '"More milk", "daddy go", "big dog"',                    18, 24, 1),
  ('language',          'Has 50+ word vocabulary',                  'Uses many different words daily',                       20, 24, 2),
  ('social_emotional',  'Parallel play evolving to cooperative',    'Begins to play with other children',                    20, 24, 1),
  ('social_emotional',  'Asserts independence',                     'Says "no" and "mine" frequently',                       18, 24, 2),
  ('cognitive',         'Follows 2-step instructions',              '"Pick up the ball and put it in the box"',              18, 24, 1),
  ('cognitive',         'Identifies pictures in books',             'Points to named pictures correctly',                    18, 24, 2);

-- ── Function to auto-populate milestones for a new baby ───────────────────────

create or replace function public.populate_milestones_for_baby(
  p_baby_id uuid,
  p_age_months integer
)
returns void language plpgsql security definer as $$
begin
  insert into public.milestones (baby_id, category, title, status)
  select
    p_baby_id,
    md.category,
    md.title,
    case
      when p_age_months > md.age_max_months then 'achieved'   -- past the window, assume done
      when p_age_months >= md.age_min_months then 'not_started' -- in current window
      else 'not_started'                                        -- future milestone
    end
  from public.milestone_definitions md
  where md.age_min_months <= (p_age_months + 6)  -- load current + next 6 months
  on conflict do nothing;
end;
$$;
