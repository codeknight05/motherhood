# MotherHood 💗

> **AI-Powered Maternal & Child Wellness Ecosystem**  
> A full-stack Flutter application supporting mothers and families through pregnancy, childbirth, recovery, baby growth, and early childhood development.

---

## Table of Contents

- [Overview](#overview)
- [Tech Stack](#tech-stack)
- [Architecture](#architecture)
- [Features Completed](#features-completed)
- [Features Pending](#features-pending)
- [Approaches & Decisions](#approaches--decisions)
- [Alternatives Considered](#alternatives-considered)
- [Project Structure](#project-structure)
- [Setup & Running](#setup--running)
- [Environment Configuration](#environment-configuration)
- [Database Schema](#database-schema)

---

## Overview

MotherHood is a multiplatform parenting and maternal wellness app built with Flutter, targeting:

- **Pregnant women** — pregnancy tracking, nutrition, due date countdown
- **New parents** — baby milestone tracking, memory diary, food recommendations
- **Family members / caregivers** — community, learning resources, support

The app is designed specifically for Indian families with culturally relevant nutrition recommendations, regional food preferences, and traditional health knowledge.

---

## Tech Stack

| Layer | Technology | Reason |
|-------|-----------|--------|
| Frontend | Flutter 3.x | Single codebase for Android, iOS, Web |
| State Management | Riverpod 2.x | Scalable, testable, compile-safe |
| Backend / Auth | Supabase | PostgreSQL + Auth + RLS in one platform |
| Image Storage | Cloudinary | 25GB free, auto-compression, CDN delivery |
| AI | Google Gemini 1.5 Flash | Recipe generation, nutrition intelligence |
| Fonts | Google Fonts (Nunito) | Warm, rounded, readable |
| Navigation | IndexedStack + Navigator | Simple tab navigation without over-engineering |

---

## Architecture

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
│   ├── community/        # Community group detail screen with post feed
│   ├── food_menu/        # Food Menu, Recipe Detail, Weekly Meal Plan, AI Recipes, Bookmarks
│   ├── home/             # Home dashboard
│   ├── learn/            # Learn / articles screen
│   ├── memories/         # Standalone memory screen (legacy)
│   ├── milestones/       # Baby Journey (Milestones + Memory Diary)
│   ├── onboarding/       # Role-based baby setup
│   ├── profile/          # User profile, edit, sign out
│   └── vaccination/      # Vaccination tracker with Indian schedule
├── models/               # BabyModel, MemoryModel, MilestoneModel, RecipeModel, VaccinationModel
└── main.dart
```

**Pattern used:** Feature-first folder structure. Each feature owns its presentation layer. Shared logic lives in `core/`. Models are plain Dart classes with no framework dependency.

---

## Features Completed

### ✅ Foundation
- Flutter project configured for Android, iOS, and Web
- App theme with Nunito font, purple/pastel color palette, consistent spacing system
- 5-tab bottom navigation: Home · Milestones · **Food Menu (center)** · Community · Learn
- All cards have consistent border styling via `AppCard`
- Zero analyzer errors/warnings across the entire codebase

### ✅ Authentication
- Email sign up with confirm password validation
- Email sign in
- Google Sign-In (native Android flow using `google_sign_in` + Supabase `signInWithIdToken`)
- Session persistence via `flutter_secure_storage` (Android Keystore)
- Splash screen reads persisted session — no re-login on app restart

### ✅ Onboarding (Role-Based)
- Step 1: Who are you? — Pregnant / I have a baby / Family member
- **Pregnant** → Due date picker, pregnancy week card
- **Parent** → Baby photo, name (optional), birth date, gender, height, weight
- **Family** → Skips baby setup entirely, goes straight to Home
- Role and due date saved to Supabase `profiles` table

### ✅ Home Screen
- Baby profile card with name, age, birth date, height, weight from real Supabase data
- "Today for you" tips carousel with smooth page indicator
- Quick actions grid: Milestone Tracker, Menu & Recipes, Communities, Knowledge Hub, Vaccination Tracker — all wired to navigate to correct screens
- Milestone progress ring with real data from Supabase (circular + linear bars per category)
- Recommended articles section
- Profile avatar tap → Profile screen

### ✅ Food Menu
- Age group selector (6–8M, 9–12M, 1–2Y, 2–4Y, 4–6Y)
- **AI Daily Recipes banner** — prominent entry point to Gemini-powered recipes
- Quick categories: Weekly Meal Plan (navigates), Saved Recipes (navigates to bookmarks)
- Today's Picks — 4 sample recipes, tappable → Recipe Detail
- Weekly Meal Plan preview card with "View Full Plan" button
- Nutrition tip card
- Popular categories chips

### ✅ Recipe Detail Screen
- Hero image (or gradient + robot emoji for AI recipes)
- Title, Report Content button
- Time / calories / tag meta chips
- Expandable description with Show More / Show Less
- Ingredients list with emoji/image thumbnails and quantities
- Step-by-step expandable cards (tap to expand, animated)
- How to Serve section
- Bookmark button (top right) — saves to bookmarks, shows snackbar
- Share button — shares recipe text via system share sheet
- AI-generated recipes show gradient hero with 🤖 emoji

### ✅ Weekly Meal Plan Screen
- Day selector with colored dots (matches UI reference)
- Full meal table: Meal time + emoji | Recipe image + name + cook time | Ingredients & benefits
- Nutrition tip card
- This Week's Highlights grid (4 cards)
- App bar with **Shopping List** and **Share Plan** action buttons (matches reference)
- Age group label in subtitle with dropdown indicator

### ✅ AI Recipes (Gemini-Powered)
- `GeminiService` calls Gemini 1.5 Flash with structured JSON prompt
- Recipes tailored to baby's exact age in months
- 8 focus themes: Surprise Me, High Protein, Iron Rich, Brain Boost, Immunity, Weight Gain, Finger Foods, Easy Digest
- Animated skeleton loading cards while Gemini generates
- Error state with retry button
- Regenerate button once recipes are loaded
- Each AI recipe card: emoji thumbnail, ✨ AI badge, category, name, time, calories, tag, bookmark
- Bookmarked AI recipes persist in `aiBookmarkedRecipesProvider` and appear in Saved Recipes
- Full recipe detail view works for AI recipes (gradient hero, all sections)
- API key stored in gitignored `secrets.dart`

### ✅ Bookmarked Recipes Screen
- Shows all bookmarked recipes — both sample and AI-generated
- List view with image, name, time, calories, tag chip
- Unbookmark directly from list
- Empty state when no bookmarks

### ✅ Baby Journey — Milestones Tab (Fully Redesigned)
- **19 granular age bands** from "0-1 Weeks" to "5-6 Years" — horizontal chip selector auto-scrolls to baby's current band
- **6 categories**: Gross Motor, Fine Motor, Language, Cognitive, Social, Feeding & Sleep
- **2×3 category grid** — each card shows emoji, name, description, X/Y progress, mini progress bar
- Tapping a category opens **`MilestoneGuidanceScreen`** — a single scrollable page with 7 sections:
  1. **About** — what to expect at this age for this category
  2. **Common Milestones** — checklist with status cycling (Not Started → In Progress → Done) and "Done" quick chip
  3. **Activities to Try** — expandable tiles with numbered steps
  4. **Signs to Look For** — positive signs (green) + signs to watch (orange)
  5. **When to Worry** — warning tiles + "Early support" card
  6. **Common Concerns** — Q&A accordion (tap question to reveal answer)
  7. **Parent Tips** — numbered tip list
- Status changes saved to Supabase instantly
- Library covers **114 guidance pages** (19 bands × 6 categories), each with full content
- Supabase statuses overlaid onto library milestones via `enrichGuidance()`
- Home screen progress ring still works via backward-compat `MilestoneCategoryProgress.fromGuidance()`

### ✅ Baby Journey — Memory Diary Tab (Real Data)
- Photo grid grouped by month, loaded from Supabase on tab open
- Filter chips (All, Milestone, First Time, Everyday, Special, Funny, Growth)
- Stats row (total memories, age in months, milestone count)
- Add Memory FAB → camera or gallery picker
- Caption input + tag selector
- **Cloudinary upload** — photos stored in cloud, not local device
- **Supabase persistence** — memory metadata saved to DB
- Full-screen photo viewer with pinch-to-zoom, share button

### ✅ Vaccination Tracker
- Indian immunisation schedule auto-generated from baby's birth date (30+ vaccines)
- Status badges: Given ✅ / Due Now 📅 / Upcoming 🔜 / Overdue ⚠️
- Filter chips: All, Due, Overdue, Upcoming, Given
- Stats row: Given count, Due count, Overdue count
- "Mark Given" / "Mark Done" with confirmation dialog
- Saves given date to Supabase `vaccinations` table
- First open auto-saves full schedule to Supabase
- Accessible from Home quick actions

### ✅ Community — Multi-Community Hub
- **Communities list screen** — landing page for the Community tab
  - 8 pre-seeded communities: January 2026 Moms, Dad's Corner, Diaper Changers 💩, Breastfeeding Support, Sleep Deprived Club, Indian Moms Network, Working Moms, Toddler Taming Squad
  - Search bar filtering by name and description
  - Category filter chips: All, Pregnancy, Parenting, Health, Humor, Culture, Lifestyle
  - "Your Communities" horizontal scroll row (joined communities)
  - Each card: emoji, name, description, member count, active count, category chip, Join/Leave toggle
  - "Create Community" FAB
- **Create Community screen** — full form with live preview card
  - Name + description with validation
  - Emoji picker (24 options), color/theme picker (8 colors), category picker
  - Returns new community to list on creation
- **Community detail screen** — now accepts any `CommunityInfo` (not hardcoded to Jan 2026 Moms)
  - Hero banner, colors, member count driven by the selected community
  - Back arrow when navigated from list
  - Post feed, like toggle, create post, tab bar (all posts still hardcoded sample data)

### ✅ Learn Screen
- Search bar with filter icon
- Category grid: Pregnancy, Newborn Care, Feeding & Nutrition, Sleep, Child Development, Parenting
- Featured articles carousel with category badge, image, title, description, read time
- Expert video picks with play button overlay, duration badge, expert name + role
- Trending Now list

### ✅ Profile Screen
- User card with Google avatar / initial fallback, email, provider badge
- Baby details card (name, age, birth date, height, weight, gender)
- Edit Profile — update display name via Supabase auth metadata
- Edit Baby Details — update name, height, weight in Supabase
- **Reset & Start Over** — deletes all baby data, resets role, returns to onboarding
- **Delete All My Data** — deletes profile + all data, signs out permanently
- Sign Out — clears session and local state

### ✅ Backend (Supabase)
- `profiles` table — user role, due date, full name, avatar
- `babies` table — name, birth date, due date, gender, height, weight
- `milestones` table — category, title, status, achieved date
- `milestone_definitions` table — 60+ master milestone templates
- `memories` table — Cloudinary image URL, caption, tag, age months, date
- `vaccinations` table — vaccine name, due date, given date
- Row Level Security (RLS) on all tables
- Auto-create profile trigger on sign-up
- `populate_milestones_for_baby()` stored function

---

## Features Pending

### 🔲 High Priority

- [ ] **Gemini 429 quota fix** — AI Recipes screen hits free-tier rate limit (15 req/min). Options: upgrade API plan, add local recipe cache, or show sample recipes as fallback. Retry logic (3 attempts, 15s/30s backoff) already exists in `ai_recipes_provider.dart`.
- [ ] **Loading shimmer placeholders** — while fetching baby data, memories, milestones from Supabase. Currently shows sample data as fallback, but a shimmer skeleton would be more polished. `shimmer` package already in `pubspec.yaml`.
- [ ] **Pregnancy tracking module** — different home screen for pregnant users (week-by-week updates, symptom tracker, kick counter). Currently pregnant users see the same home screen as parents.
- [ ] **Custom milestones** — let parents add their own milestones beyond the library defaults. Requires a FAB in `MilestoneGuidanceScreen` → bottom sheet → Supabase insert with `is_custom: true`.
- [ ] **Push notifications** — vaccination reminders ("BCG due in 3 days"), milestone prompts, daily tips. Requires Firebase Cloud Messaging (FCM) setup.

### 🔲 Medium Priority

- [ ] **Multiple babies** — add/switch between babies. Currently only the first baby is loaded. Requires a baby switcher UI in the profile and food menu screens.
- [ ] **Food safety / AI chat** — "Can my 8-month-old eat honey?" type queries via Gemini. A dedicated chat screen or inline Q&A in the food menu.
- [ ] **Indian meal recommendations engine** — rule-based suggestions by pregnancy week or baby age (beyond the current static sample recipes).
- [ ] **App icon + splash branding** — custom MotherHood icon replacing the default Flutter icon.
- [ ] **Community — real backend** — community list and create flow are UI-complete but all data is in-memory. Needs Supabase `communities` + `posts` tables, real-time subscriptions, and persistence for join/leave and post creation.
- [ ] **Learn — real content** — current learn screen uses hardcoded articles/videos. Needs a CMS or Supabase `articles` table.

### 🔲 Lower Priority

- [ ] **Subscription screen** — free vs premium feature gating.
- [ ] **Razorpay integration** — UPI, cards, net banking for premium.
- [ ] **Product recommendations** — Amazon affiliate links based on baby age.
- [ ] **Regional language support** — Hindi, Tamil, Telugu, Gujarati.
- [ ] **GoRouter migration** — for deep linking from push notifications.

---

## 🌸 Future Feature — Fertility & Ovulation Tracking

> **Note:** Planned for Phase 2 after push notifications and multiple babies are done.

### Why Add It
Currently MotherHood covers the journey from **pregnancy onwards**. Adding fertility tracking fills the gap before pregnancy:

```
Trying to conceive → Pregnant → Postpartum → Baby growth → Early childhood
     (Fertility)      (Pregnancy)  (Recovery)   (Milestones)    (Learning)
```

### What to Build
- Cycle tracker (period start/end, cycle length, predictions)
- Ovulation predictor (fertile window, peak day, calendar view)
- Symptom logging (mood, energy, BBT, cramps)
- TTC mode with phase-specific tips

### Onboarding Change Required
Add a 4th role: `🌸 I'm trying to conceive`

### DB Changes Required
```sql
alter table public.profiles
  add constraint profiles_role_check
  check (role in ('trying_to_conceive', 'pregnant', 'parent', 'family'));

create table public.cycles (
  id           uuid primary key default uuid_generate_v4(),
  user_id      uuid references profiles(id) on delete cascade,
  period_start date not null,
  period_end   date,
  cycle_length integer,
  notes        text,
  created_at   timestamptz default now()
);

create table public.cycle_logs (
  id         uuid primary key default uuid_generate_v4(),
  user_id    uuid references profiles(id) on delete cascade,
  log_date   date not null,
  mood       text,
  energy     integer check (energy between 1 and 5),
  cramps     integer check (cramps between 1 and 5),
  bbt        numeric(4,2),
  discharge  text,
  notes      text
);
```

---

## Approaches & Decisions

### State Management — Riverpod over Provider/Bloc
**Decision:** Riverpod 2.x with `StateNotifier`

**Why:** Provider is being deprecated in favour of Riverpod by the same author. Bloc adds too much boilerplate for an MVP. Riverpod gives compile-safe providers, easy testing, and `ref.watch` / `ref.read` that work cleanly in both widgets and services.

**How it's used:**
- `babyProvider` — holds the current baby, loads from Supabase, used across all screens
- `authNotifierProvider` — handles sign in/up/out state with loading and error states
- `sessionProvider` — stream of Supabase auth state changes
- `aiRecipesProvider` — manages Gemini recipe generation state
- `bookmarksProvider` — in-memory bookmark set (sample + AI recipes)
- `aiBookmarkedRecipesProvider` — persists AI recipe objects for bookmark screen

---

### AI Integration — Gemini 1.5 Flash for Recipe Generation
**Decision:** Google Gemini 1.5 Flash with `responseMimeType: 'application/json'`

**Why:** Gemini Flash is fast and cost-effective for structured generation. Using JSON response mode eliminates the need to parse markdown fences. The prompt instructs Gemini to return exactly the `RecipeModel` schema, so AI recipes render identically to hand-crafted ones.

**How it works:**
1. User opens AI Recipes screen → `GeminiService.generateRecipes()` called
2. Prompt includes baby's age in months + optional focus theme
3. Gemini returns JSON array of 5 recipes
4. `AiRecipesNotifier._parseRecipe()` maps JSON → `RecipeModel`
5. Recipes render using the same `RecipeDetailScreen` as sample recipes

---

### Navigation — IndexedStack over GoRouter
**Decision:** `IndexedStack` for tabs, `Navigator.push` for sub-screens

**Why:** GoRouter adds complexity (route definitions, path parameters, redirects) that isn't needed at this stage. `IndexedStack` keeps all tab screens alive in memory (no rebuild on tab switch). GoRouter will be added when deep linking is needed (e.g. notification taps opening specific screens).

---

### Backend — Supabase over Firebase
**Decision:** Supabase for auth, database, and storage

**Why:**
- PostgreSQL is more powerful than Firestore for relational data (babies → milestones → memories)
- Row Level Security (RLS) enforces data isolation at the DB level
- Single platform for auth + DB + storage
- Open source and self-hostable

**Trade-off:** Supabase storage is limited to 1GB on free tier, which is why Cloudinary was added for photos.

---

### Image Storage — Cloudinary over Supabase Storage
**Decision:** Cloudinary for all user-uploaded photos

**Why:** Supabase free tier gives only 1GB total storage. Cloudinary gives 25GB free with auto-compression, CDN delivery, and on-the-fly transformations.

**How it works:** Photo → upload to Cloudinary → get HTTPS URL → store URL in Supabase `memories` table.

---

### Auth — Native Google Sign-In over OAuth Redirect
**Decision:** `google_sign_in` package + `signInWithIdToken` instead of Supabase OAuth redirect

**Why:** Supabase's `signInWithOAuth(OAuthProvider.google)` opens a browser tab, which feels jarring on mobile. The native flow shows the native Google account picker sheet.

---

### Milestone Content — Local Library (19 Age Bands × 6 Categories)
**Decision:** Static `milestone_library.dart` for all milestone guidance content

**Why:** Storing 114 guidance pages (19 bands × 6 categories) in Supabase would require complex tables, joins, and network round-trips. Since this content is universal (not user-specific), a local Dart file is faster, works offline, and is trivial to update. Only user statuses are stored in Supabase.

**How it works:**
1. `guidanceForAgeBand(bandIndex)` returns 6 `CategoryGuidance` objects from the local library
2. Provider fetches user's milestone statuses from Supabase (`title + status + achieved_at`)
3. `enrichGuidance()` overlays Supabase statuses onto library milestones by title match
4. Age band chip selector calls `loadMilestones(bandIndex: i)` — switches content instantly
5. Status updates write to Supabase and update local state immediately via `withUpdatedMilestone()`

---

## Alternatives Considered

| Decision | Chosen | Alternatives Considered | Why Not Chosen |
|----------|--------|------------------------|----------------|
| State management | Riverpod | Provider, Bloc, GetX | Provider deprecated; Bloc too verbose; GetX anti-pattern |
| Backend | Supabase | Firebase, PocketBase, Appwrite | Firebase adds Google dependency; PocketBase needs self-hosting |
| Image storage | Cloudinary | Firebase Storage, Backblaze B2 | Firebase = second backend; Backblaze = complex setup |
| Auth (Google) | Native `google_sign_in` | Supabase OAuth redirect | Browser redirect feels jarring on mobile |
| Navigation | IndexedStack | GoRouter, AutoRoute | GoRouter overkill for current stage |
| AI | Gemini 2.0 Flash (REST) | GPT-4, Claude, google_generative_ai SDK | Gemini free tier generous; SDK dropped (deprecated endpoint) |

---

## Project Structure

```
motherhood/
├── android/
│   └── app/
│       ├── build.gradle.kts
│       └── src/main/AndroidManifest.xml
├── assets/
│   └── icons/
│       └── google_logo.svg
├── lib/
│   ├── core/
│   │   ├── constants/app_constants.dart
│   │   ├── providers/
│   │   │   ├── ai_recipes_provider.dart    # Gemini recipe generation state
│   │   │   ├── auth_provider.dart          # Auth state + Google sign-in
│   │   │   ├── baby_provider.dart          # Baby CRUD + Supabase sync
│   │   │   ├── milestones_provider.dart    # Milestone state + Supabase sync
│   │   │   └── recipe_provider.dart        # Bookmarks + AI recipe store
│   │   ├── services/
│   │   │   ├── cloudinary_service.dart     # Photo upload + thumbnail URLs
│   │   │   ├── gemini_service.dart         # Gemini API recipe generation
│   │   │   ├── secrets.dart                # API keys (gitignored)
│   │   │   ├── supabase_config.dart        # Project URL + anon key
│   │   │   └── supabase_service.dart       # DB + storage helpers
│   │   ├── theme/
│   │   │   ├── app_colors.dart
│   │   │   ├── app_text_styles.dart
│   │   │   └── app_theme.dart
│   │   └── widgets/
│   │       ├── app_card.dart               # Card with default border
│   │       ├── baby_avatar.dart
│   │       ├── main_shell.dart             # Bottom nav (Food Menu center)
│   │       └── section_header.dart
│   ├── features/
│   │   ├── auth/presentation/
│   │   │   ├── login_screen.dart
│   │   │   └── splash_screen.dart
│   │   ├── community/presentation/
│   │   │   ├── communities_list_screen.dart    # Community tab landing — list, search, filter, join
│   │   │   ├── community_screen.dart           # Group detail + post feed (accepts CommunityInfo)
│   │   │   └── create_community_screen.dart    # Create community form with live preview
│   │   ├── food_menu/presentation/
│   │   │   ├── ai_recipes_screen.dart      # Gemini AI recipe generation
│   │   │   ├── bookmarked_recipes_screen.dart
│   │   │   ├── food_menu_screen.dart
│   │   │   ├── recipe_detail_screen.dart   # Works for both sample + AI recipes
│   │   │   └── weekly_meal_plan_screen.dart
│   │   ├── home/presentation/home_screen.dart
│   │   ├── learn/presentation/learn_screen.dart
│   │   ├── milestones/presentation/
│   │   │   ├── baby_journey_screen.dart
│   │   │   ├── milestone_guidance_screen.dart    # 7-section guidance page (main flow)
│   │   │   ├── milestone_category_screen.dart    # Legacy (kept for compat)
│   │   │   ├── milestone_detail_screen.dart      # Legacy (kept for compat)
│   │   │   └── milestones_screen.dart
│   │   ├── onboarding/presentation/baby_setup_screen.dart
│   │   ├── profile/presentation/profile_screen.dart
│   │   └── vaccination/presentation/vaccination_screen.dart
│   ├── models/
│   │   ├── baby_model.dart
│   │   ├── memory_model.dart
│   │   ├── milestone_model.dart
│   │   ├── milestone_library.dart            # 19 bands × 6 categories × 7 sections (114 guidance pages)
│   │   ├── recipe_model.dart               # RecipeModel + 6 sample recipes
│   │   └── vaccination_model.dart          # Indian schedule generator
│   └── main.dart
├── pubspec.yaml
└── README.md
```

---

## Setup & Running

### Prerequisites
- Flutter SDK 3.x
- Android Studio / VS Code with Flutter extension
- Physical Android device or emulator (API 21+)

### Steps

```bash
git clone https://github.com/ShriHarsh05/motherhood.git
cd motherhood
flutter pub get
flutter run
```

### Building APK

```bash
flutter build apk --debug
```

---

## Environment Configuration

| File | Contains |
|------|---------|
| `lib/core/services/supabase_config.dart` | Supabase project URL + anon key |
| `lib/core/services/cloudinary_service.dart` | Cloudinary cloud name + upload preset |
| `lib/core/providers/auth_provider.dart` | Google Web Client ID |
| `lib/core/services/secrets.dart` | Gemini API key (**gitignored**) |

> ⚠️ `secrets.dart` is listed in `.gitignore` and will not be committed. All other config files are safe for a private repo.

---

## Database Schema

Run `supabase/schema.sql` in Supabase SQL Editor to create all tables.

### Tables

| Table | Purpose |
|-------|---------|
| `profiles` | One row per auth user. Role (pregnant/parent/family), due date, name |
| `babies` | Baby profiles. Linked to user. Supports born + unborn (due_date) |
| `milestones` | Milestone tracking per baby. Category, status, achieved date |
| `milestone_definitions` | 60+ master milestone templates |
| `memories` | Memory diary entries. Cloudinary image URL, caption, tag, date |
| `vaccinations` | Vaccination schedule per baby. Indian immunisation schedule |

### RLS Policy Summary
- All tables have RLS enabled
- Users can only read/write rows where `user_id = auth.uid()`
- Milestones and vaccinations check via baby ownership
- Auto-create profile trigger fires on `auth.users` insert

---

## Key Dependencies

```yaml
supabase_flutter: ^2.8.4        # Auth + DB + Storage
google_sign_in: ^6.2.2          # Native Google account picker
cloudinary_public: ^0.23.1      # Unsigned image uploads
flutter_riverpod: ^2.6.1        # State management
http: ^1.6.0                    # Gemini REST API calls (google_generative_ai SDK dropped)
google_fonts: ^6.2.1            # Nunito font
image_picker: ^1.1.2            # Camera + gallery access
image_cropper: ^8.0.2           # Crop before upload
share_plus: ^10.1.4             # Share recipe text
shimmer: ^3.0.0                 # Loading skeleton (installed, not yet wired)
smooth_page_indicator: ^1.2.0   # Carousel dots
percent_indicator: ^4.2.3       # Progress rings/bars
cached_network_image: ^3.4.1    # Network image caching
flutter_secure_storage: ^9.2.4  # Session persistence (Android Keystore)
flutter_svg: ^2.0.17            # Google logo SVG
go_router: ^14.8.1              # Installed, not yet wired (planned for deep links)
intl: ^0.20.2                   # Date formatting
```

> **Note:** `google_generative_ai` was removed — it targets the deprecated v1beta endpoint. `GeminiService` calls the Gemini REST API directly via `http`.

---

*Built with Flutter 💙 | Powered by Supabase + Cloudinary + Gemini*
