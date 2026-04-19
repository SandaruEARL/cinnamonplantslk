class AdvertisementEntity {
  final String id;
  final String sellerId;
  final String sellerName;
  final String sellerPhone;
  final String? sellerProfilePic;
  final bool sellerVerified;
  final String title;
  final String description;
  final String category;
  final double price;
  final String? grade;
  final int? quantity;
  final String location;
  final List<String> imageUrls;
  final DateTime createdAt;
  final String status; // pending, approved, rejected
  final String? rejectionReason;

  bool get isPending => status == 'pending';
  bool get isApproved => status == 'approved';
  bool get isRejected => status == 'rejected';

  const AdvertisementEntity({
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
    this.status = 'pending',
    this.rejectionReason,
  });
}