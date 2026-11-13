import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../bloc/closet_bloc.dart';
import '../bloc/closet_event.dart';
import '../bloc/closet_state.dart';
import '../models/clothing_item.dart';
import '../models/saved_outfit.dart';

class FavoritesScreen
    extends StatelessWidget {
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
  Widget build(
    BuildContext context,
  ) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Favorites',
        ),
      ),
      body: BlocBuilder<
          ClosetBloc,
          ClosetState>(
        builder:
            (context, state) {
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
                    EdgeInsets.all(
                  32,
                ),
                child: Column(
                  mainAxisAlignment:
                      MainAxisAlignment
                          .center,
                  children: [
                    Icon(
                      Icons
                          .favorite_border,
                      size: 64,
                      color:
                          Colors.black38,
                    ),
                    SizedBox(
                      height: 20,
                    ),
                    Text(
                      'No favorites yet',
                      style:
                          TextStyle(
                        fontSize: 22,
                        fontWeight:
                            FontWeight
                                .w700,
                      ),
                    ),
                    SizedBox(
                      height: 8,
                    ),
                    Text(
                      'Save outfits you love from the picker.',
                      textAlign:
                          TextAlign
                              .center,
                      style:
                          TextStyle(
                        color: Colors
                            .black54,
                      ),
                    ),
                  ],
                ),
              ),
            );
          }

          return Column(
            crossAxisAlignment:
                CrossAxisAlignment
                    .stretch,
            children: [
              const Padding(
                padding:
                    EdgeInsets
                        .fromLTRB(
                  16,
                  8,
                  16,
                  16,
                ),
                child: Text(
                  'Looks you loved',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight:
                        FontWeight
                            .w800,
                  ),
                ),
              ),

              Expanded(
                child:
                    ListView.builder(
                  padding:
                      const EdgeInsets
                          .fromLTRB(
                    16,
                    0,
                    16,
                    24,
                  ),
                  itemCount:
                      favorites.length,
                  itemBuilder:
                      (context, index) {
                    final favorite =
                        favorites[
                            index];

                    final top =
                        _findClothingById(
                      wardrobe,
                      favorite.topId,
                    );

                    final bottom =
                        _findClothingById(
                      wardrobe,
                      favorite
                          .bottomId,
                    );

                    final shoes =
                        _findClothingById(
                      wardrobe,
                      favorite
                          .shoeId,
                    );

                    if (top == null ||
                        bottom ==
                            null ||
                        shoes ==
                            null) {
                      return const SizedBox
                          .shrink();
                    }

                    return Padding(
                      padding:
                          const EdgeInsets
                              .only(
                        bottom: 16,
                      ),
                      child:
                          _FavoriteOutfitCard(
                        favorite:
                            favorite,
                        top: top,
                        bottom:
                            bottom,
                        shoes: shoes,
                        onDelete: () {
                          context
                              .read<
                                  ClosetBloc>()
                              .add(
                                FavoriteDeleted(
                                  favorite,
                                ),
                              );
                        },
                      ),
                    );
                  },
                ),
              ),
            ],
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
      File(
        item.imagePath,
      ),
      height: 100,
      fit: BoxFit.contain,
    );
  }

  @override
  Widget build(
    BuildContext context,
  ) {
    return Card(
      child: Padding(
        padding:
            const EdgeInsets.all(
          16,
        ),
        child: Column(
          children: [
            Row(
              children: [
                Expanded(
                  child:
                      _buildImage(
                    top,
                  ),
                ),
                const SizedBox(
                  width: 8,
                ),
                Expanded(
                  child:
                      _buildImage(
                    bottom,
                  ),
                ),
                const SizedBox(
                  width: 8,
                ),
                Expanded(
                  child:
                      _buildImage(
                    shoes,
                  ),
                ),
              ],
            ),

            const SizedBox(
              height: 14,
            ),

            Text(
              '${favorite.score}% match',
              style:
                  const TextStyle(
                fontSize: 18,
                fontWeight:
                    FontWeight.w700,
              ),
            ),

            const SizedBox(
              height: 6,
            ),

            Text(
              '${top.name} • '
              '${bottom.name} • '
              '${shoes.name}',
              textAlign:
                  TextAlign.center,
              style:
                  const TextStyle(
                color:
                    Colors.black54,
              ),
            ),

            const SizedBox(
              height: 8,
            ),

            Align(
              alignment:
                  Alignment.centerRight,
              child: IconButton(
                onPressed:
                    onDelete,
                icon: const Icon(
                  Icons
                      .delete_outline,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}