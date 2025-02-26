import 'package:flutter/cupertino.dart';

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
  double _latitude = 0.0;
  double _longitude = 0.0;
  dynamic _address;

  double get latitude => _latitude;
  double get longitude => _longitude;
  get address => _address;

  void updatePosition(
      {required double lat, required double long, required address}) {
    _latitude = lat;
    _longitude = long;
    _address = address;
    notifyListeners();
  }
}
