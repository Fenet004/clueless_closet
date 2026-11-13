import 'dart:io';

import 'package:flutter/material.dart';

import '../models/clothing_item.dart';

class ClothingPicker extends StatelessWidget {
  final ClothingItem item;
  final VoidCallback onPrevious;
  final VoidCallback onNext;
  final bool enabled;

  const ClothingPicker({
    super.key,
    required this.item,
    required this.onPrevious,
    required this.onNext,
    this.enabled = true,
  });

  Widget _buildArrowButton({
    required IconData icon,
    required VoidCallback? onPressed,
  }) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        shape: BoxShape.circle,
      ),
      child: IconButton(
        onPressed: onPressed,
        icon: Icon(icon),
      ),
    );
  }

  Widget _buildImage() {
    if (item.isAssetImage) {
      return Image.asset(
        item.imagePath,
        key: ValueKey(item.imagePath),
        fit: BoxFit.contain,
      );
    }

    return Image.file(
      File(item.imagePath),
      key: ValueKey(item.imagePath),
      fit: BoxFit.contain,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        _buildArrowButton(
          icon: Icons.chevron_left,
          onPressed: enabled
              ? onPrevious
              : null,
        ),
        
        const SizedBox(width: 10),

        Expanded(
          child: Container(
            height: 230,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border.all(
                color: Colors.black12,
              ),
              borderRadius: BorderRadius.circular(24),
            ),
            child: Column(
              children: [
                Expanded(
                  child: AnimatedSwitcher(
                    duration: const Duration(
                      milliseconds: 180,
                    ),
                    child: _buildImage(),
                  ),
                ),

                const SizedBox(height: 12),

                AnimatedSwitcher(
                  duration: const Duration(
                    milliseconds: 180,
                  ),
                  child: Text(
                    item.name,
                    key: ValueKey(item.name),
                    textAlign: TextAlign.center,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),

                const SizedBox(height: 4),

                Text(
                  '${item.color} • ${item.style}',
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 13,
                    color: Colors.black54,
                  ),
                ),
              ],
            ),
          ),
        ),

        const SizedBox(width: 10),

        _buildArrowButton(
          icon: Icons.chevron_right,
          onPressed: enabled
              ? onNext
              : null,
        ),
      ],
    );
  }
}