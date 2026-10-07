import 'dart:io';
import 'package:flutter/material.dart';
import '../models/clothing_item.dart';

class ClothingPicker extends StatelessWidget {
  final ClothingItem item;
  final VoidCallback onPrevious;
  final VoidCallback onNext;

  const ClothingPicker({
    super.key,
    required this.item,
    required this.onPrevious,
    required this.onNext,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        IconButton(
          onPressed: onPrevious,
          icon: const Icon(
            Icons.chevron_left,
            size: 40,
          ),
        ),

        Container(
          width: 220,
          height: 190,
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            border: Border.all(
              width: 2,
            ),
            borderRadius: BorderRadius.circular(18),
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
                        fit: BoxFit.contain
                      )
              ),

              const SizedBox(height: 8),

              Text(
                item.name,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 4),

              Text(
                item.color,
                style: const TextStyle(
                  fontSize: 13,
                ),
              ),
            ],
          ),
        ),

        IconButton(
          onPressed: onNext,
          icon: const Icon(
            Icons.chevron_right,
            size: 40,
          ),
        ),
      ],
    );
  }
}