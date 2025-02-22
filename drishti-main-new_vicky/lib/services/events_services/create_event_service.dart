import 'dart:convert';
import 'package:srisridrishti/models/create_event_model.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../../utils/api_constants.dart';
import '../../utils/shared_preference_helper.dart';

class CreateEventService {
  final http.Client client;

  CreateEventService({http.Client? httpClient})
      : client = httpClient ?? http.Client();

  Future<bool> createEvent({
    required CreateEventModel event,
    required String token,
    String? eventId,
    String? edit,
  }) async {
    debugPrint('CreateEventService: Starting event creation');

    try {
      final jsonData = event.toJson();
      
      // Ensure duration is included in request
      if (!jsonData.containsKey('duration')) {
        throw Exception('duration is required');
      }

      debugPrint('Event Model: $jsonData');
      debugPrint('Edit mode: $edit, EventId: $eventId');

      final String url = '${ApiConstants.baseUrl}/event/create';
      debugPrint('CreateEventService: Using API URL: $url');

      // Remove durationFrom and durationTo from request since we use duration array
      jsonData.remove('durationFrom');
      jsonData.remove('durationTo');
      
      debugPrint('CreateEventService: Request Body: ${json.encode(jsonData)}');
      debugPrint('Token  yo $token');

      final response = await http.post(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': token,
        },
        body: json.encode(jsonData),
      );

      debugPrint('CreateEventService: API Response Status Code: ${response.statusCode}');
      debugPrint('CreateEventService: API Response Body: ${response.body}');

      if (response.statusCode == 201 || response.statusCode == 200) {
        return true;
      } else {
        final errorResponse = json.decode(response.body);
        throw Exception(errorResponse['message'] ?? 'Failed to create event');
      }
    } catch (e, stackTrace) {
      debugPrint('CreateEventService: Error creating event: $e');
      debugPrint('CreateEventService: Stack Trace: $stackTrace');
      rethrow;
    }
  }
}
