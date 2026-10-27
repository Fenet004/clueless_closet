import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../bloc/closet_bloc.dart';
import '../bloc/closet_event.dart';
import '../bloc/closet_state.dart';
import '../models/clothing_item.dart';
import '../models/saved_outfit.dart';

class FavoritesScreen extends StatelessWidget {
  const FavoritesScreen({
    super.key,
  });

  ClothingItem? _findClothingById(
    List<ClothingItem> wardrobe,
    int id,
  ) {
    for (final item in wardrobe) {
      if (item.id == id) {
        return item;
      }
    }

    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Favorite Outfits',
        ),
      ),
      body:
          BlocBuilder<ClosetBloc, ClosetState>(
        builder: (context, state) {
          if (state.isLoading) {
            return const Center(
              child:
                  CircularProgressIndicator(),
            );
          }

          final wardrobe =
              state.wardrobe;

          final favorites =
              state.favorites;

          if (favorites.isEmpty) {
            return const Center(
              child: Padding(
                padding:
                    EdgeInsets.all(32),
                child: Column(
                  mainAxisAlignment:
                      MainAxisAlignment
                          .center,
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
            );
          }

          return ListView.builder(
            padding:
                const EdgeInsets.all(16),
            itemCount:
                favorites.length,
            itemBuilder:
                (context, index) {
              final favorite =
                  favorites[index];

              final top =
                  _findClothingById(
                wardrobe,
                favorite.topId,
              );

              final bottom =
                  _findClothingById(
                wardrobe,
                favorite.bottomId,
              );

              final shoes =
                  _findClothingById(
                wardrobe,
                favorite.shoeId,
              );

              if (top == null ||
                  bottom == null ||
                  shoes == null) {
                return const SizedBox
                    .shrink();
              }

              return _FavoriteOutfitCard(
                favorite: favorite,
                top: top,
                bottom: bottom,
                shoes: shoes,
                onDelete: () {
                  context
                      .read<ClosetBloc>()
                      .add(
                        FavoriteDeleted(
                          favorite,
                        ),
                      );
                },
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
      margin:
          const EdgeInsets.only(
        bottom: 16,
      ),
      child: Padding(
        padding:
            const EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              children: [
                Expanded(
                  child:
                      _buildImage(top),
                ),
                const SizedBox(
                  width: 8,
                ),
                Expanded(
                  child:
                      _buildImage(bottom),
                ),
                const SizedBox(
                  width: 8,
                ),
                Expanded(
                  child:
                      _buildImage(shoes),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              '${favorite.score}% MATCH',
              style: const TextStyle(
                fontWeight:
                    FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              '${top.name} + '
              '${bottom.name} + '
              '${shoes.name}',
              textAlign:
                  TextAlign.center,
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