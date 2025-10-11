import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:geolocator/geolocator.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class GeofencingService {
  static StreamSubscription<Position>? _positionStream;
  static final FlutterLocalNotificationsPlugin _notifications =
      FlutterLocalNotificationsPlugin();

  // Keep track of which geofences we are inside (avoid duplicate spam)
  static final Set<String> _activeGeofences = {};

  /// Initialize local notifications
  static Future<void> initNotifications() async {
    const AndroidInitializationSettings androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    const InitializationSettings settings =
        InitializationSettings(android: androidSettings);

    await _notifications.initialize(settings);
  }

  /// Show alert notification
  static Future<void> showAlert(String title, String body) async {
    const androidDetails = AndroidNotificationDetails(
      'geofence_channel',
      'Geofence Alerts',
      channelDescription: 'Notifies when inside geofenced areas',
      importance: Importance.max,
      priority: Priority.high,
    );

    const details = NotificationDetails(android: androidDetails);
    await _notifications.show(
      DateTime.now().millisecondsSinceEpoch ~/ 1000, // unique id each time
      title,
      body,
      details,
    );
  }

  /// Fetch geofences from Firestore
  static Future<List<Map<String, dynamic>>> fetchGeofences() async {
    final snapshot =
        await FirebaseFirestore.instance.collection('geofences').get();

    return snapshot.docs.map((doc) {
      final data = doc.data();
      return {
        'id': doc.id,
        'latitude': (data['latitude'] as num).toDouble(),
        'longitude': (data['longitude'] as num).toDouble(),
        'radius': (data['radius'] as num).toDouble(),
        'label': data['label'] ?? "Risk Zone",
      };
    }).toList();
  }

  /// Check if inside geofence
  static bool isInsideGeofence(
      Position position, Map<String, dynamic> geofence) {
    final distance = Geolocator.distanceBetween(
      position.latitude,
      position.longitude,
      geofence['latitude'],
      geofence['longitude'],
    );
    return distance <= geofence['radius'];
  }

  /// Start monitoring location continuously
  static Future<void> startMonitoring() async {
    final geofences = await fetchGeofences();

    _positionStream?.cancel(); // prevent duplicate streams

    _positionStream = Geolocator.getPositionStream(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.bestForNavigation, // fastest, high accuracy
        distanceFilter: 0, // update even if moved very little
      ),
    ).listen((position) {
      for (var geo in geofences) {
        final inside = isInsideGeofence(position, geo);

        if (inside && !_activeGeofences.contains(geo['id'])) {
          // Entered a new geofence
          _activeGeofences.add(geo['id']);
          print("⚠️ Entered geofence: ${geo['label']}");
          showAlert("⚠️ Alert", "You are inside ${geo['label']} area!");
        } else if (!inside && _activeGeofences.contains(geo['id'])) {
          // Exited geofence
          _activeGeofences.remove(geo['id']);
          print("✅ Exited geofence: ${geo['label']}");
          // (Optional) notify exit:
          //_showAlert("✅ Safe Zone", "You left ${geo['label']} area.");
        }
      }
    });
  }

  /// Stop monitoring
  static void stopMonitoring() {
    _positionStream?.cancel();
    _activeGeofences.clear();
  }
}
