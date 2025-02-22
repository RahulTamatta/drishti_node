import 'package:srisridrishti/models/create_event_model.dart';

import '../../handler/responses/all_events_response.dart';

abstract class AllEventsRepository {
  Future<EventResponse?> getAllEvents(String? path, lat, long, radius, date);

  Future<bool> createEvent({
    required CreateEventModel event,
    required String? edit,
    required String? eventId
  });
}
