import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';
import '../../models/location_model.dart';

class LocationService {
  Future<LocationFetchResult> fetchLocation() async {
    try {
      bool hasLocationPermission = await _checkLocationPermission();
      if (!hasLocationPermission) {
        return LocationFetchResult.error(LocationPermissionDeniedException());
      }

      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      List<Placemark> placemarks = await placemarkFromCoordinates(
        position.latitude,
        position.longitude,
      );

      String pincode =
          placemarks.isNotEmpty ? placemarks[0].postalCode ?? "" : "";

      String cityName = placemarks.isNotEmpty
          ? (placemarks[0].locality ?? "").replaceAll(RegExp(r'[^\w\s]+'), '')
          : "";

      String stateName = placemarks.isNotEmpty
          ? (placemarks[0].administrativeArea ?? "")
              .replaceAll(RegExp(r'[^\w\s]+'), '')
          : "";

      String countryName = placemarks.isNotEmpty
          ? (placemarks[0].country ?? "").replaceAll(RegExp(r'[^\w\s]+'), '')
          : "";
      if (cityName.isNotEmpty &&
          stateName.isNotEmpty &&
          countryName.isNotEmpty) {
        Placemark firstPlacemark = placemarks[0];

        String streetAddress = firstPlacemark.thoroughfare!;

        LocationData locationData = LocationData(
            position: position,
            cityName: cityName,
            pincode: pincode,
            stateName: stateName,
            countryName: countryName,
            streetAddress: streetAddress);
        return LocationFetchResult.success(locationData);
      }
    } on LocationPermissionDeniedException {
      return LocationFetchResult.error(LocationPermissionDeniedException());
    } catch (e) {
      return LocationFetchResult.error(
          LocationFetchException('Failed to fetch location'));
    }
    return LocationFetchResult.error(
        LocationFetchException('No location data available'));
  }

  Future<bool> _checkLocationPermission() async {
    var status = await Permission.location.status;
    if (status.isGranted) {
      return true;
    } else {
      var result = await Permission.location.request();
      return result.isGranted;
    }
  }

  static Future<List<String>> getStates(String country) async {
    // Mock implementation, replace with actual API call
    await Future.delayed(Duration(seconds: 1));
    return ['Bihar', 'Uttar Pradesh', 'West Bengal'];
  }

  static Future<List<String>> getCities(String state) async {
    // Mock implementation, replace with actual API call
    await Future.delayed(Duration(seconds: 1));
    if (state == 'Bihar') {
      return ['Patna', 'Gaya', 'Muzaffarpur', 'Bhagalpur'];
    } else if (state == 'Uttar Pradesh') {
      return ['Lucknow', 'Kanpur', 'Varanasi', 'Agra'];
    } else if (state == 'West Bengal') {
      return ['Kolkata', 'Howrah', 'Durgapur', 'Siliguri'];
    } else {
      return [];
    }
  }
}

// Custom exceptions
class LocationFetchException implements Exception {
  final String message;
  LocationFetchException(this.message);
}

class LocationPermissionDeniedException implements Exception {}

// Custom data class to encapsulate location information and error
class LocationFetchResult {
  final LocationData? locationData;
  final Exception? error;

  LocationFetchResult.success(this.locationData) : error = null;
  LocationFetchResult.error(this.error) : locationData = null;
}
