import 'dart:io';
import 'package:flutter/material.dart';
import '../models/clothing_item.dart';
import '../models/saved_outfit.dart';
import '../services/database_service.dart';

class FavoritesScreen extends StatefulWidget {
  final List<ClothingItem> wardrobe;

  const FavoritesScreen({
    super.key,
    required this.wardrobe,
  });

  @override
  State<FavoritesScreen> createState() => _FavoritesScreenState();
}

class _FavoritesScreenState extends State<FavoritesScreen> {
  final DatabaseService _databaseService = DatabaseService.instance;

  List<SavedOutfit> favorites = [];
  
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    loadFavorites();
  }

  Future<void> loadFavorites() async {
    final saved = await _databaseService.getFavoriteOutfits();

    if (!mounted) {
      return;
    }

    setState(() {
      favorites = saved;
      isLoading = false;
    });
  }

  ClothingItem? findClothingById(int id) {
    for (final item in widget.wardrobe) {
      if (item.id == id) {
        return item;
      }
    }

    return null;
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Favorite Outfits',
        ),
      ),
      body: favorites.isEmpty
          ? const Center(
              child: Text(
                'No favorite outfits yet.',
              ),
            )
          : ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: favorites.length,
            itemBuilder: (context, index) {
              final favorite = favorites[index];
              final top = findClothingById(favorite.topId);
              final bottom = findClothingById(favorite.bottomId);
              final shoes = findClothingById(favorite.shoeId);

              if (top == null || bottom == null || shoes == null) {
                return const SizedBox.shrink();
              }

              return _FavoriteOutfitCard(
                favorite: favorite,
                top: top,
                bottom: bottom,
                shoes: shoes,
                onDelete: () {
                  deleteFavorite(favorite);
                },
              );
            },
          ),
    );
  }

  Future<void> deleteFavorite(SavedOutfit favorite) async {
    if (favorite.id == null) {
      return;
    }

    await _databaseService.deleteFavoriteOutfit(favorite.id!);

    if (!mounted) {
      return;
    }

    setState(() {
      favorites.remove(favorite);
    });
  }
}

class _FavoriteOutfitCard extends StatelessWidget {
  final SavedOutfit favorite;
  final ClothingItem top;
  final ClothingItem bottom;
  final ClothingItem shoes;
  final VoidCallback onDelete;

  const _FavoriteOutfitCard({
    required this.favorite,
    required this.top,
    required this.bottom,
    required this.shoes,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: _buildImage(top),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _buildImage(bottom),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _buildImage(shoes),
                ),
              ],
            ),

            const SizedBox(height: 12),

            Text(
              '${favorite.score}% MATCH',
              style: const TextStyle(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),

            Text(
              '${top.name} + '
              '${bottom.name} + '
              '${shoes.name}',
              textAlign: TextAlign.center,
            ),

            const SizedBox(height: 8),

            IconButton(
              onPressed: onDelete,
              icon: const Icon(Icons.delete_outline),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildImage(ClothingItem item) {
    if (item.isAssetImage) {
      return Image.asset(
        item.imagePath,
        height: 100,
        fit: BoxFit.contain,
      );
    }

    return Image.file(
      File(item.imagePath),
      height: 100,
      fit: BoxFit.contain,
    );
  }
}