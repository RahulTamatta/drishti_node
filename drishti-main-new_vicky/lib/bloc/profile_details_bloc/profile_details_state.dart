import 'package:equatable/equatable.dart';
import 'package:srisridrishti/handler/responses/profile_details_response.dart';

abstract class ProfileDetailsState extends Equatable {
  const ProfileDetailsState();

  @override
  List<Object?> get props => [];
}

class ProfileDetailsInitial extends ProfileDetailsState {}

class ProfileDetailsLoading extends ProfileDetailsState {}

class ProfileDetailsLoadedSuccessfully extends ProfileDetailsState {
  final ProfileDetailsResponse profileResponse;

  const ProfileDetailsLoadedSuccessfully({required this.profileResponse});

  @override
  List<Object?> get props => [profileResponse];
}

class FailedToFetchProfileDetails extends ProfileDetailsState {
  final ProfileDetailsResponse profileResponse;

  const FailedToFetchProfileDetails({required this.profileResponse});

  @override
  List<Object?> get props => [profileResponse];
}

class ProfileDetailsUpdatedSuccessfully extends ProfileDetailsState {
  final ProfileDetailsResponse profileResponse;

  const ProfileDetailsUpdatedSuccessfully({required this.profileResponse});

  @override
  List<Object?> get props => [profileResponse];
}

class FailedToUpdateProfileDetails extends ProfileDetailsState {
  final ProfileDetailsResponse profileResponse;

  const FailedToUpdateProfileDetails({required this.profileResponse});

  @override
  List<Object?> get props => [profileResponse];
}

class ProfileDeletedSuccessfully extends ProfileDetailsState {
  final ProfileDetailsResponse profileResponse;

  const ProfileDeletedSuccessfully({required this.profileResponse});

  @override
  List<Object?> get props => [profileResponse];
}

class FailedToDeleteProfile extends ProfileDetailsState {
  final ProfileDetailsResponse profileResponse;

  const FailedToDeleteProfile({required this.profileResponse});

  @override
  List<Object?> get props => [profileResponse];
}
