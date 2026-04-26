import 'dart:io';
import '../../domain/entities/business_location_entity.dart';

abstract class LocationEvent {
  const LocationEvent();
}

class LocationApprovedLoadRequested extends LocationEvent {
  final LocationType type;
  const LocationApprovedLoadRequested(this.type);
}

class LocationUserLoadRequested extends LocationEvent {
  final String userId;
  const LocationUserLoadRequested(this.userId);
}

class LocationSaveRequested extends LocationEvent {
  final BusinessLocationEntity location;
  final List<File> newPhotos;
  const LocationSaveRequested({
    required this.location,
    required this.newPhotos,
  });
}

class LocationDeleteRequested extends LocationEvent {
  final String locationId;
  const LocationDeleteRequested(this.locationId);
}

/// Submits an edit for an already-APPROVED location into the
/// `pendingEdit` subcollection. Original stays on the map until approved.
class LocationEditRequested extends LocationEvent {
  final String locationId;
  final String businessName;
  final String description;
  final String address;
  final double latitude;
  final double longitude;
  final String? openingHours;
  final List<String> existingPhotoUrls;
  final List<File> newPhotos;

  const LocationEditRequested({
    required this.locationId,
    required this.businessName,
    required this.description,
    required this.address,
    required this.latitude,
    required this.longitude,
    this.openingHours,
    required this.existingPhotoUrls,
    required this.newPhotos,
  });
}