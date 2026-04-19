import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../../core/error/exceptions.dart';
import '../../../../data/services/cloudinary/cloudinary_service.dart';
import '../models/advertisement_model.dart';

abstract class MarketplaceRemoteDataSource {
  Stream<List<AdvertisementModel>> getAdvertisements({
    String? category,
    int? limit,
  });

  Stream<List<AdvertisementModel>> getUserAdvertisements(String userId);

  Future<void> createAdvertisement(
      AdvertisementModel ad,
      List<String> imageUrls,
      );

  Future<List<String>> uploadImages(List<File> images);

  Future<void> addToFavorites(String userId, String adId);

  Future<void> removeFromFavorites(String userId, String adId);
}

class MarketplaceRemoteDataSourceImpl implements MarketplaceRemoteDataSource {
  final FirebaseFirestore _firestore;
  final CloudinaryService _cloudinary;

  MarketplaceRemoteDataSourceImpl({
    required FirebaseFirestore firestore,
    required CloudinaryService cloudinary,
  })  : _firestore = firestore,
        _cloudinary = cloudinary;

  @override
  Stream<List<AdvertisementModel>> getAdvertisements({
    String? category,
    int? limit,
  }) {
    try {
      Query query = _firestore
          .collection('advertisements')
          .where('status', isEqualTo: 'approved')
          .orderBy('createdAt', descending: true);

      if (category != null) {
        query = query.where('category', isEqualTo: category);
      }
      if (limit != null) {
        query = query.limit(limit);
      }

      return query.snapshots().map(
            (snap) => snap.docs
            .map((doc) => AdvertisementModel.fromFirestore(doc))
            .toList(),
      );
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  @override
  Stream<List<AdvertisementModel>> getUserAdvertisements(String userId) {
    try {
      return _firestore
          .collection('advertisements')
          .where('sellerId', isEqualTo: userId)
          .orderBy('createdAt', descending: true)
          .snapshots()
          .map((snap) =>
          snap.docs.map((doc) => AdvertisementModel.fromFirestore(doc)).toList());
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  @override
  Future<void> createAdvertisement(
      AdvertisementModel ad,
      List<String> imageUrls,
      ) async {
    try {
      final data = ad.toFirestore();
      data['imageUrls'] = imageUrls;
      await _firestore.collection('advertisements').add(data);
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  @override
  Future<List<String>> uploadImages(List<File> images) async {
    try {
      return await _cloudinary.uploadAdImages(images);
    } catch (e) {
      throw ServerException('Image upload failed: $e');
    }
  }

  @override
  Future<void> addToFavorites(String userId, String adId) async {
    try {
      await _firestore.collection('users').doc(userId).update({
        'favorites': FieldValue.arrayUnion([adId]),
      });
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  @override
  Future<void> removeFromFavorites(String userId, String adId) async {
    try {
      await _firestore.collection('users').doc(userId).update({
        'favorites': FieldValue.arrayRemove([adId]),
      });
    } catch (e) {
      throw ServerException(e.toString());
    }
  }
}