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

  Future<bool> createEvent(
      CreateEventModel model, String? edit, String? eventId) async {
    String? token = await SharedPreferencesHelper.getAccessToken() ?? await SharedPreferencesHelper.getRefreshToken();
    if (token == null) {
      throw Exception("Authorization token not found");
    }

    final url = edit == "edit" && eventId != null
        ? "${ApiConstants.baseUrl}/event/edit/$eventId"
        : "${ApiConstants.baseUrl}/event/create";
    
    try {
      // Prepare request body
      final Map<String, dynamic> eventData = {
        "mode": model.mode,
        "aol": model.aol,
        "title": model.title,
        "timeTitle": model.timeTitle,
        "date": model.date?.toJson(),
        "recurring": model.recurring ?? false,
        "durationFrom": model.durationFrom,
        "durationTo": model.durationTo,
        "timeOffset": model.timeOffset,
        "meetingLink": model.meetingLink,
        "phoneNumber": model.phoneNumber?.isNotEmpty == true ? model.phoneNumber![0] : null,
        "address": model.address,
        "description": model.description,
        "registrationLink": model.registrationLink,
        "coordinates": model.coordinates,
        "teachers": model.teachers,
      };

      // Remove null values and empty lists
      eventData.removeWhere((key, value) => 
        value == null || 
        (value is List && value.isEmpty) ||
        (value is Map && value.isEmpty));

      final response = await client.post(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: json.encode(eventData),
      );

      if (response.statusCode == 201 || response.statusCode == 200) {
        return true;
      } else {
        final errorBody = json.decode(response.body);
        throw Exception(errorBody['message'] ?? 'Failed to create event');
      }
    } catch (e) {
      throw Exception('Error creating event: ${e.toString()}');
    }
  }
}
