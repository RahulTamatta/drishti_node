import 'package:flutter/foundation.dart';

class CreateEventModel {
  String? mode;
  List<String>? aol;
  List<String>? title;
  EventDateTime? date; // Renamed to avoid conflict
  bool? recurring;
  String? durationFrom;
  List<Map<String, String>>? duration;

  String? durationTo;
  String? timeTitle;
  String? timeOffset;
  String? meetingLink;
  List<String>? phoneNumber;
  List<String>? address;
  String? description;
  String? mapUrl;
  String? registrationLink;
  List<double>? coordinates;
  List<String>? teachers;

  CreateEventModel(
      {this.mode,
      this.aol,
      this.title,
      this.date,
      this.timeTitle,
      this.recurring,
      this.durationFrom,
      this.durationTo,
      this.timeOffset,
      this.meetingLink,
      this.phoneNumber,
      this.address,
      this.description,
      this.registrationLink,
      this.coordinates,
      this.teachers,
      this.mapUrl});

  // @override
  // String toString() {
  //   return 'CreateEventModel{'
  //       'aol: $aol, '
  //       'meetingLink: $meetingLink, '
  //       'description: $description, '
  //       'phoneNumber: $phoneNumber, '
  //       'registrationLink: $registrationLink, '
  //       'teachers: $teachers, '
  //       'coordinates: $coordinates, '
  //       'title: $title, '
  //       'timeTitle : $timeTitle, '
  //       'durationFrom: $durationFrom,'
  //       'durationTo: $durationTo,'
  //       'mode: $mode, '
  //       'address: $address}';
  // }

  CreateEventModel.fromJson(Map<String, dynamic> json) {
    mode = json['mode'];
    aol = List<String>.from(json['aol']);
    title = List<String>.from(json['title']);
    timeTitle = json['timeTitle'];
    date = json['date'] != null ? EventDateTime.fromJson(json['date']) : null;
    recurring = json['recurring'];
    durationFrom = json['durationFrom'];
    durationTo = json['durationTo'];
    timeOffset = json['timeOffset'];
    meetingLink = json['meetingLink'];
<<<<<<< HEAD
<<<<<<< HEAD
    phoneNumber = json['phoneNumber'] != null ? [json['phoneNumber']] : null;
    address =
        json['address'] != null ? List<String>.from(json['address']) : null;
=======
    phoneNumber = json['phoneNumber'];
    address = List<String>.from(json['address']);
>>>>>>> parent of 283b956a (latest update .create course is remaining)
    description = json['description'];
    mapUrl = json['mapUrl'];
    registrationLink = json['registrationLink'];
<<<<<<< HEAD
    coordinates = json['coordinates'] != null
        ? List<double>.from(json['coordinates'])
        : null;
    teachers =
        json['teachers'] != null ? List<String>.from(json['teachers']) : null;
  }

  Map<String, dynamic> toJson() {
    debugPrint('CreateEventModel: Converting to JSON');
    final Map<String, dynamic> data = <String, dynamic>{};

    // Add required fields
    data['aol'] = aol ?? ['course'];
    if (mode != null) data['mode'] = mode;
    if (title != null && title!.isNotEmpty) data['title'] = title;
    if (date != null) data['date'] = date!.toJson();
    if (recurring != null) data['recurring'] = recurring;

    // Duration handling with time format validation
    if (durationFrom != null && durationTo != null) {
      data['duration'] = [
        {'from': _formatTime(durationFrom!), 'to': _formatTime(durationTo!)}
      ];
    }

    // Add optional fields
    if (meetingLink != null) data['meetingLink'] = meetingLink;
    if (phoneNumber != null && phoneNumber!.isNotEmpty) {
      data['phoneNumber'] = phoneNumber![0];
    }
    if (address != null && address!.isNotEmpty) data['address'] = address;
    if (description != null) data['description'] = description;
    if (registrationLink != null) data['registrationLink'] = registrationLink;
    if (coordinates != null && coordinates!.isNotEmpty) {
      data['coordinates'] = coordinates;
    }
    if (teachers != null && teachers!.isNotEmpty) data['teachers'] = teachers;

    debugPrint('Final JSON data: $data');
    return data;
  }

  // Helper method to format time strings
  String _formatTime(String time) {
    final RegExp exp = RegExp(r'(\d{1,2}):(\d{2})(AM|PM)');
    final match = exp.firstMatch(time);

    if (match != null) {
      var hour = int.parse(match.group(1)!);
      final minute = match.group(2)!;
      final period = match.group(3);

      if (period == 'PM' && hour < 12) hour += 12;
      if (period == 'AM' && hour == 12) hour = 0;

      return '${hour.toString().padLeft(2, '0')}:$minute';
    }
    return time;
  }

=======
    coordinates = List<double>.from(json['coordinates']);
    teachers = List<String>.from(json['teachers']);
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['mode'] = mode;
    data['aol'] = aol;
    data['title'] = title;
    data['timeTitle'] = timeTitle;
    if (date != null) {
      data['date'] = date!.toJson();
    }
    data['recurring'] = recurring;

    data['durationFrom'] = durationFrom!;
    data['durationTo'] = durationTo!;

    data['timeOffset'] = timeOffset;
    data['meetingLink'] = meetingLink;
    data['phoneNumber'] = phoneNumber;
    data['address'] = address;
    data['description'] = description;
    data['mapUrl'] = mapUrl;
    data['registrationLink'] = registrationLink;
    data['coordinates'] = coordinates;
    data['teachers'] = teachers;
    return data;
  }

  // The copyWith method
>>>>>>> parent of 283b956a (latest update .create course is remaining)
=======
    phoneNumber = json['phoneNumber'];
    address = List<String>.from(json['address']);
    description = json['description'];
    mapUrl = json['mapUrl'];
    registrationLink = json['registrationLink'];
    coordinates = List<double>.from(json['coordinates']);
    teachers = List<String>.from(json['teachers']);
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['mode'] = mode;
    data['aol'] = aol;
    data['title'] = title;
    data['timeTitle'] = timeTitle;
    if (date != null) {
      data['date'] = date!.toJson();
    }
    data['recurring'] = recurring;

    data['durationFrom'] = durationFrom!;
    data['durationTo'] = durationTo!;

    data['timeOffset'] = timeOffset;
    data['meetingLink'] = meetingLink;
    data['phoneNumber'] = phoneNumber;
    data['address'] = address;
    data['description'] = description;
    data['mapUrl'] = mapUrl;
    data['registrationLink'] = registrationLink;
    data['coordinates'] = coordinates;
    data['teachers'] = teachers;
    return data;
  }

  // The copyWith method
>>>>>>> parent of 283b956a (latest update .create course is remaining)
  CreateEventModel copyWith({
    String? mode,
    List<String>? aol,
    List<String>? title,
    String? timeTitle,
    EventDateTime? date, // Updated here
    bool? recurring,
    String? durationFrom,
    String? durationTo,
    String? timeOffset,
    String? meetingLink,
    List<String>? phoneNumber,
    List<String>? address,
    String? description,
    String? mapUrl,
    String? registrationLink,
    List<double>? coordinates,
    List<String>? teachers,
  }) {
    return CreateEventModel(
      mode: mode ?? this.mode,
      aol: aol ?? this.aol,
      title: title ?? this.title,
      timeTitle: timeTitle ?? this.timeTitle,
      date: date ?? this.date,
      recurring: recurring ?? this.recurring,
      durationFrom: durationFrom ?? this.durationFrom,
      durationTo: durationTo ?? this.durationTo,
      timeOffset: timeOffset ?? this.timeOffset,
      meetingLink: meetingLink ?? this.meetingLink,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      address: address ?? this.address,
      description: description ?? this.description,
      mapUrl: mapUrl ?? this.mapUrl,
      registrationLink: registrationLink ?? this.registrationLink,
      coordinates: coordinates ?? this.coordinates,
      teachers: teachers ?? this.teachers,
    );
  }
}

class EventDateTime {
  // Renamed to avoid conflict
  String? from;
  String? to;

  EventDateTime({this.from, this.to});

  EventDateTime.fromJson(Map<String, dynamic> json) {
    from = json['from'];
    to = json['to'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['from'] = from;
    data['to'] = to;
    return data;
  }
}
