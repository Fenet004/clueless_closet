import 'dart:io';
import 'package:flutter/material.dart';
import '../models/clothing_item.dart';
import '../models/outfit_history.dart';
import '../services/database_service.dart';

class HistoryScreen extends StatefulWidget {
  final List<ClothingItem> wardrobe;

  const HistoryScreen({
    super.key,
    required this.wardrobe,
  });

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  final DatabaseService _databaseService = DatabaseService.instance;

  List<OutfitHistory> history = [];

  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    loadHistory();
  }

  Future<void> loadHistory() async {
    final items = await _databaseService.getOutfitHistory();

    if (!mounted) {
      return;
    }

    setState(() {
      history = items;
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

  Future<void> deleteHistoryItem(OutfitHistory item) async {
    if (item.id == null) {
      return;
    }

    await _databaseService.deleteOutfitHistory(item.id!);

    if (!mounted) {
      return;
    }

    setState(() {
      history.remove(item);
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
          'Outfit History',
        ),
      ),
      body: history.isEmpty
          ? const Center(
              child: Text(
                'No outfits worn yet.',
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: history.length,
              itemBuilder: (context, index) {
                final historyItem = history[index];
                final top = findClothingById(historyItem.topId);
                final bottom = findClothingById(historyItem.bottomId);
                final shoes = findClothingById(historyItem.shoeId);

                if (top == null || bottom == null || shoes == null) {
                  return const SizedBox.shrink();
                } 

                return _HistoryCard(
                  historyItem: historyItem,
                  top: top,
                  bottom: bottom,
                  shoes: shoes,
                  onDelete: () {
                    deleteHistoryItem(historyItem);
                  },
                );
              },
            ),
    );
  }
}

class _HistoryCard extends StatelessWidget {
  final OutfitHistory historyItem;
  final ClothingItem top;
  final ClothingItem bottom;
  final ClothingItem shoes;
  final VoidCallback onDelete;

  const _HistoryCard({
    required this.historyItem,
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
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                _formatDate(historyItem.wornAt),
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),

            const SizedBox(height: 12),

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
              '${top.name} + '
              '${bottom.name} + '
              '${shoes.name}',
              textAlign: TextAlign.center,
            ),

            const SizedBox(height: 6),

            Text(
              '${historyItem.score}% match',
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
        height: 90,
        fit: BoxFit.contain
      );
    }

    return Image.file(
      File(item.imagePath),
      height: 90,
      fit: BoxFit.contain,
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();

    final today = DateTime(
      now.year,
      now.month,
      now.day,
    );

    final historyDate = DateTime(
      date.year,
      date.month,
      date.day
    );

    final difference = today.difference(historyDate).inDays;

    if (difference == 0) {
      return 'Today';
    }

    if (difference == 1) {
      return 'Yesterday';
    }

    return '${date.day}/${date.month}/${date.year}';
  }
}