import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/entities/advertisement_entity.dart';
import '../../domain/usecases/create_advertisement.dart';
import '../../domain/usecases/get_advertisements.dart';
import '../../domain/usecases/get_anouncements.dart';
import '../../domain/usecases/get_user_advertisements.dart';
import '../../domain/usecases/toggle_favorite.dart';
import '../../domain/usecases/update_advertisement.dart';
import '../../domain/usecases/submit_ad_edit.dart';
import '../../domain/usecases/upload_images.dart';
import 'marketplace_event.dart';
import 'marketplace_state.dart';

class MarketplaceBloc extends Bloc<MarketplaceEvent, MarketplaceState> {
  final GetAdvertisements getAdvertisements;
  final GetAnnouncements getAnnouncements;
  final GetUserAdvertisements getUserAdvertisements;
  final CreateAdvertisement createAdvertisement;
  final AddToFavorites addToFavorites;
  final RemoveFromFavorites removeFromFavorites;
  final UpdateAdvertisement updateAdvertisement;
  final SubmitAdEdit submitAdEdit;
  final UploadImages uploadImages;

  StreamSubscription? _adsSubscription;

  MarketplaceBloc({
    required this.getAdvertisements,
    required this.getAnnouncements,
    required this.getUserAdvertisements,
    required this.createAdvertisement,
    required this.addToFavorites,
    required this.uploadImages,
    required this.updateAdvertisement,
    required this.submitAdEdit,
    required this.removeFromFavorites,
  }) : super(const MarketplaceInitial()) {
    on<MarketplaceLoadRequested>(_onLoadRequested);
    on<MarketplaceAnnouncementsLoadRequested>(_onAnnouncementsLoadRequested);
    on<MarketplaceUserAdsLoadRequested>(_onUserAdsLoadRequested);
    on<MarketplaceAdCreateRequested>(_onAdCreateRequested);
    on<MarketplaceAdUpdateRequested>(_onAdUpdateRequested);
    on<MarketplaceAdEditRequested>(_onAdEditRequested);
    on<MarketplaceFavoriteToggled>(_onFavoriteToggled);
  }

  Future<void> _onLoadRequested(
      MarketplaceLoadRequested event,
      Emitter<MarketplaceState> emit,
      ) async {
    emit(const MarketplaceLoading());
    await _adsSubscription?.cancel();

    await emit.forEach(
      getAdvertisements(GetAdvertisementsParams(category: event.category)),
      onData: (result) => result.fold(
            (failure) => MarketplaceError(failure.message),
            (ads) => MarketplaceLoaded(ads),
      ),
    );
  }

  Future<void> _onAnnouncementsLoadRequested(
      MarketplaceAnnouncementsLoadRequested event,
      Emitter<MarketplaceState> emit,
      ) async {
    emit(const MarketplaceLoading());

    await emit.forEach(
      getAnnouncements(GetAnnouncementsParams(category: event.category)),
      onData: (result) => result.fold(
            (failure) => MarketplaceError(failure.message),
            (announcements) => MarketplaceAnnouncementsLoaded(announcements),
      ),
    );
  }

  /// PENDING ad edit — replaces fields in-place, no admin review.
  Future<void> _onAdUpdateRequested(
      MarketplaceAdUpdateRequested event,
      Emitter<MarketplaceState> emit,
      ) async {
    emit(const MarketplaceAdCreating());

    final allImages = await _resolveImages(
      emit: emit,
      existingUrls: event.existingImageUrls,
      newImages: event.newImages,
    );
    if (allImages == null) return; // upload failed, error already emitted

    final result = await updateAdvertisement(UpdateAdvertisementParams(
      adId: event.adId,
      data: {
        'title': event.title,
        'description': event.description,
        'category': event.category,
        'price': event.price,
        'grade': event.grade,
        'location': event.location,
        'imageUrls': allImages,
        'status': 'pending',
        'isActive': false,
        'updatedAt': DateTime.now().toIso8601String(),
      },
    ));

    result.fold(
          (failure) => emit(MarketplaceError(failure.message)),
          (_) => emit(const MarketplaceAdUpdated()),
    );
  }

  /// LIVE/APPROVED ad edit — writes to `pendingEdit` subcollection.
  /// Original ad stays live until admin approves.
  Future<void> _onAdEditRequested(
      MarketplaceAdEditRequested event,
      Emitter<MarketplaceState> emit,
      ) async {
    emit(const MarketplaceAdCreating());

    final allImages = await _resolveImages(
      emit: emit,
      existingUrls: event.existingImageUrls,
      newImages: event.newImages,
    );
    if (allImages == null) return;

    final result = await submitAdEdit(SubmitAdEditParams(
      adId: event.adId,
      editData: {
        'title': event.title,
        'description': event.description,
        'category': event.category,
        'price': event.price,
        'grade': event.grade,
        'location': event.location,
        'imageUrls': allImages,
        'type': event.type,
        'submittedAt': DateTime.now().toIso8601String(),
        'status': 'pending',
      },
    ));

    result.fold(
          (failure) => emit(MarketplaceError(failure.message)),
          (_) => emit(const MarketplaceAdEditSubmitted()),
    );
  }

  Future<void> _onUserAdsLoadRequested(
      MarketplaceUserAdsLoadRequested event,
      Emitter<MarketplaceState> emit,
      ) async {
    emit(const MarketplaceLoading());
    await emit.forEach(
      getUserAdvertisements(event.userId),
      onData: (result) => result.fold(
            (failure) => MarketplaceError(failure.message),
            (ads) => MarketplaceLoaded(ads),
      ),
    );
  }

  Future<void> _onAdCreateRequested(
      MarketplaceAdCreateRequested event,
      Emitter<MarketplaceState> emit,
      ) async {
    emit(const MarketplaceAdCreating());
    final ad = AdvertisementEntity(
      id: '',
      sellerId: event.sellerId,
      sellerName: event.sellerName,
      sellerPhone: event.sellerPhone,
      sellerProfilePic: event.sellerProfilePic,
      title: event.title,
      description: event.description,
      category: event.category,
      price: event.price,
      grade: event.grade,
      quantity: event.quantity,
      location: event.location,
      imageUrls: [],
      createdAt: DateTime.now(),
      type: event.type,
    );
    final result = await createAdvertisement(
      CreateAdvertisementParams(ad: ad, images: event.images),
    );
    result.fold(
          (failure) => emit(MarketplaceError(failure.message)),
          (_) => emit(const MarketplaceAdCreated()),
    );
  }

  Future<void> _onFavoriteToggled(
      MarketplaceFavoriteToggled event,
      Emitter<MarketplaceState> emit,
      ) async {
    if (event.isFavorite) {
      await addToFavorites(
        FavoriteParams(userId: event.userId, adId: event.adId),
      );
    } else {
      await removeFromFavorites(
        FavoriteParams(userId: event.userId, adId: event.adId),
      );
    }
  }

  /// Uploads new images and merges with existing URLs.
  /// Returns null and emits [MarketplaceError] on failure.
  Future<List<String>?> _resolveImages({
    required Emitter<MarketplaceState> emit,
    required List<String> existingUrls,
    required List<dynamic> newImages,
  }) async {
    if (newImages.isEmpty) return existingUrls;

    final uploadResult = await uploadImages(newImages.cast());
    return uploadResult.fold(
          (failure) {
        emit(MarketplaceError(failure.message));
        return null;
      },
          (newUrls) => [...existingUrls, ...newUrls],
    );
  }

  @override
  Future<void> close() {
    _adsSubscription?.cancel();
    return super.close();
  }
}