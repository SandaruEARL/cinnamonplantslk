import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/app_colors.dart';
import '../../../../core/di/injection_container.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../../features/location/presentation/screens/register_location_screen.dart';
import '../../domain/entities/business_location_entity.dart';
import '../bloc/location_bloc.dart';
import '../bloc/location_event.dart';
import '../bloc/location_state.dart';

class MyLocationsScreen extends StatelessWidget {
  final String userId;
  const MyLocationsScreen({super.key, required this.userId});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<LocationBloc>()
        ..add(LocationUserLoadRequested(userId)),
      child: _MyLocationsView(userId: userId),
    );
  }
}

class _MyLocationsView extends StatelessWidget {
  final String userId;
  const _MyLocationsView({required this.userId});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        iconTheme: const IconThemeData(color: Colors.white),
        title: Text(l10n.myLocationsTitle,
            style: const TextStyle(
                color: Colors.white, fontWeight: FontWeight.w600)),
        flexibleSpace: Container(
          decoration:
          const BoxDecoration(gradient: AppColors.primaryGradient),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: BlocConsumer<LocationBloc, LocationState>(
        listener: (context, state) {
          if (state is LocationEditSubmitted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text(
                  'Edit submitted for review. Your location stays on the map.',
                ),
              ),
            );
          } else if (state is LocationError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.message)),
            );
          }
        },
        builder: (context, state) {
          final locations = state is LocationLoaded
              ? state.locations
              : <BusinessLocationEntity>[];

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    Expanded(
                      child: _RegisterCard(
                        label: l10n.plantationsLabel,
                        description: l10n.plantationsDescription,
                        type: LocationType.nursery,
                        existing: locations
                            .where((l) => l.type == LocationType.nursery)
                            .firstOrNull,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _RegisterCard(
                        label: l10n.baleBuyersLabel,
                        description: l10n.baleBuyersDescription,
                        type: LocationType.shop,
                        existing: locations
                            .where((l) => l.type == LocationType.shop)
                            .firstOrNull,
                      ),
                    ),
                  ],
                ),
              ),

              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Text(l10n.locationsReviewNotice,
                    style: TextStyle(
                        fontSize: 12, color: Colors.grey.shade500)),
              ),

              const SizedBox(height: 32),

              if (state is LocationLoading)
                const Expanded(
                    child: Center(child: CircularProgressIndicator()))
              else if (locations.isEmpty)
                Expanded(
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.location_off,
                            size: 72, color: Colors.grey.shade300),
                        const SizedBox(height: 16),
                        Text(l10n.noLocationsYet,
                            style: TextStyle(
                                color: Colors.grey.shade500,
                                fontSize: 14)),
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
                    itemBuilder: (context, i) => _LocationCard(
                      location: locations[i],
                      onTap: () {
                        final bloc = context.read<LocationBloc>();
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => BlocProvider.value(
                              value: bloc,
                              child: RegisterLocationScreen(
                                type: locations[i].type,
                                existing: locations[i],
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ),
            ],
          );
        },
      ),
    );
  }
}

class _RegisterCard extends StatelessWidget {
  final String label;
  final String description;
  final LocationType type;
  final BusinessLocationEntity? existing;

  const _RegisterCard({
    required this.label,
    required this.description,
    required this.type,
    this.existing,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final hasExisting = existing != null;

    return Container(
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(label,
                  style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary)),
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
                      Text(l10n.addedBadge,
                          style: TextStyle(
                              fontSize: 10,
                              color: Colors.green.shade700,
                              fontWeight: FontWeight.w600)),
                    ],
                  ),
                ),
            ],
          ),
          const SizedBox(height: 6),
          Text(description,
              style: const TextStyle(
                  fontSize: 11,
                  color: AppColors.textSecondary,
                  height: 1.4)),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: () {
                final bloc = context.read<LocationBloc>();
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => BlocProvider.value(
                      value: bloc,
                      child: RegisterLocationScreen(
                        type: type,
                        existing: existing,
                      ),
                    ),
                  ),
                );
              },
              icon: Icon(
                hasExisting
                    ? Icons.edit_location_alt
                    : Icons.add_location_alt,
                size: 14,
              ),
              label: Text(
                hasExisting ? l10n.editLocation : l10n.addLocation,
                style: const TextStyle(fontSize: 12),
              ),
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.textPrimary,
                side: const BorderSide(color: Colors.black54),
                padding: const EdgeInsets.symmetric(vertical: 8),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20)),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _LocationCard extends StatelessWidget {
  final BusinessLocationEntity location;
  final VoidCallback onTap;
  const _LocationCard({required this.location, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final isNursery = location.type == LocationType.nursery;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Card(
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
              const Icon(Icons.chevron_right, size: 18, color: Colors.grey),
              IconButton(
                icon: const Icon(Icons.location_off_outlined,
                    color: Colors.grey),
                tooltip: l10n.removeLocationTitle,
                onPressed: () => _confirmDelete(context),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _confirmDelete(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(l10n.removeLocationTitle),
        content: Text(location.type == LocationType.nursery
            ? l10n.removeNurseryBody
            : l10n.removeShopBody),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(l10n.cancel)),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              context
                  .read<LocationBloc>()
                  .add(LocationDeleteRequested(location.id));
            },
            style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white),
            child: Text(l10n.remove),
          ),
        ],
      ),
    );
  }
}

class _StatusBadge extends StatelessWidget {
  final BusinessLocationEntity location;
  const _StatusBadge({required this.location});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final Color bg;
    final Color fg;
    final String label;
    final IconData icon;

    if (location.isApproved) {
      bg = Colors.green.shade50;
      fg = Colors.green.shade700;
      label = l10n.statusVisibleOnMap;
      icon = Icons.check_circle_outline;
    } else if (location.isPending) {
      bg = Colors.grey.shade100;
      fg = Colors.grey.shade600;
      label = l10n.statusPendingReview;
      icon = Icons.hourglass_top_rounded;
    } else {
      bg = Colors.red.shade50;
      fg = Colors.red.shade700;
      label = location.rejectionReason ?? l10n.statusRejected;
      icon = Icons.cancel_outlined;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration:
      BoxDecoration(color: bg, borderRadius: BorderRadius.circular(20)),
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