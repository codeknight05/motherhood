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
| Fonts | Google Fonts (Nunito) | Warm, rounded, readable |
| Navigation | IndexedStack + Navigator | Simple tab navigation without over-engineering |

---

## Architecture

```
lib/
├── core/
│   ├── constants/        # Spacing, sizing, app name
│   ├── providers/        # Riverpod state (auth, baby)
│   ├── services/         # Supabase, Cloudinary service layers
│   ├── theme/            # Colors, text styles, app theme
│   └── widgets/          # Shared widgets (AppCard, BabyAvatar, etc.)
├── features/
│   ├── auth/             # Splash, Login screens
│   ├── community/        # Community screen
│   ├── food_menu/        # Food Menu screen
│   ├── home/             # Home dashboard
│   ├── learn/            # Learn / articles screen
│   ├── memories/         # Standalone memory screen (legacy)
│   ├── milestones/       # Baby Journey (Milestones + Memory Diary)
│   ├── onboarding/       # Role-based baby setup
│   └── profile/          # User profile, edit, sign out
├── models/               # BabyModel, MemoryModel, MilestoneModel
└── main.dart
```

**Pattern used:** Feature-first folder structure. Each feature owns its presentation layer. Shared logic lives in `core/`. Models are plain Dart classes with no framework dependency.

---

## Features Completed

### ✅ Foundation
- Flutter project configured for Android, iOS, and Web
- App theme with Nunito font, purple/pastel color palette, consistent spacing system
- 5-tab bottom navigation shell with elevated center "Journey" button

### ✅ Screens (UI)
- **Home** — Baby profile card, tips carousel with page indicator, quick action grid, milestone progress ring, recommended content
- **Food Menu** — Age group selector, today's picks, weekly meal plan, nutrition tip, popular categories
- **Community** — Hero banner, communities list with online count, popular discussions, browse by topics
- **Learn** — Category grid, featured articles, expert video picks, trending topics
- **Baby Journey** — Tabbed screen combining Milestones and Memory Diary

### ✅ Baby Journey — Milestones Tab
- Age group selector (0–3M, 4–6M, 7–9M, 10–12M, 1–2Y)
- Animated age group banner with description
- Overall progress bar with percentage
- Development area cards (Gross Motor, Fine Motor, Language, Social & Emotional, Cognitive)
- Status dots per milestone (achieved / in progress / not started)
- Encouragement card

### ✅ Baby Journey — Memory Diary Tab
- Photo grid grouped by month
- Filter chips (All, Milestone, First Time, Everyday, Special, Funny, Growth)
- Stats row (total memories, age in months, milestone count)
- Add Memory FAB → camera or gallery picker
- Caption input + tag selector
- Full-screen photo viewer with pinch-to-zoom, share button
- **Cloudinary upload** — photos stored in cloud, not local device
- **Supabase persistence** — memory metadata saved to DB, loaded on tab open

### ✅ Authentication
- Email sign up with confirm password validation
- Email sign in
- Google Sign-In (native Android flow using `google_sign_in` + Supabase `signInWithIdToken`)
- Session persistence via `flutter_secure_storage` (Android Keystore)
- Splash screen reads persisted session — no re-login on app restart

### ✅ Onboarding (Role-Based)
- Step 1: Who are you? — Pregnant / I have a baby / Family member
- **Pregnant** → Due date picker, pregnancy week card (no gender question)
- **Parent** → Baby photo, name (optional), birth date, gender, height, weight
- **Family** → Skips baby setup entirely, goes straight to Home
- Role and due date saved to Supabase `profiles` table

### ✅ Real Data Integration
- `babyProvider` (Riverpod StateNotifier) loads baby from Supabase on app start
- Home, Food Menu, Baby Journey screens all read from `babyProvider`
- Baby name, age string, birth date, height, weight shown from real DB data
- Fallback to `sampleBaby` while loading (prevents null crashes)

### ✅ Profile Screen
- User card with Google avatar / initial fallback, email, provider badge
- Baby details card (name, age, birth date, height, weight, gender)
- Edit Profile — update display name via Supabase auth metadata
- Edit Baby Details — update name, height, weight in Supabase
- **Reset & Start Over** — deletes all baby data (cascades to milestones, memories, vaccinations), resets role, returns to onboarding
- **Delete All My Data** — deletes profile + all data, signs out permanently
- Sign Out — clears session and local state

### ✅ Backend (Supabase)
- `profiles` table — user role, due date, full name, avatar
- `babies` table — name, birth date, due date, gender, height, weight
- `milestones` table — category, title, status, achieved date
- `memories` table — image URL, caption, tag, age months, date
- `vaccinations` table — vaccine name, due date, given date
- Row Level Security (RLS) on all tables — users can only access their own data
- Auto-create profile trigger on sign-up
- Storage buckets for memories and baby avatars

### ✅ Cloud Storage (Cloudinary)
- Cloud Name: `dpfowxtg2`
- Upload Preset: `motherhood_memories` (unsigned, folder: `motherhood`)
- Photos organised as `motherhood/{userId}/{babyId}/{timestamp}.jpg`
- Auto-compression and CDN delivery via `thumbnailUrl()` helper
- 25GB free storage — sufficient for thousands of baby photos

### ✅ Version Control
- Private GitHub repository: `ShriHarsh05/motherhood`
- `.gitignore` configured for Flutter + Android keystores

---

## Features Pending

### 🔲 High Priority
- [ ] **Vaccination Tracker screen** — schedule, due dates, given dates, reminders
- [ ] **AI Chat (Ask MotherHood)** — Gemini API powered assistant for meal suggestions, parenting questions, food safety checks
- [ ] **Loading shimmer placeholders** — while fetching baby data, memories, milestones
- [ ] **Empty states** — when no milestones, memories, or data exists yet

### 🔲 Medium Priority
- [ ] **Indian meal recommendations** — rule-based engine first (pregnancy week / baby age → meal suggestions), AI second
- [ ] **Food safety checker** — "Can I eat papaya?" type queries via Gemini
- [ ] **Pregnancy tracking module** — different home screen for pregnant users (week-by-week updates, symptom tracker)
- [ ] **Real milestones from DB** — currently using sample data; needs Supabase integration
- [ ] **Push notifications** — vaccination reminders, milestone prompts, daily tips

### 🔲 Lower Priority
- [ ] **App icon + splash branding** — custom MotherHood icon
- [ ] **Subscription screen** — free vs premium feature gating
- [ ] **Razorpay integration** — UPI, cards, net banking
- [ ] **Product recommendations** — Amazon affiliate links based on baby age
- [ ] **Multiple babies** — add/switch between babies
- [ ] **Regional language support** — Hindi, Tamil, Telugu, Gujarati

---

## Approaches & Decisions

### State Management — Riverpod over Provider/Bloc
**Decision:** Riverpod 2.x with `StateNotifier`

**Why:** Provider is being deprecated in favour of Riverpod by the same author. Bloc adds too much boilerplate for an MVP. Riverpod gives compile-safe providers, easy testing, and `ref.watch` / `ref.read` that work cleanly in both widgets and services.

**How it's used:**
- `babyProvider` — holds the current baby, loads from Supabase, used across all screens
- `authNotifierProvider` — handles sign in/up/out state with loading and error states
- `sessionProvider` — stream of Supabase auth state changes

---

### Navigation — IndexedStack over GoRouter
**Decision:** `IndexedStack` for tabs, `Navigator.push` for sub-screens

**Why:** GoRouter adds complexity (route definitions, path parameters, redirects) that isn't needed at this stage. `IndexedStack` keeps all tab screens alive in memory (no rebuild on tab switch), which is the correct behaviour for a tab-based app. GoRouter will be added when deep linking is needed (e.g. notification taps opening specific screens).

---

### Backend — Supabase over Firebase
**Decision:** Supabase for auth, database, and storage

**Why:**
- PostgreSQL is more powerful than Firestore for relational data (babies → milestones → memories)
- Row Level Security (RLS) enforces data isolation at the DB level — more secure than client-side rules
- Single platform for auth + DB + storage
- Open source and self-hostable if needed later
- Free tier: 500MB DB, 1GB storage, 50MB file uploads

**Trade-off:** Supabase storage is limited to 1GB on free tier, which is why Cloudinary was added for photos.

---

### Image Storage — Cloudinary over Supabase Storage
**Decision:** Cloudinary for all user-uploaded photos

**Why:** Supabase free tier gives only 1GB total storage across all users — a photo diary app would exhaust this quickly. Cloudinary gives 25GB free with:
- Auto image compression (reduces file size by 60–80%)
- CDN delivery (fast loading globally)
- On-the-fly transformations (thumbnails, cropping)
- Permanent URLs that survive app reinstalls

**How it works:** Photo → upload to Cloudinary → get HTTPS URL → store URL in Supabase `memories` table.

---

### Auth — Native Google Sign-In over OAuth Redirect
**Decision:** `google_sign_in` package + `signInWithIdToken` instead of Supabase OAuth redirect

**Why:** Supabase's `signInWithOAuth(OAuthProvider.google)` opens a browser tab, which feels jarring on mobile. The native flow (`google_sign_in` → get ID token → pass to Supabase) shows the native Google account picker sheet, which is the standard Android UX.

**Setup required:**
- Web OAuth client ID (for Supabase)
- Android OAuth client ID (registered with SHA-1 fingerprint)
- Both client IDs added to Supabase Google provider settings
- "Skip nonce checks" enabled in Supabase (required for Android native flow)

---

### Onboarding — Role-Based over Single Flow
**Decision:** Three distinct user roles with branching onboarding

**Why:** The app targets pregnant women, parents with babies, and family members. Forcing all users through a baby setup screen would confuse pregnant users (no baby name yet) and family members (not their baby). Role selection on step 1 branches to the appropriate setup.

- **Pregnant** → due date only (no baby name/gender — unknown)
- **Parent** → full baby details (name optional, birth date required)
- **Family** → skip setup entirely

---

### Font — Nunito via Google Fonts
**Decision:** Nunito loaded at runtime via `google_fonts` package

**Why:** Nunito's rounded letterforms match the warm, friendly tone of the app. Loading via `google_fonts` avoids bundling font files in the APK (saves ~500KB). The package caches fonts after first download.

**Trade-off:** First launch requires internet to download the font. Subsequent launches use the cache.

---

## Alternatives Considered

| Decision | Chosen | Alternatives Considered | Why Not Chosen |
|----------|--------|------------------------|----------------|
| State management | Riverpod | Provider, Bloc, GetX | Provider deprecated; Bloc too verbose; GetX anti-pattern |
| Backend | Supabase | Firebase, PocketBase, Appwrite | Firebase adds Google dependency; PocketBase needs self-hosting; Appwrite less mature |
| Image storage | Cloudinary | Firebase Storage, Backblaze B2, ImgBB | Firebase = second backend; Backblaze = complex setup; ImgBB = no privacy |
| Auth (Google) | Native `google_sign_in` | Supabase OAuth redirect | Browser redirect feels jarring on mobile |
| Navigation | IndexedStack | GoRouter, AutoRoute | GoRouter overkill for current stage; AutoRoute adds code generation |
| Database | PostgreSQL (Supabase) | Firestore, SQLite (local) | Firestore = NoSQL, harder for relational data; SQLite = no sync across devices |
| Phone auth | Removed | Twilio via Supabase | Twilio requires paid account; not needed for MVP |

---

## Project Structure

```
motherhood/
├── android/                    # Android native config
│   └── app/
│       ├── build.gradle.kts    # manifestPlaceholders for OAuth
│       └── src/main/
│           └── AndroidManifest.xml  # Camera, storage permissions, deep link
├── assets/
│   └── icons/
│       └── google_logo.svg     # Google G logo for login button
├── lib/
│   ├── core/
│   │   ├── constants/app_constants.dart
│   │   ├── providers/
│   │   │   ├── auth_provider.dart      # Auth state + Google sign-in
│   │   │   └── baby_provider.dart      # Baby CRUD + Supabase sync
│   │   ├── services/
│   │   │   ├── cloudinary_service.dart # Photo upload + thumbnail URLs
│   │   │   ├── supabase_config.dart    # Project URL + anon key
│   │   │   └── supabase_service.dart   # DB + storage helpers
│   │   ├── theme/
│   │   │   ├── app_colors.dart         # Full color palette
│   │   │   ├── app_text_styles.dart    # Nunito text styles
│   │   │   └── app_theme.dart          # MaterialApp theme
│   │   └── widgets/
│   │       ├── app_card.dart
│   │       ├── baby_avatar.dart
│   │       ├── main_shell.dart         # Bottom nav + IndexedStack
│   │       └── section_header.dart
│   ├── features/
│   │   ├── auth/presentation/
│   │   │   ├── login_screen.dart       # Email + Google login/signup
│   │   │   └── splash_screen.dart      # Session check + routing
│   │   ├── community/presentation/community_screen.dart
│   │   ├── food_menu/presentation/food_menu_screen.dart
│   │   ├── home/presentation/home_screen.dart
│   │   ├── learn/presentation/learn_screen.dart
│   │   ├── milestones/presentation/
│   │   │   ├── baby_journey_screen.dart  # Milestones + Memory Diary
│   │   │   └── milestones_screen.dart    # Re-export
│   │   ├── onboarding/presentation/baby_setup_screen.dart
│   │   └── profile/presentation/profile_screen.dart
│   ├── models/
│   │   ├── baby_model.dart       # Supports born + unborn babies
│   │   ├── memory_model.dart     # MemoryEntry + MemoryTag
│   │   └── milestone_model.dart  # MilestoneCategoryProgress
│   └── main.dart                 # Supabase init + ProviderScope
├── supabase/
│   ├── schema.sql                # Full DB schema + RLS + triggers
│   ├── add_role_migration.sql    # Added role, due_date to profiles
│   └── add_due_date_to_babies.sql
├── pubspec.yaml
└── README.md
```

---

## Setup & Running

### Prerequisites
- Flutter SDK 3.x
- Android Studio / VS Code with Flutter extension
- A physical Android device or emulator (API 21+)

### Steps

```bash
# 1. Clone the repo
git clone https://github.com/ShriHarsh05/motherhood.git
cd motherhood

# 2. Install dependencies
flutter pub get

# 3. Run on device
flutter run
```

### Building APK

```bash
flutter build apk --debug
# Output: build/app/outputs/flutter-apk/app-debug.apk
```

---

## Environment Configuration

All configuration is in source files (safe for private repo):

| File | Contains |
|------|---------|
| `lib/core/services/supabase_config.dart` | Supabase project URL + anon key |
| `lib/core/services/cloudinary_service.dart` | Cloudinary cloud name + upload preset |
| `lib/core/providers/auth_provider.dart` | Google Web Client ID |

> ⚠️ If making this repo public, move these values to a `.env` file and add it to `.gitignore`.

---

## Database Schema

Run `supabase/schema.sql` in Supabase SQL Editor to create all tables.

### Tables

| Table | Purpose |
|-------|---------|
| `profiles` | One row per auth user. Role (pregnant/parent/family), due date, name |
| `babies` | Baby profiles. Linked to user. Supports born + unborn (due_date) |
| `milestones` | Milestone tracking per baby. Category, status, achieved date |
| `memories` | Memory diary entries. Cloudinary image URL, caption, tag, date |
| `vaccinations` | Vaccination schedule per baby |

### RLS Policy Summary
- All tables have RLS enabled
- Users can only read/write rows where `user_id = auth.uid()`
- Milestones and vaccinations check via baby ownership
- Auto-create profile trigger fires on `auth.users` insert

---

## Key Dependencies

```yaml
supabase_flutter: ^2.8.4      # Auth + DB + Storage
google_sign_in: ^6.2.2        # Native Google account picker
cloudinary_public: ^0.23.1    # Unsigned image uploads
flutter_riverpod: ^2.6.1      # State management
google_fonts: ^6.2.1          # Nunito font
image_picker: ^1.1.2          # Camera + gallery access
smooth_page_indicator: ^1.2.0 # Carousel dots
flutter_svg: ^2.0.17          # Google logo SVG
intl: ^0.20.2                 # Date formatting
```

---

## Contributing

This is a private project. For questions or collaboration, contact the repository owner.

---

*Built with Flutter 💙 | Powered by Supabase + Cloudinary*
