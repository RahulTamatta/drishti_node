part of 'user_location_bloc.dart';

@immutable
sealed class UserLocationState {
  const UserLocationState();
}

final class UserLocationInitial extends UserLocationState {}

final class LocationLoadingState extends UserLocationState {
  const LocationLoadingState();
}

final class UserLocationLoadedSuccessfully extends UserLocationState {
  final LocationData locationData;
  const UserLocationLoadedSuccessfully({required this.locationData});
}

final class FailedToGetLocation extends UserLocationState {}
