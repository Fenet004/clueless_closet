import 'package:flutter_bloc/flutter_bloc.dart';
import '../services/database_service.dart';
import '../services/image_storage_service.dart';
import 'closet_event.dart';
import 'closet_state.dart';

class ClosetBloc extends Bloc<ClosetEvent, ClosetState> {
  final DatabaseService databaseService;
  final ImageStorageService imageStorageService;

  ClosetBloc({
    required this.databaseService,
    required this.imageStorageService,
  }) : super(const ClosetState()) {
    on<ClosetStarted>(_onClosetStarted);
    on<ClothingAdded>(_onClothingAdded);
    on<ClothingUpdated>(_onClothingUpdated);
    on<ClothingDeleted>(_onClothingDeleted);
    on<FavoriteAdded>(_onFavoriteAdded);
    on<FavoriteDeleted>(_onFavoriteDeleted);
    on<HistoryAdded>(_onHistoryAdded);
    on<HistoryDeleted>(_onHistoryDeleted);
  }

  Future<void> _onClosetStarted(
    ClosetStarted event,
    Emitter<ClosetState> emit,
  ) async {
    emit(
      state.copyWith(
        isLoading: true,
        clearError: true,
      ),
    );

    try {
      final wardrobe = await databaseService.getAllClothing();
      final favorites = await databaseService.getFavoriteOutfits();
      final history = await databaseService.getOutfitHistory();

      emit(
        state.copyWith(
          wardrobe: wardrobe,
          favorites: favorites,
          history: history,
          isLoading: false,
          clearError: true,
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(
          isLoading: false,
          errorMessage: 'Could not load closet data.',
        ),
      );
    }
  }

  Future<void> _onClothingAdded(
    ClothingAdded event,
    Emitter<ClosetState> emit,
  ) async {
    try {
      final savedItem = await databaseService.insertClothing(event.item);
      
      emit(
        state.copyWith(
          wardrobe: [
            ...state.wardrobe,
            savedItem,
          ],
          clearError: true,
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(
          errorMessage: 'Could not add clothing.',
        ),
      );
    }
  }

  Future<void> _onClothingUpdated(
    ClothingUpdated event,
    Emitter<ClosetState> emit,
  ) async {
    try {
      await databaseService.updateClothing(event.item);
      
      final updatedWardrobe = 
          state.wardrobe.map((item) {
        if (item.id == event.item.id) {
          return event.item;
        }

        return item;
      }).toList();

      emit(
        state.copyWith(
          wardrobe: updatedWardrobe,
          clearError: true,
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(
          errorMessage: 'Could not update clothing.',
        ),
      );
    }
  }

  Future<void> _onClothingDeleted(
    ClothingDeleted event,
    Emitter<ClosetState> emit,
  ) async {
    try {
      final item = event.item;

      if (item.id != null) {
        await databaseService.deleteClothing(item.id!);
      }

      if (!item.isAssetImage) {
        await imageStorageService.deleteImage(item.imagePath);
      }

      final updatedWardrobe =
          state.wardrobe.where((current) {
        return current.id != item.id;
      }).toList();

      emit(
        state.copyWith(
          wardrobe: updatedWardrobe,
          clearError: true,
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(
          errorMessage: 'Could not delete clothing,',
        ),
      );
    }
  }

  Future<void> _onFavoriteAdded(
    FavoriteAdded event,
    Emitter<ClosetState> emit,
  ) async {
    try {
      final alreadySaved = await databaseService.isFavoriteOutfit(
        event.outfit.topId,
        event.outfit.bottomId,
        event.outfit.shoeId,
      );

      if (alreadySaved) {
        emit(
          state.copyWith(
            errorMessage: 'This outfit is already in favorites.',
          ),
        );

        return;
      }

      final saved = await databaseService.insertFavoriteOutfit(event.outfit);

      emit(
        state.copyWith(
          favorites: [
            saved,
            ...state.favorites,
          ],
          clearError: true,
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(
          errorMessage: 'Could not save favorite.',
        ),
      );
    }
  }

  Future<void> _onFavoriteDeleted(
    FavoriteDeleted event,
    Emitter<ClosetState> emit,
  ) async {
    try {
      if (event.outfit.id != null) {
        await databaseService.deleteFavoriteOutfit(event.outfit.id!);
      }

      emit(
        state.copyWith(
          favorites: state.favorites.where(
            (favorite) {
              return favorite.id != event.outfit.id;
            },
          ).toList(),
          clearError: true,
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(
          errorMessage: 'Could not delete favorite.',
        ),
      );
    }
  }

  Future<void> _onHistoryAdded(
    HistoryAdded event,
    Emitter<ClosetState> emit,
  ) async {
    try {
      final saved = await databaseService.insertOutfitHistory(event.history);

      emit(
        state.copyWith(
          history: [
            saved,
            ...state.history,
          ],
          clearError: true,
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(
          errorMessage: 'Could not save outfit history.',
        ),
      );
    }
  }

  Future<void> _onHistoryDeleted(
    HistoryDeleted event,
    Emitter<ClosetState> emit,
  ) async {
    try {
      if (event.history.id != null) {
        await databaseService.deleteOutfitHistory(event.history.id!);
      }

      emit(
        state.copyWith(
          history: state.history.where(
            (history) {
              return history.id != event.history.id;
            },
          ).toList(),
          clearError: true,
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(
          errorMessage: 'Could not delete history item.',
        ),
      );
    }
  }
}