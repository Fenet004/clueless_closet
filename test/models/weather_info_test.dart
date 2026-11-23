import 'package:flutter_test/flutter_test.dart';
import 'package:clueless_closet/models/weather_info.dart';

void main() {
  group(
    'WeatherInfo',
    () {
      test(
        'classifies hot temperatures correctly',
        () {
          final weather = WeatherInfo(
            temperature: 31,
            precipitation: 0,
            weatherCode: 0
          );

          expect(
            weather.temperatureCategory,
            'Hot',
          );
        },
      );

      test(
        'detects rain from precipitation',
        () {
          final weather = WeatherInfo(
            temperature: 20,
            precipitation: 2.5,
            weatherCode: 0,
          );

          expect(weather.isRainy, true);
        },
      );

      test(
        'detects rain from weather code',
        () {
          final weather = WeatherInfo(
            temperature: 20,
            precipitation: 0,
            weatherCode: 61,
          );

          expect(weather.isRainy, true);
        },
      );
    },
  );
}