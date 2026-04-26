import 'dart:io';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/repositories/location_repository.dart';
import '../../domain/usecases/delete_location.dart';
import '../../domain/usecases/get_approved_locations.dart';
import '../../domain/usecases/get_user_locations.dart';
import '../../domain/usecases/save_location.dart';
import '../../domain/usecases/upload_location_photos.dart';
import 'location_event.dart';
import 'location_state.dart';

class LocationBloc extends Bloc<LocationEvent, LocationState> {
  final GetApprovedLocations getApprovedLocations;
  final GetUserLocations getUserLocations;
  final SaveLocation saveLocation;
  final DeleteLocation deleteLocation;
  final LocationRepository locationRepository;
  final UploadLocationPhotos uploadLocationPhotos;

  LocationBloc({
    required this.getApprovedLocations,
    required this.getUserLocations,
    required this.saveLocation,
    required this.deleteLocation,
    required this.locationRepository,
    required this.uploadLocationPhotos,
  }) : super(const LocationInitial()) {
    on<LocationApprovedLoadRequested>(_onApprovedLoadRequested);
    on<LocationUserLoadRequested>(_onUserLoadRequested);
    on<LocationSaveRequested>(_onSaveRequested);
    on<LocationDeleteRequested>(_onDeleteRequested);
    on<LocationEditRequested>(_onEditRequested);
  }

  Future<void> _onApprovedLoadRequested(
      LocationApprovedLoadRequested event,
      Emitter<LocationState> emit,
      ) async {
    emit(const LocationLoading());
    await emit.forEach(
      getApprovedLocations(event.type),
      onData: (result) => result.fold(
            (failure) => LocationError(failure.message),
            (locations) => LocationLoaded(locations),
      ),
    );
  }

  Future<void> _onUserLoadRequested(
      LocationUserLoadRequested event,
      Emitter<LocationState> emit,
      ) async {
    emit(const LocationLoading());
    await emit.forEach(
      getUserLocations(event.userId),
      onData: (result) => result.fold(
            (failure) => LocationError(failure.message),
            (locations) => LocationLoaded(locations),
      ),
    );
  }

  Future<void> _onSaveRequested(
      LocationSaveRequested event,
      Emitter<LocationState> emit,
      ) async {
    emit(const LocationSaving());
    final result = await saveLocation(SaveLocationParams(
      location: event.location,
      newPhotos: event.newPhotos,
    ));
    result.fold(
          (failure) => emit(LocationError(failure.message)),
          (_) => emit(const LocationSaved()),
    );
  }

  Future<void> _onDeleteRequested(
      LocationDeleteRequested event,
      Emitter<LocationState> emit,
      ) async {
    final result = await deleteLocation(event.locationId);
    result.fold(
          (failure) => emit(LocationError(failure.message)),
          (_) => emit(const LocationDeleted()),
    );
  }

  /// APPROVED location edit — uploads new photos then writes to `pendingEdit`
  /// subcollection. Original stays on the map until admin approves.
  Future<void> _onEditRequested(
      LocationEditRequested event,
      Emitter<LocationState> emit,
      ) async {
    emit(const LocationSaving());

    List<String> allPhotos = event.existingPhotoUrls;

    if (event.newPhotos.isNotEmpty) {
      final uploadResult = await uploadLocationPhotos(event.newPhotos);
      final failed = uploadResult.fold((f) => true, (_) => false);
      if (failed) {
        emit(LocationError(uploadResult.fold((f) => f.message, (_) => '')));
        return;
      }
      final newUrls = uploadResult.fold((_) => <String>[], (urls) => urls);
      allPhotos = [...event.existingPhotoUrls, ...newUrls];
    }

    final result = await locationRepository.submitLocationEdit(event.locationId, {
      'businessName': event.businessName,
      'description': event.description,
      'address': event.address,
      'latitude': event.latitude,
      'longitude': event.longitude,
      'openingHours': event.openingHours,
      'photoUrls': allPhotos,
      'submittedAt': DateTime.now().toIso8601String(),
      'status': 'pending',
    });

    result.fold(
          (failure) => emit(LocationError(failure.message)),
          (_) => emit(const LocationEditSubmitted()),
    );
  }
}