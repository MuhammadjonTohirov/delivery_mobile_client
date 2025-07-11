import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:delivery_customer/core/services/api/api_service.dart';
import '../../../../core/services/storage_service.dart';

// Events
abstract class AuthEvent extends Equatable {
  const AuthEvent();

  @override
  List<Object> get props => [];
}

class AuthCheckRequested extends AuthEvent {}

class AuthLoginRequested extends AuthEvent {
  final String email;
  final String password;

  const AuthLoginRequested({
    required this.email,
    required this.password,
  });

  @override
  List<Object> get props => [email, password];
}

class AuthRegisterRequested extends AuthEvent {
  final String email;
  final String password;
  final String fullName;
  final String? phone;

  const AuthRegisterRequested({
    required this.email,
    required this.password,
    required this.fullName,
    this.phone,
  });

  @override
  List<Object> get props => [email, password, fullName];
}

class AuthLogoutRequested extends AuthEvent {}

class AuthForgotPasswordRequested extends AuthEvent {
  final String email;

  const AuthForgotPasswordRequested({
    required this.email,
  });

  @override
  List<Object> get props => [email];
}

// States
abstract class AuthState extends Equatable {
  const AuthState();

  @override
  List<Object> get props => [];
}

class AuthInitial extends AuthState {}

class AuthLoading extends AuthState {}

class AuthAuthenticated extends AuthState {
  final Map<String, dynamic> user;

  const AuthAuthenticated({required this.user});

  @override
  List<Object> get props => [user];
}

class AuthUnauthenticated extends AuthState {}

class AuthError extends AuthState {
  final String message;

  const AuthError({required this.message});

  @override
  List<Object> get props => [message];
}

class AuthRegistrationSuccess extends AuthState {
  final String message;

  const AuthRegistrationSuccess({required this.message});

  @override
  List<Object> get props => [message];
}

class AuthForgotPasswordSuccess extends AuthState {
  final String message;

  const AuthForgotPasswordSuccess({required this.message});

  @override
  List<Object> get props => [message];
}

// Bloc
class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final ApiService apiService;

  AuthBloc({required this.apiService}) : super(AuthInitial()) {
    on<AuthCheckRequested>(_onAuthCheckRequested);
    on<AuthLoginRequested>(_onAuthLoginRequested);
    on<AuthRegisterRequested>(_onAuthRegisterRequested);
    on<AuthLogoutRequested>(_onAuthLogoutRequested);
    on<AuthForgotPasswordRequested>(_onAuthForgotPasswordRequested);
  }

  Future<void> _onAuthCheckRequested(
    AuthCheckRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());

    try {
      final token = await StorageService.getAuthToken();
      if (token == null) {
        emit(AuthUnauthenticated());
        return;
      }

      // Verify token by getting user profile
      final response = await apiService.getUserProfile();
      if (response.success && response.data != null) {
        await StorageService.setUserData(response.data!);
        emit(AuthAuthenticated(user: response.data!));
      } else {
        // Token is invalid, remove it
        await StorageService.removeAuthToken();
        emit(AuthUnauthenticated());
      }
    } catch (e) {
      await StorageService.removeAuthToken();
      emit(AuthUnauthenticated());
    }
  }

  Future<void> _onAuthLoginRequested(
    AuthLoginRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());

    try {
      final response = await apiService.login(event.email, event.password);
      
      if (response.success && response.data != null) {
        final data = response.data!;
        
        // Store token and user data
        if (data.containsKey('access_token') || data.containsKey('token') || data.containsKey('access')) {
          final token = data['access_token'] ?? data['token'] ?? data['access'];
          await StorageService.setAuthToken(token);
        }
        
        if (data.containsKey('user')) {
          await StorageService.setUserData(data['user']);
          emit(AuthAuthenticated(user: data['user']));
        } else {
          // Get user profile after login
          final profileResponse = await apiService.getUserProfile();
          if (profileResponse.success && profileResponse.data != null) {
            await StorageService.setUserData(profileResponse.data!);
            emit(AuthAuthenticated(user: profileResponse.data!));
          } else {
            emit(const AuthError(message: 'Failed to get user profile'));
          }
        }
      } else {
        emit(AuthError(message: response.error ?? 'Login failed'));
      }
    } catch (e) {
      emit(AuthError(message: 'An unexpected error occurred: ${e.toString()}'));
    }
  }

  Future<void> _onAuthRegisterRequested(
    AuthRegisterRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());

    try {
      final response = await apiService.register(
        email: event.email,
        password: event.password,
        fullName: event.fullName,
        phone: event.phone,
      );
      
      if (response.success && response.data != null) {
        // Registration successful - emit success state instead of auto-login
        emit(const AuthRegistrationSuccess(
          message: 'Registration successful! Please login with your credentials.',
        ));
      } else {
        emit(AuthError(message: response.error ?? 'Registration failed'));
      }
    } catch (e) {
      emit(AuthError(message: 'An unexpected error occurred: ${e.toString()}'));
    }
  }

  Future<void> _onAuthLogoutRequested(
    AuthLogoutRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());

    try {
      await StorageService.logout();
      emit(AuthUnauthenticated());
    } catch (e) {
      // Even if logout fails, clear local data
      await StorageService.logout();
      emit(AuthUnauthenticated());
    }
  }

  Future<void> _onAuthForgotPasswordRequested(
    AuthForgotPasswordRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());

    try {
      final response = await apiService.forgotPassword(event.email);
      
      if (response.success && response.data != null) {
        final message = response.data!['message'] ?? 
            'If your email is registered, you will receive password reset instructions.';
        emit(AuthForgotPasswordSuccess(message: message));
      } else {
        emit(AuthError(message: response.error ?? 'Failed to send reset instructions'));
      }
    } catch (e) {
      emit(AuthError(message: 'An unexpected error occurred: ${e.toString()}'));
    }
  }
}