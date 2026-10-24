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

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment:
          MainAxisAlignment.center,
      children: [
        IconButton(
          onPressed:
              enabled ? onPrevious : null,
          icon: const Icon(
            Icons.chevron_left,
            size: 40,
          ),
        ),
        Expanded(
          child: Container(
            height: 210,
            padding:
                const EdgeInsets.all(12),
            decoration: BoxDecoration(
              border: Border.all(),
              borderRadius:
                  BorderRadius.circular(
                18,
              ),
            ),
            child: Column(
              children: [
                Expanded(
                  child: AnimatedSwitcher(
                    duration:
                        const Duration(
                      milliseconds: 180,
                    ),
                    child:
                        item.isAssetImage
                            ? Image.asset(
                                item.imagePath,
                                key: ValueKey(
                                  item.imagePath,
                                ),
                                fit:
                                    BoxFit.contain,
                              )
                            : Image.file(
                                File(
                                  item.imagePath,
                                ),
                                key: ValueKey(
                                  item.imagePath,
                                ),
                                fit:
                                    BoxFit.contain,
                              ),
                  ),
                ),
                const SizedBox(height: 8),
                AnimatedSwitcher(
                  duration:
                      const Duration(
                    milliseconds: 180,
                  ),
                  child: Text(
                    item.name,
                    key: ValueKey(
                      item.name,
                    ),
                    textAlign:
                        TextAlign.center,
                    style:
                        const TextStyle(
                      fontSize: 16,
                      fontWeight:
                          FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  item.color,
                  style:
                      const TextStyle(
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
        ),
        IconButton(
          onPressed:
              enabled ? onNext : null,
          icon: const Icon(
            Icons.chevron_right,
            size: 40,
          ),
        ),
      ],
    );
  }
}