import 'dart:math';
import '../models/clothing_item.dart';
import '../models/outfit.dart';

class OutfitService {
  final Random _random = Random();

  Outfit? generateOutfit({
    required List<ClothingItem> tops,
    required List<ClothingItem> bottoms,
    required List<ClothingItem> shoes,
    required String occasion,
  }) {
    final matchingTops = _filterByOccasion(tops, occasion);
    final matchingBottoms = _filterByOccasion(bottoms, occasion);
    final matchingShoes = _filterByOccasion(shoes, occasion);
    
    if (matchingTops.isEmpty || matchingBottoms.isEmpty || matchingShoes.isEmpty) {
      return null;
    }

    Outfit? bestOutfit;

    for (int i = 0; i < 20; i++) {
      final top = matchingTops[_random.nextInt(matchingTops.length)];
      final bottom = matchingBottoms[_random.nextInt(matchingBottoms.length)];
      final shoe = matchingShoes[_random.nextInt(matchingShoes.length)];

      final score = calculateScore(top, bottom, shoe, occasion);

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

    return bestOutfit;
  }

  int calculateScore(
    ClothingItem top,
    ClothingItem bottom,
    ClothingItem shoes,
    String occasion,
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

  List<ClothingItem> _filterByOccasion(
    List<ClothingItem> items,
    String occasion,
  ) {
    final matches = items.where((item) {
      return item.occasion == occasion || item.occasion == 'Everyday';
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
}