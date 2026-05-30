import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../services/supabase_service.dart';

// ── Current session ───────────────────────────────────────────────────────────

final sessionProvider = StreamProvider<Session?>((ref) {
  return SupabaseService.authStateChanges.map((state) => state.session);
});

final isAuthenticatedProvider = Provider<bool>((ref) {
  final session = ref.watch(sessionProvider);
  return session.maybeWhen(data: (s) => s != null, orElse: () => false);
});

final currentUserProvider = Provider<User?>((ref) {
  final session = ref.watch(sessionProvider);
  return session.maybeWhen(data: (s) => s?.user, orElse: () => null);
});

// ── Auth state ────────────────────────────────────────────────────────────────

enum AuthStatus { idle, loading, success, error }

class AuthState {
  final AuthStatus status;
  final String? errorMessage;

  const AuthState({this.status = AuthStatus.idle, this.errorMessage});

  AuthState copyWith({AuthStatus? status, String? errorMessage}) =>
      AuthState(
        status: status ?? this.status,
        errorMessage: errorMessage ?? this.errorMessage,
      );

  bool get isLoading => status == AuthStatus.loading;
  bool get hasError => status == AuthStatus.error;
}

// ── Auth notifier ─────────────────────────────────────────────────────────────

class AuthNotifier extends StateNotifier<AuthState> {
  AuthNotifier() : super(const AuthState());

  // ── Email ──────────────────────────────────────────────────────────────────

  Future<bool> signInWithEmail(String email, String password) async {
    state = const AuthState(status: AuthStatus.loading);
    try {
      await SupabaseService.signInWithEmail(email, password);
      state = const AuthState(status: AuthStatus.success);
      return true;
    } on AuthException catch (e) {
      state = AuthState(status: AuthStatus.error, errorMessage: e.message);
      return false;
    } catch (_) {
      state = const AuthState(
          status: AuthStatus.error,
          errorMessage: 'Something went wrong. Please try again.');
      return false;
    }
  }

  Future<bool> signUpWithEmail(String email, String password) async {
    state = const AuthState(status: AuthStatus.loading);
    try {
      final response = await SupabaseService.signUpWithEmail(email, password);
      // If session is null, email confirmation is required
      if (response.session == null) {
        state = const AuthState(
          status: AuthStatus.error,
          errorMessage: 'Check your email to confirm your account, then sign in.',
        );
        return false;
      }
      state = const AuthState(status: AuthStatus.success);
      return true;
    } on AuthException catch (e) {
      state = AuthState(status: AuthStatus.error, errorMessage: e.message);
      return false;
    } catch (_) {
      state = const AuthState(
          status: AuthStatus.error,
          errorMessage: 'Something went wrong. Please try again.');
      return false;
    }
  }

  // ── Google (native flow — works on Android & iOS without browser) ──────────

  Future<bool> signInWithGoogle() async {
    state = const AuthState(status: AuthStatus.loading);
    try {
      // Step 1: trigger native Google account picker
      const webClientId =
          '80123756166-4vkb4t78pl7pt6gpcd9dmmhooheqrvit.apps.googleusercontent.com';

      final googleSignIn = GoogleSignIn(
        serverClientId: webClientId,
        scopes: ['email', 'profile'],
      );

      final googleUser = await googleSignIn.signIn();
      if (googleUser == null) {
        // User cancelled
        state = const AuthState();
        return false;
      }

      // Step 2: get auth tokens
      final googleAuth = await googleUser.authentication;
      final idToken = googleAuth.idToken;
      final accessToken = googleAuth.accessToken;

      if (idToken == null) {
        state = const AuthState(
            status: AuthStatus.error,
            errorMessage: 'Google sign-in failed. No ID token received.');
        return false;
      }

      // Step 3: sign in to Supabase with the Google tokens
      await SupabaseService.client.auth.signInWithIdToken(
        provider: OAuthProvider.google,
        idToken: idToken,
        accessToken: accessToken,
      );

      // Small delay to let the session propagate
      await Future.delayed(const Duration(milliseconds: 300));

      state = const AuthState(status: AuthStatus.success);
      return true;
    } on AuthException catch (e) {
      debugPrint('AuthException during Google sign-in: ${e.message} (${e.statusCode})');
      state = AuthState(status: AuthStatus.error, errorMessage: e.message);
      return false;
    } catch (e, stack) {
      debugPrint('Unexpected error during Google sign-in: $e');
      debugPrint('Stack: $stack');
      state = AuthState(
          status: AuthStatus.error,
          errorMessage: 'Google sign-in failed: $e');
      return false;
    }
  }

  // ── Sign out ───────────────────────────────────────────────────────────────

  Future<void> signOut() async {
    await SupabaseService.signOut();
    state = const AuthState();
  }

  void clearError() => state = const AuthState();
}

final authNotifierProvider =
    StateNotifierProvider<AuthNotifier, AuthState>((_) => AuthNotifier());
