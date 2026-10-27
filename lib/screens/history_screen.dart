import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../bloc/closet_bloc.dart';
import '../bloc/closet_event.dart';
import '../bloc/closet_state.dart';
import '../models/clothing_item.dart';
import '../models/outfit_history.dart';

class HistoryScreen extends StatelessWidget {
  const HistoryScreen({
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
          'Outfit History',
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

          final history =
              state.history;

          if (history.isEmpty) {
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
                      Icons.history,
                      size: 72,
                    ),
                    SizedBox(height: 20),
                    Text(
                      'No outfits worn yet',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight:
                            FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      'Outfits you mark as worn will appear here.',
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
            itemCount: history.length,
            itemBuilder:
                (context, index) {
              final historyItem =
                  history[index];

              final top =
                  _findClothingById(
                wardrobe,
                historyItem.topId,
              );

              final bottom =
                  _findClothingById(
                wardrobe,
                historyItem.bottomId,
              );

              final shoes =
                  _findClothingById(
                wardrobe,
                historyItem.shoeId,
              );

              if (top == null ||
                  bottom == null ||
                  shoes == null) {
                return const SizedBox
                    .shrink();
              }

              return _HistoryCard(
                historyItem:
                    historyItem,
                top: top,
                bottom: bottom,
                shoes: shoes,
                onDelete: () {
                  context
                      .read<ClosetBloc>()
                      .add(
                        HistoryDeleted(
                          historyItem,
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

class _HistoryCard
    extends StatelessWidget {
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

  Widget _buildImage(
    ClothingItem item,
  ) {
    if (item.isAssetImage) {
      return Image.asset(
        item.imagePath,
        height: 90,
        fit: BoxFit.contain,
      );
    }

    return Image.file(
      File(item.imagePath),
      height: 90,
      fit: BoxFit.contain,
    );
  }

  String _formatDate(
    DateTime date,
  ) {
    final now = DateTime.now();

    final today = DateTime(
      now.year,
      now.month,
      now.day,
    );

    final historyDate = DateTime(
      date.year,
      date.month,
      date.day,
    );

    final difference =
        today
            .difference(historyDate)
            .inDays;

    if (difference == 0) {
      return 'Today';
    }

    if (difference == 1) {
      return 'Yesterday';
    }

    return '${date.day}/${date.month}/${date.year}';
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
            Align(
              alignment:
                  Alignment.centerLeft,
              child: Text(
                _formatDate(
                  historyItem.wornAt,
                ),
                style:
                    const TextStyle(
                  fontSize: 16,
                  fontWeight:
                      FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(height: 12),
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
              '${top.name} + '
              '${bottom.name} + '
              '${shoes.name}',
              textAlign:
                  TextAlign.center,
            ),
            const SizedBox(height: 6),
            Text(
              '${historyItem.score}% match',
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