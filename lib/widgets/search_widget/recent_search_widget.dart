import 'package:flutter/material.dart';

class RecentSearchWidget extends StatelessWidget {
  const RecentSearchWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(
          'London → Bangkok',
          style: TextStyle(
            color: Colors.grey[600],
            fontSize: 14,
          ),
        ),
        const SizedBox(width: 8),
        Text(
          'Feb 11',
          style: TextStyle(
            color: Colors.grey[600],
            fontSize: 14,
          ),
        ),
        const SizedBox(width: 8),
        Icon(Icons.delete_outline, color: Colors.grey[400], size: 20),
      ],
    );
  }
}
