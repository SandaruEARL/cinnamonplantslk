import 'package:equatable/equatable.dart';

enum LocationType { nursery, shop }
enum LocationStatus { pending, approved, rejected }

class BusinessLocation extends Equatable {
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
  final LocationStatus status;
  final String? rejectionReason;
  final DateTime createdAt;
  final DateTime updatedAt;

  const BusinessLocation({
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
    this.status = LocationStatus.pending,
    this.rejectionReason,
    required this.createdAt,
    required this.updatedAt,
  });

  factory BusinessLocation.fromJson(Map<String, dynamic> json) {
    return BusinessLocation(
      id:               json['id'] as String,
      userId:           json['userId'] as String,
      ownerName:        json['ownerName'] as String,
      ownerPhone:       json['ownerPhone'] as String,
      ownerProfilePic:  json['ownerProfilePic'] as String?,
      type:             _parseType(json['type'] as String?),
      businessName:     json['businessName'] as String,
      description:      json['description'] as String,
      address:          json['address'] as String,
      latitude:         (json['latitude'] as num).toDouble(),
      longitude:        (json['longitude'] as num).toDouble(),
      openingHours:     json['openingHours'] as String?,
      photoUrls:        List<String>.from(json['photoUrls'] as List? ?? []),
      status:           _parseStatus(json['status'] as String?),
      rejectionReason:  json['rejectionReason'] as String?,
      createdAt:        DateTime.parse(json['createdAt'] as String),
      updatedAt:        DateTime.parse(json['updatedAt'] as String),
    );
  }

  static LocationType _parseType(String? value) {
    return value == 'shop' ? LocationType.shop : LocationType.nursery;
  }

  static LocationStatus _parseStatus(String? value) {
    switch (value) {
      case 'approved': return LocationStatus.approved;
      case 'rejected': return LocationStatus.rejected;
      default:         return LocationStatus.pending;
    }
  }

  Map<String, dynamic> toJson() => {
    'userId':          userId,
    'ownerName':       ownerName,
    'ownerPhone':      ownerPhone,
    'ownerProfilePic': ownerProfilePic,
    'type':            type.name,
    'businessName':    businessName,
    'description':     description,
    'address':         address,
    'latitude':        latitude,
    'longitude':       longitude,
    'openingHours':    openingHours,
    'photoUrls':       photoUrls,
    'status':          status.name,
    'rejectionReason': rejectionReason,
    'createdAt':       createdAt.toIso8601String(),
    'updatedAt':       updatedAt.toIso8601String(),
  };

  bool get isPending  => status == LocationStatus.pending;
  bool get isApproved => status == LocationStatus.approved;
  bool get isRejected => status == LocationStatus.rejected;

  BusinessLocation copyWith({
    LocationStatus? status,
    String? rejectionReason,
    String? businessName,
    String? description,
    String? address,
    double? latitude,
    double? longitude,
    String? openingHours,
    List<String>? photoUrls,
    DateTime? updatedAt,
  }) => BusinessLocation(
    id:              id,
    userId:          userId,
    ownerName:       ownerName,
    ownerPhone:      ownerPhone,
    ownerProfilePic: ownerProfilePic,
    type:            type,
    businessName:    businessName    ?? this.businessName,
    description:     description     ?? this.description,
    address:         address         ?? this.address,
    latitude:        latitude        ?? this.latitude,
    longitude:       longitude       ?? this.longitude,
    openingHours:    openingHours    ?? this.openingHours,
    photoUrls:       photoUrls       ?? this.photoUrls,
    status:          status          ?? this.status,
    rejectionReason: rejectionReason ?? this.rejectionReason,
    createdAt:       createdAt,
    updatedAt:       updatedAt       ?? this.updatedAt,
  );

  @override
  List<Object?> get props => [id, userId, type, status, updatedAt];
}