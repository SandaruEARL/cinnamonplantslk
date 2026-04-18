import 'package:equatable/equatable.dart';

enum AdStatus { pending, approved, rejected }

class Advertisement extends Equatable {
  final String id;
  final String sellerId;
  final String sellerName;
  final String sellerPhone;
  final String?  sellerProfilePic;
  final bool sellerVerified;
  final String title;
  final String description;
  final String category;
  final double price;
  final String? grade; // For cinnamon bales
  final int?  quantity;
  final String location;
  final List<String> imageUrls;
  final DateTime createdAt;
  final bool isActive;
  final int views;
  final int favorites;
  final AdStatus status;
  final String? rejectionReason;

  const Advertisement({
    required this.id,
    required this.sellerId,
    required this.sellerName,
    required this.sellerPhone,
    this.sellerProfilePic,
    this.sellerVerified = false,
    required this.title,
    required this.description,
    required this.category,
    required this.price,
    this.grade,
    this.quantity,
    required this.location,
    required this.imageUrls,
    required this.createdAt,
    this.isActive = false,
    this.views = 0,
    this.favorites = 0,
    this.status = AdStatus.pending,
    this.rejectionReason,
  });

  factory Advertisement.fromJson(Map<String, dynamic> json) {
    return Advertisement(
      id: json['id'] as String,
      sellerId: json['sellerId'] as String,
      sellerName: json['sellerName'] as String,
      sellerPhone: json['sellerPhone'] as String,
      sellerProfilePic: json['sellerProfilePic'] as String?,
      sellerVerified: json['sellerVerified'] as bool? ?? false,
      title: json['title'] as String,
      description: json['description'] as String,
      category: json['category'] as String,
      price: (json['price'] as num). toDouble(),
      grade: json['grade'] as String?,
      quantity: json['quantity'] as int?,
      location: json['location'] as String,
      imageUrls: List<String>.from(json['imageUrls'] as List),
      createdAt: DateTime. parse(json['createdAt'] as String),
      isActive: json['isActive'] as bool? ?? false,
      status: _parseStatus(json['status'] as String?),
      rejectionReason: json['rejectionReason'] as String?,
      views: json['views'] as int? ?? 0,
      favorites: json['favorites'] as int? ?? 0,
    );
  }

  static AdStatus _parseStatus(String? value) {
    switch (value) {
      case 'approved': return AdStatus.approved;
      case 'rejected': return AdStatus.rejected;
      default: return AdStatus.pending;
    }
  }

  Map<String, dynamic> toJson() {
    return {
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
      'createdAt': createdAt.toIso8601String(),
      'isActive':  isActive,
      'status': status.name,
      'rejectionReason': rejectionReason,
      'views': views,
      'favorites': favorites,

    };
  }

  bool get isPending  => status == AdStatus.pending;
  bool get isApproved => status == AdStatus.approved;
  bool get isRejected => status == AdStatus.rejected;

  @override
  List<Object?> get props => [
    id,
    sellerId,
    title,
    category,
    price,
    location,
    createdAt,
    status
  ];

}