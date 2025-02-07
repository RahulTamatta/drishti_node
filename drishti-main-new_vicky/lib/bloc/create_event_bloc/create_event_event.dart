part of 'create_event_bloc.dart';

@immutable
sealed class CreateEventEvent {}

class CreateEvent extends CreateEventEvent {
  final CreateEventModel event;
  final String? edit;
  final String? eventId;
  CreateEvent({required this.event, required this.edit, required this.eventId});
}
