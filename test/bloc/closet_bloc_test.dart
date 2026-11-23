import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:clueless_closet/bloc/closet_bloc.dart';
import 'package:clueless_closet/bloc/closet_event.dart';
import 'package:clueless_closet/bloc/closet_state.dart';
import 'package:clueless_closet/models/clothing_item.dart';
import 'package:clueless_closet/services/database_service.dart';
import 'package:clueless_closet/services/image_storage_service.dart';

class MockDatabaseService extends Mock
    implements DatabaseService {}

class MockImageStorageService extends Mock
    implements ImageStorageService {}

void main() {
  late MockDatabaseService databaseService;
  late MockImageStorageService imageStorageService;

  late ClothingItem newItem;
  late ClothingItem savedItem;
  late ClothingItem updatedItem;

  setUp(() {
    databaseService = MockDatabaseService();
    imageStorageService = MockImageStorageService();

    newItem = ClothingItem(
      name: 'Blue Shirt',
      category: 'Top',
      color: 'Blue',
      imagePath: '/images/blue_shirt.jpg',
      isAssetImage: false,
      style: 'Casual',
      occasion: 'Everyday',
      season: 'All',
      warmthLevel: 2,
      rainSuitable: false,
      waterResistant: false,
    );

    savedItem = newItem.copyWith(
      id: 10,
    );

    updatedItem = savedItem.copyWith(
      name: 'Dark Blue Shirt',
      warmthLevel: 3,
    );
  });

  group(
    'ClosetBloc',
    () {
      test(
        'initial state is empty',
        () {
          final bloc = ClosetBloc(
            databaseService: databaseService,
            imageStorageService:
                imageStorageService,
          );

          expect(
            bloc.state,
            const ClosetState(),
          );

          bloc.close();
        },
      );

      blocTest<ClosetBloc, ClosetState>(
        'loads wardrobe, favorites, and history when ClosetStarted is added',
        setUp: () {
          when(
            () => databaseService
                .getAllClothing(),
          ).thenAnswer(
            (_) async => [savedItem],
          );

          when(
            () => databaseService
                .getFavoriteOutfits(),
          ).thenAnswer(
            (_) async => [],
          );

          when(
            () => databaseService
                .getOutfitHistory(),
          ).thenAnswer(
            (_) async => [],
          );
        },
        build: () {
          return ClosetBloc(
            databaseService: databaseService,
            imageStorageService:
                imageStorageService,
          );
        },
        act: (bloc) {
          bloc.add(
            const ClosetStarted(),
          );
        },
        expect: () => [
          isA<ClosetState>()
              .having(
                (state) => state.isLoading,
                'isLoading',
                true,
              )
              .having(
                (state) => state.errorMessage,
                'errorMessage',
                null,
              ),
          isA<ClosetState>()
              .having(
                (state) => state.isLoading,
                'isLoading',
                false,
              )
              .having(
                (state) => state.wardrobe.length,
                'wardrobe length',
                1,
              )
              .having(
                (state) => state.wardrobe.first.id,
                'first clothing id',
                10,
              )
              .having(
                (state) => state.favorites.isEmpty,
                'favorites empty',
                true,
              )
              .having(
                (state) => state.history.isEmpty,
                'history empty',
                true,
              ),
        ],
        verify: (_) {
          verify(
            () => databaseService
                .getAllClothing(),
          ).called(1);

          verify(
            () => databaseService
                .getFavoriteOutfits(),
          ).called(1);

          verify(
            () => databaseService
                .getOutfitHistory(),
          ).called(1);
        },
      );

      blocTest<ClosetBloc, ClosetState>(
        'adds saved clothing to wardrobe',
        setUp: () {
          when(
            () => databaseService
                .insertClothing(
              newItem,
            ),
          ).thenAnswer(
            (_) async => savedItem,
          );
        },
        build: () {
          return ClosetBloc(
            databaseService: databaseService,
            imageStorageService:
                imageStorageService,
          );
        },
        act: (bloc) {
          bloc.add(
            ClothingAdded(
              newItem,
            ),
          );
        },
        expect: () => [
          isA<ClosetState>()
              .having(
                (state) => state.wardrobe.length,
                'wardrobe length',
                1,
              )
              .having(
                (state) => state.wardrobe.first.id,
                'saved clothing id',
                10,
              )
              .having(
                (state) =>
                    state.wardrobe.first.name,
                'saved clothing name',
                'Blue Shirt',
              ),
        ],
        verify: (_) {
          verify(
            () => databaseService
                .insertClothing(
              newItem,
            ),
          ).called(1);
        },
      );

      blocTest<ClosetBloc, ClosetState>(
        'updates existing clothing in wardrobe',
        setUp: () {
          when(
            () => databaseService.updateClothing(
              updatedItem,
            ),
          ).thenAnswer(
            (_) async => 1,
          );
        },
        seed: () {
          return ClosetState(
            wardrobe: [
              savedItem,
            ],
          );
        },
        build: () {
          return ClosetBloc(
            databaseService: databaseService,
            imageStorageService: imageStorageService,
          );
        },
        act: (bloc) {
          bloc.add(
            ClothingUpdated(
              updatedItem,
            ),
          );
        },
        expect: () => [
          isA<ClosetState>()
              .having(
                (state) => state.wardrobe.length,
                'wardrobe length',
                1,
              )
              .having(
                (state) => state.wardrobe.first.name,
                'updated clothing name',
                'Dark Blue Shirt',
              )
              .having(
                (state) => state.wardrobe.first.warmthLevel,
                'updated warmth level',
                3,
              ),
        ],
        verify: (_) {
          verify(
            () => databaseService.updateClothing(
              updatedItem,
            ),
          ).called(1);
        },
      );

      blocTest<ClosetBloc, ClosetState>(
        'deletes clothing from wardrobe and deletes its stored image',
        setUp: () {
          when(
            () => databaseService
                .deleteClothing(
              savedItem.id!,
            ),
          ).thenAnswer(
            (_) async => 1,
          );

          when(
            () => imageStorageService
                .deleteImage(
              savedItem.imagePath,
            ),
          ).thenAnswer(
            (_) async {},
          );
        },
        seed: () {
          return ClosetState(
            wardrobe: [
              savedItem,
            ],
          );
        },
        build: () {
          return ClosetBloc(
            databaseService: databaseService,
            imageStorageService:
                imageStorageService,
          );
        },
        act: (bloc) {
          bloc.add(
            ClothingDeleted(
              savedItem,
            ),
          );
        },
        expect: () => [
          isA<ClosetState>().having(
            (state) => state.wardrobe.isEmpty,
            'wardrobe empty',
            true,
          ),
        ],
        verify: (_) {
          verify(
            () => databaseService
                .deleteClothing(
              savedItem.id!,
            ),
          ).called(1);

          verify(
            () => imageStorageService
                .deleteImage(
              savedItem.imagePath,
            ),
          ).called(1);
        },
      );

      blocTest<ClosetBloc, ClosetState>(
        'does not delete image file for asset clothing',
        setUp: () {
          final assetItem = ClothingItem(
            id: 20,
            name: 'White Shirt',
            category: 'Top',
            color: 'White',
            imagePath:
                'assets/images/white_shirt.png',
            isAssetImage: true,
            style: 'Casual',
            occasion: 'Everyday',
            season: 'All',
            warmthLevel: 2,
            rainSuitable: false,
            waterResistant: false,
          );

          when(
            () => databaseService
                .deleteClothing(
              assetItem.id!,
            ),
          ).thenAnswer(
            (_) async => 1,
          );
        },
        seed: () {
          final assetItem = ClothingItem(
            id: 20,
            name: 'White Shirt',
            category: 'Top',
            color: 'White',
            imagePath:
                'assets/images/white_shirt.png',
            isAssetImage: true,
            style: 'Casual',
            occasion: 'Everyday',
            season: 'All',
            warmthLevel: 2,
            rainSuitable: false,
            waterResistant: false,
          );

          return ClosetState(
            wardrobe: [
              assetItem,
            ],
          );
        },
        build: () {
          return ClosetBloc(
            databaseService: databaseService,
            imageStorageService:
                imageStorageService,
          );
        },
        act: (bloc) {
          final assetItem =
              bloc.state.wardrobe.first;

          bloc.add(
            ClothingDeleted(
              assetItem,
            ),
          );
        },
        expect: () => [
          isA<ClosetState>().having(
            (state) => state.wardrobe.isEmpty,
            'wardrobe empty',
            true,
          ),
        ],
        verify: (_) {
          verifyNever(
            () => imageStorageService
                .deleteImage(
              any(),
            ),
          );
        },
      );

      blocTest<ClosetBloc, ClosetState>(
        'emits an error message when loading closet data fails',
        setUp: () {
          when(
            () => databaseService
                .getAllClothing(),
          ).thenThrow(
            Exception(
              'Database failure',
            ),
          );
        },
        build: () {
          return ClosetBloc(
            databaseService: databaseService,
            imageStorageService:
                imageStorageService,
          );
        },
        act: (bloc) {
          bloc.add(
            const ClosetStarted(),
          );
        },
        expect: () => [
          isA<ClosetState>().having(
            (state) => state.isLoading,
            'isLoading',
            true,
          ),
          isA<ClosetState>()
              .having(
                (state) => state.isLoading,
                'isLoading',
                false,
              )
              .having(
                (state) => state.errorMessage,
                'errorMessage',
                'Could not load closet data.',
              ),
        ],
      );

      blocTest<ClosetBloc, ClosetState>(
        'emits an error message when adding clothing fails',
        setUp: () {
          when(
            () => databaseService
                .insertClothing(
              newItem,
            ),
          ).thenThrow(
            Exception(
              'Insert failed',
            ),
          );
        },
        build: () {
          return ClosetBloc(
            databaseService: databaseService,
            imageStorageService:
                imageStorageService,
          );
        },
        act: (bloc) {
          bloc.add(
            ClothingAdded(
              newItem,
            ),
          );
        },
        expect: () => [
          isA<ClosetState>()
              .having(
                (state) => state.wardrobe.isEmpty,
                'wardrobe empty',
                true,
              )
              .having(
                (state) => state.errorMessage,
                'errorMessage',
                'Could not add clothing.',
              ),
        ],
      );
    },
  );
}