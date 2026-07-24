import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'package:latlong2/latlong.dart';

import '../../../../core/app_colors.dart';
import '../../../../l10n/app_localizations.dart';


class LocationResult {
  final double latitude;
  final double longitude;
  final String address;

  const LocationResult({
    required this.latitude,
    required this.longitude,
    required this.address,
  });
}

class LocationPickerScreen extends StatefulWidget {
  final double? initialLat;
  final double? initialLng;

  const LocationPickerScreen({super.key, this.initialLat, this.initialLng});

  @override
  State<LocationPickerScreen> createState() => _LocationPickerScreenState();
}

class _LocationPickerScreenState extends State<LocationPickerScreen> {
  final MapController _mapController = MapController();
  final TextEditingController _searchController = TextEditingController();

  // Default to Sri Lanka center
  LatLng _pickedLocation = const LatLng(7.8731, 80.7718);
  String _address = '';
  bool _loadingAddress = false;
  bool _loadingGps = false;

  @override
  void initState() {
    super.initState();
    if (widget.initialLat != null && widget.initialLng != null) {
      _pickedLocation = LatLng(widget.initialLat!, widget.initialLng!);
    }
    _reverseGeocode(_pickedLocation);
  }

  Future<void> _reverseGeocode(LatLng position) async {
    setState(() => _loadingAddress = true);
    try {
      final placemarks = await placemarkFromCoordinates(
        position.latitude,
        position.longitude,
      );
      if (placemarks.isNotEmpty) {
        final p = placemarks.first;
        final parts = [p.subLocality, p.locality, p.administrativeArea]
            .where((s) => s != null && s.isNotEmpty)
            .toList();
        setState(() => _address = parts.join(', '));
      }
    } catch (_) {
      setState(() => _address = '${_pickedLocation.latitude.toStringAsFixed(4)}, '
          '${_pickedLocation.longitude.toStringAsFixed(4)}');
    } finally {
      setState(() => _loadingAddress = false);
    }
  }

  Future<void> _useGpsLocation() async {
    final l10n = AppLocalizations.of(context)!;
    setState(() => _loadingGps = true);

    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        throw Exception('Location services are disabled');
      }

      LocationPermission permission = await Geolocator.checkPermission();

      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }

      if (permission == LocationPermission.deniedForever) {
        throw Exception('Location permission permanently denied');
      }

      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      final newLocation = LatLng(position.latitude, position.longitude);

      setState(() => _pickedLocation = newLocation);
      _mapController.move(newLocation, 15);

      await _reverseGeocode(newLocation);

    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(l10n.couldNotGetLocation(e.toString()))),
        );
      }
    } finally {
      setState(() => _loadingGps = false);
    }
  }

  Future<void> _searchAddress(String query) async {
    final l10n = AppLocalizations.of(context)!;
    if (query.trim().isEmpty) return;
    try {
      final locations = await locationFromAddress('$query, Sri Lanka');
      if (locations.isNotEmpty) {
        final newLocation = LatLng(locations.first.latitude, locations.first.longitude);
        setState(() => _pickedLocation = newLocation);
        _mapController.move(newLocation, 14);
        await _reverseGeocode(newLocation);
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(l10n.locationNotFound)),
          );
        }
      }
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(l10n.couldNotFindLocation)),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.pickLocationTitle),
        flexibleSpace: Container(
          decoration: const BoxDecoration(gradient: AppColors.primaryGradient),
        ),
        actions: [
          TextButton(
            onPressed: _address.isEmpty ? null : () {
              Navigator.of(context).pop(LocationResult(
                latitude:  _pickedLocation.latitude,
                longitude: _pickedLocation.longitude,
                address:   _address,
              ));
            },
            child: Text(
              l10n.confirmLocation,
              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
      body: Stack(
        children: [
          // Map
          FlutterMap(
            mapController: _mapController,
            options: MapOptions(
              initialCenter: _pickedLocation,
              initialZoom: 10,
              onTap: (_, latLng) async {
                setState(() => _pickedLocation = latLng);
                await _reverseGeocode(latLng);
              },
            ),
            children: [
              TileLayer(
                urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                userAgentPackageName: 'com.example.cinnamon_marketplace',
              ),
              MarkerLayer(
                markers: [
                  Marker(
                    point: _pickedLocation,
                    width: 40,
                    height: 40,
                    child: const Icon(
                      Icons.location_pin,
                      color: Colors.red,
                      size: 40,
                    ),
                  ),
                ],
              ),
            ],
          ),

          // Search bar
          Positioned(
            top: 12,
            left: 12,
            right: 12,
            child: Material(
              elevation: 0,
              borderRadius: BorderRadius.circular(30),
              color: Colors.white,
              shadowColor: Colors.black.withOpacity(0.07),
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(30),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.07),
                      blurRadius: 12,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: TextField(
                  controller: _searchController,
                  onSubmitted: _searchAddress,
                  decoration: InputDecoration(
                    hintText: l10n.searchLocationHint,
                    hintStyle: const TextStyle(color: Color(0xFFAAAAAA)),
                    suffixIcon: IconButton(
                      icon: const Icon(Icons.search, color: Color(0xFFAAAAAA)),
                      onPressed: () => _searchAddress(_searchController.text),
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(30),
                      borderSide: BorderSide.none,
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(30),
                      borderSide: BorderSide.none,
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(30),
                      borderSide: BorderSide.none,
                    ),
                    filled: true,
                    fillColor: Colors.white,
                    contentPadding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                  ),
                ),
              ),
            ),
          ),

          // GPS button
          Positioned(
            bottom: 120,
            right: 16,
            child: FloatingActionButton.small(
              heroTag: 'gps',
              onPressed: _loadingGps ? null : _useGpsLocation,
              backgroundColor: Colors.white,
              child: _loadingGps
                  ? const SizedBox(
                width: 20, height: 20,
                child: CircularProgressIndicator(strokeWidth: 2),
              )
                  : const Icon(Icons.my_location, color: AppColors.primaryGreen),
            ),
          ),

          // Address display
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              padding: const EdgeInsets.all(20),
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
                boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 8)],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    l10n.selectedLocation,
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                  ),
                  const SizedBox(height: 6),
                  _loadingAddress
                      ? const SizedBox(
                    height: 20,
                    child: LinearProgressIndicator(),
                  )
                      : Text(
                    _address.isEmpty ? l10n.tapMapToSelect : _address,
                    style: const TextStyle(fontSize: 15, color: AppColors.textSecondary),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${_pickedLocation.latitude.toStringAsFixed(5)}, '
                        '${_pickedLocation.longitude.toStringAsFixed(5)}',
                    style: const TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _mapController.dispose();
    _searchController.dispose();
    super.dispose();
  }
}