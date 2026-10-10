import 'clothing_item.dart';

class Outfit {
  final ClothingItem top;
  final ClothingItem bottom;
  final ClothingItem shoes;
  final int score;

  Outfit({
    required this.top,
    required this.bottom,
    required this.shoes,
    required this.score,
  });
}