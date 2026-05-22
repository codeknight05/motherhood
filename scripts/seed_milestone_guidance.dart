// ignore_for_file: avoid_print

// One-time seed script guide for the Supabase milestone_guidance table.
//
// Run from the project root:
//   dart run scripts/seed_milestone_guidance.dart
//
// Prerequisites:
//   1. Create the table in Supabase SQL editor (see README or PROJECT_CONTEXT.md)
//   2. Set SUPABASE_URL and SUPABASE_SERVICE_KEY environment variables
//      (use the SERVICE ROLE key, not the anon key — it bypasses RLS)

import 'dart:io';

// ── Inline the model + library data here so the script is self-contained ──────
// We re-use the same JSON structure that CategoryGuidance.toJson() produces.

void main() async {
  final url = Platform.environment['SUPABASE_URL'];
  final key = Platform.environment['SUPABASE_SERVICE_KEY'];

  if (url == null || key == null) {
    print(
      'ERROR: Set SUPABASE_URL and SUPABASE_SERVICE_KEY environment variables.',
    );
    print('Example:');
    print('  \$env:SUPABASE_URL="https://your-project.supabase.co"');
    print('  \$env:SUPABASE_SERVICE_KEY="your-service-role-key"');
    exit(1);
  }

  print('Seeding milestone_guidance table...');
  print('URL: $url');

  // Import the Flutter app's library by running flutter pub run instead
  // This script is a guide — the actual seeding is done via the in-app
  // admin screen (MilestoneGuidanceSeedScreen) which calls
  // MilestoneGuidanceService.seedFromLibrary()
  print('');
  print('NOTE: This script is a placeholder.');
  print('To seed the database, use the in-app seed screen:');
  print('  1. Run the app in debug mode');
  print('  2. Navigate to Profile → Developer → Seed Milestone Guidance');
  print('  3. Tap "Seed Now"');
  print('');
  print('This will upload all 114 guidance pages (19 bands × 6 categories)');
  print('to your Supabase milestone_guidance table.');
}
