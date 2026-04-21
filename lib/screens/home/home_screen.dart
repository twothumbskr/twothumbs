import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../models/restaurant.dart';
import '../../services/auth_service.dart';
import '../../services/restaurant_service.dart';
import '../../widgets/restaurant_card.dart';
import 'map_view.dart';

final _listProvider = FutureProvider.autoDispose
    .family<List<(Restaurant, RestaurantStats)>, bool>((ref, halalOnly) async {
  final restaurants = await RestaurantService.list(halalOnly: halalOnly);
  final stats = await Future.wait(
    restaurants.map((r) => RestaurantService.statsFor(r.id)),
  );
  return [for (var i = 0; i < restaurants.length; i++) (restaurants[i], stats[i])];
});

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  int _tabIndex = 0;

  @override
  Widget build(BuildContext context) {
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
      body: IndexedStack(
        index: _tabIndex,
        children: const [
          _ListBody(),
          MapView(),
        ],
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _tabIndex,
        onDestinationSelected: (i) => setState(() => _tabIndex = i),
        destinations: const [
          NavigationDestination(icon: Icon(Icons.list), label: 'List'),
          NavigationDestination(icon: Icon(Icons.map_outlined), label: 'Map'),
        ],
      ),
    );
  }
}

class _ListBody extends ConsumerStatefulWidget {
  const _ListBody();

  @override
  ConsumerState<_ListBody> createState() => _ListBodyState();
}

class _ListBodyState extends ConsumerState<_ListBody> {
  bool _halalOnly = false;

  @override
  Widget build(BuildContext context) {
    final async = ref.watch(_listProvider(_halalOnly));

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          child: Row(
            children: [
              FilterChip(
                label: const Text('🕌 Halal'),
                selected: _halalOnly,
                onSelected: (v) => setState(() => _halalOnly = v),
              ),
            ],
          ),
        ),
        Expanded(
          child: async.when(
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (e, _) => Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Text('Error loading restaurants:\n$e',
                    textAlign: TextAlign.center),
              ),
            ),
            data: (items) {
              if (items.isEmpty) {
                return const _EmptyState();
              }
              return RefreshIndicator(
                onRefresh: () async =>
                    ref.invalidate(_listProvider(_halalOnly)),
                child: ListView.builder(
                  padding: const EdgeInsets.only(bottom: 16),
                  itemCount: items.length,
                  itemBuilder: (_, i) {
                    final (r, s) = items[i];
                    return RestaurantCard(
                      restaurant: r,
                      stats: s,
                      onTap: () => context.push('/restaurant/${r.id}'),
                    );
                  },
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('🍽️', style: TextStyle(fontSize: 64)),
            const SizedBox(height: 16),
            const Text('No restaurants yet',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
            const SizedBox(height: 8),
            Text(
              'Seed data will be added soon.\nPull to refresh.',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey.shade600),
            ),
          ],
        ),
      ),
    );
  }
}
