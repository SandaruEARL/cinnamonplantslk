import '../../domain/entities/user_entity.dart';

// Model knows about JSON/Firebase — entity does NOT
class UserModel extends UserEntity {
  const UserModel({
    required super.id,
    required super.name,
    required super.email,
    required super.phone,
    required super.userType,
    required super.blockedUsers,
    super.profilePicUrl,
    super.location,
    super.isVerified,
  });

  factory UserModel.fromFirestore(Map<String, dynamic> map, String uid) {
    return UserModel(
      id: uid,
      name: map['name'] ?? '',
      email: map['email'] ?? '',
      phone: map['phone'] ?? '',
      userType: map['userType'] ?? '',
      profilePicUrl: map['profilePicUrl'],
      location: map['location'],
      isVerified: map['isVerified'] ?? false,
      blockedUsers: List<String>.from(map['blockedUsers'] ?? []),

    );
  }

  Map<String, dynamic> toFirestore() => {
    'name': name,
    'email': email,
    'phone': phone,
    'userType': userType,
    'profilePicUrl': profilePicUrl,
    'location': location,
    'isVerified': isVerified,
    'blockedUsers': blockedUsers,
  };
}