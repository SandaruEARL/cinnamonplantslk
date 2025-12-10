import 'package:equatable/equatable.dart';

abstract class AuthEvent extends Equatable {
  const AuthEvent();

  @override
  List<Object? > get props => [];
}

class AuthCheckRequested extends AuthEvent {}

class AuthSignUpRequested extends AuthEvent {
  final String email;
  final String password;
  final String name;
  final String phone;
  final String userType;

  const AuthSignUpRequested({
    required this.email,
    required this. password,
    required this.name,
    required this.phone,
    required this.userType,
  });

  @override
  List<Object?> get props => [email, password, name, phone, userType];
}

class AuthSignInRequested extends AuthEvent {
  final String email;
  final String password;

  const AuthSignInRequested({
    required this.email,
    required this.password,
  });

  @override
  List<Object?> get props => [email, password];
}

class AuthSignOutRequested extends AuthEvent {}