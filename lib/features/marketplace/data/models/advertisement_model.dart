import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/advertisement_entity.dart';

class AdvertisementModel extends AdvertisementEntity {
  const AdvertisementModel({
    required super.id,
    required super.sellerId,
    required super.sellerName,
    required super.sellerPhone,
    super.sellerProfilePic,
    super.sellerVerified,
    required super.title,
    required super.description,
    required super.category,
    required super.price,
    super.grade,
    super.quantity,
    required super.location,
    required super.imageUrls,
    required super.createdAt,
    super.status,
    super.rejectionReason,
  });

  factory AdvertisementModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return AdvertisementModel(
      id: doc.id,
      sellerId: data['sellerId'] ?? '',
      sellerName: data['sellerName'] ?? '',
      sellerPhone: data['sellerPhone'] ?? '',
      sellerProfilePic: data['sellerProfilePic'],
      sellerVerified: data['sellerVerified'] ?? false,
      title: data['title'] ?? '',
      description: data['description'] ?? '',
      category: data['category'] ?? '',
      price: (data['price'] ?? 0).toDouble(),
      grade: data['grade'],
      quantity: data['quantity'],
      location: data['location'] ?? '',
      imageUrls: List<String>.from(data['imageUrls'] ?? []),
      createdAt: data['createdAt'] is Timestamp
          ? (data['createdAt'] as Timestamp).toDate()
          : DateTime.parse(data['createdAt'] as String),
      status: data['status'] ?? 'pending',
      rejectionReason: data['rejectionReason'],
    );
  }

  Map<String, dynamic> toFirestore() => {
    'sellerId': sellerId,
    'sellerName': sellerName,
    'sellerPhone': sellerPhone,
    'sellerProfilePic': sellerProfilePic,
    'sellerVerified': sellerVerified,
    'title': title,
    'description': description,
    'category': category,
    'price': price,
    'grade': grade,
    'quantity': quantity,
    'location': location,
    'imageUrls': imageUrls,
    'createdAt': Timestamp.fromDate(createdAt),
    'status': status,
    'rejectionReason': rejectionReason,
  };
}