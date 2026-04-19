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