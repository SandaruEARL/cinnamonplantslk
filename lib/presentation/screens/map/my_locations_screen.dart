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
      appBar: AppBar(
        title: const Text('My Registered Locations'),
        flexibleSpace: Container(
          decoration: const BoxDecoration(
              gradient: AppColors.primaryGradient),
        ),
      ),
      body: StreamBuilder<List<BusinessLocation>>(
        stream: context.read<FirestoreService>().getUserLocations(userId),
        builder: (context, snapshot) {
          final locations = snapshot.data ?? [];

          return Column(
            children: [
              // Register buttons
              Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    Expanded(
                      child: _RegisterButton(
                        label: 'Nursery / Plantation',
                        icon: Icons.park,
                        type: LocationType.nursery,
                        existing: locations
                            .where((l) => l.type == LocationType.nursery)
                            .firstOrNull,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _RegisterButton(
                        label: 'Bale Buying Shop',
                        icon: Icons.store,
                        type: LocationType.shop,
                        existing: locations
                            .where((l) => l.type == LocationType.shop)
                            .firstOrNull,
                      ),
                    ),
                  ],
                ),
              ),

              if (locations.isEmpty)
                const Expanded(
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.location_off,
                            size: 64, color: Colors.grey),
                        SizedBox(height: 16),
                        Text("You haven't registered any locations yet",
                            style: TextStyle(color: AppColors.textSecondary)),
                      ],
                    ),
                  ),
                )
              else
                Expanded(
                  child: ListView.separated(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: locations.length,
                    separatorBuilder: (_, __) =>
                    const SizedBox(height: 12),
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

class _RegisterButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final LocationType type;
  final BusinessLocation? existing;

  const _RegisterButton({
    required this.label,
    required this.icon,
    required this.type,
    this.existing,
  });

  @override
  Widget build(BuildContext context) {
    final hasExisting = existing != null;
    return OutlinedButton.icon(
      onPressed: () => Navigator.of(context).push(MaterialPageRoute(
        builder: (_) => RegisterLocationScreen(
            type: type, existing: existing),
      )),
      icon: Icon(hasExisting ? Icons.edit : Icons.add_location_alt,
          size: 18),
      label: Text(hasExisting ? 'Update' : 'Add',
          style: const TextStyle(fontSize: 13)),
      style: OutlinedButton.styleFrom(
        foregroundColor: AppColors.primaryBrown,
        side: const BorderSide(color: AppColors.primaryBrown),
        padding: const EdgeInsets.symmetric(vertical: 12),
      ),
    );
  }
}

class _LocationCard extends StatelessWidget {
  final BusinessLocation location;
  const _LocationCard({required this.location});

  @override
  Widget build(BuildContext context) {
    final isNursery = location.type == LocationType.nursery;

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: (isNursery ? Colors.green : AppColors.primaryBrown)
                    .withOpacity(0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                isNursery ? Icons.park : Icons.store,
                color: isNursery
                    ? Colors.green
                    : AppColors.primaryBrown,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(location.businessName,
                      style: const TextStyle(
                          fontWeight: FontWeight.bold, fontSize: 15)),
                  const SizedBox(height: 2),
                  Text(location.address,
                      style: const TextStyle(
                          fontSize: 12,
                          color: AppColors.textSecondary),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis),
                  const SizedBox(height: 6),
                  _StatusBadge(location: location),
                ],
              ),
            ),
            // Unpin button
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
                'location will be removed from the map.'),
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
          Text(label,
              style: TextStyle(
                  fontSize: 11,
                  color: fg,
                  fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }
}