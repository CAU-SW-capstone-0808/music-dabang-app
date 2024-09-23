import 'package:music_dabang/components/custom_chip.dart';
import 'package:flutter/material.dart';

class ChipSelector extends StatelessWidget {
  final List<String> items;
  final List<int> selectedIndexes;
  final void Function(int) onSelected;

  const ChipSelector({
    super.key,
    required this.items,
    required this.selectedIndexes,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: List.generate(items.length, (index) {
        final isSelected = selectedIndexes.contains(index);
        return Padding(
          padding: const EdgeInsets.only(right: 8.0),
          child: CustomChip(
            label: items[index],
            value: isSelected,
            onPressed: () => onSelected(index),
          ),
        );
      }),
    );
  }
}
