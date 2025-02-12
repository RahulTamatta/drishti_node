class CreateEventModel {
  String? mode;
  List<String>? aol;
  List<String>? title;
  EventDateTime? date; // Renamed to avoid conflict
  bool? recurring;
  String? durationFrom;
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
