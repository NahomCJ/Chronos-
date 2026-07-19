import '../../data/datasources/profile_remote_datasource.dart';

abstract class ProfileState {
  const ProfileState();
}

class ProfileInitial extends ProfileState {
  const ProfileInitial();
}

class ProfileLoading extends ProfileState {
  const ProfileLoading();
}

class ProfileLoaded extends ProfileState {
  final UserProfileModel user;
  final bool isUpdating;
  final String? updateError;
  final String? updateSuccess;

  const ProfileLoaded({
    required this.user,
    this.isUpdating = false,
    this.updateError,
    this.updateSuccess,
  });

  ProfileLoaded copyWith({
    UserProfileModel? user,
    bool? isUpdating,
    String? updateError,
    String? updateSuccess,
  }) {
    return ProfileLoaded(
      user: user ?? this.user,
      isUpdating: isUpdating ?? this.isUpdating,
      updateError: updateError,
      updateSuccess: updateSuccess,
    );
  }
}

class ProfileError extends ProfileState {
  final String message;
  const ProfileError(this.message);
}
