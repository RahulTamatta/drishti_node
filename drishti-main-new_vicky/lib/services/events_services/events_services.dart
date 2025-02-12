import 'dart:async';
import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:srisridrishti/utils/shared_preference_helper.dart';
import 'package:http/http.dart' as http;
import '../../handler/responses/all_events_response.dart';
import '../../models/map_models.dart';
import '../../utils/logging.dart';
import '../../models/all_events_model.dart';
import '../../utils/api_constants.dart';

class EventServices {
  final http.Client client;
  final Dio _dio = Dio();

  EventServices({http.Client? httpClient})
      : client = httpClient ?? http.Client();

  Future<EventResponse?> getAllEvents(
      String? path, double lat, long, radius, date) async {
    final Map<String, dynamic> requestBody = radius != 0
        ? {"date": date, "lat": lat, "long": long, "radius": radius.toInt()}
        : {
            // "mode": "both",
            "date": date,
            //"page": 1,
            //"pageSize": 20
          };
    print(requestBody);
    final String rawBody = jsonEncode(requestBody);

    try {
      // String? token = await SharedPreferencesHelper.getAccessToken();
      var url = '${ApiConstants.allEvents}?matchQuery=$path';
      print(url);
      final http.Response response = await client
          .post(
            Uri.parse(url),
            headers: {
              'Content-Type': 'application/json',
              'Accept': 'application/json',
              // 'Authorization': token ?? "",
            },
            body: rawBody,
          )
          .timeout(const Duration(seconds: 30));

      print(response.body);

      if (response.statusCode == 200) {
        var data = jsonDecode(response.body);

        // Print the body data to the console
        print('Response data: ');
        // Logger logger = Logger();
        // logger.d(data);

        EventResponse eventResponse = EventResponse(
          success: true,
          message: data['message'],
          data: AllEvents.fromJson(data),
        );
        return eventResponse;
      } else {
        return EventResponse(
          success: false,
          message:
              'Failed to get events: ${response.statusCode} ${response.reasonPhrase}',
          data: null,
        );
      }
    } on http.ClientException catch (e) {
      return EventResponse(
        success: false,
        message: 'Client exception: $e',
        data: null,
      );
    } on TimeoutException catch (e) {
      logError('Request timeout: $e');
      return EventResponse(
        success: false,
        message: 'Request timeout: $e',
        data: null,
      );
    } catch (e) {
      logError('Unexpected error: $e');
      return EventResponse(
        success: false,
        message: 'Unexpected error: $e',
        data: null,
      );
    }
  }

  Future<List<EventModel>?> getEvents(
      {String? token,
      int? year,
      int? month,
      String? course,
      DateTime? date,
      double? lat,
      double? long,
      String? aol,
      String mode = "both",
      String? path}) async {
    String? token0 = await SharedPreferencesHelper.getAccessToken();

    try {
      Map<String, dynamic> data = {"mode": mode};
      if (lat != null && long != null) {
        data['latitude'] = lat;
        data['longitude'] = long;
      }
      if (date != null) {
        data['date'] = (date.toUtc()).toIso8601String();
      }
      if (year != null) {
        data['year'] = year;
      }
      if (month != null) {
        data['month'] = month;
      }
      if (course != null) {
        data['course'] = course;
      }
      if (aol != null) {
        data['aol'] = aol;
      }

      var result = await _dio.post(
          "${ApiConstants.baseUrl}/event/all-events?matchQuery=$path",
          data: data,
          options: Options(headers: {"Authorization": token0 ?? ""}));

      print(path);
      if (result.statusCode == 200) {
        // print("Hello");
        List<EventDetailsModel> events = [];
        for (var item in result.data['data']) {
          events.add(EventDetailsModel.jsonToEventDetails(item));
        }
        List<String> timeList = [];
        for (var item in events) {
          var times = item.duration.map((e) => e.toString()).toList();
          timeList.addAll(times);
        }
        List<String> uniqueTime = (timeList.toSet()).toList();
        List<EventModel> eventList = [];
        for (var item in uniqueTime) {
          var list = events.where((e) => e.duration.contains(item)).toList();
          eventList.add(EventModel(evens_list: list, time: item));
        }
        return eventList;
      } else {
        return null;
      }
    } catch (error) {
      return null;
    }
  }
}
