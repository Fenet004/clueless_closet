import 'package:equatable/equatable.dart';
import '../models/clothing_item.dart';
import '../models/outfit_history.dart';
import '../models/saved_outfit.dart';

abstract class ClosetEvent extends Equatable {
  const ClosetEvent();

  @override
  List<Object?> get props => [];
}

class ClosetStarted extends ClosetEvent {
  const ClosetStarted();
}

class ClothingAdded extends ClosetEvent {
  final ClothingItem item;

  const ClothingAdded(this.item);

  @override
  List<Object?> get props => [item];
}

class ClothingUpdated extends ClosetEvent {
  final ClothingItem item;

  const ClothingUpdated(this.item);

  @override
  List<Object?> get props => [item];
}

class ClothingDeleted extends ClosetEvent {
  final ClothingItem item;

  const ClothingDeleted(this.item);

  @override
  List<Object?> get props => [item];
}

class FavoriteAdded extends ClosetEvent {
  final SavedOutfit outfit;

  const FavoriteAdded(this.outfit);

  @override
  List<Object?> get props => [outfit];
}

class FavoriteDeleted extends ClosetEvent {
  final SavedOutfit outfit;

  const FavoriteDeleted(this.outfit);

  @override
  List<Object?> get props => [outfit];
}

class HistoryAdded extends ClosetEvent {
  final OutfitHistory history;

  const HistoryAdded(this.history);

  @override
  List<Object?> get props => [history];
}

class HistoryDeleted extends ClosetEvent {
  final OutfitHistory history;

  const HistoryDeleted(this.history);

  @override
  List<Object?> get props => [history];
}