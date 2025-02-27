// import 'dart:async';
// import 'dart:convert';
// import 'package:flutter/material.dart';
// import 'package:geolocator/geolocator.dart';
// import 'package:provider/provider.dart';
// import 'package:http/http.dart' as http;
//
// class CoursesRepository {
//   final http.Client client;
//   final String baseUrl = "https://drishtinode-production.up.railway.app";
//
//   CoursesRepository({http.Client? httpClient})
//       : client = httpClient ?? http.Client();
//
//   Future<CoursesData?> getAllEventsCourseData() async {
//     final String url = "$baseUrl/event/all-events";
//     try {
//       var mode = "online";
//       var lat = 19.1926489;
//       var long = 72.9440513;
//
//       final queryParameter =
//           jsonEncode({'mode': mode, "lat": lat, "long": long});
//       String token =
//           "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpZCI6IjY1YTY2NWIxOTQ1ODRjMmQ4YjJiODczZCIsInJvbGUiOiJ1c2VyIiwiaWF0IjoxNzA2NjMyMjU3LCJleHAiOjE3MDkyMjQyNTd9.bjiI2IV3GDaV-XRx5JxZxKX5-c-O0_421e2AFHCn0yU";
//
//       final response = await client.post(
//         Uri.parse(url),
//         headers: {
//           'Content-Type': 'application/json',
//           'Authorization': token,
//         },
//         body: queryParameter,
//       );
//
//       debugPrint("Response status code: ${response.statusCode}");
//       if (response.statusCode == 200) {
//         var data = jsonDecode(response.body);
//         CoursesData courseListData = CoursesData.fromJson(data);
//         return courseListData;
//       } else {
//         debugPrint("Failed to load data. Status code: ${response.statusCode}");
//       }
//     } catch (e) {
//       debugPrint("Error in fetching course data: $e");
//     }
//     return null;
//   }
//
//   Future<MyEventsData?> getMyEventsCourseData() async {
//     final String url = "$baseUrl/event/my-events";
//     try {
//       final response = await client.post(
//         Uri.parse(url),
//         headers: {
//           'Content-Type': 'application/json',
//         },
//       );
//
//       debugPrint("Response status code: ${response.statusCode}");
//       if (response.statusCode == 200) {
//         var data = jsonDecode(response.body);
//         MyEventsData myCourseListData = MyEventsData.fromJson(data);
//         return myCourseListData;
//       } else {
//         debugPrint("Failed to load data. Status code: ${response.statusCode}");
//       }
//     } catch (e) {
//       debugPrint("Error in fetching my events data: $e");
//     }
//     return null;
//   }
// }
