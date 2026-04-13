import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../core/app_colors.dart';
import '../../../data/services/firebase/firestore_service.dart';
import '../../../domain/entities/location.dart';

class AdsMapScreen extends StatefulWidget {
  final String title;
  final LocationType locationType;
  final Color pinColor;

  const AdsMapScreen({
    super.key,
    required this.title,
    required this.locationType,
    required this.pinColor,
  });

  @override
  State<AdsMapScreen> createState() => _AdsMapScreenState();
}

class _AdsMapScreenState extends State<AdsMapScreen> {
  final MapController _mapController = MapController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        flexibleSpace: Container(
          decoration: const BoxDecoration(gradient: AppColors.primaryGradient),
        ),
      ),
      body: StreamBuilder<List<BusinessLocation>>(
        stream: context
            .read<FirestoreService>()
            .getApprovedLocations(widget.locationType),
        builder: (context, snapshot) {
          final locations = snapshot.data ?? [];

          return Stack(
            children: [

              // Map
              FlutterMap(
                mapController: _mapController,
                options: const MapOptions(
                  initialCenter: LatLng(7.8731, 80.7718), // Sri Lanka center
                  initialZoom: 8,
                ),
                children: [
                  TileLayer(
                    urlTemplate:
                    'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                    userAgentPackageName:
                    'com.example.cinnamon_marketplace',
                  ),
                  MarkerLayer(
                    markers: locations.map((loc) {
                      return Marker(
                        point: LatLng(loc.latitude, loc.longitude),
                        width: 44,
                        height: 44,
                        child: GestureDetector(
                          onTap: () => _showLocationDetail(context, loc),
                          child: Container(
                            decoration: BoxDecoration(
                              color: widget.pinColor,
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: widget.pinColor.withOpacity(0.4),
                                  blurRadius: 8,
                                  offset: const Offset(0, 3),
                                ),
                              ],
                            ),
                            child: Icon(
                              loc.type == LocationType.nursery
                                  ? Icons.park
                                  : Icons.store,
                              color: Colors.white,
                              size: 22,
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ],
              ),

              // Loading indicator
              if (snapshot.connectionState == ConnectionState.waiting)
                const Positioned(
                  top: 16,
                  left: 0,
                  right: 0,
                  child: Center(
                    child: Card(
                      child: Padding(
                        padding: EdgeInsets.symmetric(
                            horizontal: 16, vertical: 8),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(
                                  strokeWidth: 2),
                            ),
                            SizedBox(width: 8),
                            Text('Loading locations...'),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),

              // Pin count badge
              if (locations.isNotEmpty)
                Positioned(
                  top: 16,
                  right: 16,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: widget.pinColor,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      '${locations.length} '
                          '${locations.length == 1 ? 'location' : 'locations'}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                      ),
                    ),
                  ),
                ),

              // Empty state
              if (snapshot.connectionState != ConnectionState.waiting &&
                  locations.isEmpty)
                Center(
                  child: Card(
                    margin: const EdgeInsets.all(32),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16)),
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            widget.locationType == LocationType.nursery
                                ? Icons.park_outlined
                                : Icons.store_outlined,
                            size: 56,
                            color: Colors.grey.shade400,
                          ),
                          const SizedBox(height: 12),
                          Text(
                            'No ${widget.title.toLowerCase()} registered yet',
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                                color: AppColors.textSecondary,
                                fontSize: 15),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
            ],
          );
        },
      ),
    );
  }

  void _showLocationDetail(BuildContext context, BusinessLocation loc) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _LocationDetailSheet(location: loc),
    );
  }

  @override
  void dispose() {
    _mapController.dispose();
    super.dispose();
  }
}

// ── Bottom sheet ────────────────────────────────────────────

class _LocationDetailSheet extends StatelessWidget {
  final BusinessLocation location;
  const _LocationDetailSheet({required this.location});

  @override
  Widget build(BuildContext context) {
    final isNursery = location.type == LocationType.nursery;

    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [

          // Handle
          Center(
            child: Container(
              margin: const EdgeInsets.only(top: 12),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),

          // Photos strip
          if (location.photoUrls.isNotEmpty) ...[
            const SizedBox(height: 12),
            SizedBox(
              height: 160,
              child: PageView.builder(
                itemCount: location.photoUrls.length,
                itemBuilder: (_, i) => CachedNetworkImage(
                  imageUrl: location.photoUrls[i],
                  fit: BoxFit.cover,
                  errorWidget: (_, __, ___) => Container(
                    color: Colors.grey.shade200,
                    child: const Icon(Icons.image_not_supported),
                  ),
                ),
              ),
            ),
          ],

          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [

                // Type badge + name
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: (isNursery
                            ? Colors.green
                            : AppColors.primaryGreen)
                            .withOpacity(0.1),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            isNursery ? Icons.park : Icons.store,
                            size: 14,
                            color: isNursery
                                ? Colors.green
                                : AppColors.primaryGreen,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            isNursery ? 'Nursery' : 'Bale Buyer',
                            style: TextStyle(
                              fontSize: 12,
                              color: isNursery
                                  ? Colors.green
                                  : AppColors.primaryGreen,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 10),

                Text(
                  location.businessName,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),

                const SizedBox(height: 6),

                Text(
                  location.description,
                  style: const TextStyle(
                    fontSize: 14,
                    color: AppColors.textSecondary,
                    height: 1.5,
                  ),
                ),

                const SizedBox(height: 12),

                // Address
                _InfoRow(
                  icon: Icons.location_on_outlined,
                  text: location.address,
                ),

                // Opening hours
                if (location.openingHours != null) ...[
                  const SizedBox(height: 6),
                  _InfoRow(
                    icon: Icons.access_time,
                    text: location.openingHours!,
                  ),
                ],

                // Owner
                const SizedBox(height: 6),
                _InfoRow(
                  icon: Icons.person_outline,
                  text: location.ownerName,
                ),

                const SizedBox(height: 20),

                // Action buttons
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () => _call(location.ownerPhone),
                        icon: const Icon(Icons.phone, size: 18),
                        label: const Text('Call'),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: AppColors.primaryGreen,
                          side: const BorderSide(
                              color: AppColors.primaryGreen),
                          padding:
                          const EdgeInsets.symmetric(vertical: 12),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () => _getDirections(
                            location.latitude, location.longitude),
                        icon: const Icon(Icons.directions, size: 18),
                        label: const Text('Directions'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primaryGreen,
                          foregroundColor: Colors.white,
                          padding:
                          const EdgeInsets.symmetric(vertical: 12),
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 8),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _call(String phone) async {
    final uri = Uri(scheme: 'tel', path: phone);
    if (await canLaunchUrl(uri)) await launchUrl(uri);
  }

  void _getDirections(double lat, double lng) async {
    final uri = Uri.parse(
        'https://www.google.com/maps/dir/?api=1&destination=$lat,$lng');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String text;
  const _InfoRow({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 16, color: AppColors.textSecondary),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            text,
            style: const TextStyle(
                fontSize: 14, color: AppColors.textSecondary),
          ),
        ),
      ],
    );
  }
}