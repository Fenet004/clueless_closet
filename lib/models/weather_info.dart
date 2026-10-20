class WeatherInfo {
  final double temperature;
  final double precipitation;
  final int weatherCode;

  WeatherInfo({
    required this.temperature,
    required this.precipitation,
    required this.weatherCode,
  });

  bool get isRainy {
    return precipitation > 0 ||
        (weatherCode >= 51 && weatherCode <= 67) ||
        (weatherCode >= 80 && weatherCode <= 82) ||
        (weatherCode >= 95);
  }

  String get temperatureCategory {
    if (temperature >= 28) {
      return 'Hot';
    }

    if (temperature >= 20) {
      return 'Warm';
    }

    if (temperature >= 12) {
      return 'Cool';
    }

    return 'Cold';
  }
}