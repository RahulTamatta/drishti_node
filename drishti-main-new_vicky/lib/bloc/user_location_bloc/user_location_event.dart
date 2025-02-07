part of 'user_location_bloc.dart';

@immutable
sealed class UserLocationEvent {
  const UserLocationEvent();
}

class GetUserLocation extends UserLocationEvent {
  final BuildContext context;
  const GetUserLocation({required this.context});
}
