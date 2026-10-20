import '../models/clothing_item.dart';
import '../models/outfit.dart';
import '../models/outfit_history.dart';
import '../models/weather_info.dart';

class OutfitService {

  Outfit? generateOutfit({
    required List<ClothingItem> tops,
    required List<ClothingItem> bottoms,
    required List<ClothingItem> shoes,
    required String occasion,
    required String season,
    required List<OutfitHistory> history,
    WeatherInfo? weather,
  }) {
    final matchingTops = _filterItems(
      items: tops,
      occasion: occasion,
      season: season,
    );

    final matchingBottoms = _filterItems(
      items: bottoms,
      occasion: occasion,
      season: season,
    );

    final matchingShoes = _filterItems(
      items: shoes,
      occasion: occasion,
      season: season,
    );

    if (matchingTops.isEmpty || matchingBottoms.isEmpty || matchingShoes.isEmpty) {
      return null;
    }

    Outfit? bestOutfit;

    for (final top in matchingTops) {
      for (final bottom in matchingBottoms) {
        for (final shoe in matchingShoes) {
          final score = calculateScore(
            top, 
            bottom,
            shoe,
            occasion,
            season,
            history,
            weather,
          );

          final outfit = Outfit(
            top: top,
            bottom: bottom,
            shoes: shoe,
            score: score,
          );

          if (bestOutfit == null || outfit.score > bestOutfit.score) {
            bestOutfit = outfit;
          }
        }
      }
    }

    return bestOutfit;
  }

  int calculateScore(
    ClothingItem top,
    ClothingItem bottom,
    ClothingItem shoes,
    String occasion,
    String season,
    List<OutfitHistory> history,
    WeatherInfo? weather,
  ) {
    int score = 25;

    score += _colorCompatibility(
      top.color,
      bottom.color,
    );

    score += _colorCompatibility(
      bottom.color,
      shoes.color,
    );

    score += _colorCompatibility(
      top.color,
      shoes.color,
    );

    if (top.style == bottom.style) {
      score += 8;
    }

    if (bottom.style == shoes.style) {
      score += 8;
    }

    score += _occasionCompatibility(top.occasion, occasion);

    score += _occasionCompatibility(bottom.occasion, occasion);

    score += _occasionCompatibility(shoes.occasion, occasion);

    score += _seasonCompatibility(top.season, season);

    score += _seasonCompatibility(bottom.season, season);

    score += _seasonCompatibility(shoes.season, season);

    score -= _recentWearPenalty(top, bottom, shoes, history);

    if (weather != null) {
      score += _weatherCompatibility(top, weather);

      score += _weatherCompatibility(bottom, weather);

      score += _weatherCompatibility(shoes, weather);
    }

    return score.clamp(0, 100);
  }

  int _colorCompatibility(
    String color1,
    String color2,
  ) {
    final first = color1.toLowerCase();
    final second = color2.toLowerCase();

    if (first == second) {
      return 10;
    }

    final neutralColors = {
      'black',
      'white',
      'gray',
      'brown',
      'khaki',
    };

    if (neutralColors.contains(first) || neutralColors.contains(second)) {
      return 12;
    }

    final goodPairs = {
      'blue-white',
      'white-blue',
      'blue-black',
      'black-blue',
      'red-black',
      'black-red',
      'green-brown',
      'brown-green',
      'blue-khaki',
      'khaki-blue',
    };

    final pair = '$first-$second';

    if (goodPairs.contains(pair)) {
      return 15;
    }

    return 3;
  }

  int _weatherCompatibility(
    ClothingItem item,
    WeatherInfo weather,
  ) {
    int score = 0;

    switch (weather.temperatureCategory) {
      case 'Hot':
        if (item.season == 'Summer') {
          score += 10;
        } else if (item.season == 'Winter') {
          score -= 15;
        }

        break;

      case 'Warm':
        if (item.season == 'Summer' || item.season == 'All') {
          score += 6;
        }

        break;

      case 'Cool':
        if (item.season == 'Spring' ||
            item.season == 'Fall' ||
            item.season == 'All') {
          score += 6;
        }

        break;

      case 'Cold':
        if (item.season == 'Winter') {
          score += 12;
        } else if (item.season == 'Summer') {
          score -= 15;
        }

        break;
    }

    return score;
  }

  List<ClothingItem> _filterItems({
    required List<ClothingItem> items,
    required String occasion,
    required String season,
  }) {
    final matches = items.where((item) {
      final occasionMatches =
          item.occasion == occasion ||
          item.occasion == 'Everyday';
      
      final seasonMatches = 
          season == 'All' ||
          item.season == season ||
          item.season == 'All';
      
      return occasionMatches && seasonMatches;
    }).toList();

    if (matches.isEmpty) {
      return items;
    }

    return matches;
  }

  int _occasionCompatibility(
    String itemOccasion,
    String targetOccasion,
  ) {
    if (itemOccasion == targetOccasion) {
      return 10;
    }

    if (itemOccasion == 'Everyday') {
      return 4;
    }

    if (targetOccasion == 'Formal' && itemOccasion == 'Gym') {
      return -20;
    }

    if (targetOccasion == 'Gym' && itemOccasion == 'Formal') {
      return -20;
    }

    return 0;
  }

  int _seasonCompatibility(String itemSeason, String targetSeason) {
    if (targetSeason == 'All') {
      return 0;
    }

    if (itemSeason == targetSeason) {
      return 8;
    }

    if (itemSeason == 'All') {
      return 4;
    }

    final badPairs = {
      'Winter-Summer',
      'Summer-Winter',
    };

    final pair = '$itemSeason-$targetSeason';

    if (badPairs.contains(pair)) {
      return -15;
    }

    return -3;
  }

  int _recentWearPenalty(
    ClothingItem top,
    ClothingItem bottom,
    ClothingItem shoes,
    List<OutfitHistory> history,
  ) {
    if (top.id == null || bottom.id == null || shoes.id == null) {
      return 0;
    }

    int penalty = 0;

    final now = DateTime.now();

    for (final item in history) {
      final daysAgo = _daysBetween(now, item.wornAt);

      if (daysAgo > 7) {
        continue;
      }

      final sameTop = item.topId == top.id;
      final sameBottom = item.bottomId == bottom.id;
      final sameShoes = item.shoeId == shoes.id;

      final exactOutfit = sameTop && sameBottom && sameShoes;

      if (exactOutfit) {
        if (daysAgo == 0) {
          penalty += 50;
        } else if (daysAgo <= 2) {
          penalty += 35;
        } else if (daysAgo <= 7) {
          penalty += 20;
        }

        continue;
      }

      if (sameTop && daysAgo <= 2) {
        penalty += 6;
      }

      if (sameBottom && daysAgo <= 2) {
        penalty += 6;
      }

      if (sameShoes && daysAgo <= 1) {
        penalty +=3;
      }
    }

    return penalty;
  }

  int _daysBetween(DateTime first, DateTime second) {
    final firstDate = DateTime(
      first.year,
      first.month,
      first.day
    );

    final secondDate = DateTime(
      second.year,
      second.month,
      second.day,
    );

    return firstDate.difference(secondDate).inDays;
  }
}