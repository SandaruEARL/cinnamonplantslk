import '../../domain/entities/business_location_entity.dart';

abstract class LocationState {
  const LocationState();
}

class LocationInitial extends LocationState {
  const LocationInitial();
}

class LocationLoading extends LocationState {
  const LocationLoading();
}

class LocationLoaded extends LocationState {
  final List<BusinessLocationEntity> locations;
  const LocationLoaded(this.locations);
}

class LocationSaving extends LocationState {
  const LocationSaving();
}

class LocationSaved extends LocationState {
  const LocationSaved();
}

/// Emitted after a live-location edit is submitted for admin review.
class LocationEditSubmitted extends LocationState {
  const LocationEditSubmitted();
}

class LocationDeleted extends LocationState {
  const LocationDeleted();
}

class LocationError extends LocationState {
  final String message;
  const LocationError(this.message);
}