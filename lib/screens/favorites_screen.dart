import 'dart:io';

import 'package:flutter/material.dart';

import '../models/clothing_item.dart';
import '../models/saved_outfit.dart';
import '../services/database_service.dart';

class FavoritesScreen extends StatefulWidget {
  const FavoritesScreen({
    super.key,
  });

  @override
  State<FavoritesScreen> createState() {
    return _FavoritesScreenState();
  }
}

class _FavoritesScreenState
    extends State<FavoritesScreen> {
  final DatabaseService _databaseService =
      DatabaseService.instance;

  List<ClothingItem> wardrobe = [];
  List<SavedOutfit> favorites = [];

  bool isLoading = true;

  @override
  void initState() {
    super.initState();

    loadData();
  }

  Future<void> loadData() async {
    final clothing =
        await _databaseService.getAllClothing();

    final saved =
        await _databaseService.getFavoriteOutfits();

    if (!mounted) {
      return;
    }

    setState(() {
      wardrobe = clothing;
      favorites = saved;
      isLoading = false;
    });
  }

  ClothingItem? findClothingById(int id) {
    for (final item in wardrobe) {
      if (item.id == id) {
        return item;
      }
    }

    return null;
  }

  Future<void> deleteFavorite(
    SavedOutfit favorite,
  ) async {
    if (favorite.id == null) {
      return;
    }

    await _databaseService.deleteFavoriteOutfit(
      favorite.id!,
    );

    if (!mounted) {
      return;
    }

    setState(() {
      favorites.remove(favorite);
    });
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
        actions: [
          IconButton(
            onPressed: loadData,
            icon: const Icon(
              Icons.refresh,
            ),
          ),
        ],
      ),
      body: favorites.isEmpty
          ? const Center(
              child: Padding(
                padding: EdgeInsets.all(32),
                child: Column(
                  mainAxisAlignment:
                      MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.favorite_border,
                      size: 72,
                    ),
                    SizedBox(height: 20),
                    Text(
                      'No favorite outfits yet',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight:
                            FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      'Save outfits you love from the outfit picker.',
                      textAlign:
                          TextAlign.center,
                    ),
                  ],
                ),
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: favorites.length,
              itemBuilder: (context, index) {
                final favorite =
                    favorites[index];

                final top = findClothingById(
                  favorite.topId,
                );

                final bottom =
                    findClothingById(
                  favorite.bottomId,
                );

                final shoes =
                    findClothingById(
                  favorite.shoeId,
                );

                if (top == null ||
                    bottom == null ||
                    shoes == null) {
                  return const SizedBox.shrink();
                }

                return _FavoriteOutfitCard(
                  favorite: favorite,
                  top: top,
                  bottom: bottom,
                  shoes: shoes,
                  onDelete: () {
                    deleteFavorite(
                      favorite,
                    );
                  },
                );
              },
            ),
    );
  }
}

class _FavoriteOutfitCard
    extends StatelessWidget {
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

  Widget _buildImage(
    ClothingItem item,
  ) {
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

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(
        bottom: 16,
      ),
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
              icon: const Icon(
                Icons.delete_outline,
              ),
            ),
          ],
        ),
      ),
    );
  }
}