part of 'profile_bloc.dart';

@immutable
sealed class ProfileState {}

final class ProfileInitial extends ProfileState {}

class ProfileDetailsAddedSuccessfully extends ProfileState {
  final OnboardResponse profileRes;
  ProfileDetailsAddedSuccessfully({required this.profileRes});
}

class ProfileDetailsAddedFailed extends ProfileState {
  final OnboardResponse profileRes;
  ProfileDetailsAddedFailed({required this.profileRes});
}

class ProfileDetailsAddingWait extends ProfileState {}
