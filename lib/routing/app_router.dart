import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../screens/auth/login_screen.dart';
import '../screens/home/home_screen.dart';
import '../screens/onboarding/onboarding_screen.dart';
import '../services/auth_service.dart';

final routerProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: '/',
    refreshListenable: _AuthChangeNotifier(AuthService.authChanges),
    redirect: (context, state) {
      final loggedIn = AuthService.currentSession != null;
      final loc = state.matchedLocation;
      final atAuth = loc == '/auth';

      if (!loggedIn && !atAuth) return '/auth';
      if (loggedIn && atAuth) return '/';
      return null;
    },
    routes: [
      GoRoute(path: '/',           builder: (_, _) => const HomeScreen()),
      GoRoute(path: '/auth',       builder: (_, _) => const LoginScreen()),
      GoRoute(path: '/onboarding', builder: (_, _) => const OnboardingScreen()),
    ],
  );
});

class _AuthChangeNotifier extends ChangeNotifier {
  _AuthChangeNotifier(Stream stream) {
    _sub = stream.listen((_) => notifyListeners());
  }
  late final StreamSubscription _sub;
  @override
  void dispose() {
    _sub.cancel();
    super.dispose();
  }
}
