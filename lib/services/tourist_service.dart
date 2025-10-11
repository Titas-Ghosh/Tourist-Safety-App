import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:geolocator/geolocator.dart';
import '../models/tourist_spot.dart';

class TouristService {
  static Future<List<TouristSpot>> fetchTouristSpots(Position userPos) async {
    try {
      final snapshot = await FirebaseFirestore.instance
          .collection('tourist_spots')
          .get();

      List<TouristSpot> spots = snapshot.docs.map((doc) {
        return TouristSpot.fromFirestore(doc.id, doc.data());
      }).toList();

      // Sort by nearest distance
      spots.sort((a, b) {
        double distA = Geolocator.distanceBetween(
          userPos.latitude, userPos.longitude, a.latitude, a.longitude);
        double distB = Geolocator.distanceBetween(
          userPos.latitude, userPos.longitude, b.latitude, b.longitude);
        return distA.compareTo(distB);
      });

      return spots;
    } catch (e) {
      print("Error fetching tourist spots: $e");
      return [];
    }
  }
}
