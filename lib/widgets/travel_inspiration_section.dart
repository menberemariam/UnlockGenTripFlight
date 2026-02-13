// lib/screens/home/widgets/travel_inspiration_header.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class TravelInspirationHeader extends StatelessWidget {
  const TravelInspirationHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => Get.toNamed('/travel_inspiration'),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Travel inspiration',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
            GestureDetector(
              onTap: () => Get.toNamed('/location'),
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.location_on,
                    color: Colors.black,
                    size: 20,
                  ),
                  SizedBox(width: 4),
                  Text(
                    'Tokyo',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.black,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}