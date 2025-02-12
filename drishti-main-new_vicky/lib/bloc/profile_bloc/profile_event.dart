part of 'profile_bloc.dart';

@immutable
sealed class ProfileEvent {}

class AddProfileDetails extends ProfileEvent {
  final Map<String, dynamic> profileData;

  AddProfileDetails({required this.profileData});
}

class UpdateProfileDetails extends ProfileDetailsEvent {
  final UserDetailsModel updatedProfile;

  const UpdateProfileDetails({required this.updatedProfile});

  @override
  List<Object> get props => [updatedProfile];
}
