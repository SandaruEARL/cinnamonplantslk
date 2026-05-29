abstract class AuthEvent {
  const AuthEvent();
}

class AuthCheckRequested extends AuthEvent {
  const AuthCheckRequested();
}

class AuthSignInRequested extends AuthEvent {
  final String email;
  final String password;
  const AuthSignInRequested({required this.email, required this.password});
}

class AuthSignUpRequested extends AuthEvent {
  final String email;
  final String password;
  final String name;
  final String phone;
  final String userType;
  const AuthSignUpRequested({
    required this.email,
    required this.password,
    required this.name,
    required this.phone,
    required this.userType,
  });
}

class AuthProfileUpdateRequested extends AuthEvent {
  final String uid;
  final String? name;
  final String? phone;
  final String? location;

  const AuthProfileUpdateRequested({
    required this.uid,
    this.name,
    this.phone,
    this.location,
  });

  @override
  List<Object?> get props => [uid, name, phone, location];
}

class AuthSignOutRequested extends AuthEvent {
  const AuthSignOutRequested();
}

class AuthForgotPasswordRequested extends AuthEvent {
  final String email;
  const AuthForgotPasswordRequested({required this.email});
}