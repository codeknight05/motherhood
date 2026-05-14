import 'dart:io';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Central access point for the Supabase client.
class SupabaseService {
  SupabaseService._();

  static SupabaseClient get client => Supabase.instance.client;
  static GoTrueClient get auth => client.auth;

  // ── Auth helpers ──────────────────────────────────────────────────────────

  static User? get currentUser => auth.currentUser;
  static bool get isLoggedIn => currentUser != null;

  static Stream<AuthState> get authStateChanges => auth.onAuthStateChange;

  /// Sign in with Google via Supabase OAuth.
  static Future<void> signInWithGoogle() async {
    await auth.signInWithOAuth(
      OAuthProvider.google,
      redirectTo: 'io.supabase.motherhood://login-callback',
    );
  }

  /// Sign in with email + password.
  static Future<AuthResponse> signInWithEmail(String email, String password) {
    return auth.signInWithPassword(email: email, password: password);
  }

  /// Sign up with email + password.
  static Future<AuthResponse> signUpWithEmail(String email, String password) {
    return auth.signUp(email: email, password: password);
  }

  /// Send OTP to phone number (E.164 format: +91XXXXXXXXXX).
  static Future<void> signInWithPhone(String phone) {
    return auth.signInWithOtp(phone: phone);
  }

  /// Verify phone OTP.
  static Future<AuthResponse> verifyPhoneOtp(String phone, String token) {
    return auth.verifyOTP(
      phone: phone,
      token: token,
      type: OtpType.sms,
    );
  }

  /// Sign out.
  static Future<void> signOut() => auth.signOut();

  // ── Database helpers ──────────────────────────────────────────────────────

  /// Upsert a user profile row after sign-up / first login.
  static Future<void> upsertProfile({
    required String userId,
    String? fullName,
    String? avatarUrl,
    String? phone,
  }) async {
    await client.from('profiles').upsert({
      'id': userId,
      if (fullName != null) 'full_name': fullName,
      if (avatarUrl != null) 'avatar_url': avatarUrl,
      if (phone != null) 'phone': phone,
      'updated_at': DateTime.now().toIso8601String(),
    });
  }

  /// Fetch the profile for the current user.
  static Future<Map<String, dynamic>?> fetchProfile(String userId) async {
    final res = await client
        .from('profiles')
        .select()
        .eq('id', userId)
        .maybeSingle();
    return res;
  }

  /// Insert a new baby profile.
  static Future<Map<String, dynamic>> createBaby({
    required String userId,
    required String name,
    required DateTime birthDate,
    String gender = 'girl',
    double? heightCm,
    double? weightKg,
  }) async {
    final res = await client.from('babies').insert({
      'user_id': userId,
      'name': name,
      'birth_date': birthDate.toIso8601String().split('T').first,
      'gender': gender,
      if (heightCm != null) 'height_cm': heightCm,
      if (weightKg != null) 'weight_kg': weightKg,
    }).select().single();
    return res;
  }

  /// Fetch all babies for the current user.
  static Future<List<Map<String, dynamic>>> fetchBabies(String userId) async {
    final res = await client
        .from('babies')
        .select()
        .eq('user_id', userId)
        .order('created_at');
    return List<Map<String, dynamic>>.from(res);
  }

  // ── Storage helpers ───────────────────────────────────────────────────────

  /// Upload a memory photo and return its public URL.
  static Future<String> uploadMemoryPhoto({
    required String userId,
    required String babyId,
    required File file,
  }) async {
    final ext = file.path.split('.').last;
    final path = '$userId/$babyId/${DateTime.now().millisecondsSinceEpoch}.$ext';

    await client.storage.from('memories').upload(
      path,
      file,
      fileOptions: const FileOptions(cacheControl: '3600', upsert: false),
    );

    return client.storage.from('memories').getPublicUrl(path);
  }

  /// Upload a baby avatar and return its public URL.
  static Future<String> uploadBabyAvatar({
    required String babyId,
    required File file,
  }) async {
    final ext = file.path.split('.').last;
    final path = 'avatars/$babyId.$ext';

    await client.storage.from('babies').upload(
      path,
      file,
      fileOptions: const FileOptions(cacheControl: '3600', upsert: true),
    );

    return client.storage.from('babies').getPublicUrl(path);
  }
}
