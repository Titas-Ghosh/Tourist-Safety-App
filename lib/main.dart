// lib/main.dart
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';

// 🔹 Your screens
import 'screens/user_type_selection_screen.dart';
import 'screens/language_selection_screen.dart';
import 'screens/manual_upload_screen.dart';
import 'screens/user_details_screen.dart';

// 🔹 Import geofencing service
import 'services/geofencing_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    // ✅ Initialize Firebase
    await Firebase.initializeApp();
    print("✅ Firebase initialized successfully");

    // ✅ Init notifications
    await GeofencingService.initNotifications();

    // ✅ Start monitoring geofences
    await GeofencingService.startMonitoring();
  } catch (e) {
    print("❌ Initialization failed: $e");
  }

  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Atithi Rakshak',
      initialRoute: '/',
      routes: {
        '/': (context) => UserTypeSelectionScreen(),
        '/language-selection': (context) => LanguageSelectionScreen(),
        '/manual-upload': (context) => ManualUploadScreen(),
        '/user-details': (context) => UserDetailsScreen(userType: ''),
      },
    );
  }
}
