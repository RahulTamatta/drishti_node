class CreateEventModel {
  String? mode;
  List<String>? aol;
  List<String>? title;
  EventDateTime? date;
  bool? recurring;
  String? durationFrom;
  String? durationTo;
  String? timeOffset;
  String? meetingLink;
  String? phoneNumber;
  List<String>? address;
  String? description;
  String? registrationLink;
  List<double>? coordinates;
  List<String>? teachers;

  CreateEventModel({
    this.mode,
    this.aol,
    this.title,
    this.date,
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
  });

  // Validate required fields and data types
  String? validate() {
    if (title == null || title!.isEmpty) {
      return 'Title is required';
    }
    if (mode == null || !['online', 'offline'].contains(mode)) {
      return 'Valid mode (online/offline) is required';
    }
    if (aol == null || aol!.isEmpty) {
      return 'AOL type is required';
    }
    // Validate title against enum values
    final validTitles = [
      "Sudarshan Kriya",
      "Medha Yoga",
      "Utkarsh Yoga",
      "Sahaj Samadh",
      "Ganesh Homa",
      "Durga Puja"
    ];
    if (title!.any((t) => !validTitles.contains(t))) {
      return 'Invalid title selected';
    }
    // Validate AOL types
    final validAolTypes = ["event", "course", "follow-up"];
    if (aol!.any((a) => !validAolTypes.contains(a))) {
      return 'Invalid AOL type selected';
    }
    return null;
  }

  CreateEventModel.fromJson(Map<String, dynamic> json) {
    mode = json['mode'];
    aol = json['aol'] != null ? List<String>.from(json['aol']) : null;
    title = json['title'] != null ? List<String>.from(json['title']) : null;
    date = json['date'] != null ? EventDateTime.fromJson(json['date']) : null;
    recurring = json['recurring'];
    durationFrom = json['durationFrom'];
    durationTo = json['durationTo'];
    timeOffset = json['timeOffset'];
    meetingLink = json['meetingLink'];
    phoneNumber = json['phoneNumber'];
    address = json['address'] != null ? List<String>.from(json['address']) : null;
    description = json['description'];
    registrationLink = json['registrationLink'];
    coordinates = json['coordinates'] != null 
        ? (json['coordinates'] is Map 
            ? List<double>.from(json['coordinates']['coordinates']) 
            : List<double>.from(json['coordinates']))
        : null;
    teachers = json['teachers'] != null ? List<String>.from(json['teachers']) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {
      'title': title ?? [],
      'mode': mode ?? 'offline',
      'aol': aol ?? [],
      'date': date?.toJson() ?? {
        'from': DateTime.now().toIso8601String(),
        'to': DateTime.now().toIso8601String()
      },
      'timeOffset': timeOffset ?? 'UTC+05:30',
      'duration': [{
        'from': durationFrom ?? '09:00AM',
        'to': durationTo ?? '12:00PM'
      }],
      'meetingLink': meetingLink ?? '',
      'recurring': recurring ?? false,
      'description': description ?? '',
      'address': address ?? [],
      'phoneNumber': phoneNumber ?? '', // Send as string
      'registrationLink': registrationLink ?? '',
      'location': {
        'type': 'Point',
        'coordinates': coordinates ?? [0, 0]
      },
      'teachers': teachers ?? []
    };

    return data;
  }

  CreateEventModel copyWith({
    String? mode,
    List<String>? aol,
    List<String>? title,
    EventDateTime? date,
    bool? recurring,
    String? durationFrom,
    String? durationTo,
    String? timeOffset,
    String? meetingLink,
    String? phoneNumber,
    List<String>? address,
    String? description,
    String? registrationLink,
    List<double>? coordinates,
    List<String>? teachers,
  }) {
    return CreateEventModel(
      mode: mode ?? this.mode,
      aol: aol ?? this.aol,
      title: title ?? this.title,
      date: date ?? this.date,
      recurring: recurring ?? this.recurring,
      durationFrom: durationFrom ?? this.durationFrom,
      durationTo: durationTo ?? this.durationTo,
      timeOffset: timeOffset ?? this.timeOffset,
      meetingLink: meetingLink ?? this.meetingLink,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      address: address ?? this.address,
      description: description ?? this.description,
      registrationLink: registrationLink ?? this.registrationLink,
      coordinates: coordinates ?? this.coordinates,
      teachers: teachers ?? this.teachers,
    );
  }
}

class EventDateTime {
  String? from;
  String? to;

  EventDateTime({this.from, this.to});

  EventDateTime.fromJson(Map<String, dynamic> json) {
    from = json['from'];
    to = json['to'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {};
    if (from != null) data['from'] = from;
    if (to != null) data['to'] = to;
    return data;
  }
}