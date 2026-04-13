import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/app_colors.dart';
import '../../../data/services/firebase/firestore_service.dart';
import '../../../domain/entities/location.dart';
import 'register_location_screen.dart';

class MyLocationsScreen extends StatelessWidget {
  final String userId;
  const MyLocationsScreen({super.key, required this.userId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // ── AppBar ───────────────────────────────────────────────────────
      appBar: AppBar(
        iconTheme: const IconThemeData(color: Colors.white),
        title: const Text(
          'My Registered Locations',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
        ),
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: AppColors.primaryGradient,
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),

      body: StreamBuilder<List<BusinessLocation>>(
        stream: context.read<FirestoreService>().getUserLocations(userId),
        builder: (context, snapshot) {
          final locations = snapshot.data ?? [];

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Two Register Cards ──────────────────────────────────
              Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    Expanded(
                      child: _RegisterCard(
                        label: 'Plantations',
                        description:
                        'Register your nursery so buyers can find you on the map.',
                        type: LocationType.nursery,
                        existing: locations
                            .where((l) => l.type == LocationType.nursery)
                            .firstOrNull,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _RegisterCard(
                        label: 'Bale Buyers',
                        description:
                        'List your shop so sellers nearby can locate you easily.',
                        type: LocationType.shop,
                        existing: locations
                            .where((l) => l.type == LocationType.shop)
                            .firstOrNull,
                      ),
                    ),
                  ],
                ),
              ),

              // ── Info text ───────────────────────────────────────────
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Text(
                  'Locations are reviewed before appearing on the map.',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey.shade500,
                  ),
                ),
              ),

              const SizedBox(height: 32),

              // ── Empty / List ────────────────────────────────────────
              if (locations.isEmpty)
                Expanded(
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.location_off,
                          size: 72,
                          color: Colors.grey.shade300,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          "You haven't registered any locations yet",
                          style: TextStyle(
                            color: Colors.grey.shade500,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                )
              else
                Expanded(
                  child: ListView.separated(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: locations.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 12),
                    itemBuilder: (context, i) =>
                        _LocationCard(location: locations[i]),
                  ),
                ),
            ],
          );
        },
      ),
    );
  }
}

// ── Register Card ─────────────────────────────────────────────────────────────

class _RegisterCard extends StatelessWidget {
  final String label;
  final String description;
  final LocationType type;
  final BusinessLocation? existing;

  const _RegisterCard({
    required this.label,
    required this.description,
    required this.type,
    this.existing,
  });

  void _navigate(BuildContext context) {
    Navigator.of(context).push(MaterialPageRoute(
      builder: (_) =>
          RegisterLocationScreen(type: type, existing: existing),
    ));
  }

  @override
  Widget build(BuildContext context) {
    final hasExisting = existing != null;

    return Container(
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Title + "Added" badge
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                label,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
              if (hasExisting)
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 7, vertical: 3),
                  decoration: BoxDecoration(
                    color: Colors.green.shade50,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.check_circle,
                          size: 10, color: Colors.green.shade700),
                      const SizedBox(width: 3),
                      Text(
                        'Added',
                        style: TextStyle(
                          fontSize: 10,
                          color: Colors.green.shade700,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),

          const SizedBox(height: 6),

          // Description
          Text(
            description,
            style: const TextStyle(
              fontSize: 11,
              color: AppColors.textSecondary,
              height: 1.4,
            ),
          ),

          const SizedBox(height: 12),

          // Add / Edit button — outlined
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: () => _navigate(context),
              icon: Icon(
                hasExisting
                    ? Icons.edit_location_alt
                    : Icons.add_location_alt,
                size: 14,
              ),
              label: Text(
                hasExisting ? 'Edit' : 'Add location',
                style: const TextStyle(fontSize: 12),
              ),
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.textPrimary,
                side: const BorderSide(color: Colors.black54),
                padding: const EdgeInsets.symmetric(vertical: 8),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Location Card ─────────────────────────────────────────────────────────────

class _LocationCard extends StatelessWidget {
  final BusinessLocation location;
  const _LocationCard({required this.location});

  @override
  Widget build(BuildContext context) {
    final isNursery = location.type == LocationType.nursery;

    return Card(
      elevation: 0,
      color: Colors.grey.shade50,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: Colors.grey.shade200),
      ),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.grey.shade200,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                isNursery ? Icons.park : Icons.store,
                color: isNursery ? Colors.green : AppColors.primaryGreen,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    location.businessName,
                    style: const TextStyle(
                        fontWeight: FontWeight.bold, fontSize: 15),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    location.address,
                    style: const TextStyle(
                        fontSize: 12, color: AppColors.textSecondary),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 6),
                  _StatusBadge(location: location),
                ],
              ),
            ),
            IconButton(
              icon: const Icon(Icons.location_off_outlined,
                  color: Colors.red),
              tooltip: 'Remove location',
              onPressed: () => _confirmDelete(context),
            ),
          ],
        ),
      ),
    );
  }

  void _confirmDelete(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Remove location?'),
        content: Text(
          'Your ${location.type == LocationType.nursery ? "nursery" : "shop"} '
              'location will be removed from the map.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              await context
                  .read<FirestoreService>()
                  .deleteLocation(location.id);
            },
            style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white),
            child: const Text('Remove'),
          ),
        ],
      ),
    );
  }
}

// ── Status Badge ──────────────────────────────────────────────────────────────

class _StatusBadge extends StatelessWidget {
  final BusinessLocation location;
  const _StatusBadge({required this.location});

  @override
  Widget build(BuildContext context) {
    final Color bg;
    final Color fg;
    final String label;
    final IconData icon;

    if (location.isApproved) {
      bg = Colors.green.shade50;
      fg = Colors.green.shade700;
      label = 'Visible on map';
      icon = Icons.check_circle_outline;
    } else if (location.isPending) {
      bg = Colors.orange.shade50;
      fg = Colors.orange.shade700;
      label = 'Pending review';
      icon = Icons.hourglass_top_rounded;
    } else {
      bg = Colors.red.shade50;
      fg = Colors.red.shade700;
      label = location.rejectionReason ?? 'Rejected';
      icon = Icons.cancel_outlined;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: fg),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              color: fg,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}