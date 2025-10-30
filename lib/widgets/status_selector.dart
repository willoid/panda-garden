import 'package:flutter/material.dart';
import '../models/user.dart';

class StatusSelector extends StatelessWidget {
  final GardenStatus currentStatus;
  final Function(GardenStatus) onStatusChanged;

  const StatusSelector({
    Key? key,
    required this.currentStatus,
    required this.onStatusChanged,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const Text(
          'Update Status',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 12),
        Wrap(
          alignment: WrapAlignment.center,
          spacing: 8,
          runSpacing: 8,
          children: GardenStatus.values.map((status) {
            final isSelected = status == currentStatus;
            return ChoiceChip(
              avatar: Text(
                status.emoji,
                style: const TextStyle(fontSize: 18),
              ),
              label: Text(status.displayName),
              selected: isSelected,
              selectedColor: Theme.of(context).colorScheme.primary,
              backgroundColor: Colors.grey.shade200,
              labelStyle: TextStyle(
                color: isSelected ? Colors.white : Colors.black87,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
              onSelected: (selected) {
                if (selected && status != currentStatus) {
                  onStatusChanged(status);
                }
              },
            );
          }).toList(),
        ),
      ],
    );
  }
}
