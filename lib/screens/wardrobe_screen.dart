import 'dart:io';

import 'package:flutter/material.dart';

import '../models/clothing_item.dart';
import '../services/database_service.dart';
import 'add_clothing_screen.dart';
import 'clothing_details_screen.dart';

class WardrobeScreen extends StatefulWidget {
  const WardrobeScreen({
    super.key,
  });

  @override
  State<WardrobeScreen> createState() {
    return _WardrobeScreenState();
  }
}

class _WardrobeScreenState extends State<WardrobeScreen> {
  final DatabaseService _databaseService =
      DatabaseService.instance;

  List<ClothingItem> clothingItems = [];

  bool isLoading = true;

  @override
  void initState() {
    super.initState();

    loadWardrobe();
  }

  Future<void> loadWardrobe() async {
    final items =
        await _databaseService.getAllClothing();

    if (!mounted) {
      return;
    }

    setState(() {
      clothingItems = items;
      isLoading = false;
    });
  }

  Future<void> addClothing() async {
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

    final savedItem =
        await _databaseService.insertClothing(
      newItem,
    );

    if (!mounted) {
      return;
    }

    setState(() {
      clothingItems.add(savedItem);
    });
  }

  Future<void> openClothingDetails(
    ClothingItem item,
    int index,
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

    if (result == null) {
      return;
    }

    if (result == 'delete') {
      if (item.id != null) {
        await _databaseService.deleteClothing(
          item.id!,
        );
      }

      if (!mounted) {
        return;
      }

      setState(() {
        clothingItems.removeAt(index);
      });
    } else if (result is ClothingItem) {
      await _databaseService.updateClothing(
        result,
      );

      if (!mounted) {
        return;
      }

      setState(() {
        clothingItems[index] = result;
      });
    }
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
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
              onPressed: addClothing,
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

  Widget _buildWardrobeGrid() {
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
        final item = clothingItems[index];

        return _buildClothingCard(
          item,
          index,
        );
      },
    );
  }

  Widget _buildClothingCard(
    ClothingItem item,
    int index,
  ) {
    return GestureDetector(
      onTap: () {
        openClothingDetails(
          item,
          index,
        );
      },
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          border: Border.all(),
          borderRadius: BorderRadius.circular(
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
                      File(item.imagePath),
                      fit: BoxFit.contain,
                    ),
            ),
            const SizedBox(height: 8),
            Text(
              item.name,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
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
          'My Closet',
        ),
      ),
      body: clothingItems.isEmpty
          ? _buildEmptyState()
          : _buildWardrobeGrid(),
      floatingActionButton:
          FloatingActionButton.extended(
        onPressed: addClothing,
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