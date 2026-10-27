import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../bloc/closet_bloc.dart';
import '../bloc/closet_event.dart';
import '../bloc/closet_state.dart';
import '../models/clothing_item.dart';
import 'add_clothing_screen.dart';
import 'clothing_details_screen.dart';

class WardrobeScreen extends StatelessWidget {
  const WardrobeScreen({
    super.key,
  });

  Future<void> _addClothing(
    BuildContext context,
  ) async {
    final ClothingItem? newItem =
        await Navigator.push<ClothingItem>(
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
          ClothingAdded(newItem),
        );
  }

  Future<void> _openClothingDetails(
    BuildContext context,
    ClothingItem item,
  ) async {
    final result = await Navigator.push(
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
            ClothingDeleted(item),
          );

      return;
    }

    if (result is ClothingItem) {
      context.read<ClosetBloc>().add(
            ClothingUpdated(result),
          );
    }
  }

  Widget _buildEmptyState(
    BuildContext context,
  ) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment:
              MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.checkroom,
              size: 72,
            ),
            const SizedBox(height: 20),
            const Text(
              'Your closet is empty',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Add your clothes to start building outfits.',
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () {
                _addClothing(context);
              },
              icon: const Icon(
                Icons.add,
              ),
              label: const Text(
                'ADD CLOTHING',
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWardrobeGrid(
    BuildContext context,
    List<ClothingItem> clothingItems,
  ) {
    return GridView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: clothingItems.length,
      gridDelegate:
          const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 0.72,
      ),
      itemBuilder: (context, index) {
        final item =
            clothingItems[index];

        return _buildClothingCard(
          context,
          item,
        );
      },
    );
  }

  Widget _buildClothingCard(
    BuildContext context,
    ClothingItem item,
  ) {
    return GestureDetector(
      onTap: () {
        _openClothingDetails(
          context,
          item,
        );
      },
      child: Container(
        padding:
            const EdgeInsets.all(12),
        decoration: BoxDecoration(
          border: Border.all(),
          borderRadius:
              BorderRadius.circular(
            16,
          ),
        ),
        child: Column(
          children: [
            Expanded(
              child: item.isAssetImage
                  ? Image.asset(
                      item.imagePath,
                      fit: BoxFit.contain,
                    )
                  : Image.file(
                      File(
                        item.imagePath,
                      ),
                      fit: BoxFit.contain,
                    ),
            ),
            const SizedBox(height: 8),
            Text(
              item.name,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontWeight:
                    FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              item.category,
              style: const TextStyle(
                fontSize: 12,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              item.color,
              style: const TextStyle(
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'My Closet',
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

          final clothingItems =
              state.wardrobe;

          if (clothingItems.isEmpty) {
            return _buildEmptyState(
              context,
            );
          }

          return _buildWardrobeGrid(
            context,
            clothingItems,
          );
        },
      ),
      floatingActionButton:
          FloatingActionButton.extended(
        onPressed: () {
          _addClothing(context);
        },
        icon: const Icon(
          Icons.add,
        ),
        label: const Text(
          'Add Clothing',
        ),
      ),
    );
  }
}