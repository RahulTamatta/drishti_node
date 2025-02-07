import 'package:bloc/bloc.dart';
import 'package:srisridrishti/models/create_event_model.dart';
import 'package:meta/meta.dart';

import '../../repos/events/all_event_repo.dart';

part 'create_event_event.dart';
part 'create_event_state.dart';

class CreateEventBloc extends Bloc<CreateEventEvent, CreateEventState> {
  final AllEventsRepository _allEventsRepository;
  CreateEventBloc(this._allEventsRepository) : super(CreateEventInitial()) {
    on<CreateEvent>(_createEvent);
  }

  _createEvent(CreateEvent event, Emitter<CreateEventState> emit) async {
    try {
      emit(CreatingEventWait());
      final bool response = await _allEventsRepository.createEvent(
          event: event.event, edit: event.edit, eventId: event.eventId);
      if (response) {
        return emit(EventCreatedSuccessfull());
      }
      return emit(EventCreationFailed());
    } catch (error) {
      return emit(EventCreationFailed());
    }
  }
}
