import 'package:equatable/equatable.dart';

class UserEntity extends Equatable {
  final String id;
  final String name;
  final String email;
  final String phone;
  final String userType;
  final String? profilePicUrl;
  final String? location;
  final bool isVerified;
  final List<String> blockedUsers;

  const UserEntity({
    required this.id,
    required this.name,
    required this.email,
    required this.phone,
    required this.userType,
    this.profilePicUrl,
    this.location,
    this.isVerified = false,
    this.blockedUsers = const [],
  });

  @override
  List<Object?> get props => [
    id, name, email, phone, userType,
    profilePicUrl, location, isVerified,
  ];
}

extension UserEntityX on UserEntity {
  UserEntity copyWith({
    String? name,
    String? phone,
    String? location,
    String? profilePicUrl,
    List<String>? blockedUsers,
  }) {
    return UserEntity(
      id:            id,
      name:          name          ?? this.name,
      email:         email,
      phone:         phone         ?? this.phone,
      userType:      userType,
      profilePicUrl: profilePicUrl ?? this.profilePicUrl,
      location:      location      ?? this.location,
      isVerified:    isVerified,
      blockedUsers:  blockedUsers  ?? this.blockedUsers,
    );
  }

  static UserEntity from(
      UserEntity base, {
        String? name,
        String? phone,
        String? location,
      }) {
    return base.copyWith(
      name:     name,
      phone:    phone,
      location: location,
    );
  }
}