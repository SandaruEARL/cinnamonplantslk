import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../data/services/firebase/auth_service.dart';
import '../../../domain/entities/user.dart' as app_user;
import 'auth_event.dart';
import 'auth_state.dart';



class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final AuthService authService;

  AuthBloc({required this.authService}) : super(const AuthInitial()) {
    on<AuthCheckRequested>(_onAuthCheckRequested);
    on<AuthSignUpRequested>(_onSignUpRequested);
    on<AuthSignInRequested>(_onSignInRequested);
    on<AuthSignOutRequested>(_onSignOutRequested);
  }

  Future<void> _onAuthCheckRequested(
      AuthCheckRequested event,
      Emitter<AuthState> emit,
      ) async {
    try {
      final currentUser = authService.currentUser;
      if (currentUser != null) {
        final user = await authService.getUserData(currentUser.uid);
        if (user != null) {
          emit(AuthAuthenticated(user));
        } else {
          emit(const AuthUnauthenticated());
        }
      } else {
        emit(const AuthUnauthenticated());
      }
    } catch (e) {
      emit(AuthError(e.toString()));
    }
  }

  Future<void> _onSignUpRequested(
      AuthSignUpRequested event,
      Emitter<AuthState> emit,
      ) async {
    emit(const AuthLoading());
    try {
      final user = await authService.signUp(
        email: event.email,
        password: event.password,
        name: event.name,
        phone: event.phone,
        userType: event.userType,
      );
      emit(AuthAuthenticated(user));
    } catch (e) {
      emit(AuthError(e. toString()));
    }
  }

  Future<void> _onSignInRequested(
      AuthSignInRequested event,
      Emitter<AuthState> emit,
      ) async {
    emit(const AuthLoading());
    try {
      final user = await authService.signIn(
        email: event.email,
        password: event.password,
      );

      // Debug log to catch type issues
      debugPrint('Sign-in returned type: ${user.runtimeType}');
      debugPrint('Sign-in returned value: $user');

      emit(AuthAuthenticated(user));
        } catch (e, stackTrace) {
      debugPrint('Sign-in exception: $e');
      debugPrint('$stackTrace');
      emit(AuthError(e.toString()));
    }
  }


  Future<void> _onSignOutRequested(
      AuthSignOutRequested event,
      Emitter<AuthState> emit,
      ) async {
    try {
      await authService.signOut();
      emit(const AuthUnauthenticated());
    } catch (e) {
      emit(AuthError(e.toString()));
    }
  }
}