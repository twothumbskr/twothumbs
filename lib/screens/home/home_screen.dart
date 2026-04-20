import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../providers/providers.dart';
import '../../services/auth_service.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profile = ref.watch(profileProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('TwoThumbs'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () => AuthService.signOut(),
          ),
        ],
      ),
      body: profile.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
        data: (p) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text('👍👍', style: TextStyle(fontSize: 64)),
              const SizedBox(height: 16),
              const Text('Korean Food Guide',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600)),
              const SizedBox(height: 24),
              if (p != null)
                Text('Welcome, ${p['country_code']} · ${p['occupation']}',
                    style: const TextStyle(color: Colors.grey)),
            ],
          ),
        ),
      ),
    );
  }
}
