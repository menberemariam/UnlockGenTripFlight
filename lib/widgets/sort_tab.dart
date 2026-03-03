// widgets/sort_tab.dart
import 'package:flutter/material.dart';

class SortTab extends StatelessWidget {
  final String label;
  final bool isActive;
  final VoidCallback onTap;

  const SortTab(this.label, {required this.isActive, required this.onTap, super.key});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Text(
            label,
            style: TextStyle(
              color: isActive ? const Color(0xFFEAA21B) : Colors.grey[800],
              fontWeight: isActive ? FontWeight.bold : FontWeight.w500,
              fontSize: 15,
            ),
          ),
          const SizedBox(height: 6),
          AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            height: 3,
            width: isActive ? 36 : 0,
            decoration: BoxDecoration(
              color: const Color(0xFFEAA21B),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
        ],
      ),
    );
  }
}