import 'package:equatable/equatable.dart';

class User extends Equatable {
  final String id;
  final String email;
  final String name;
  final String phone;
  final String userType;
  final String?  profilePicUrl;
  final String? location;
  final bool isVerified;
  final double rating;
  final int totalRatings;
  final DateTime createdAt;

  const User({
    required this.id,
    required this.email,
    required this.name,
    required this.phone,
    required this.userType,
    this.profilePicUrl,
    this.location,
    this. isVerified = false,
    this.rating = 0.0,
    this.totalRatings = 0,
    required this.createdAt,
  });

  factory User. fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'] as String,
      email: json['email'] as String,
      name: json['name'] as String,
      phone: json['phone'] as String,
      userType: json['userType'] as String,
      profilePicUrl: json['profilePicUrl'] as String?,
      location: json['location'] as String?,
      isVerified: json['isVerified'] as bool?  ?? false,
      rating: (json['rating'] as num?)?.toDouble() ?? 0.0,
      totalRatings: json['totalRatings'] as int? ?? 0,
      createdAt: DateTime.parse(json['createdAt'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'name': name,
      'phone': phone,
      'userType': userType,
      'profilePicUrl': profilePicUrl,
      'location': location,
      'isVerified': isVerified,
      'rating': rating,
      'totalRatings': totalRatings,
      'createdAt': createdAt. toIso8601String(),
    };
  }

  @override
  List<Object? > get props => [
    id,
    email,
    name,
    phone,
    userType,
    profilePicUrl,
    location,
    isVerified,
    rating,
    totalRatings,
    createdAt,
  ];
}