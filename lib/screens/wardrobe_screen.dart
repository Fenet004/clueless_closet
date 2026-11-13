import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../bloc/closet_bloc.dart';
import '../bloc/closet_event.dart';
import '../bloc/closet_state.dart';
import '../models/clothing_item.dart';
import 'add_clothing_screen.dart';
import 'clothing_details_screen.dart';

class WardrobeScreen
    extends StatelessWidget {
  const WardrobeScreen({
    super.key,
  });

  Future<void> _addClothing(
    BuildContext context,
  ) async {
    final ClothingItem? newItem =
        await Navigator.push<
            ClothingItem>(
      context,
      MaterialPageRoute(
        builder: (context) {
          return const AddClothingScreen();
        },
      ),
    );

    if (newItem == null) {
      return;
    }

    if (!context.mounted) {
      return;
    }

    context.read<ClosetBloc>().add(
          ClothingAdded(
            newItem,
          ),
        );
  }

  Future<void>
      _openClothingDetails(
    BuildContext context,
    ClothingItem item,
  ) async {
    final result =
        await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) {
          return ClothingDetailsScreen(
            item: item,
          );
        },
      ),
    );

    if (!context.mounted) {
      return;
    }

    if (result == null) {
      return;
    }

    if (result == 'delete') {
      context.read<ClosetBloc>().add(
            ClothingDeleted(
              item,
            ),
          );

      return;
    }

    if (result is ClothingItem) {
      context.read<ClosetBloc>().add(
            ClothingUpdated(
              result,
            ),
          );
    }
  }

  Widget _buildEmptyState(
    BuildContext context,
  ) {
    return Center(
      child: Padding(
        padding:
            const EdgeInsets.all(
          32,
        ),
        child: Column(
          mainAxisAlignment:
              MainAxisAlignment.center,
          children: [
            const Icon(
              Icons
                  .checkroom_outlined,
              size: 64,
              color: Colors.black38,
            ),
            const SizedBox(
              height: 20,
            ),
            const Text(
              'Your closet is empty',
              style: TextStyle(
                fontSize: 22,
                fontWeight:
                    FontWeight.w700,
              ),
            ),
            const SizedBox(
              height: 8,
            ),
            const Text(
              'Start by adding a few pieces you love.',
              textAlign:
                  TextAlign.center,
              style: TextStyle(
                color:
                    Colors.black54,
              ),
            ),
            const SizedBox(
              height: 24,
            ),
            ElevatedButton.icon(
              onPressed: () {
                _addClothing(
                  context,
                );
              },
              icon: const Icon(
                Icons.add,
              ),
              label: const Text(
                'ADD ITEM',
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildClothingCard(
    BuildContext context,
    ClothingItem item,
  ) {
    return Card(
      clipBehavior:
          Clip.antiAlias,
      child: InkWell(
        onTap: () {
          _openClothingDetails(
            context,
            item,
          );
        },
        child: Padding(
          padding:
              const EdgeInsets.all(
            12,
          ),
          child: Column(
            children: [
              Expanded(
                child:
                    item.isAssetImage
                        ? Image.asset(
                            item
                                .imagePath,
                            fit:
                                BoxFit
                                    .contain,
                          )
                        : Image.file(
                            File(
                              item
                                  .imagePath,
                            ),
                            fit:
                                BoxFit
                                    .contain,
                          ),
              ),

              const SizedBox(
                height: 12,
              ),

              Text(
                item.name,
                textAlign:
                    TextAlign.center,
                maxLines: 1,
                overflow:
                    TextOverflow
                        .ellipsis,
                style:
                    const TextStyle(
                  fontWeight:
                      FontWeight.w700,
                ),
              ),

              const SizedBox(
                height: 4,
              ),

              Text(
                '${item.color} • ${item.category}',
                textAlign:
                    TextAlign.center,
                style:
                    const TextStyle(
                  fontSize: 12,
                  color:
                      Colors.black54,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildWardrobe(
    BuildContext context,
    List<ClothingItem>
        clothingItems,
  ) {
    return Column(
      children: [
        Padding(
          padding:
              const EdgeInsets
                  .fromLTRB(
            16,
            8,
            16,
            12,
          ),
          child: Row(
            mainAxisAlignment:
                MainAxisAlignment
                    .spaceBetween,
            children: [
              Text(
                '${clothingItems.length} items',
                style:
                    const TextStyle(
                  color:
                      Colors.black54,
                ),
              ),
            ],
          ),
        ),

        Expanded(
          child: GridView.builder(
            padding:
                const EdgeInsets
                    .fromLTRB(
              16,
              0,
              16,
              100,
            ),
            itemCount:
                clothingItems.length,
            gridDelegate:
                const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing:
                  12,
              mainAxisSpacing: 12,
              childAspectRatio:
                  0.72,
            ),
            itemBuilder:
                (context, index) {
              final item =
                  clothingItems[
                      index];

              return _buildClothingCard(
                context,
                item,
              );
            },
          ),
        ),
      ],
    );
  }

  @override
  Widget build(
    BuildContext context,
  ) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'My Closet',
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

          final clothingItems =
              state.wardrobe;

          if (clothingItems
              .isEmpty) {
            return _buildEmptyState(
              context,
            );
          }

          return _buildWardrobe(
            context,
            clothingItems,
          );
        },
      ),

      floatingActionButton:
          FloatingActionButton
              .extended(
        onPressed: () {
          _addClothing(
            context,
          );
        },
        icon: const Icon(
          Icons.add,
        ),
        label: const Text(
          'Add item',
        ),
      ),
    );
  }
}