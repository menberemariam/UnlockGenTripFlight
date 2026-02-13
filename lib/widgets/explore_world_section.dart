import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/booking_middle_controller.dart';
import 'destination_card.dart';
import 'more_flights.dart';

class ExploreWorldSection extends StatelessWidget {
  const ExploreWorldSection({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<HomeController>();

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF6F7FBD), Color(0xFF3350C4)],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        children: [
          GestureDetector(
            onTap: () => Get.toNamed('/explore_world'),
            child: Padding(
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
                    onPressed: (){
                      Get.to( MoreFlights());
                    },
                    icon: const Icon(
                      Icons.arrow_forward,
                      color: Colors.white,
                      size: 20,
                    ),
                  ),
                ],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: const [
                _CityChip(name: 'Beijing', price: '\$99.80', route: '/beijing'),
                _CityChip(name: 'Manila',   price: '\$97.60', route: '/manila'),
              ],
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: 480,
            child: ListView(
              scrollDirection: Axis.horizontal,
              children: [
                _buildSection('Cheap flights', const Color(0xFF00BFFF), controller.cheapFlights, const Color(0xFF00BFFF)),
                _buildSection('Best deals',     const Color(0xFFFF69B4), controller.bestDeals,     const Color(0xFFFF69B4)),
                _buildSection('Trending destinations', const Color(0xFFFFA500), controller.trending, const Color(0xFFFFA500)),
              ],
            ),
          ),
          const SizedBox(height: 8),
        ],
      ),
    );
  }

  Widget _buildSection(
      String title,
      Color titleColor,
      List<Map<String, String>> data,
      Color labelColor,
      ) {
    return Container(
      width: 220,
      margin: const EdgeInsets.only(left: 16, right: 8, bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Text(
              title,
              style: TextStyle(
                color: titleColor,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          ...data.asMap().entries.map((entry) {
            final idx = entry.key;
            final item = entry.value;
            return DestinationCard(
              index: idx + 1,
              name: item['name']!,
              date: item['date']!,
              price: item['price']!,
              imageUrl: item['image']!,
              labelColor: labelColor,
            );
          }),
          const Padding(
            padding: EdgeInsets.all(16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Text(
                  'View more >',
                  style: TextStyle(
                    color: Color(0xFF007AFF),
                    fontSize: 14,
                  ),
                ),
              ],
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
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            decoration: BoxDecoration(
              color: const Color(0xFF4A90E2),
              borderRadius: BorderRadius.circular(5),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(name, style: const TextStyle(color: Colors.white, fontSize: 14)),
                Text('From $price', style: const TextStyle(color: Colors.white, fontSize: 12)),
              ],
            ),
          ),
          const Icon(
            Icons.arrow_drop_down,
            color: Color(0xFF4A90E2),
            size: 20,
          ),
        ],
      ),
    );
  }
}