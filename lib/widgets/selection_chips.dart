import 'package:flutter/material.dart';

class SelectionChips extends StatelessWidget {
  final String title;
  final List<String> options;
  final String selectedValue;
  final ValueChanged<String> onSelected;

  const SelectionChips({
    super.key,
    required this.title,
    required this.options,
    required this.selectedValue,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: options.map(
            (option) {
              return ChoiceChip(
                label: Text(option),
                selected: selectedValue == option,
                onSelected: (selected) {
                  if (selected) {
                    onSelected(option);
                  }
                },
              );
            },
          ).toList(),
        ),
      ],
    );
  }
}