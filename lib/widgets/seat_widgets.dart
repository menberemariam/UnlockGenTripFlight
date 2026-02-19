import 'package:flutter/material.dart';
import '../utils/extensions.dart';

class SeatWidget extends StatelessWidget {
  final String label;
  final bool isSelected;
  final bool isOccupied;
  final Color brandColor;
  final VoidCallback onTap;

  const SeatWidget({
    super.key,
    required this.label,
    required this.isSelected,
    required this.isOccupied,
    required this.brandColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    Color bgColor;
    Color borderColor;
    Color textColor;

    if (isOccupied) {
      bgColor = Colors.grey.shade700;
      borderColor = Colors.grey.shade800;
      textColor = Colors.grey.shade400;
    } else if (isSelected) {
      bgColor = brandColor;
      borderColor = brandColor.darker(0.2);
      textColor = Colors.black87;
    } else {
      bgColor = Colors.white;
      borderColor = Colors.grey.shade400;
      textColor = Colors.black87;
    }

    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 38,
        height: 38,
        margin: const EdgeInsets.symmetric(horizontal: 3, vertical: 4),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: borderColor, width: 1.5),
        ),
        alignment: Alignment.center,
        child: Text(
          label,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: textColor,
          ),
        ),
      ),
    );
  }
}