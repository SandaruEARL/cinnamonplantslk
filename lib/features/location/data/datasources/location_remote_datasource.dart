import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../../core/error/exceptions.dart';
import '../../../../data/services/cloudinary/cloudinary_service.dart';
import '../../domain/entities/business_location_entity.dart';
import '../models/business_location_model.dart';

abstract class LocationRemoteDataSource {
  Stream<List<BusinessLocationModel>> getApprovedLocations(LocationType type);
  Stream<List<BusinessLocationModel>> getUserLocations(String userId);
  Future<void> saveLocation(BusinessLocationModel location);
  Future<List<String>> uploadPhotos(List<File> photos);
  Future<void> deleteLocation(String locationId);
}

class LocationRemoteDataSourceImpl implements LocationRemoteDataSource {
  final FirebaseFirestore _firestore;
  final CloudinaryService _cloudinary;

  LocationRemoteDataSourceImpl({
    required FirebaseFirestore firestore,
    required CloudinaryService cloudinary,
  })  : _firestore = firestore,
        _cloudinary = cloudinary;

  @override
  Stream<List<BusinessLocationModel>> getApprovedLocations(
      LocationType type,
      ) {
    try {
      return _firestore
          .collection('locations')
          .where('type', isEqualTo: type.name)
          .where('status', isEqualTo: 'approved')
          .snapshots()
          .map((snap) => snap.docs
          .map((doc) => BusinessLocationModel.fromFirestore(doc))
          .toList());
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  @override
  Stream<List<BusinessLocationModel>> getUserLocations(String userId) {
    try {
      return _firestore
          .collection('locations')
          .where('userId', isEqualTo: userId)
          .snapshots()
          .map((snap) => snap.docs
          .map((doc) => BusinessLocationModel.fromFirestore(doc))
          .toList());
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  @override
  Future<void> saveLocation(BusinessLocationModel location) async {
    try {
      if (location.id.isEmpty) {
        await _firestore.collection('locations').add(location.toFirestore());
      } else {
        await _firestore
            .collection('locations')
            .doc(location.id)
            .set(location.toFirestore(), SetOptions(merge: true));
      }
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  @override
  Future<List<String>> uploadPhotos(List<File> photos) async {
    try {
      return await _cloudinary.uploadAdImages(photos);
    } catch (e) {
      throw ServerException('Photo upload failed: $e');
    }
  }

  @override
  Future<void> deleteLocation(String locationId) async {
    try {
      await _firestore.collection('locations').doc(locationId).delete();
    } catch (e) {
      throw ServerException(e.toString());
    }
  }
}