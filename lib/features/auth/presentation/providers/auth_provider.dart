import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

final supabaseClientProvider = Provider<SupabaseClient>((ref) {
  return Supabase.instance.client;
});

final authStateProvider = StreamProvider<User?>((ref) {
  final client = ref.watch(supabaseClientProvider);
  return client.auth.onAuthStateChange.map((event) => event.session?.user);
});

final currentUserProvider = Provider<User?>((ref) {
  return ref.watch(authStateProvider).valueOrNull;
});

class AuthNotifier extends StateNotifier<AsyncValue<void>> {
  final SupabaseClient _client;

  AuthNotifier(this._client) : super(const AsyncValue.data(null));

  Future<void> signInWithEmail(String email, String password) async {
    debugPrint('🔐 [AuthProvider] signInWithEmail started — email: $email');
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      await _client.auth.signInWithPassword(email: email, password: password);
      debugPrint('✅ [AuthProvider] signInWithEmail success');
    });
    if (state.hasError) {
      debugPrint('❌ [AuthProvider] signInWithEmail error: ${state.error}');
    }
  }

  Future<void> signUpWithEmail(String email, String password, String name) async {
    debugPrint('🔐 [AuthProvider] signUpWithEmail started — email: $email, name: $name');
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      await _client.auth.signUp(
        email: email,
        password: password,
        data: {'display_name': name},
      );
      debugPrint('✅ [AuthProvider] signUpWithEmail success');
    });
    if (state.hasError) {
      debugPrint('❌ [AuthProvider] signUpWithEmail error: ${state.error}');
    }
  }

  Future<void> signInWithGoogle() async {
    debugPrint('🔐 [AuthProvider] signInWithGoogle started');
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      await _client.auth.signInWithOAuth(OAuthProvider.google);
      debugPrint('✅ [AuthProvider] signInWithGoogle success');
    });
    if (state.hasError) {
      debugPrint('❌ [AuthProvider] signInWithGoogle error: ${state.error}');
    }
  }

  Future<void> resetPassword(String email) async {
    debugPrint('🔐 [AuthProvider] resetPassword started — email: $email');
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      await _client.auth.resetPasswordForEmail(email);
      debugPrint('✅ [AuthProvider] resetPassword success');
    });
    if (state.hasError) {
      debugPrint('❌ [AuthProvider] resetPassword error: ${state.error}');
    }
  }

  Future<void> signOut() async {
    debugPrint('🔐 [AuthProvider] signOut started');
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      await _client.auth.signOut();
      debugPrint('✅ [AuthProvider] signOut success');
    });
    if (state.hasError) {
      debugPrint('❌ [AuthProvider] signOut error: ${state.error}');
    }
  }
}

final authNotifierProvider =
    StateNotifierProvider<AuthNotifier, AsyncValue<void>>((ref) {
  final client = ref.watch(supabaseClientProvider);
  return AuthNotifier(client);
});
