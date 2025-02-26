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

<<<<<<< HEAD
<<<<<<< HEAD
<<<<<<< HEAD
  Future<bool> createEvent({
    required CreateEventModel event,
    required String token,
    String? eventId,
    String? edit,
  }) async {
    debugPrint('CreateEventService: Starting event creation');
=======
  Future<bool> createEvent(
      CreateEventModel model, String? edit, String? eventId) async {
    String? token = await SharedPreferencesHelper.getAccessToken() ?? await SharedPreferencesHelper.getRefreshToken();
    if (token == null) {
      throw Exception("Authorization token not found");
    }
>>>>>>> parent of f9353431 (bug)

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
<<<<<<< HEAD
    } catch (e, stackTrace) {
      debugPrint('CreateEventService: Error creating event: $e');
      debugPrint('CreateEventService: Stack Trace: $stackTrace');
      rethrow;
=======
  Future<bool> createEvent(
      CreateEventModel model, String? edit, String? eventId) async {
    String? token = await SharedPreferencesHelper.getAccessToken() ?? await SharedPreferencesHelper.getRefreshToken();
    print("Token: $token");

    print("Model${model.title}");
    print("${model.durationFrom}${model.timeTitle}");
    final Map<String, dynamic> requestBody = {
      "title": model.title,
      "mode": model.mode,
      "aol": model.aol,
      "date": {"from": model.date?.from, "to": model.date?.to},
      "timeOffset": "UTC+05:30",
      "duration": [
        // {"from": "05:15AM", "to": "06:15AM"}
        {
          "from": "${model.durationFrom}${model.timeTitle}",
          "to": "${model.durationTo}${model.timeTitle}"
        }
      ], // Use the duration from the model
      "meetingLink": model.meetingLink,
      "recurring": true,
      "description": model.description,
      "address": model.address,
      "phoneNumber": model.phoneNumber,
      "mapUrl": model.mapUrl,
      "registrationLink": model.registrationLink,
      "coordinates": model.coordinates,
      "teachers": model.teachers
    };

    final String rawBody = jsonEncode(requestBody);

    // Print the request body for debugging
    print("Request Body: $rawBody");

    if (edit == 'Edit Meeting') {
      try {
        final http.Response response = await client.patch(
          Uri.parse('${ApiConstants.createEvent}/$eventId'),
          headers: {
            'Content-Type': 'application/json',
            'Authorization': token ?? "",
          },
          body: rawBody,
        );

        if (response.statusCode == 200) {
          // Print the response status and body for debugging
          print("Response Status: ${response.statusCode}");
          print("Response Body: ${response.body}");
          return true;
        } else {
          debugPrint(
              'Failed to create event: ${response.statusCode} ${response.body}');
          return false;
        }
      } catch (e) {
        debugPrint('Exception occurred: $e');
        return false;
      }
    } else {
      try {
        final http.Response response = await client.post(
          Uri.parse(ApiConstants.createEvent),
          headers: {
            'Content-Type': 'application/json',
            'Authorization': token ?? "",
          },
          body: rawBody,
        );

        if (response.statusCode == 200) {
          // Print the response status and body for debugging
          print("Response Status: ${response.statusCode}");
          print("Response Body: ${response.body}");
          return true;
        } else {
          debugPrint(
              'Failed to create event: ${response.statusCode} ${response.body}');
          return false;
        }
      } catch (e) {
        debugPrint('Exception occurred: $e');
        return false;
      }
>>>>>>> parent of 283b956a (latest update .create course is remaining)
=======
  Future<bool> createEvent(
      CreateEventModel model, String? edit, String? eventId) async {
    String? token = await SharedPreferencesHelper.getAccessToken() ?? await SharedPreferencesHelper.getRefreshToken();
    print("Token: $token");

    print("Model${model.title}");
    print("${model.durationFrom}${model.timeTitle}");
    final Map<String, dynamic> requestBody = {
      "title": model.title,
      "mode": model.mode,
      "aol": model.aol,
      "date": {"from": model.date?.from, "to": model.date?.to},
      "timeOffset": "UTC+05:30",
      "duration": [
        // {"from": "05:15AM", "to": "06:15AM"}
        {
          "from": "${model.durationFrom}${model.timeTitle}",
          "to": "${model.durationTo}${model.timeTitle}"
        }
      ], // Use the duration from the model
      "meetingLink": model.meetingLink,
      "recurring": true,
      "description": model.description,
      "address": model.address,
      "phoneNumber": model.phoneNumber,
      "mapUrl": model.mapUrl,
      "registrationLink": model.registrationLink,
      "coordinates": model.coordinates,
      "teachers": model.teachers
    };

    final String rawBody = jsonEncode(requestBody);

    // Print the request body for debugging
    print("Request Body: $rawBody");

    if (edit == 'Edit Meeting') {
      try {
        final http.Response response = await client.patch(
          Uri.parse('${ApiConstants.createEvent}/$eventId'),
          headers: {
            'Content-Type': 'application/json',
            'Authorization': token ?? "",
          },
          body: rawBody,
        );

        if (response.statusCode == 200) {
          // Print the response status and body for debugging
          print("Response Status: ${response.statusCode}");
          print("Response Body: ${response.body}");
          return true;
        } else {
          debugPrint(
              'Failed to create event: ${response.statusCode} ${response.body}');
          return false;
        }
      } catch (e) {
        debugPrint('Exception occurred: $e');
        return false;
      }
    } else {
      try {
        final http.Response response = await client.post(
          Uri.parse(ApiConstants.createEvent),
          headers: {
            'Content-Type': 'application/json',
            'Authorization': token ?? "",
          },
          body: rawBody,
        );

        if (response.statusCode == 200) {
          // Print the response status and body for debugging
          print("Response Status: ${response.statusCode}");
          print("Response Body: ${response.body}");
          return true;
        } else {
          debugPrint(
              'Failed to create event: ${response.statusCode} ${response.body}');
          return false;
        }
      } catch (e) {
        debugPrint('Exception occurred: $e');
        return false;
      }
>>>>>>> parent of 283b956a (latest update .create course is remaining)
=======
    } catch (e) {
      throw Exception('Error creating event: ${e.toString()}');
>>>>>>> parent of f9353431 (bug)
    }
  }
}
