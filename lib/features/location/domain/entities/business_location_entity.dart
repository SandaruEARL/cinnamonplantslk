enum LocationType { nursery, shop }

class BusinessLocationEntity {
  final String id;
  final String userId;
  final String ownerName;
  final String ownerPhone;
  final String? ownerProfilePic;
  final LocationType type;
  final String businessName;
  final String description;
  final String address;
  final double latitude;
  final double longitude;
  final String? openingHours;
  final List<String> photoUrls;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String status;
  final String? rejectionReason;

  bool get isApproved => status == 'approved';
  bool get isPending => status == 'pending';
  bool get isRejected => status == 'rejected';

  const BusinessLocationEntity({
    required this.id,
    required this.userId,
    required this.ownerName,
    required this.ownerPhone,
    this.ownerProfilePic,
    required this.type,
    required this.businessName,
    required this.description,
    required this.address,
    required this.latitude,
    required this.longitude,
    this.openingHours,
    required this.photoUrls,
    required this.createdAt,
    required this.updatedAt,
    this.status = 'pending',
    this.rejectionReason,
  });
}