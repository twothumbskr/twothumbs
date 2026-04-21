import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import '../../models/restaurant.dart';
import '../../services/restaurant_service.dart';
import '../../widgets/halal_badge.dart';
import '../../widgets/thumbs_rating.dart';

final _mapRestaurantsProvider = FutureProvider.autoDispose<
    List<(Restaurant, RestaurantStats)>>((ref) async {
  final restaurants = await RestaurantService.list(limit: 500);
  final stats = await Future.wait(
    restaurants.map((r) => RestaurantService.statsFor(r.id)),
  );
  return [for (var i = 0; i < restaurants.length; i++) (restaurants[i], stats[i])];
});

class MapView extends ConsumerStatefulWidget {
  const MapView({super.key});

  @override
  ConsumerState<MapView> createState() => _MapViewState();
}

class _MapViewState extends ConsumerState<MapView> {
  static const _seoulCenter = CameraPosition(
    target: LatLng(37.5665, 126.9780),
    zoom: 11.5,
  );

  @override
  Widget build(BuildContext context) {
    final async = ref.watch(_mapRestaurantsProvider);

    return async.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Text('Map error:\n$e', textAlign: TextAlign.center),
        ),
      ),
      data: (items) {
        final markers = <Marker>{};
        for (final (r, s) in items) {
          if (r.lat == null || r.lng == null) continue;
          markers.add(
            Marker(
              markerId: MarkerId(r.id),
              position: LatLng(r.lat!, r.lng!),
              icon: r.isHalal
                  ? BitmapDescriptor.defaultMarkerWithHue(
                      BitmapDescriptor.hueGreen)
                  : BitmapDescriptor.defaultMarker,
              onTap: () => _showPreview(r, s),
            ),
          );
        }

        return GoogleMap(
          initialCameraPosition: _seoulCenter,
          markers: markers,
          myLocationButtonEnabled: false,
          compassEnabled: true,
        );
      },
    );
  }

  void _showPreview(Restaurant r, RestaurantStats s) {
    showModalBottomSheet(
      context: context,
      showDragHandle: true,
      builder: (sheetCtx) => _RestaurantPreviewSheet(restaurant: r, stats: s),
    );
  }
}

class _RestaurantPreviewSheet extends StatelessWidget {
  final Restaurant restaurant;
  final RestaurantStats stats;
  const _RestaurantPreviewSheet({required this.restaurant, required this.stats});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 4, 16, 16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Text(
                    restaurant.name,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                if (restaurant.isHalal) ...[
                  const SizedBox(width: 8),
                  HalalBadge(certType: restaurant.halalCertType, compact: true),
                ],
              ],
            ),
            if (restaurant.category != null)
              Padding(
                padding: const EdgeInsets.only(top: 2),
                child: Text(
                  restaurant.category!,
                  style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
                ),
              ),
            if (restaurant.address != null)
              Padding(
                padding: const EdgeInsets.only(top: 4),
                child: Text(
                  restaurant.address!,
                  style: TextStyle(color: Colors.grey.shade700, fontSize: 13),
                ),
              ),
            const SizedBox(height: 16),
            const Text('TwoThumbs rating',
                style: TextStyle(fontWeight: FontWeight.w600)),
            const SizedBox(height: 8),
            ThumbsRatingDisplay(stats: stats),
            if (restaurant.googleRating != null) ...[
              const SizedBox(height: 16),
              Row(
                children: [
                  const Icon(Icons.star, size: 16, color: Colors.amber),
                  const SizedBox(width: 4),
                  Text(
                    '${restaurant.googleRating!.toStringAsFixed(1)} on Google',
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                  if (restaurant.googleReviewCount != null) ...[
                    const SizedBox(width: 6),
                    Text(
                      '(${restaurant.googleReviewCount} reviews)',
                      style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
                    ),
                  ],
                ],
              ),
            ],
            const SizedBox(height: 20),
            FilledButton(
              onPressed: () {
                Navigator.pop(context);
                context.push('/restaurant/${restaurant.id}');
              },
              child: const Text('View details'),
            ),
          ],
        ),
      ),
    );
  }
}
