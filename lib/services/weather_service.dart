import 'dart:convert';
import 'package:http/http.dart' as http;

class WeatherService {
  static const String _apiKey = "4f7594e54df2310e9a5c3da1f017deb1"; // 🔹 Replace with your OpenWeatherMap API key

  static Future<Map<String, dynamic>?> fetchWeather(double lat, double lon) async {
    final url =
        "https://api.openweathermap.org/data/2.5/weather?lat=$lat&lon=$lon&appid=$_apiKey&units=metric";

    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        return json.decode(response.body);
      }
    } catch (e) {
      print("Weather fetch error: $e");
    }
    return null;
  }
}
