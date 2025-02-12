import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';
import '../../handler/responses/all_events_response.dart';
import '../../repos/events/all_event_repo.dart';
part 'all_event_event.dart';
part 'all_event_state.dart';

class AllEventBloc extends Bloc<AllEventEvent, AllEventState> {
  final AllEventsRepository _allEventsRepository;
  AllEventBloc(this._allEventsRepository) : super(AllEventInitial()) {
    on<FetchAllEvents>(_fetchAllEvents);
  }

  _fetchAllEvents(FetchAllEvents event, Emitter<AllEventState> emit) async {
    emit(AllEventLoading());
    try {
      final EventResponse? eventResponse =
          await _allEventsRepository.getAllEvents(
              event.path, event.lat, event.long, event.radius, event.date);

      if (eventResponse != null && eventResponse.success) {
        return emit(AllEventLoadSuccess(events: eventResponse));
      } else {
        return emit(AllEventLoadFailure(events: eventResponse!));
      }
    } catch (e) {
      emit(
        AllEventLoadFailure(
            events: EventResponse(
                success: false, message: e.toString(), data: null)),
      );
    }
  }
}
