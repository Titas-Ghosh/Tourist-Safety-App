import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';

class LocationService {
  /// Get current city name from GPS
  static Future<String?> getCurrentCity() async {
    try {
      // ✅ Ensure permissions are granted
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          return "Permission Denied";
        }
      }

      if (permission == LocationPermission.deniedForever) {
        return "Permission Denied Forever";
      }

      // ✅ Get current position
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      // ✅ Reverse geocode to get placemark (city, state, country)
      List<Placemark> placemarks = await placemarkFromCoordinates(
        position.latitude,
        position.longitude,
      );

      if (placemarks.isNotEmpty) {
        final place = placemarks.first;
        return place.locality ?? place.administrativeArea ?? place.country;
      }

      return "Unknown Location";
    } catch (e) {
      return "Error: $e";
    }
  }
}
