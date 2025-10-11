// lib/services/safety_score_service.dart
import 'dart:math';

class SafetyScoreService {
  /// Calculate safety score based on simple logic
  static int calculateScore({
    required int riskyZonesEntered,
    required int safeZonesEntered,
    required int tripsCompleted,
  }) {
    int base = 100;

    // Deduct points for risky zones
    base -= riskyZonesEntered * 15;

    // Add points for safe behaviour
    base += safeZonesEntered * 5;

    // Small bonus for completed trips
    base += tripsCompleted * 2;

    // Clamp between 0–100
    return max(0, min(100, base));
  }
}
