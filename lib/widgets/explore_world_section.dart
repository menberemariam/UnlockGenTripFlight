import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../controllers/booking_middle_controller.dart';
import '../screens/flight_result_screen.dart';
import 'destination_card.dart';
import '../screens/more_flights_screen.dart';

class ExploreWorldSection extends StatelessWidget {
  const ExploreWorldSection({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<MiddleController>();

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFFF3CC84), Color(0xFFEDB853)],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Explore the world',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                IconButton(
                  onPressed: () => Get.to(() => MoreFlights()),
                  icon: const Icon(
                    Icons.arrow_forward,
                    color: Colors.white,
                    size: 28,
                  ),
                ),
              ],
            ),
          ),

          // Quick city chips
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: const [
                _CityChip(name: 'Beijing', price: '\$99.80', route: '/beijing'),
                _CityChip(name: 'Manila', price: '\$97.60', route: '/manila'),
              ],
            ),
          ),

          const SizedBox(height: 12),

          // Horizontal sections
          SizedBox(
            height: 480,
            child: Obx(
                  () => ListView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 8),
                children: [
                  _buildSection(
                    title: 'Cheap flights',
                    titleColor: const Color(0xFF00BFFF),
                    data: controller.cheapFlights,
                    labelColor: const Color(0xFF00BFFF),
                  ),
                  _buildSection(
                    title: 'Best deals',
                    titleColor: const Color(0xFFFF69B4),
                    data: controller.bestDeals,
                    labelColor: const Color(0xFFFF69B4),
                  ),
                  _buildSection(
                    title: 'Trending destinations',
                    titleColor: const Color(0xFFFFA500),
                    data: controller.trending,
                    labelColor: const Color(0xFFFFA500),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 12),
        ],
      ),
    );
  }

  Widget _buildSection({
    required String title,
    required Color titleColor,
    required List<Map<String, String>> data,
    required Color labelColor,
  }) {
    return Container(
      width: 260, // increased from 220 → better text/image balance
      margin: const EdgeInsets.only(left: 8, right: 12, bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 12, 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    color: titleColor,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                IconButton(
                  icon: const Icon(
                    Icons.bookmark_add_outlined,
                    color: Color(0xFFEAA21B),
                    size: 24,
                  ),
                  onPressed: () {
                    Get.to(() => const FlightResultsScreen());
                  },
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
              ],
            ),
          ),

          // Cards
          ...data.asMap().entries.map((entry) {
            final idx = entry.key;
            final item = entry.value;

            return DestinationCard(
              index: idx + 1,
              name: item['name'] ?? 'Unknown',
              date: item['date'] ?? '—',
              price: item['price'] ?? 'N/A',
              imageUrl: item['image'] ?? '',
              labelColor: labelColor,
            );
          }).toList(),

          // View more
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 1),
            child: GestureDetector(
              onTap: () => Get.to(() => const FlightResultsScreen()),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Text(
                    'View more  →',
                    style: TextStyle(
                      color: Color(0xFFEAA21B),
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _CityChip extends StatelessWidget {
  final String name;
  final String price;
  final String route;

  const _CityChip({
    required this.name,
    required this.price,
    required this.route,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => Get.toNamed(route),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            decoration: BoxDecoration(
              color: const Color(0xFFEAA21B),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'From $price',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
          const Icon(
            Icons.arrow_drop_down,
            color: Color(0xFFEAA21B),
            size: 20,
          ),
        ],
      ),
    );
  }
}