import 'package:flutter_test/flutter_test.dart';
import 'package:clueless_closet/models/clothing_item.dart';

void main() {
  group(
    'ClothingItem',
    () {
      test(
        'converts to map correctly',
        () {
          final item = ClothingItem(
            id: 1,
            name: 'Black Hoodie',
            category: 'Top',
            color: 'Black',
            imagePath: 'images/hoodie.jpg',
            isAssetImage: false,
            style: 'Casual',
            occasion: 'Everyday',
            season: 'Winter',
            warmthLevel: 4,
            rainSuitable: true,
            waterResistant: false,
          );

          final map = item.toMap();

          expect(
            map['id'],
            1,
          );

          expect(
            map['name'],
            'Black Hoodie',
          );

          expect(
            map['category'],
            'Top',
          );

          expect(
            map['color'],
            'Black',
          );

          expect(
            map['style'],
            'Casual',
          );

          expect(
            map['occasion'],
            'Everyday',
          );

          expect(
            map['season'],
            'Winter',
          );

          expect(
            map['warmthLevel'],
            4,
          );

          expect(
            map['rainSuitable'],
            1,
          );

          expect(
            map['waterResistant'],
            0,
          );
        },
      );

      test(
        'creates ClothingItem from map correctly',
        () {
          final map = {
            'id': 5,
            'name': 'Rain Boots',
            'category': 'Shoes',
            'color': 'Black',
            'imagePath': '/images/boots.jpg',
            'isAssetImage': 0,
            'style': 'Casual',
            'occasion': 'Everyday',
            'season': 'Winter',
            'warmthLevel': 4,
            'rainSuitable': 1,
            'waterResistant': 1,
          };

          final item = ClothingItem.fromMap(map);

          expect(item.id, 5);

          expect(item.name, 'Rain Boots');

          expect(item.category, 'Shoes');

          expect(item.warmthLevel, 4);

          expect(item.rainSuitable, true);

          expect(item.waterResistant, true);

          expect(item.isAssetImage, false);
        },
      );

      test(
        'copyWith changes selected values and keeps the rest',
        () {
          final original = ClothingItem(
            id: 1,
            name: 'Black Hoodie',
            category: 'Top',
            color: 'Black',
            imagePath: '/hoodie.jpg',
            isAssetImage: false,
            style: 'Casual',
            occasion: 'Everyday',
            season: 'Winter',
            warmthLevel: 4,
            rainSuitable: false,
            waterResistant: false,
          );

          final updated = original.copyWith(
            name: 'Heavy Black Hoodie',
            warmthLevel: 5,
          );

          expect(updated.name, 'Heavy Black Hoodie');

          expect(updated.warmthLevel, 5);

          expect(updated.id, original.id);

          expect(updated.color, original.color);

          expect(updated.category, original.category);
        },
      );
    },
  );
}