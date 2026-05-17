# MotherHood — Project Context

> **AI-Powered Maternal & Child Wellness Ecosystem**  
> Flutter app supporting mothers and families through pregnancy, baby growth, and early childhood development.

---

## 1. What This App Does

MotherHood is a multiplatform parenting and maternal wellness app targeting three user types:

| Role | What they get |
|------|--------------|
| **Pregnant** | Pregnancy week tracking, due date countdown, nutrition tips |
| **Parent** | Baby milestone tracking, memory diary, AI food recommendations, vaccination schedule |
| **Family member** | Community, learning resources, support content |

Designed specifically for **Indian families** — culturally relevant nutrition, regional food preferences, and traditional health knowledge are first-class concerns.

---

## 2. Tech Stack

| Layer | Technology | Notes |
|-------|-----------|-------|
| Frontend | Flutter 3.x | Android, iOS, Web from one codebase |
| State Management | Riverpod 2.x (`StateNotifier`) | Compile-safe, testable |
| Backend / Auth | Supabase | PostgreSQL + Auth + RLS |
| Image Storage | Cloudinary | 25 GB free, CDN, auto-compression |
| AI | Google Gemini 2.0 Flash | REST v1beta endpoint via `http` package |
| Fonts | Google Fonts — Nunito | Warm, rounded, readable |
| Navigation | `IndexedStack` + `Navigator.push` | Tabs stay alive; GoRouter planned for deep links |

> **Note:** The `google_generative_ai` SDK was intentionally dropped — it uses the deprecated v1beta endpoint. `GeminiService` calls the REST API directly via the `http` package.

---

## 3. Architecture

```
lib/
├── core/
│   ├── constants/        # Spacing, sizing, app name
│   ├── providers/        # Riverpod state (auth, baby, milestones, recipes, AI)
│   ├── services/         # Supabase, Cloudinary, Gemini service layers
│   ├── theme/            # Colors, text styles, app theme
│   └── widgets/          # Shared widgets (AppCard, BabyAvatar, etc.)
├── features/
│   ├── auth/             # Splash, Login screens
│   ├── community/        # Communities list + detail screen + create community
│   ├── food_menu/        # Food Menu, Recipe Detail, Weekly Meal Plan, AI Recipes, Bookmarks
│   ├── home/             # Home dashboard
│   ├── learn/            # Learn / articles screen
│   ├── memories/         # Standalone memory screen (legacy)
│   ├── milestones/       # Baby Journey (Milestones + Memory Diary tabs)
│   ├── onboarding/       # Role-based baby setup
│   ├── profile/          # User profile, edit, sign out
│   └── vaccination/      # Vaccination tracker with Indian schedule
├── models/               # BabyModel, MemoryModel, MilestoneModel, RecipeModel, VaccinationModel
└── main.dart
```

**Pattern:** Feature-first folder structure. Each feature owns its presentation layer. Shared logic lives in `core/`. Models are plain Dart classes with no framework dependency.

---

## 4. Full File Map

```
lib/
├── main.dart
├── core/
│   ├── constants/app_constants.dart
│   ├── providers/
│   │   ├── ai_recipes_provider.dart          # Gemini recipe generation state + retry logic
│   │   ├── auth_provider.dart                # Auth state + Google sign-in
│   │   ├── baby_provider.dart                # Baby CRUD + Supabase sync
│   │   ├── milestones_provider.dart          # Milestone state + Supabase sync
│   │   └── recipe_provider.dart              # Bookmarks + AI recipe store
│   ├── services/
│   │   ├── cloudinary_service.dart           # Photo upload + thumbnail URLs
│   │   ├── gemini_service.dart               # Gemini REST API recipe generation
│   │   ├── secrets.dart                      # API keys (gitignored)
│   │   ├── supabase_config.dart              # Project URL + anon key
│   │   └── supabase_service.dart             # DB + storage helpers
│   ├── theme/
│   │   ├── app_colors.dart                   # Purple/pastel palette + gradients
│   │   ├── app_text_styles.dart
│   │   └── app_theme.dart
│   └── widgets/
│       ├── app_card.dart                     # Card with default border
│       ├── baby_avatar.dart
│       ├── main_shell.dart                   # Bottom nav — Community tab → CommunitiesListScreen
│       └── section_header.dart
├── features/
│   ├── auth/presentation/
│   │   ├── login_screen.dart
│   │   └── splash_screen.dart
│   ├── community/presentation/
│   │   ├── communities_list_screen.dart      # NEW — Community tab landing: list + search + filter
│   │   ├── community_screen.dart             # Detail view — now accepts CommunityInfo param
│   │   └── create_community_screen.dart      # NEW — Create community form with live preview
│   ├── food_menu/
│   │   ├── data/                             # (empty — data layer not yet built)
│   │   └── presentation/
│   │       ├── ai_recipes_screen.dart        # Gemini AI recipe generation UI
│   │       ├── bookmarked_recipes_screen.dart
│   │       ├── food_menu_screen.dart
│   │       ├── recipe_detail_screen.dart     # Works for both sample + AI recipes
│   │       └── weekly_meal_plan_screen.dart
│   ├── home/presentation/home_screen.dart
│   ├── learn/presentation/learn_screen.dart
│   ├── memories/presentation/memories_screen.dart   # Legacy — see Known Gaps
│   ├── milestones/presentation/
│   │   ├── baby_journey_screen.dart          # Tabs: Milestones (19-band selector + category grid) + Memory Diary
│   │   ├── milestone_guidance_screen.dart    # NEW — 7-section guidance page (replaces category+detail screens)
│   │   ├── milestone_category_screen.dart    # Legacy — kept for backward compat, not used in main flow
│   │   ├── milestone_detail_screen.dart      # Legacy — kept for backward compat, not used in main flow
│   │   └── milestones_screen.dart            # Re-export shim
│   ├── onboarding/presentation/baby_setup_screen.dart
│   ├── profile/presentation/profile_screen.dart
│   └── vaccination/presentation/vaccination_screen.dart
└── models/
    ├── baby_model.dart
    ├── memory_model.dart
    ├── milestone_model.dart              # AgeBand (19 bands), CategoryGuidance (7-section), MilestoneItem, CommonConcern
    ├── milestone_library.dart            # Full content library: 19 bands × 6 categories × 7 sections
    ├── recipe_model.dart                     # RecipeModel + 6 sample recipes
    └── vaccination_model.dart                # Indian schedule generator
```

---

## 5. Key Providers

| Provider | Type | Purpose |
|----------|------|---------|
| `babyProvider` | `StateNotifierProvider<BabyNotifier, BabyState>` | Loads/creates/updates baby from Supabase |
| `currentBabyProvider` | `Provider<BabyModel?>` | Convenience — just the `BabyModel` or null |
| `authNotifierProvider` | `StateNotifierProvider` | Sign in / sign up / sign out + loading state |
| `sessionProvider` | `StreamProvider` | Supabase auth state stream |
| `aiRecipesProvider` | `StateNotifierProvider<AiRecipesNotifier, AiRecipesState>` | Gemini recipe generation with retry |
| `bookmarksProvider` | `StateNotifierProvider` | In-memory bookmark set (sample + AI) |
| `aiBookmarkedRecipesProvider` | `StateNotifierProvider` | Persists AI recipe objects for bookmark screen |
| `milestonesProvider` | `StateNotifierProvider` | Milestone status + Supabase sync |

---

## 6. Key Services

### `GeminiService`
- Calls `gemini-2.0-flash` via REST (`v1beta` endpoint)
- Returns structured JSON array of `RecipeModel`-compatible objects
- Prompt includes baby age in months + optional focus theme
- Strips markdown fences from response before JSON parsing
- **Known issue:** Free tier quota (429) hit frequently — retry logic exists (3 attempts, 15s/30s backoff) but free tier limit is 15 req/min

### `SupabaseService`
- Wraps all DB queries (babies, milestones, memories, vaccinations)
- RLS enforced at DB level — all queries are user-scoped automatically

### `CloudinaryService`
- Unsigned uploads to Cloudinary
- Returns HTTPS CDN URL stored in Supabase `memories` table

---

## 7. Theme & Design System

- **Primary color:** `#7C4DFF` (purple)
- **Background:** `#F8F6FF` (soft lavender-white)
- **Font:** Nunito (Google Fonts)
- **Card style:** Consistent border via `AppCard` widget
- **Bottom nav:** 5 tabs — Home · Milestones · Food Menu (center, larger) · Community · Learn
- **Accent colors:** Green (food), Pink (memories), Orange (warnings), Blue (info)

---

## 8. Database Schema (Supabase)

| Table | Purpose |
|-------|---------|
| `profiles` | One row per auth user. Role, due date, full name, avatar |
| `babies` | Baby profiles linked to user. Supports born + unborn (due_date) |
| `milestones` | Milestone tracking per baby. Category, status, achieved date |
| `milestone_definitions` | 60+ master milestone templates (0–24 months) |
| `memories` | Memory diary entries. Cloudinary URL, caption, tag, date |
| `vaccinations` | Indian immunisation schedule per baby |

**RLS:** All tables have Row Level Security. Users can only read/write their own rows.  
**Trigger:** Auto-creates a `profiles` row on `auth.users` insert.  
**Function:** `populate_milestones_for_baby()` auto-creates milestones on first open.

---

## 9. Environment / Secrets

| File | Contains | Committed? |
|------|---------|-----------|
| `lib/core/services/supabase_config.dart` | Supabase URL + anon key | ✅ Yes (safe for private repo) |
| `lib/core/services/cloudinary_service.dart` | Cloud name + upload preset | ✅ Yes |
| `lib/core/providers/auth_provider.dart` | Google Web Client ID | ✅ Yes |
| `lib/core/services/secrets.dart` | Gemini API key | ❌ Gitignored |

---

## 10. Key Dependencies (`pubspec.yaml`)

```yaml
flutter_riverpod: ^2.6.1        # State management
supabase_flutter: ^2.8.4        # Auth + DB + Storage
google_sign_in: ^6.2.2          # Native Google account picker
cloudinary_public: ^0.23.1      # Unsigned image uploads
http: ^1.6.0                    # Gemini REST calls
google_fonts: ^6.2.1            # Nunito font
image_picker: ^1.1.2            # Camera + gallery access
image_cropper: ^8.0.2           # Crop before upload
share_plus: ^10.1.4             # Share recipe text
shimmer: ^3.0.0                 # Loading skeleton (installed, not yet used)
smooth_page_indicator: ^1.2.0   # Carousel dots
percent_indicator: ^4.2.3       # Progress rings/bars
cached_network_image: ^3.4.1    # Network image caching
flutter_secure_storage: ^9.2.4  # Session persistence (Android Keystore)
go_router: ^14.8.1              # Installed, not yet wired (planned for deep links)
intl: ^0.20.2                   # Date formatting
```

---

## 11. Completed Features Summary

- ✅ Auth — email sign up/in, Google Sign-In (native), session persistence
- ✅ Onboarding — role-based (Pregnant / Parent / Family), baby setup
- ✅ Home screen — baby card, tips carousel, quick actions, milestone ring (real data)
- ✅ Food Menu — age selector, AI recipes banner, weekly meal plan, recipe detail
- ✅ AI Recipes — Gemini 2.0 Flash, 8 focus themes, skeleton loading, retry, bookmarks
- ✅ Recipe Detail — hero image/gradient, ingredients, step-by-step, bookmark, share
- ✅ Weekly Meal Plan — day selector, meal table, shopping list, share plan
- ✅ Bookmarked Recipes — sample + AI recipes, unbookmark, empty state
- ✅ Baby Journey / Milestones — **fully redesigned** with 19 granular age bands (0-1 weeks → 5-6 years), 6 categories (Gross Motor, Fine Motor, Language, Cognitive, Social, Feeding & Sleep), 7-section guidance per category (About, Common Milestones checklist, Activities, Signs to look for, When to worry, Common concerns, Parent tips), real Supabase status sync, age band auto-selected from baby's age
- ✅ Memory Diary — Cloudinary upload, photo grid, full-screen viewer, tags, filter
- ✅ Vaccination Tracker — Indian schedule, status badges, mark given, Supabase sync
- ✅ Community — **multi-community list** with search/filter, join/leave, create community flow
- ✅ Learn — search, categories, articles carousel, expert videos (hardcoded data)
- ✅ Profile — edit name/baby details, reset onboarding, delete all data, sign out

---

## 12. Session Change Log

### Session 2 — May 2026

#### ✅ Community Redesign
**Problem:** Community tab opened directly into a hardcoded "January 2026 Moms" detail screen with no way to discover or create other communities.

**What was built:**

`communities_list_screen.dart` (new — Community tab landing)
- 8 pre-seeded communities: January 2026 Moms, Dad's Corner, Diaper Changers 💩, Breastfeeding Support, Sleep Deprived Club, Indian Moms Network, Working Moms, Toddler Taming Squad
- Search bar filtering by name and description
- Category filter chips: All, Pregnancy, Parenting, Health, Humor, Culture, Lifestyle
- "Your Communities" horizontal scroll row at the top (joined communities only)
- Each card: emoji avatar, name, description, member count, active count, category chip, Join/Leave toggle
- "Create Community" FAB

`create_community_screen.dart` (new)
- Live preview card that updates as you type
- Name (min 3 chars) + description (min 10 chars) with validation
- Emoji picker (24 options)
- Color/theme picker (8 colors, animated selection ring)
- Category picker
- Create button disabled until form is valid; spinner on submit
- Returns new `CommunityInfo` to list, inserted at top

`community_screen.dart` (updated)
- Now accepts optional `CommunityInfo` parameter
- Hero banner, title, member count, active count, accent color all driven by passed community
- Shows back arrow when navigated from list; no back arrow when used as direct tab (backward compatible)
- `_formatCount()` helper added for member count display

`main_shell.dart` (updated)
- Community tab now points to `CommunitiesListScreen` instead of `CommunityScreen`

#### ⚠️ Known Issue — Gemini 429 Rate Limit
The free Gemini API tier is hitting quota limits (429) on the AI Recipes screen. The retry logic (3 attempts, 15s/30s backoff) is in place but the free tier cap of 15 req/min is being exceeded. Options:
1. Upgrade to a paid Gemini API plan
2. Add a local cache so generated recipes aren't re-fetched on every screen open
3. Show cached/sample recipes as fallback when quota is exceeded

---

### Session 3 — May 2026

#### ✅ Milestone Page — Rich Detail & Activity System

**Problem:** The milestone page only recorded whether a baby had achieved a milestone. There was no guidance on *how* to help the baby reach it, no signs to watch for, and no medical red flags.

**Navigation flow changed:**
```
Milestones tab
  └── _DevelopmentAreaCard tap
        └── MilestoneCategoryScreen  (NEW — full screen, was a bottom sheet)
              └── milestone row tap
                    └── MilestoneDetailScreen  (NEW — 4-tab detail screen)
```

**`milestone_model.dart` — extended `MilestoneItem`**

New fields added to `MilestoneItem`:
| Field | Type | Purpose |
|-------|------|---------|
| `description` | `String` | One-line description of what the milestone looks like |
| `ageRange` | `String` | e.g. `"6-9 Months"` |
| `activities` | `List<MilestoneActivity>` | Structured activities to encourage the milestone |
| `positiveSign` | `List<MilestoneSign>` | Green signs — baby is on track |
| `watchSigns` | `List<MilestoneSign>` | Orange signs — may need more time |
| `warnings` | `List<MilestoneWarning>` | Red flags — talk to a doctor |
| `activitySectionTitle` | `String?` | Custom title for the Activities tab |
| `activityFilters` | `List<String>` | Filter chips on Activities tab (e.g. Tummy to Back) |
| `parentingTip` | `String?` | Tip shown at the bottom of the category screen |

New model classes:
- `MilestoneActivity` — title, description, emoji, steps list, optional filter tag
- `MilestoneSign` — title, description, isPositive flag
- `MilestoneWarning` — title, description, emoji
- `MilestoneItem.copyWith()` — added for clean state updates

Rich sample data added for "Rolls over in both directions" (full activities, signs, warnings). All other sample milestones updated with `description`, `ageRange`, and `parentingTip`.

**`milestone_category_screen.dart`** (new)
- Full-screen category view (e.g. "Gross Motor") replacing the old bottom sheet
- Hero card: category emoji, description, baby name + age pill
- Live progress bar: `X/Y Achieved` with contextual encouragement message
- Milestone list rows: emoji, title, description, status badge (Achieved ✅ / In Progress ○ / Not Started 🔒), chevron
- Parenting Tip card at the bottom (pulled from item data)
- Tapping a row navigates to `MilestoneDetailScreen`

**`milestone_detail_screen.dart`** (new — 4 tabs)

Tab 1 — **About**
- Two video placeholder cards (e.g. "Front to Back" / "Back to Front") with play button overlay
- "Every baby develops at their own pace" tip banner
- "How to encourage" list — activity rows with emoji, title, description, chevron
- Track Progress card (shown only when milestone is Achieved) — achieved date + Edit button

Tab 2 — **Activities**
- Section title + subtitle
- Filter chips (e.g. All Activities / Tummy to Back / Back to Tummy / Tips)
- Activity cards: image placeholder (emoji), activity emoji badge, title, description, numbered steps (up to 3), chevron
- "Make it fun!" banner at the bottom

Tab 3 — **Signs to look for**
- Positive signs card (green) — checkmark list of on-track behaviours
- Signs to watch card (orange) — dot list of behaviours needing attention
- "Every baby is unique" tip banner

Tab 4 — **When to worry**
- Warning rows: emoji icon, title, description, chevron
- "Early support makes a big difference" pink card
- "Remember — you're doing a great job" purple card

**Shared across all tabs:**
- Hero header: category label, milestone title, description, age range chip, status card (Achieved/In Progress/Not Started + achieved date + Edit)
- "Update Progress" bottom bar → status picker sheet (3 options with animated selection)
- Back arrow, favourite, more-options in app bar

**`baby_journey_screen.dart`** (updated)
- `_DevelopmentAreaCard` now navigates to `MilestoneCategoryScreen` via `Navigator.push`
- Old `_MilestoneDetailSheet` and `_MilestoneItemRow` classes removed
- `milestones_provider.dart` updated to use `MilestoneItem.copyWith()` instead of manual reconstruction

**`milestones_provider.dart`** (updated)
- `updateMilestoneStatus` now uses `item.copyWith()` — cleaner and preserves all rich fields

---

### Session 4 — May 2026

#### ✅ Age-Based Milestone Library

**Problem:** The milestone page showed the same hardcoded 6–9 month milestones regardless of the baby's actual age. Tapping a different age group chip had no effect on the content. Supabase-loaded items had no activities, signs, or warnings.

**What was built:**

**`milestone_library.dart`** (new — `lib/models/`)

A static content library covering all 5 age groups × 5 categories:

| Age Group | Index | Milestones per category |
|-----------|-------|------------------------|
| 0–3 Months | 0 | 3–4 per category |
| 4–6 Months | 1 | 3–4 per category |
| 6–9 Months | 2 | 3–6 per category (richest — full activities/signs/warnings) |
| 9–12 Months | 3 | 4–5 per category |
| 1–2 Years | 4 | 4–5 per category |

Key functions:
- `milestonesForAgeGroup(index)` — returns full `List<MilestoneCategoryProgress>` for the group, all items with `notStarted` status (real statuses overlaid from Supabase)
- `enrichItem(item)` — takes a bare Supabase `MilestoneItem` (id/title/category/status only) and fills in description, ageRange, activities, positiveSign, watchSigns, warnings, activitySectionTitle, activityFilters, parentingTip by matching title + category against the library
- `ageGroupFromMonths(months)` — maps baby age in months to group index (0–4)
- `ageGroupLabels` — const list of human-readable labels per group

**`milestone_model.dart`** (updated)
- `MilestoneItem.copyWith()` extended to accept all fields (description, ageRange, activities, positiveSign, watchSigns, warnings, activitySectionTitle, activityFilters, parentingTip) so `enrichItem` can overlay library content without losing Supabase status/achievedDate

**`milestones_provider.dart`** (updated)
- `loadMilestones` now accepts optional `ageGroupIndex` parameter
- Derives group from `ageInMonths` if not provided (backward compatible)
- After loading from Supabase, filters rows to only those whose titles exist in the selected age group's library
- Enriches every loaded item with `enrichItem()` — Supabase items now get full activities/signs/warnings
- Falls back to `milestonesForAgeGroup()` (all notStarted) if Supabase has no matching items for the selected group or on error

**`baby_journey_screen.dart`** (updated)
- Initial `_loadMilestones()` passes `ageGroupIndex: _selectedAgeGroup` to the provider
- Age group selector chips now call `loadMilestones` with the tapped index — switching chips reloads content for that age group
- Baby's actual age auto-selects the correct chip on first load

---

### Session 5 — May 2026

#### ✅ Milestone System — Full Redesign

**Problem:** The milestone page used 5 broad age groups (0-3m, 4-6m, etc.) and 5 categories. The detail view was a 4-tab screen per individual milestone item. There was no guidance on feeding/sleep, and the age granularity was too coarse for newborns.

**New architecture:**

```
Milestones tab
  └── 19-band horizontal chip selector (auto-scrolls to baby's band)
        └── 6 category grid cards (tap)
              └── MilestoneGuidanceScreen — 7 sections:
                    1. About
                    2. Common Milestones (checklist with status cycling)
                    3. Activities to Try (expandable steps)
                    4. Signs to Look For (positive + watch)
                    5. When to Worry (warning tiles)
                    6. Common Concerns (Q&A accordion)
                    7. Parent Tips (numbered list)
```

**`milestone_model.dart`** — completely rewritten:
- `AgeBand` — 19 bands from "0-1 Weeks" to "5-6 Years" with `minDays`/`maxDays`, `shortLabel`, `emoji`
- `ageBandFromMonths(months)` — maps baby age to band index
- `MilestoneCategory` — 6 values: grossMotor, fineMotor, language, cognitive, social, **feedingSleep** (new)
- `CategoryGuidance` — the core data object: holds all 7 sections for one category × age band
- `CommonConcern` — new model: question + answer for the Q&A section
- `MilestoneItem.signsToLookFor` — renamed from `positiveSign`
- `MilestoneCategoryProgress.fromGuidance()` — backward-compat factory for home screen ring
- `CategoryGuidance.withUpdatedMilestone()` — immutable status update

**`milestone_library.dart`** — completely rewritten:
- `guidanceForAgeBand(bandIndex)` — returns all 6 `CategoryGuidance` objects for a band
- `enrichGuidance(guidance, supabaseStatuses)` — overlays Supabase statuses onto library milestones
- Full content for all 19 bands × 6 categories = **114 guidance pages**
- Each page has: aboutText, 3-6 milestones, 2-3 activities with steps, positive/watch signs, warnings, 2-3 Q&A concerns, 3-4 parent tips

**`milestones_provider.dart`** — rewritten:
- State now holds `List<CategoryGuidance>` instead of `List<MilestoneCategoryProgress>`
- `loadMilestones(babyId, ageInMonths, {bandIndex})` — loads library for band, overlays Supabase statuses
- `updateMilestoneStatus` uses `CategoryGuidance.withUpdatedMilestone()` for immutable updates
- Backward-compat `categories` getter returns `List<MilestoneCategoryProgress>` for home screen ring

**`baby_journey_screen.dart`** — milestones tab rewritten:
- 19-band horizontal chip selector with `ScrollController` — auto-scrolls to baby's current band
- 2×3 category grid (6 cards) replacing the old 5-item list
- Each card shows: emoji, category name, description, `X/Y` progress, mini progress bar
- Tapping a card navigates to `MilestoneGuidanceScreen`

**`milestone_guidance_screen.dart`** (new — replaces both category + detail screens):
- 7 numbered sections rendered as a single scrollable page
- Section 2 checklist: tap status circle to cycle notStarted → inProgress → achieved, or tap "Done" chip
- Section 3 activities: expandable tiles showing numbered steps
- Section 6 concerns: Q&A accordion (tap question to reveal answer)
- Status changes propagate back to provider and Supabase immediately

**Fixes applied:**
- `socialEmotional` → `social` everywhere
- `positiveSign` → `signsToLookFor` in `milestone_detail_screen.dart`
- Unused `milestone_category_screen.dart` import removed from `baby_journey_screen.dart`
- `feedingSleep` case added to all switch statements in `milestone_category_screen.dart`

---

## 13. Pending Tasks

### 🔴 High Priority

- [ ] **Loading shimmer placeholders**  
  While fetching baby data, memories, and milestones from Supabase. The `shimmer` package is already in `pubspec.yaml` — just needs to be wired into the screens.

- [ ] **Pregnancy tracking module**  
  Pregnant users currently see the same home screen as parents. Needs a separate home screen with week-by-week updates, symptom tracker, and kick counter.

- [ ] **Custom milestones**  
  Let parents add their own milestones beyond the library defaults. Requires a FAB in `MilestoneGuidanceScreen` → bottom sheet → Supabase insert with `is_custom: true`.

- [ ] **Push notifications**  
  Vaccination reminders, milestone prompts, daily tips. Requires FCM setup + GoRouter for deep link handling.

- [ ] **Gemini quota fix**  
  AI Recipes hitting 429 on free tier. Add recipe caching or upgrade API plan.

### 🟡 Medium Priority

- [ ] **Multiple babies**  
  Currently only the first baby is loaded (`babies.first` in `BabyNotifier.loadBaby()`). Needs a baby switcher UI in Profile and Food Menu screens.

- [ ] **Food safety / AI chat**  
  "Can my 8-month-old eat honey?" queries via Gemini. Dedicated chat screen or inline Q&A.

- [ ] **Indian meal recommendations engine**  
  Rule-based suggestions by pregnancy week or baby age, beyond static sample recipes.

- [ ] **App icon + splash branding**  
  Custom MotherHood icon. Needs assets + `flutter_launcher_icons` package.

- [ ] **Community — real backend**  
  All three community screens use hardcoded data. Needs Supabase `communities` + `posts` tables, real-time subscriptions, and actual post/community creation persisted to DB.

- [ ] **Learn — real content**  
  `learn_screen.dart` uses hardcoded articles/videos. Needs a CMS or Supabase `articles` table.

### 🟢 Lower Priority

- [ ] **Subscription screen** — free vs premium feature gating
- [ ] **Razorpay integration** — UPI, cards, net banking for premium
- [ ] **Product recommendations** — Amazon affiliate links based on baby age
- [ ] **Regional language support** — Hindi, Tamil, Telugu, Gujarati
- [ ] **GoRouter migration** — for deep linking from push notifications (`go_router` already in `pubspec.yaml`)

### 🌸 Future Phase — Fertility & Ovulation Tracking

Planned for Phase 2 after push notifications and multiple babies are done.

**Scope:** Cycle tracker, ovulation predictor, symptom logging, TTC mode  
**Onboarding change:** Add 4th role — `🌸 I'm trying to conceive`  
**New DB tables required:** `cycles`, `cycle_logs`

---

## 14. Known Gaps / Notes for Next Developer

1. **`food_menu/data/` is empty** — all recipe data lives in `models/recipe_model.dart` as static sample data.

2. **`router/` folder exists** but `go_router` is not yet wired into `main.dart`. App still uses `MaterialApp` with `SplashScreen` as home. Migration needed before push notifications can deep-link.

3. **`memories_screen.dart` is legacy** — the Memory Diary tab inside `baby_journey_screen.dart` is the active implementation.

4. **`shimmer` package is installed** but not used anywhere yet.

5. **`image_cropper` is installed** but crop flow may not be fully integrated in the memory upload path.

6. **Community data is all in-memory** — `CommunitiesListScreen` holds community state locally in `_communities` list. Join/leave and newly created communities are lost on tab switch because `IndexedStack` keeps the widget alive but state resets on hot restart. Needs Riverpod provider or Supabase backend to persist.

7. **Gemini API key is exposed in logs** — `GeminiService` prints the full URL including `?key=...` to debug console. Should be removed or masked before production.

8. **Milestone library title matching with Supabase** — `enrichGuidance()` matches by milestone title (lowercase). If the Supabase `milestone_definitions` table uses different wording, statuses won't be overlaid. The library is now the source of truth — consider dropping the Supabase `milestone_definitions` table and storing only user statuses (title + category + status + achieved_at).

9. **`milestone_category_screen.dart` and `milestone_detail_screen.dart` are legacy** — the new flow goes directly to `MilestoneGuidanceScreen`. These files are kept to avoid breaking any remaining references but are not used in the main navigation flow.

10. **`MilestoneGuidanceScreen` video section is not implemented** — the About section has no video cards in the new design. If video guidance is needed, add a `videoUrls` field to `CategoryGuidance` and integrate `video_player` or `chewie`.

---

*Last updated: May 2026 | Flutter 3.x | Supabase + Cloudinary + Gemini 2.0 Flash*
