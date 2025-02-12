import 'package:equatable/equatable.dart';
import 'package:srisridrishti/models/user_details_model.dart';

abstract class ProfileDetailsEvent extends Equatable {
  const ProfileDetailsEvent();

  @override
  List<Object> get props => [];
}

class GetProfileDetails extends ProfileDetailsEvent {}

class UpdateProfileDetails extends ProfileDetailsEvent {
  final UserDetailsModel updatedProfile;

  const UpdateProfileDetails({required this.updatedProfile});

  @override
  List<Object> get props => [updatedProfile];
}

class DeleteProfile extends ProfileDetailsEvent {}
