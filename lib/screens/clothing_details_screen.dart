import 'dart:io';
import 'package:flutter/material.dart';
import '../models/clothing_item.dart';
import 'edit_clothing_screen.dart';

class ClothingDetailsScreen extends StatelessWidget {
  final ClothingItem item;

  const ClothingDetailsScreen({
    super.key,
    required this.item,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(item.name),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
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

            const SizedBox(height: 24),

            Text(
              item.name,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 8),

            Text(
              '${item.category} • ${item.color}',
              textAlign: TextAlign.center,
            ),

            const SizedBox(height: 32),

            ElevatedButton.icon(
              onPressed: () async {
                final ClothingItem? updatedItem = 
                    await Navigator.push<ClothingItem>(
                      context,
                      MaterialPageRoute(
                        builder: (context) {
                          return EditClothingScreen(
                            item: item,
                          );
                        },
                      ),
                    );
                
                if (updatedItem == null) {
                  return;
                }

                if (!context.mounted) {
                  return;
                }

                Navigator.pop(context, updatedItem);
              },
              icon: const Icon(Icons.edit),
              label: const Text('EDIT'),
            ),

            const SizedBox(height: 12),

            OutlinedButton.icon(
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (context) {
                    return AlertDialog(
                      title: const Text('Delete clothing?'),
                      content: Text(
                        'Are you sure you want to delete ${item.name}?',
                      ),
                      actions: [
                        TextButton(
                          onPressed: () {
                            Navigator.pop(context);
                          },
                          child: const Text('CANCEL'),
                        ),
                        TextButton(
                          onPressed: () {
                            Navigator.pop(context);

                            Navigator.pop(context, 'delete');
                          },
                          child: const Text('DELETE'),
                        ),
                      ],
                    );
                  },
                );
              },
              icon: const Icon(Icons.delete),
              label: const Text('DELETE'),
            ),
          ],
        ),
      ),
    );
  }
}