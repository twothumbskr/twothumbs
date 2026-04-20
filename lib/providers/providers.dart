import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../services/auth_service.dart';
import '../services/profile_service.dart';

final authStateProvider = StreamProvider<AuthState>((ref) {
  return AuthService.authChanges;
});

final currentUserProvider = Provider<User?>((ref) {
  ref.watch(authStateProvider);
  return AuthService.currentUser;
});

final profileProvider = FutureProvider.autoDispose<Map<String, dynamic>?>((ref) async {
  final user = ref.watch(currentUserProvider);
  if (user == null) return null;
  return ProfileService.fetchCurrent();
});
