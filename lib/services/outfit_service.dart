import 'dart:math';
import '../models/clothing_item.dart';
import '../models/outfit.dart';

class OutfitService {
  final Random _random = Random();

  Outfit? generateOutfit({
    required List<ClothingItem> tops,
    required List<ClothingItem> bottoms,
    required List<ClothingItem> shoes,
  }) {
    if (tops.isEmpty || bottoms.isEmpty || shoes.isEmpty) {
      return null;
    }

    Outfit? bestOutfit;

    for (int i = 0; i < 20; i++) {
      final top = tops[_random.nextInt(tops.length)];
      final bottom = bottoms[_random.nextInt(bottoms.length)];
      final shoe = shoes[_random.nextInt(shoes.length)];

      final score = calculateScore(top, bottom, shoe);

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
  ) {
    int score = 30;

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
      score += 10;
    }

    if (bottom.style == shoes.style) {
      score += 10;
    }

    if (top.occasion == bottom.occasion) {
      score += 5;
    }

    if (bottom.occasion == shoes.occasion) {
      score += 5;
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
}