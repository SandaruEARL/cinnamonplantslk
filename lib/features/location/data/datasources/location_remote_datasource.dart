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
  Future<void> submitLocationEdit(String locationId, Map<String, dynamic> editData);
}

class LocationRemoteDataSourceImpl implements LocationRemoteDataSource {
  final FirebaseFirestore _firestore;
  final CloudinaryService _cloudinary;

  LocationRemoteDataSourceImpl({
    required FirebaseFirestore firestore,
    required CloudinaryService cloudinary,
  })  : _firestore = firestore,
        _cloudinary = cloudinary;

  Stream<List<BusinessLocationModel>> getApprovedLocations(LocationType type) {
    return _firestore
        .collection('locations')
        .where('type', isEqualTo: type.name)
        .where('status', isEqualTo: 'approved')
        .snapshots()
        .map((snap) {
      print('DEBUG: got ${snap.docs.length} docs for type=${type.name}');
      final results = <BusinessLocationModel>[];
      for (final doc in snap.docs) {
        try {
          results.add(BusinessLocationModel.fromFirestore(doc));
          print('DEBUG: parsed ${doc.id} ok');
        } catch (e) {
          print('DEBUG: failed to parse ${doc.id}: $e');
        }
      }
      print('DEBUG: returning ${results.length} locations');
      return results;
    });
  }

  @override
  Future<void> submitLocationEdit(
      String locationId,
      Map<String, dynamic> editData,
      ) async {
    try {
      await _firestore
          .collection('locations')
          .doc(locationId)
          .collection('pendingEdit')
          .add(editData);
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  @override
  Stream<List<BusinessLocationModel>> getUserLocations(String userId) {
    return _firestore
        .collection('locations')
        .where('userId', isEqualTo: userId)
        .snapshots()
        .map((snap) {
      final results = <BusinessLocationModel>[];
      for (final doc in snap.docs) {
        try {
          results.add(BusinessLocationModel.fromFirestore(doc));
        } catch (e) {
          // skip malformed docs
        }
      }
      return results;
    });
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
            .update({
          'businessName': location.businessName,
          'description': location.description,
          'address': location.address,
          'latitude': location.latitude,
          'longitude': location.longitude,
          'ownerPhone': location.ownerPhone,
          'ownerName': location.ownerName,
          'ownerProfilePic': location.ownerProfilePic,
          'openingHours': location.openingHours,
          'photoUrls': location.photoUrls,
          'updatedAt': FieldValue.serverTimestamp(),
        });
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