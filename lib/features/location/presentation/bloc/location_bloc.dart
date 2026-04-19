import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/usecases/delete_location.dart';
import '../../domain/usecases/get_approved_locations.dart';
import '../../domain/usecases/get_user_locations.dart';
import '../../domain/usecases/save_location.dart';
import 'location_event.dart';
import 'location_state.dart';

class LocationBloc extends Bloc<LocationEvent, LocationState> {
  final GetApprovedLocations getApprovedLocations;
  final GetUserLocations getUserLocations;
  final SaveLocation saveLocation;
  final DeleteLocation deleteLocation;

  LocationBloc({
    required this.getApprovedLocations,
    required this.getUserLocations,
    required this.saveLocation,
    required this.deleteLocation,
  }) : super(const LocationInitial()) {
    on<LocationApprovedLoadRequested>(_onApprovedLoadRequested);
    on<LocationUserLoadRequested>(_onUserLoadRequested);
    on<LocationSaveRequested>(_onSaveRequested);
    on<LocationDeleteRequested>(_onDeleteRequested);
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
}