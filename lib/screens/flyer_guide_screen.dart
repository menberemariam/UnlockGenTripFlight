import 'package:flutter/material.dart';
import 'package:get/get.dart';

class FlyerGuideScreen extends StatelessWidget {
  const FlyerGuideScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFEEF4FF),
      appBar: AppBar(
        backgroundColor: const Color(0xFFEAA21B),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Get.back(),
        ),
        title: const Text(
          'Flyer Guide',
          style: TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildSectionCard(
            title: 'Before You Fly',
            items: [
              'Check-in: Online 24–48 hours before departure',
              'Arrive at airport: 3 hours (international), 2 hours (domestic)',
              'Valid travel documents: Passport/ID + visa if required',
              'Baggage allowance: Check your ticket type',
            ],
          ),
          const SizedBox(height: 16),
          _buildSectionCard(
            title: 'At the Airport',
            items: [
              'Security screening: Liquids ≤ 100ml in transparent bag',
              'Boarding: Gate closes 15–30 minutes before departure',
              'Priority boarding: Available for premium & special passengers',
              'Flight delays: Ask staff for updates & refreshments if long delay',
            ],
          ),
          const SizedBox(height: 16),
          _buildSectionCard(
            title: 'On Board',
            items: [
              'Seat belts: Fasten during taxi, takeoff, landing & turbulence',
              'Electronic devices: Airplane mode required',
              'Cabin crew instructions: Always follow crew directions',
              'During landing: Return seat & tray to upright position',
            ],
          ),
          const SizedBox(height: 24),
          Card(
            color: Colors.white,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  const Icon(
                    Icons.flight_takeoff,
                    size: 48,
                    color: Color(0xFFEAA21B),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Safe travels with Habesha Wings!',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'We wish you a pleasant journey',
                    style: TextStyle(color: Colors.grey[700]),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 40),
        ],
      ),
    );
  }

  Widget _buildSectionCard({
    required String title,
    required List<String> items,
  }) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Color(0xFFEAA21B),
              ),
            ),
            const SizedBox(height: 12),
            ...items.map((item) => Padding(
              padding: const EdgeInsets.symmetric(vertical: 6),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(
                    Icons.check_circle_outline,
                    size: 20,
                    color: Color(0xFFEAA21B),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      item,
                      style: const TextStyle(
                        fontSize: 15,
                        height: 1.4,
                      ),
                    ),
                  ),
                ],
              ),
            )),
          ],
        ),
      ),
    );
  }
}