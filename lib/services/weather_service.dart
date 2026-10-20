import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/weather_info.dart';

class WeatherService {
  Future<WeatherInfo> getCurrentWeather({
    required double latitude,
    required double longitude,
  }) async {
    final uri = Uri.parse(
      'https://api.open-meteo.com/v1/forecast'
      '?latitude=$latitude'
      '&longitude=$longitude'
      '&current=temperature_2m,precipitation,weather_code',
    );

    final response = await http.get(uri);

    if (response.statusCode != 200) {
      throw Exception('Failed to load weather');
    }

    final data = jsonDecode(response.body);

    final current = data['current'] as Map<String, dynamic>;

    return WeatherInfo(
      temperature: (current['temperature_2m'] as num).toDouble(),
      precipitation: (current['precipitation'] as num).toDouble(),
      weatherCode: current['weather_code'] as int,
    );
  }
}