import 'package:flutter_test/flutter_test.dart';
import 'package:clueless_closet/models/clothing_item.dart';
import 'package:clueless_closet/models/outfit_history.dart';
import 'package:clueless_closet/models/weather_info.dart';
import 'package:clueless_closet/services/outfit_service.dart';

ClothingItem createItem({
  required int id,
  required String name,
  required String category,
  String color = 'Black',
  String style = 'Casual',
  String occasion = 'Everyday',
  String season = 'All',
  int warmthLevel = 3,
  bool rainSuitable = false,
  bool waterResistant = false,
}) {
  return ClothingItem(
    id: id,
    name: name,
    category: category,
    color: color,
    imagePath: '/test/$name.jpg',
    isAssetImage: false,
    style: style,
    occasion: occasion,
    season: season,
    warmthLevel: warmthLevel,
    rainSuitable: rainSuitable,
    waterResistant: waterResistant,
  );
}

void main() {
  late OutfitService outfitService;

  setUp(() {
    outfitService = OutfitService();
  });

  group(
    'OutfitService',
    () {
      test(
        'generates an outfit when all categories exist',
        () {
          final top = createItem(
            id: 1,
            name: 'Black Shirt',
            category: 'Top',
          );

          final bottom = createItem(
            id: 2,
            name: 'Black Pants',
            category: 'Bottom',
          );

          final shoes = createItem(
            id: 3,
            name: 'Black Shoes',
            category: 'Shoes',
          );

          final result = outfitService.generateOutfit(
            tops: [top],
            bottoms: [bottom],
            shoes: [shoes],
            occasion: 'Everyday',
            season: 'All',
            history: const [],
          );

          expect(result, isNotNull);

          expect(result!.top.id, 1);

          expect(result.bottom.id, 2);

          expect(result.shoes.id, 3);
        },
      );

      test(
        'returns null when there are no shoes',
        () {
          final top = createItem(
            id: 1,
            name: 'Shirt',
            category: 'Top',
          );

          final bottom = createItem(
            id: 2,
            name: 'Pants',
            category: 'Bottom',
          );

          final result = outfitService.generateOutfit(
            tops: [top],
            bottoms: [bottom],
            shoes: const [],
            occasion: 'Everyday',
            season: 'All',
            history: const [],
          );

          expect(result, isNull);
        },
      );

      test(
        'score stays between 0 and 100',
        () {
          final top = createItem(
            id: 1,
            name: 'Shirt',
            category: 'Top',
          );

          final bottom = createItem(
            id: 2,
            name: 'Pants',
            category: 'Bottom',
          );

          final shoes = createItem(
            id: 3,
            name: 'Shoes',
            category: 'Shoes',
          );

          final score = outfitService.calculateScore(
            top, 
            bottom,
            shoes,
            'Everyday',
            'All',
            const [],
            null,
          );

          expect(
            score,
            inInclusiveRange(0, 100),
          );
        },
      );

      test(
        'recently worn exact outfit receives a lower score',
        () {
          final top = createItem(
            id: 1,
            name: 'Black Shirt',
            category: 'Top',
          );

          final bottom = createItem(
            id: 2,
            name: 'Jeans',
            category: 'Bottom',
          );

          final shoes = createItem(
            id: 3,
            name: 'Sneakers',
            category: 'Shoes',
          );

          final normalScore = outfitService.calculateScore(
            top,
            bottom,
            shoes,
            'Everyday',
            'All',
            const [],
            null,
          );

          final history = [
            OutfitHistory(
              id: 1,
              topId: 1,
              bottomId: 2,
              shoeId: 3,
              score: normalScore,
              wornAt: DateTime.now(),
            ),
          ];

          final repeatedScore = outfitService.calculateScore(
            top, 
            bottom,
            shoes,
            'Everyday',
            'All',
            history,
            null,
          );

          expect(
            repeatedScore,
            lessThan(normalScore),
          );
        },
      );

      test(
        'light clothing scores better than very warm clothing in hot weather',
        () {
          final lightTop = createItem(
            id: 1,
            name: 'Light Shirt',
            category: 'Top',
            warmthLevel: 1,
            season: 'Summer',
          );

          final warmTop = createItem(
            id: 2,
            name: 'Heavy Hoodie',
            category: 'Top',
            warmthLevel: 5,
            season: 'Winter',
          );

          final bottom = createItem(
            id: 3,
            name: 'Pants',
            category: 'Bottom',
            warmthLevel: 1,
          );

          final shoes = createItem(
            id: 4,
            name: 'Sneakers',
            category: 'Shoes',
            warmthLevel: 1,
          );

          final weather = WeatherInfo(
            temperature: 32,
            precipitation: 0,
            weatherCode: 0,
          );

          final lightScore = outfitService.calculateScore(
            lightTop,
            bottom,
            shoes,
            'Everyday',
            'All',
            const [],
            weather,
          );

          final warmScore = outfitService.calculateScore(
            warmTop,
            bottom,
            shoes,
            'Everybody',
            'All',
            const [],
            weather,
          );

          expect(
            lightScore,
            greaterThan(warmScore),
          );
        },
      );

      test(
        'rain-friendly shoes score better in rainy weather',
        () {
          final top = createItem(
            id: 1,
            name: 'Top',
            category: 'Top',
            color: 'Blue',
            style: 'Casual',
            occasion: 'Work',
            season: 'All',
            warmthLevel: 3,
            rainSuitable: true,
          );

          final bottom = createItem(
            id: 2,
            name: 'Bottom',
            category: 'Bottom',
            color: 'Brown',
            style: 'Formal',
            occasion: 'Work',
            season: 'All',
            warmthLevel: 3,
            rainSuitable: true,
          );

          final rainBoots = createItem(
            id: 3,
            name: 'Rain Boots',
            category: 'Shoes',
            color: 'Green',
            style: 'Sport',
            occasion: 'Gym',
            season: 'All',
            warmthLevel: 3,
            rainSuitable: true,
            waterResistant: true,
          );

          final canvasShoes = createItem(
            id: 4,
            name: 'Canvas Shoes',
            category: 'Shoes',
            color: 'Green',
            style: 'Sport',
            occasion: 'Gym',
            season: 'All',
            warmthLevel: 3,
            rainSuitable: false,
            waterResistant: false,
          );

          final weather = WeatherInfo(
            temperature: 18,
            precipitation: 4,
            weatherCode: 61,
          );

          final bootsScore =
              outfitService.calculateScore(
            top,
            bottom,
            rainBoots,
            'Everyday',
            'All',
            const [],
            weather,
          );

          final canvasScore =
              outfitService.calculateScore(
            top,
            bottom,
            canvasShoes,
            'Everyday',
            'All',
            const [],
            weather,
          );

          expect(
            bootsScore,
            greaterThan(canvasScore),
          );
        },
      );
    },
  );
}
