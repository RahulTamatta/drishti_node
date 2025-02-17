import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import '../../bloc/user_location_bloc/user_location_bloc.dart';
import '../../models/display_course_model.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import '../../providers/bottom_content_provider.dart';
import '../../providers/course_list_provder.dart';

class courseRepo {
  static Future<DisplayCourseModel> getCourses(BuildContext context) async {
    try {
      String apiUrl = 'http://10.0.2.2:8080';
      // DateTime? dateTime =
      //     Provider.of<BottomSheetContentProvider>(context, listen: false).date;

      // var date = "${dateTime.year}-${dateTime.month}-${dateTime.day}";
      final userLocationBloc = context.read<UserLocationBloc>();
      final state = userLocationBloc.state;
      String? latitude = "";
      String? longitude = "";
      if (state is UserLocationLoadedSuccessfully) {
        latitude = state.locationData.position?.latitude.toString();
        latitude = state.locationData.position?.longitude.toString();
      }
      final Map<String, dynamic> requestBody = {
        "lat": latitude,
        "long": longitude
      };
      final String rawBody = jsonEncode(requestBody);
      Response res = await http.post(Uri.parse('$apiUrl/event/all-events'),
          headers: {'Authorization': ""}, body: rawBody);
      if (res.statusCode != 200) {
        throw Exception(
            "API request failed with status code ${res.statusCode}");
      }
      DisplayCourseModel data =
          DisplayCourseModel.fromJson(jsonDecode(res.body));
      return data;
    } catch (e) {
      rethrow; // rethrow the exception to propagate it further if needed
    }
  }

// below method will be used to fetch courses on the basis of map visible area coordinates;

  static Future<DisplayCourseModel> getMapBasedCourses(
      BuildContext context) async {
    String apiUrl = 'http://10.0.2.2:8080';
    LatLng? position =
        Provider.of<CourseListProvider>(context, listen: false).newCo_ordinates;

    DateTime dateTime =
        Provider.of<BottomSheetContentProvider>(context, listen: false).date;
    var date = "${dateTime.year}-${dateTime.month}-${dateTime.day}";

    Response res = await http.post(
      Uri.parse('$apiUrl/event/all-events'),
      headers: {
        'Authorization': '',
      },
      body: jsonEncode({
        "date": date,
        "lat": position!.latitude.toString(),
        "lng": position.longitude.toString()
      }),
    );
    DisplayCourseModel data = DisplayCourseModel.fromJson(jsonDecode(res.body));
    return data;
  }
}
