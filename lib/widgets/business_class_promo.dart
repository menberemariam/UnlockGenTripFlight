// lib/screens/home/widgets/business_class_promo.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class BusinessClassPromo extends StatelessWidget {
  const BusinessClassPromo({super.key});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => Get.toNamed('/business_class'),
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: const Color(0xFFDCC7A8),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            const Icon(
              Icons.airline_seat_flat_angled,
              color: Color(0xFFC6A373),
              size: 30,
            ),
            const SizedBox(width: 8),
            const Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Business class top picks',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF704009),
                    ),
                  ),
                  Text(
                    'Discover luxury options for less',
                    style: TextStyle(
                      fontSize: 12,
                      color: Color(0xFF855C2D),
                    ),
                  ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: const Color(0xFFE3AF6F),
                borderRadius: BorderRadius.circular(5),
              ),
              child: const Text(
                'Explore >',
                style: TextStyle(color: Colors.brown, fontSize: 14),
              ),
            ),
          ],
        ),
      ),
    );
  }
}