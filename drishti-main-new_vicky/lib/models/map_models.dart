import 'package:srisridrishti/models/user_details_model.dart';

class EventModel {
  String time;
  List<EventDetailsModel> evens_list = [];

  EventModel({required this.evens_list, required this.time});
}

class EventDetailsModel {
  String id;
  String title;
  String mode;
  List<String> aol;
  String userId;
  DateTime dateFrom;
  DateTime dateTo;
  String timeOffset;
  List<String> duration;
  String meetingLink;
  bool recurring;
  List<String> description;
  List<String> address;
  String phoneNumber;
  String registrationLink;
  double lat;
  double long;
  List<String> teachers;
  DateTime createdAt;
  DateTime updatedAt;
  List<UserDetailsModel> usersDetails;
  List<UserDetailsModel> teachersDetails;

  EventDetailsModel(
      {required this.address,
      required this.aol,
      required this.createdAt,
      required this.dateFrom,
      required this.dateTo,
      required this.description,
      required this.duration,
      required this.id,
      required this.lat,
      required this.long,
      required this.meetingLink,
      required this.mode,
      required this.phoneNumber,
      required this.recurring,
      required this.registrationLink,
      required this.teachers,
      required this.timeOffset,
      required this.title,
      required this.updatedAt,
      required this.userId,
      required this.teachersDetails,
      required this.usersDetails});

  static EventDetailsModel jsonToEventDetails(dynamic data) {
    return EventDetailsModel(
      address:
          (data['address'] as List<dynamic>).map((e) => e.toString()).toList(),
      aol: (data['aol'] as List<dynamic>).map((e) => e.toString()).toList(),
      createdAt: DateTime.parse(data['createdAt']),
      dateFrom: DateTime.parse(data['date']['from']),
      dateTo: DateTime.parse(data['date']['to']),
      description: (data['description'] as List<dynamic>)
          .map((e) => e.toString())
          .toList(),
      duration:
          (data['duration'] as List<dynamic>).map((e) => e.toString()).toList(),
      id: data['_id'],
      lat: data['location']['coordinates'][0],
      long: data['location']['coordinates'][1],
      meetingLink: data['meetingLink'],
      mode: data['mode'],
      phoneNumber: data['phoneNumber'],
      recurring: data['recurring'],
      registrationLink: data['registrationLink'],
      teachers:
          (data['teachers'] as List<dynamic>).map((e) => e.toString()).toList(),
      timeOffset: data['timeOffset'],
      title: data['title'],
      updatedAt: DateTime.parse(data['updatedAt']),
      userId: data['userId'],
      teachersDetails: (data['teachersDetails'] as List<dynamic>)
          .map((e) => UserDetailsModel.jsonToUserDetails(e))
          .toList(),
      usersDetails: (data['userDetails'] as List<dynamic>)
          .map((e) => UserDetailsModel.jsonToUserDetails(e))
          .toList(),
    );
  }
}
