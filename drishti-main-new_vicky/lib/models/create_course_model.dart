class CreateCourseModel {
  String? name;
  String? course;
  String? mode;
  String? time;
  String? duration;
  String? zoomLink;
  String? description;
  Location? location;
  List<String>? teachers;

  CreateCourseModel(
      {this.name,
      this.course,
      this.mode,
      this.time,
      this.duration,
      this.zoomLink,
      this.description,
      this.location,
      this.teachers});

  CreateCourseModel.fromJson(Map<String, dynamic> json) {
    name = json['name'];
    course = json['course'];
    mode = json['mode'];
    time = json['time'];
    duration = json['duration'];
    zoomLink = json['zoomLink'];
    description = json['description'];
    location =
        json['location'] != null ? Location.fromJson(json['location']) : null;
    teachers = json['teachers'].cast<String>();
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['name'] = name;
    data['course'] = course;
    data['mode'] = mode;
    data['time'] = time;
    data['duration'] = duration;
    data['zoomLink'] = zoomLink;
    data['description'] = description;
    if (location != null) {
      data['location'] = location!.toJson();
    }
    data['teachers'] = teachers;
    return data;
  }
}

class Location {
  String? address;
  LatLng? latLng;

  Location({this.address, this.latLng});

  Location.fromJson(Map<String, dynamic> json) {
    address = json['address'];
    latLng = json['latLng'] != null ? LatLng.fromJson(json['latLng']) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['address'] = address;
    if (latLng != null) {
      data['latLng'] = latLng!.toJson();
    }
    return data;
  }
}

class LatLng {
  Coordinates? coordinates;

  LatLng({this.coordinates});

  LatLng.fromJson(Map<String, dynamic> json) {
    coordinates = json['coordinates'] != null
        ? Coordinates.fromJson(json['coordinates'])
        : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    if (coordinates != null) {
      data['coordinates'] = coordinates!.toJson();
    }
    return data;
  }
}

class Coordinates {
  double? lat;
  double? lng;

  Coordinates({this.lat, this.lng});

  Coordinates.fromJson(Map<String, dynamic> json) {
    lat = json['lat'];
    lng = json['lng'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['lat'] = lat;
    data['lng'] = lng;
    return data;
  }
}
