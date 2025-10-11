import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import '../services/geofencing_service.dart';

class MapPage extends StatefulWidget {
  const MapPage({Key? key}) : super(key: key);

  @override
  State<MapPage> createState() => _MapPageState();
}

class _MapPageState extends State<MapPage> {
  GoogleMapController? _mapController;
  Position? _currentPosition;
  final Set<Marker> _markers = {};
  final Set<Circle> _circles = {};

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    // Get current location
    _currentPosition = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );

    // Fetch geofences from Firestore
    final geofences = await GeofencingService.fetchGeofences();

    // Add geofence markers + circles
    for (var gf in geofences) {
      final LatLng pos = LatLng(gf['latitude'], gf['longitude']);

      _markers.add(
        Marker(
          markerId: MarkerId(gf['id']),
          position: pos,
          infoWindow: InfoWindow(title: gf['label']),
          icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
        ),
      );

      _circles.add(
        Circle(
          circleId: CircleId(gf['id']),
          center: pos,
          radius: gf['radius'].toDouble(),
          strokeWidth: 2,
          strokeColor: Colors.red,
          fillColor: Colors.red.withOpacity(0.2),
        ),
      );
    }

    // Add current user location marker
    if (_currentPosition != null) {
      final LatLng userPos =
          LatLng(_currentPosition!.latitude, _currentPosition!.longitude);

      _markers.add(
        Marker(
          markerId: const MarkerId("user"),
          position: userPos,
          infoWindow: const InfoWindow(title: "You are here"),
          icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue),
        ),
      );
    }

    setState(() {});
  }

  /// Move camera to user location
  Future<void> _goToUserLocation() async {
    if (_currentPosition != null && _mapController != null) {
      _mapController!.animateCamera(
        CameraUpdate.newLatLngZoom(
          LatLng(_currentPosition!.latitude, _currentPosition!.longitude),
          16,
        ),
      );
    }
  }

  /// Zoom in
  void _zoomIn() {
    _mapController?.animateCamera(CameraUpdate.zoomIn());
  }

  /// Zoom out
  void _zoomOut() {
    _mapController?.animateCamera(CameraUpdate.zoomOut());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Geofence Map"),
        backgroundColor: Colors.redAccent,
      ),
      body: _currentPosition == null
          ? const Center(child: CircularProgressIndicator())
          : Stack(
              children: [
                GoogleMap(
                  initialCameraPosition: CameraPosition(
                    target: LatLng(
                      _currentPosition!.latitude,
                      _currentPosition!.longitude,
                    ),
                    zoom: 14,
                  ),
                  onMapCreated: (controller) => _mapController = controller,
                  myLocationEnabled: true,
                  myLocationButtonEnabled: false, // using our custom button
                  markers: _markers,
                  circles: _circles,
                ),

                // Map Controls (Bottom Right)
                Positioned(
                  bottom: 20,
                  right: 10,
                  child: Column(
                    children: [
                      FloatingActionButton(
                        heroTag: "zoomIn",
                        onPressed: _zoomIn,
                        mini: true,
                        backgroundColor: Colors.white,
                        child: const Icon(Icons.add, color: Colors.black),
                      ),
                      const SizedBox(height: 10),
                      FloatingActionButton(
                        heroTag: "zoomOut",
                        onPressed: _zoomOut,
                        mini: true,
                        backgroundColor: Colors.white,
                        child: const Icon(Icons.remove, color: Colors.black),
                      ),
                      const SizedBox(height: 10),
                      FloatingActionButton(
                        heroTag: "myLocation",
                        onPressed: _goToUserLocation,
                        mini: true,
                        backgroundColor: Colors.blueAccent,
                        child: const Icon(Icons.my_location),
                      ),
                    ],
                  ),
                ),
              ],
            ),
    );
  }
}
