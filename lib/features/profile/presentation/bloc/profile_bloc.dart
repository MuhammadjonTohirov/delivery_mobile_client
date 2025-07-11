import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:image_picker/image_picker.dart';
import '../../../../core/services/api_service.dart';
import '../../../../core/services/storage_service.dart';
import '../../../../core/services/logger_service.dart';

// Events
abstract class ProfileEvent extends Equatable {
  const ProfileEvent();

  @override
  List<Object> get props => [];
}

class ProfileLoadRequested extends ProfileEvent {}

class ProfileUpdateRequested extends ProfileEvent {
  final String? fullName;
  final String? phone;
  final String? email;

  const ProfileUpdateRequested({
    this.fullName,
    this.phone,
    this.email,
  });

  @override
  List<Object> get props => [fullName ?? '', phone ?? '', email ?? ''];
}

class ProfileImageUpdateRequested extends ProfileEvent {
  final XFile imageFile;

  const ProfileImageUpdateRequested({required this.imageFile});

  @override
  List<Object> get props => [imageFile];
}

// States
abstract class ProfileState extends Equatable {
  const ProfileState();

  @override
  List<Object> get props => [];
}

class ProfileInitial extends ProfileState {}

class ProfileLoading extends ProfileState {}

class ProfileLoaded extends ProfileState {
  final Map<String, dynamic> user;

  const ProfileLoaded({required this.user});

  @override
  List<Object> get props => [user];
}

class ProfileUpdating extends ProfileState {
  final Map<String, dynamic> user;

  const ProfileUpdating({required this.user});

  @override
  List<Object> get props => [user];
}

class ProfileError extends ProfileState {
  final String message;

  const ProfileError({required this.message});

  @override
  List<Object> get props => [message];
}

// Bloc
class ProfileBloc extends Bloc<ProfileEvent, ProfileState> {
  final ApiService _apiService;

  ProfileBloc({ApiService? apiService})
      : _apiService = apiService ?? ApiService(),
        super(ProfileInitial()) {
    on<ProfileLoadRequested>(_onProfileLoadRequested);
    on<ProfileUpdateRequested>(_onProfileUpdateRequested);
    on<ProfileImageUpdateRequested>(_onProfileImageUpdateRequested);
  }

  Future<void> _onProfileLoadRequested(
    ProfileLoadRequested event,
    Emitter<ProfileState> emit,
  ) async {
    emit(ProfileLoading());
    try {
      // Try to load from server first
      final response = await _apiService.getUserProfile();
      
      if (response.success && response.data != null) {
        final userData = response.data!;
        
        // Save to local storage
        await StorageService.setUserData(userData);
        
        emit(ProfileLoaded(user: userData));
      } else {
        // Fallback to local storage
        final userData = StorageService.getUserData();
        if (userData != null && userData.isNotEmpty) {
          emit(ProfileLoaded(user: userData));
        } else {
          emit(ProfileError(message: response.error ?? 'Failed to load profile'));
        }
      }
    } catch (e) {
      // Try local storage as fallback
      try {
        final userData = StorageService.getUserData();
        if (userData != null && userData.isNotEmpty) {
          emit(ProfileLoaded(user: userData));
        } else {
          emit(ProfileError(message: 'Failed to load profile: ${e.toString()}'));
        }
      } catch (localError) {
        emit(ProfileError(message: 'Failed to load profile: ${e.toString()}'));
      }
    }
  }

  Future<void> _onProfileUpdateRequested(
    ProfileUpdateRequested event,
    Emitter<ProfileState> emit,
  ) async {
    final currentState = state;
    if (currentState is ProfileLoaded) {
      emit(ProfileUpdating(user: currentState.user));
      
      try {
        final response = await _apiService.updateProfile(
          fullName: event.fullName,
          phone: event.phone,
          email: event.email,
        );
        
        if (response.success && response.data != null) {
          final updatedUser = response.data!;
          
          // Save updated data to local storage
          await StorageService.setUserData(updatedUser);
          
          emit(ProfileLoaded(user: updatedUser));
        } else {
          // Revert to previous state
          emit(ProfileLoaded(user: currentState.user));
          emit(ProfileError(message: response.error ?? 'Failed to update profile'));
        }
      } catch (e) {
        // Revert to previous state
        emit(ProfileLoaded(user: currentState.user));
        emit(ProfileError(message: 'Failed to update profile: ${e.toString()}'));
      }
    }
  }

  Future<void> _onProfileImageUpdateRequested(
    ProfileImageUpdateRequested event,
    Emitter<ProfileState> emit,
  ) async {
    final currentState = state;
    if (currentState is ProfileLoaded) {
      LoggerService.info('Starting profile image update');
      emit(ProfileUpdating(user: currentState.user));
      
      try {
        final response = await _apiService.updateProfileImage(
          imageFile: event.imageFile,
        );
        
        LoggerService.info('Profile image update response received', 'success=${response.success}');
        
        if (response.success && response.data != null) {
          final updatedUser = response.data!;
          
          LoggerService.debug('Updated user data received', updatedUser.toString());
          LoggerService.debug('New avatar URL', updatedUser['avatar']);
          
          // Save updated data to local storage
          await StorageService.setUserData(updatedUser);
          
          emit(ProfileLoaded(user: updatedUser));
          LoggerService.info('Profile image update completed successfully');
        } else {
          LoggerService.warning('Profile image update failed', response.error);
          // Revert to previous state
          emit(ProfileLoaded(user: currentState.user));
          emit(ProfileError(message: response.error ?? 'Failed to update profile image'));
        }
      } catch (e) {
        LoggerService.error('Profile image update exception', e);
        // Revert to previous state
        emit(ProfileLoaded(user: currentState.user));
        emit(ProfileError(message: 'Failed to update profile image: ${e.toString()}'));
      }
    }
  }
}