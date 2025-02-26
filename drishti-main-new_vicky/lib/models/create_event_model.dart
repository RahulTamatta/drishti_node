class CreateEventModel {
  List<String>? title;
  String? mode;
  List<String>? aol;
  EventDateTime? date;
  String? timeOffset;
  String? durationFrom;
  String? durationTo;
  bool? recurring;
  String? description;
  String? phoneNumber; // Changed from List<String> to String
  String? meetingLink;
  String? registrationLink;
  List<String>? teachers;
  List<String>? address;
  List<dynamic>? coordinates;

  CreateEventModel({
    this.title,
    this.mode,
    this.aol,
    this.date,
    this.timeOffset,
    this.durationFrom,
    this.durationTo,
    this.recurring,
    this.description,
    this.phoneNumber,
    this.meetingLink,
    this.registrationLink,
    this.teachers,
    this.address,
    this.coordinates,
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

  // Factory constructor to create a CreateEventModel from JSON
  factory CreateEventModel.fromJson(Map<String, dynamic> json) {
    return CreateEventModel(
      title: json['title'] != null ? List<String>.from(json['title']) : null,
      mode: json['mode'],
      aol: json['aol'] != null ? List<String>.from(json['aol']) : null,
      date: json['date'] != null ? EventDateTime.fromJson(json['date']) : null,
      timeOffset: json['timeOffset'],
      durationFrom: json['durationFrom'],
      durationTo: json['durationTo'],
      recurring: json['recurring'],
      description: json['description'],
      phoneNumber: json['phoneNumber'], // Now expecting a string
      meetingLink: json['meetingLink'],
      registrationLink: json['registrationLink'],
      teachers:
          json['teachers'] != null ? List<String>.from(json['teachers']) : null,
      address:
          json['address'] != null ? List<String>.from(json['address']) : null,
      coordinates: json['coordinates'],
    );
  }

  // Method to convert CreateEventModel to JSON
  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {};
    if (title != null) data['title'] = title;
    if (mode != null) data['mode'] = mode;
    if (aol != null) data['aol'] = aol;
    if (date != null) data['date'] = date!.toJson();
    if (timeOffset != null) data['timeOffset'] = timeOffset;
    if (durationFrom != null) data['durationFrom'] = durationFrom;
    if (durationTo != null) data['durationTo'] = durationTo;
    if (recurring != null) data['recurring'] = recurring;
    if (description != null) data['description'] = description;
    if (phoneNumber != null) data['phoneNumber'] = phoneNumber;
    if (meetingLink != null) data['meetingLink'] = meetingLink;
    if (registrationLink != null) data['registrationLink'] = registrationLink;
    if (teachers != null) data['teachers'] = teachers;
    if (address != null) data['address'] = address;
    if (coordinates != null) data['coordinates'] = coordinates;
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
    List<dynamic>? coordinates,
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
