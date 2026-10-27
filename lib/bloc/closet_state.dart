import 'package:equatable/equatable.dart';
import '../models/clothing_item.dart';
import '../models/outfit_history.dart';
import '../models/saved_outfit.dart';

class ClosetState extends Equatable {
  final List<ClothingItem> wardrobe;
  final List<SavedOutfit> favorites;
  final List<OutfitHistory> history;
  final bool isLoading;
  final String? errorMessage;

  const ClosetState({
    this.wardrobe = const [],
    this.favorites = const [],
    this.history = const [],
    this.isLoading = false,
    this.errorMessage, 
  });

  ClosetState copyWith({
    List<ClothingItem>? wardrobe,
    List<SavedOutfit>? favorites,
    List<OutfitHistory>? history,
    bool? isLoading,
    String? errorMessage,
    bool clearError = false,
  }) {
    return ClosetState(
      wardrobe: wardrobe ?? this.wardrobe,
      favorites: favorites ?? this.favorites,
      history: history ?? this.history,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: clearError ? null : errorMessage ?? this.errorMessage,
    );
  }

  @override
  List<Object?> get props => [
    wardrobe,
    favorites,
    history,
    isLoading,
    errorMessage
  ];
}