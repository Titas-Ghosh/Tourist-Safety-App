# Tourist Safety App

A modern tourist safety app built with Flutter that provides real-time alerts for unsafe zones, SOS messaging, and trip management features to ensure a secure travel experience.

## Core Features
- **Geofencing Alerts:** Automatically sends notifications when a user enters a pre-defined unsafe zone fetched from Cloud Firestore.
- **SOS System:** Sends a custom emergency message with the user's live location to saved contacts.
- **Trip Management:** Plan upcoming trips and view their status (Upcoming/Ongoing) on the dashboard.
- **Dynamic Safety Score:** Calculates a safety score based on user activity and location.
- **Live Weather Updates:** Shows current weather conditions for the user's location.

## Tech Stack
- **Frontend:** Flutter
- **Database:** Cloud Firestore
- **Services:** `geofencing_api`, `flutter_local_notifications`, `geolocator`, `shared_preferences`, `http`

## Getting Started

This project is a starting point for a Flutter application.

A few resources to get you started if this is your first Flutter project:

- [Lab: Write your first Flutter app](https://docs.flutter.dev/get-started/codelab)
- [Cookbook: Useful Flutter samples](https://docs.flutter.dev/cookbook)

For help getting started with Flutter development, view the
[online documentation](https://docs.flutter.dev/), which offers tutorials,
samples, guidance on mobile development, and a full API reference.