part of 'all_event_bloc.dart';

@immutable
sealed class AllEventState {}

final class AllEventInitial extends AllEventState {}

class AllEventLoading extends AllEventState {}

class AllEventLoadSuccess extends AllEventState {
  final EventResponse events;

  AllEventLoadSuccess({required this.events});

  List<Object> get props => [events];
}

class AllEventLoadFailure extends AllEventState {
  final EventResponse events;

  AllEventLoadFailure({required this.events});

  List<Object> get props => [events];
}
