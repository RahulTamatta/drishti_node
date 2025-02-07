import 'package:geolocator/geolocator.dart';

class LocationData {
  final Position? position;
  final String? cityName;
  final String? pincode;
  final String? stateName;
  final String? countryName;
  final String? streetAddress;

  LocationData({
    required this.position,
    required this.cityName,
    required this.pincode,
    required this.stateName,
    required this.countryName,
    required this.streetAddress,
  });
}

class Location {
  String? type;
  List<double>? coordinates;

  Location({this.type, this.coordinates});

  Location.fromJson(Map<String, dynamic> json) {
    type = json['type'];
    coordinates = json['coordinates'].cast<double>();
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['type'] = type;
    data['coordinates'] = coordinates;
    return data;
  }
}
