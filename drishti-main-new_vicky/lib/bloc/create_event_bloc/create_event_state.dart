part of 'create_event_bloc.dart';

@immutable
sealed class CreateEventState {}

final class CreateEventInitial extends CreateEventState {}

final class CreatingEventWait extends CreateEventState {}

class EventCreatedSuccessfull extends CreateEventState {}

class EventCreationFailed extends CreateEventState {}
