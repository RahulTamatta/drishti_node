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
Future createEvent(CreateEventModel model, String? edit, String? eventId) async {
  String? token = await SharedPreferencesHelper.getAccessToken() ??
                  await SharedPreferencesHelper.getRefreshToken();
  if (token == null) {
    throw Exception("Authorization token not found");
  }

  final url = edit == "edit" && eventId != null
      ? "${ApiConstants.baseUrl}/event/edit/$eventId"
      : "${ApiConstants.baseUrl}/event/create";

  try {
    // Validate required fields and enums based on MongoDB schema
    if (model.title == null || !_validateTitleEnum(model.title!)) {
      throw Exception("Invalid title. Must be one of: Sudarshan Kriya, Medha Yoga, Utkarsh Yoga, Sahaj Samadh, Ganesh Homa, Durga Puja");
    }
    
    if (model.mode == null || !["online", "offline"].contains(model.mode)) {
      throw Exception("Valid mode (online/offline) is required");
    }
    
    if (model.aol == null || !_validateAOLEnum(model.aol!)) {
      throw Exception("Invalid AOL type. Must be one of: event, course, follow-up");
    }

    // Prepare request body matching MongoDB schema
    final Map eventData = {
      "title": model.title,
      "mode": model.mode?.toLowerCase(),
      "aol": model.aol,
      "date": {
        "from": DateTime.parse(model.date!.from!).toIso8601String(),
        "to": DateTime.parse(model.date!.to!).toIso8601String(),
      },
      "timeOffset": model.timeOffset ?? "UTC+05:30",
      "duration": [
        {
          "from": model.durationFrom,
          "to": model.durationTo,
        }
      ],
      "recurring": model.recurring ?? false,
      "description": model.description,
      // Fixed: Ensure phoneNumber is always an array of strings
      "phoneNumber": model.phoneNumber != null ? [model.phoneNumber.toString()] : [],
      "address": model.address ?? [],
    };

    // Add optional fields only if they have valid values
    if (model.meetingLink?.isNotEmpty == true) {
      eventData["meetingLink"] = model.meetingLink;
    }

    if (model.registrationLink?.isNotEmpty == true) {
      eventData["registrationLink"] = model.registrationLink;
    }

    if (model.teachers?.isNotEmpty == true) {
      eventData["teachers"] = model.teachers;
    }

    // Only add location if coordinates are valid
    if (model.coordinates != null && 
        model.coordinates!.length == 2 &&
        _validateCoordinates(model.coordinates![0], model.coordinates![1])) {
      eventData["location"] = {
        "type": "Point",
        "coordinates": model.coordinates
      };
    }

    print("Request Body: ${json.encode(eventData)}");

    final response = await client.post(
      Uri.parse(url),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: json.encode(eventData),
    );

    print("Response Status Code: ${response.statusCode}");
    print("Response Body: ${response.body}");

    if (response.statusCode == 201 || response.statusCode == 200) {
      return true;
    } else {
      final errorBody = json.decode(response.body);
      throw Exception(errorBody['message'] ?? 'Failed to create event');
    }
  } catch (e) {
    print("Error creating event: ${e.toString()}");
    throw Exception('Error creating event: ${e.toString()}');
  }
}
bool _validateTitleEnum(List<String> titles) {
  final validTitles = [
    "Sudarshan Kriya",
    "Medha Yoga",
    "Utkarsh Yoga",
    "Sahaj Samadh",
    "Ganesh Homa",
    "Durga Puja"
  ];
  return titles.every((title) => validTitles.contains(title));
}

bool _validateAOLEnum(List<String> aolTypes) {
  final validTypes = ["event", "course", "follow-up"];
  return aolTypes.every((type) => validTypes.contains(type));
}

bool _validateCoordinates(num longitude, num latitude) {
  return longitude >= -180 && longitude <= 180 && 
         latitude >= -90 && latitude <= 90;
}}