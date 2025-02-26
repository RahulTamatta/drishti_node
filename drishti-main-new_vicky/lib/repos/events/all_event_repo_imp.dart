import 'package:srisridrishti/handler/responses/all_events_response.dart';

import '../../models/create_event_model.dart';
import '../../services/events_services/create_event_service.dart';
import '../../services/events_services/events_services.dart';
import 'all_event_repo.dart';

class AllEventsRepositoryImpl implements AllEventsRepository {
  @override
  Future<EventResponse?> getAllEvents(
      String? path, lat, long, radius, date) async {
    try {
      return await EventServices().getAllEvents(path, lat, long, radius, date);
    } catch (e) {
      return EventResponse(
        success: false,
        message: 'Error fetching events: $e',
        data: null,
      );
    }
  }

  @override
  Future<bool> createEvent(
      {required CreateEventModel event,
      required String? edit,
      required String? eventId}) async {
    try {
      return await CreateEventService().createEvent(event, edit, eventId);
    } catch (error) {
      return false;
    }
  }
}
