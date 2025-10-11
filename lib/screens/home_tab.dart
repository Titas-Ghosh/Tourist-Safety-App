import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:geolocator/geolocator.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../services/safety_score_service.dart';
import '../services/location_service.dart';
import '../services/weather_service.dart';
import '../services/geofencing_service.dart';

class HomeTab extends StatefulWidget {
  const HomeTab({Key? key}) : super(key: key);

  @override
  _HomeTabState createState() => _HomeTabState();
}

class _HomeTabState extends State<HomeTab> {
  int safetyScore = 100;
  String userName = "Tourist";
  String? currentCity;
  Map<String, dynamic>? weatherData;

  List<Map<String, dynamic>> geofences = [];
  String? activeGeofenceWarning;
  Position? currentPosition;

  List<Map<String, dynamic>> touristSpots = [];
  


  @override
  void initState() {
    super.initState();
    _loadData();
    _initGeofencing();
    _fetchTouristSpots();
  }

  Future<void> _loadData() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      userName = prefs.getString('fullName') ?? "Tourist";
    });

    // Fetch actual city
    String? fetchedCity = await LocationService.getCurrentCity();
    setState(() {
      currentCity = (fetchedCity != null && fetchedCity.isNotEmpty)
          ? fetchedCity
          : "Fetching location...";
    });

    // Replace with real values later
    int riskyZones = 2;
    int safeZones = 5;
    int trips = 3;
    setState(() {
      safetyScore = SafetyScoreService.calculateScore(
        riskyZonesEntered: riskyZones,
        safeZonesEntered: safeZones,
        tripsCompleted: trips,
      );
    });

    // Fetch weather
    await _loadWeather();
  }

  Future<void> _loadWeather() async {
    try {
      Position position = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high);

      final data = await WeatherService.fetchWeather(
          position.latitude, position.longitude);

      setState(() {
        weatherData = data;
        currentPosition = position;
      });
    } catch (e) {
      print("Error fetching weather: $e");
    }
  }

  /// Initialize geofencing
  Future<void> _initGeofencing() async {
    geofences = await GeofencingService.fetchGeofences();

    Geolocator.getPositionStream(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.high,
        distanceFilter: 0, // update every 10m
      ),
    ).listen((Position position) {
      setState(() {
        currentPosition = position;
      });
      List<String> insideZones = [];
      for (var geofence in geofences) {
        if (GeofencingService.isInsideGeofence(position, geofence)) {
          insideZones.add(geofence['label']);
        }
      }
      if (insideZones.isNotEmpty) {
        setState(() {
          activeGeofenceWarning =
              "Geofencing Alert: You are entering unsafe/unauthorized area ${insideZones.join(', ')}";
        });
      
        //Trigger local notification
        GeofencingService.initNotifications();
        GeofencingService.showAlert(
            "⚠ Alert", 
            "Geofencing Alert: You are entering unsafe/unauthorized area ${insideZones.join(', ')}"
        );
      }
      else {
        setState(() {
          activeGeofenceWarning = null;
        });
      }
    });
  }
      

  /// Fetch tourist spots dynamically from Firestore
  Future<void> _fetchTouristSpots() async {
    try {
      final snapshot =
          await FirebaseFirestore.instance.collection('tourist_spots').get();

      List<Map<String, dynamic>> spots = snapshot.docs.map((doc) {
        final data = doc.data();
        return {
          "id": doc.id,
          "name": doc['name'],
          "latitude": doc['latitude'],
          "longitude": doc['longitude'],
          "description": doc['description'],
          "imageUrl": data.containsKey('imageUrl') ? data['imageUrl'] : null,
        };
      }).toList();

      // Add distance field if we already have user position
      if (currentPosition != null) {
        for (var spot in spots) {
          spot['distance'] = Geolocator.distanceBetween(
            currentPosition!.latitude,
            currentPosition!.longitude,
            spot['latitude'],
            spot['longitude'],
          );
        }
        spots.sort((a, b) => (a['distance'] ?? 0).compareTo(b['distance'] ?? 0));
      }

      setState(() {
        touristSpots = spots;
      });
    } catch (e) {
      print("Error fetching tourist spots: $e");
    }
  }

  Color getSafetyColor() {
    if (safetyScore > 70) return Colors.green;
    if (safetyScore > 40) return Colors.orange;
    return Colors.red;
  }

  IconData getWeatherIcon(String condition) {
    condition = condition.toLowerCase();
    if (condition.contains("cloud")) return Icons.cloud;
    if (condition.contains("rain")) return Icons.beach_access;
    if (condition.contains("storm") || condition.contains("thunder")) {
      return Icons.flash_on;
    }
    if (condition.contains("snow")) return Icons.ac_unit;
    return Icons.wb_sunny;
  }

  double _calculateDistance(Map<String, dynamic> geofence) {
    if (currentPosition == null) return 0.0;
    return Geolocator.distanceBetween(
      currentPosition!.latitude,
      currentPosition!.longitude,
      geofence['latitude'],
      geofence['longitude'],
    );
  }

  Future<void> _openInGoogleMaps(double lat, double lng) async {
    final url = "https://www.google.com/maps/search/?api=1&query=$lat,$lng";
    if (await canLaunchUrl(Uri.parse(url))) {
      await launchUrl(Uri.parse(url));
    } else {
      throw "Could not launch Google Maps";
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.blue.shade100, Colors.white],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
      ),
      child: RefreshIndicator(
        onRefresh: () async {
          await _loadData();
          await _fetchTouristSpots();
        },
        child: SingleChildScrollView(
          physics: AlwaysScrollableScrollPhysics(),
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(24),
                topRight: Radius.circular(24),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black12,
                  blurRadius: 6,
                  offset: Offset(0, -2),
                )
              ],
            ),
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 👋 Welcome Message
                Text(
                  "Welcome, $userName 👋",
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                SizedBox(height: 20),

                // ⚠ Geofence Warning / Safe Zone Card
                Card(
                  color: activeGeofenceWarning != null
                      ? Colors.red.shade100
                      : Colors.green.shade100,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  elevation: 5,
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      children: [
                        Icon(
                          activeGeofenceWarning != null
                              ? Icons.warning
                              : Icons.check_circle,
                          color: activeGeofenceWarning != null
                              ? Colors.red
                              : Colors.green,
                        ),
                        SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            activeGeofenceWarning ??
                                "✅ You are currently in a safe zone",
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: activeGeofenceWarning != null
                                  ? Colors.red.shade900
                                  : Colors.green.shade900,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                SizedBox(height: 20),

                // 📍 Tourist Spots
                if (touristSpots.isNotEmpty) ...[
                  Text(
                    "Nearby Tourist Spots:",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  SizedBox(height: 10),
                  ...touristSpots.map((spot) {
                    return Card(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 3,
                      child: ListTile(
                        leading: spot['imageUrl'] != null
                            ? ClipRRect(
                                borderRadius: BorderRadius.circular(8),
                                child: Image.network(
                                  spot['imageUrl'],
                                  width: 50,
                                  height: 50,
                                  fit: BoxFit.cover,
                                ),
                              )
                            : Icon(Icons.landscape, color: Colors.blueAccent),
                        title: Text(spot['name']),
                        subtitle: Text(
                          "${spot['description']}\n${spot['distance'] != null ? '${spot['distance'].toStringAsFixed(1)} m away' : ''}",
                        ),
                        onTap: () => _openInGoogleMaps(
                          spot['latitude'],
                          spot['longitude'],
                        ),
                      ),
                    );
                  }).toList(),
                  SizedBox(height: 20),
                ],

                // 📍 List of all Geofences
                if (geofences.isNotEmpty)
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Nearby Geofences:",
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      SizedBox(height: 10),
                      ...geofences.map((geo) {
                        double dist = _calculateDistance(geo);
                        return Card(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          elevation: 3,
                          child: ListTile(
                            leading: Icon(Icons.location_on,
                                color: Colors.blueAccent),
                            title: Text(geo['label']),
                            subtitle: Text(
                              "Radius: ${geo['radius']} m | Distance: ${dist.toStringAsFixed(1)} m",
                            ),
                          ),
                        );
                      }).toList(),
                    ],
                  ),

                SizedBox(height: 20),

                // 📍 Current City Card
                Card(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  elevation: 5,
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Row(
                      children: [
                        CircleAvatar(
                          backgroundColor: Colors.blue.withOpacity(0.2),
                          child: Icon(Icons.location_city, color: Colors.blue),
                        ),
                        SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "Current City",
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              SizedBox(height: 6),
                              Text(
                                currentCity ?? "Fetching location...",
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w500,
                                  color: Colors.black87,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                SizedBox(height: 20),

                // 🛡 Safety Score Card
                Card(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  elevation: 4,
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      children: [
                        Text(
                          "Your Safety Score",
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        SizedBox(height: 12),
                        CircleAvatar(
                          radius: 50,
                          backgroundColor: getSafetyColor(),
                          child: Text(
                            "$safetyScore",
                            style: TextStyle(
                              fontSize: 32,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ),
                        SizedBox(height: 12),
                        Text(
                          safetyScore > 70
                              ? "✅ Safe"
                              : (safetyScore > 40
                                  ? "⚠ Moderate Risk"
                                  : "🚨 High Risk"),
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                SizedBox(height: 20),

                // 🌦 Weather Info Card
                if (weatherData != null)
                  Card(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    elevation: 4,
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Row(
                        children: [
                          CircleAvatar(
                            backgroundColor: Colors.orange.withOpacity(0.2),
                            child: Icon(
                              getWeatherIcon(
                                  weatherData!['weather'][0]['main'] ?? ''),
                              color: Colors.orange,
                            ),
                          ),
                          SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  "${weatherData!['name'] ?? ''}",
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                SizedBox(height: 6),
                                Text(
                                  "${weatherData!['main']['temp']}°C | ${weatherData!['weather'][0]['description']}",
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w500,
                                    color: Colors.black87,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  )
                else
                  Center(child: CircularProgressIndicator()),
              ],
            ),
          ),
        ),
      ),
    );
  }
}