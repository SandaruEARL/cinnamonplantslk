import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/business_location_entity.dart';

class BusinessLocationModel extends BusinessLocationEntity {
  const BusinessLocationModel({
    required super.id,
    required super.userId,
    required super.ownerName,
    required super.ownerPhone,
    super.ownerProfilePic,
    required super.type,
    required super.businessName,
    required super.description,
    required super.address,
    required super.latitude,
    required super.longitude,
    super.openingHours,
    required super.photoUrls,
    required super.createdAt,
    required super.updatedAt,
    super.status,
    super.rejectionReason,
  });

  factory BusinessLocationModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return BusinessLocationModel(
      id: doc.id,
      userId: data['userId'] ?? '',
      ownerName: data['ownerName'] ?? '',
      ownerPhone: data['ownerPhone'] ?? '',
      ownerProfilePic: data['ownerProfilePic'],
      type: data['type'] == 'nursery' ? LocationType.nursery : LocationType.shop,
      businessName: data['businessName'] ?? '',
      description: data['description'] ?? '',
      address: data['address'] ?? '',
      latitude: (data['latitude'] ?? 0).toDouble(),
      longitude: (data['longitude'] ?? 0).toDouble(),
      openingHours: data['openingHours'],
      photoUrls: List<String>.from(data['photoUrls'] ?? []),
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      updatedAt: (data['updatedAt'] as Timestamp).toDate(),
      status: data['status'] ?? 'pending',
      rejectionReason: data['rejectionReason'],
    );
  }

  Map<String, dynamic> toFirestore() => {
    'userId': userId,
    'ownerName': ownerName,
    'ownerPhone': ownerPhone,
    'ownerProfilePic': ownerProfilePic,
    'type': type.name,
    'businessName': businessName,
    'description': description,
    'address': address,
    'latitude': latitude,
    'longitude': longitude,
    'openingHours': openingHours,
    'photoUrls': photoUrls,
    'createdAt': Timestamp.fromDate(createdAt),
    'updatedAt': Timestamp.fromDate(updatedAt),
    'status': status,
    'rejectionReason': rejectionReason,
  };
}