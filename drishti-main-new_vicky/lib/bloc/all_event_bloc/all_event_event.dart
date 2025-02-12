part of 'all_event_bloc.dart';

@immutable
sealed class AllEventEvent {}

class FetchAllEvents extends AllEventEvent {
  final String path;
  final dynamic lat, long, radius, date;

  FetchAllEvents(this.path, this.lat, this.long, this.radius, this.date);
}
