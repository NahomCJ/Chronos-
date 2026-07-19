import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/datasources/profile_remote_datasource.dart';
import 'profile_state.dart';

class ProfileCubit extends Cubit<ProfileState> {
  final ProfileRemoteDataSource _dataSource;

  ProfileCubit(this._dataSource) : super(const ProfileInitial());

  Future<void> loadProfile() async {
    emit(const ProfileLoading());
    try {
      final user = await _dataSource.getProfile();
      emit(ProfileLoaded(user: user));
    } catch (e) {
      emit(ProfileError(e.toString()));
    }
  }

  Future<void> updateProfile({
    String? firstName,
    String? lastName,
    String? phone,
  }) async {
    final current = state;
    if (current is! ProfileLoaded) return;

    emit(current.copyWith(isUpdating: true));
    try {
      final updated = await _dataSource.updateProfile(
        firstName: firstName,
        lastName: lastName,
        phone: phone,
      );
      emit(ProfileLoaded(
        user: updated.copyWith(
          firstName: firstName ?? updated.firstName,
          lastName: lastName ?? updated.lastName,
          phone: phone ?? updated.phone,
        ),
        updateSuccess: 'Profile updated',
      ));
    } catch (e) {
      emit(current.copyWith(
        isUpdating: false,
        updateError: e.toString(),
      ));
    }
  }
}
