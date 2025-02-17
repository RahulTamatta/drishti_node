import 'package:srisridrishti/models/all_events_model.dart';

class EventResponse {
  final bool success;
  final String? message;
  final AllEvents? data;

  EventResponse({required this.success, this.message, required this.data});
}
