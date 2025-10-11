// ✅ Imports
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:geolocator/geolocator.dart';
import 'package:url_launcher/url_launcher.dart';

// 🔹 Firebase
import 'package:cloud_firestore/cloud_firestore.dart';

// 🔹 Your Pages
import 'emergency_contacts_screen.dart';
import 'home_tab.dart';
import 'map_page.dart'; // ✅ Import MapPage here
import 'trip_details_page.dart';
import 'complaint_page.dart';

class MainScreen extends StatefulWidget {
  @override
  _MainScreenState createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _selectedIndex = 0;

  // 🔹 User Profile Fields
  String? fullName, dob, gender, idType, idNumber, mobile;

  @override
  void initState() {
    super.initState();
    _loadUserDetails();
  }

  // 🔹 Load user details from SharedPreferences
  Future<void> _loadUserDetails() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      fullName = prefs.getString('fullName');
      dob = prefs.getString('dob');
      gender = prefs.getString('gender');
      idType = prefs.getString('idType');
      idNumber = prefs.getString('idNumber');
      mobile = prefs.getString('mobile');
    });
  }

  // 🔹 Request location permission
  Future<Position> _getUserLocation() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      throw Exception("Location services are disabled.");
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        throw Exception("Location permissions are denied.");
      }
    }

    if (permission == LocationPermission.deniedForever) {
      throw Exception("Location permissions are permanently denied.");
    }

    return await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);
  }

  // 🔹 SOS Functionality
  Future<void> _onSOSPressed() async {
    final prefs = await SharedPreferences.getInstance();
    final contacts = prefs.getStringList('emergency_contacts') ?? [];

    if (contacts.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("⚠️ No emergency contacts added!")),
      );
      return;
    }

    try {
      Position position = await _getUserLocation();
      final locationLink =
          "https://maps.google.com/?q=${position.latitude},${position.longitude}";

      final message =
          "🚨 SOS Alert! I need help.\nMy location: $locationLink";

      // ✅ Send SMS (existing feature)
      final String allRecipients = contacts.join(',');
      final Uri smsUri = Uri(
        scheme: 'sms',
        path: allRecipients,
        queryParameters: <String, String>{'body': message},
      );

      if (await canLaunchUrl(smsUri)) {
        await launchUrl(smsUri);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("✅ Opening SMS app for ${contacts.length} contacts!"),
            backgroundColor: Colors.red,
          ),
        );
      } else {
        throw Exception("Could not launch SMS app.");
      }

      // ✅ Push alert to Firebase Firestore
      await FirebaseFirestore.instance.collection("alerts").add({
        "title": "SOS Alert 🚨",
        "description": "User ${fullName ?? "Unknown"} requested help!",
        "priority": "urgent",
        "type": "urgent",
        "location": locationLink,
        "latitude": position.latitude,
        "longitude": position.longitude,
        "timestamp": DateTime.now().toIso8601String(),
        "status": "active",
        "user": {
          "name": fullName ?? "Unknown",
          "mobile": mobile ?? "-",
        }
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("❌ Failed to send SOS: $e")),
      );
    }
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  Widget _buildNavItem({
    required IconData icon,
    required String label,
    required int index,
  }) {
    final isSelected = _selectedIndex == index;
    return GestureDetector(
      onTap: () => _onItemTapped(index),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          AnimatedContainer(
            duration: Duration(milliseconds: 250),
            curve: Curves.easeInOut,
            padding: EdgeInsets.all(isSelected ? 10 : 6),
            decoration: BoxDecoration(
              color: isSelected ? Colors.white : Colors.transparent,
              shape: BoxShape.circle,
              boxShadow: isSelected
                  ? [
                      BoxShadow(
                        color: Colors.black26,
                        blurRadius: 6,
                        offset: Offset(0, 3),
                      )
                    ]
                  : [],
            ),
            child: Icon(
              icon,
              color: isSelected ? Colors.black : Colors.grey,
              size: isSelected ? 28 : 24,
            ),
          ),
          SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              color: isSelected ? Colors.black : Colors.grey,
            ),
          ),
        ],
      ),
    );
  }

  // 🔹 "You" Tab (Profile Page + Emergency Contacts)
  Widget _buildYouPage() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Profile / Settings",
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 20),

          // ✅ Show User Profile Info
          if (fullName != null && mobile != null)
            Card(
              elevation: 4,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildDetailRow("👤 Full Name", fullName!),
                    _buildDetailRow("🎂 Date of Birth", dob ?? "-"),
                    _buildDetailRow("⚧ Gender", gender ?? "-"),
                    _buildDetailRow("🪪 ID Type", idType ?? "-"),
                    _buildDetailRow("🔢 ID Number", idNumber ?? "-"),
                    _buildDetailRow("📱 Mobile", mobile!),
                  ],
                ),
              ),
            )
          else
            Text("⚠️ No user details found."),

          SizedBox(height: 20),

          ElevatedButton.icon(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => EmergencyContactsScreen(),
                ),
              ).then((_) => _loadUserDetails()); // ✅ Refresh after returning
            },
            icon: Icon(Icons.contacts),
            label: Text("Manage Emergency Contacts"),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.redAccent,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              padding: EdgeInsets.symmetric(vertical: 14, horizontal: 16),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10.0),
      child: Row(
        children: [
          Text(
            "$label: ",
            style: TextStyle(
                fontWeight: FontWeight.w600, fontSize: 15, color: Colors.black),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(fontSize: 15, color: Colors.grey.shade800),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final pages = [
      const HomeTab(),
      const MapPage(),
      const ComplaintPage(),
      const TripDetailsPage(),
      _buildYouPage(),
    ];

    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.blue.shade100,
              Colors.white,
            ],
            stops: [0.0, 0.5],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // 🔹 Top bar
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'अतिथि रक्षक',
                          style: TextStyle(
                            fontFamily: 'HindiFont',
                            fontSize: 20,
                            fontWeight: FontWeight.w700,
                            color: Colors.black,
                          ),
                        ),
                        SizedBox(height: 4),
                        Row(
                          children: [
                            Icon(Icons.location_on,
                                size: 16, color: Colors.black),
                            SizedBox(width: 4),
                            Text(
                              "SRM Institute of Science and Technology",
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                                color: Colors.black87,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),

                    // 🔹 SOS Button
                    GestureDetector(
                      onTap: _onSOSPressed,
                      child: Column(
                        children: [
                          Icon(
                            Icons.notifications_active,
                            size: 50,
                            color: Colors.red,
                          ),
                          Text(
                            "SOS",
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: Colors.red,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              // Page Content
              Expanded(
                child: pages[_selectedIndex],
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: Container(
        padding: EdgeInsets.symmetric(vertical: 8),
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 8,
              offset: Offset(0, -2),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _buildNavItem(icon: Icons.home, label: "Home", index: 0),
            _buildNavItem(icon: Icons.map, label: "Map", index: 1),
            _buildNavItem(
                icon: Icons.report_problem, label: "Complaint", index: 2),
            _buildNavItem(icon: Icons.list_alt, label: "Trip Details", index: 3),
            _buildNavItem(icon: Icons.person, label: "You", index: 4),
          ],
        ),
      ),
    );
  }
}
