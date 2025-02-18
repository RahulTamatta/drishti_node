import 'package:flutter/cupertino.dart';
import 'package:geocoding_platform_interface/src/models/placemark.dart';

class LocationProvider extends ChangeNotifier {
  double _latitude = 0.0;
  double _longitude = 0.0;

  double get latitude => _latitude;
  double get longitude => _longitude;

  void updatePosition({required double lat, required double long}) {
    _latitude = lat;
    _longitude = long;
    notifyListeners();
  }
}

class AddressProvider extends ChangeNotifier {
  double? _latitude;
  double? _longitude;
  List<Placemark>? _address;

  double? get latitude => _latitude;
  double? get longitude => _longitude;
  List<Placemark>? get address => _address;

  void updatePosition({
    required double lat,
    required double long,
    required List<Placemark> address,
  }) {
    _latitude = lat;
    _longitude = long;
    _address = address;
    notifyListeners();
  }

  void clear() {
    _latitude = null;
    _longitude = null;
    _address = null;
    notifyListeners();
  }
}
