import 'dart:io';
import 'package:flutter/material.dart';
import '../models/clothing_item.dart';
import 'clothing_details_screen.dart';

class WardrobeScreen extends StatefulWidget {
  final List<ClothingItem> clothingItems;

  const WardrobeScreen({
    super.key,
    required this.clothingItems,
  });

  @override
  State<WardrobeScreen> createState() => _WardrobeScreenState();
}

class _WardrobeScreenState extends State<WardrobeScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Wardrobe'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: GridView.builder(
          itemCount: widget.clothingItems.length,
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            childAspectRatio: 0.75,
          ),
          itemBuilder: (context, index) {
            final item = widget.clothingItems[index];

            return GestureDetector(
              onTap: () async {
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

                setState(() {
                  if (result == 'delete') {
                    widget.clothingItems.remove(item);
                  } else if (result is ClothingItem) {
                    widget.clothingItems[index] = result;
                  }
                });
              },
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  border: Border.all(),
                  borderRadius: BorderRadius.circular(16),
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
            
          },
        ),
      ),
    );
  }
}
