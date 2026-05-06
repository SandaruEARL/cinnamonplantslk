import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/usecase/usecase.dart';
import '../../domain/usecases/forgot_password.dart';
import '../../domain/usecases/get_current_user.dart';
import '../../domain/usecases/sign_in.dart';
import '../../domain/usecases/sign_out.dart';
import '../../domain/usecases/sign_up.dart';
import '../../domain/usecases/update_profile.dart';

import 'auth_event.dart';
import 'auth_state.dart';
import '../../domain/entities/user_entity.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final SignIn signIn;
  final SignUp signUp;
  final SignOut signOut;
  final GetCurrentUser getCurrentUser;
  final UpdateProfile updateProfile;
  final ForgotPassword forgotPassword;

  AuthBloc({
    required this.signIn,
    required this.signUp,
    required this.signOut,
    required this.getCurrentUser,
    required this.updateProfile,
    required this.forgotPassword,
  }) : super(const AuthInitial()) {
    on<AuthCheckRequested>(_onCheckRequested);
    on<AuthSignInRequested>(_onSignInRequested);
    on<AuthSignUpRequested>(_onSignUpRequested);
    on<AuthSignOutRequested>(_onSignOutRequested);
    on<AuthProfileUpdateRequested>(_onProfileUpdateRequested);
    on<AuthForgotPasswordRequested>(_onForgotPasswordRequested);
  }

  Future<void> _onCheckRequested(
      AuthCheckRequested event,
      Emitter<AuthState> emit,
      ) async {
    emit(const AuthLoading());
    final result = await getCurrentUser(NoParams());
    result.fold(
          (failure) => emit(const AuthUnauthenticated()),
          (user) => user != null
          ? emit(AuthAuthenticated(user))
          : emit(const AuthUnauthenticated()),
    );
  }

  Future<void> _onProfileUpdateRequested(
      AuthProfileUpdateRequested event,
      Emitter<AuthState> emit,
      ) async {
    final currentState = state;
    if (currentState is! AuthAuthenticated) return;

    final result = await updateProfile(
      UpdateProfileParams(
        uid: event.uid,
        name: event.name,
        phone: event.phone,
        location: event.location,
      ),
    );

    result.fold(
          (failure) => emit(AuthError(failure.message)),
          (_) {
        final updated = UserEntityX.from(
          currentState.user,
          name: event.name,
          phone: event.phone,
          location: event.location,
        );
        emit(AuthAuthenticated(updated));
      },
    );
  }

  Future<void> _onSignInRequested(
      AuthSignInRequested event,
      Emitter<AuthState> emit,
      ) async {
    emit(const AuthLoading());
    final result = await signIn(
      SignInParams(email: event.email, password: event.password),
    );
    result.fold(
          (failure) => emit(AuthError(failure.message)),
          (user) => emit(AuthAuthenticated(user)),
    );
  }

  Future<void> _onSignUpRequested(
      AuthSignUpRequested event,
      Emitter<AuthState> emit,
      ) async {
    emit(const AuthLoading());
    final result = await signUp(
      SignUpParams(
        email: event.email,
        password: event.password,
        name: event.name,
        phone: event.phone,
        userType: event.userType,
      ),
    );
    result.fold(
          (failure) => emit(AuthError(failure.message)),
          (user) => emit(AuthAuthenticated(user)),
    );
  }

  Future<void> _onSignOutRequested(
      AuthSignOutRequested event,
      Emitter<AuthState> emit,
      ) async {
    await signOut(NoParams());
    emit(const AuthUnauthenticated());
  }

  Future<void> _onForgotPasswordRequested(
      AuthForgotPasswordRequested event,
      Emitter<AuthState> emit,
      ) async {
    emit(const AuthLoading());
    final result = await forgotPassword(
      ForgotPasswordParams(email: event.email),
    );
    result.fold(
          (failure) => emit(AuthError(failure.message)),
          (_) => emit(const AuthPasswordResetEmailSent()),
    );
  }
}