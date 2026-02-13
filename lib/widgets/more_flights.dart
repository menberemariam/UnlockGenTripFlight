import 'package:flutter/material.dart';
import 'package:get/get.dart';

class MoreFlights extends StatelessWidget {
  MoreFlights({super.key});

  // Use local assets instead of network images
  final List<Map<String, dynamic>> destinations = [
    {
      'city': 'Hong Kong',
      'country': 'China',
      'highlight': null,
      'image': 'asset/images/flight_anywhere.jpg',
      'dates': [
        {'day': 'Mon, Feb 16', 'price': 98.30},
        {'day': 'Wed, Feb 18', 'price': 107.70},
      ],
    },
    {
      'city': 'Seoul',
      'country': 'South Korea',
      'highlight': 'Myeong-dong',
      'image': 'asset/images/flight_trending.jpg',
      'dates': [
        {'day': 'Fri, Feb 13', 'price': 123.80},
        {'day': 'Sun, Feb 15', 'price': 129.60},
      ],
    },
    {
      'city': 'Manila',
      'country': 'Philippines',
      'highlight': null,
      'image': 'asset/images/flight_beach.jpg',
      'dates': [
        {'day': 'Sat, Feb 28', 'price': 124.90},
        {'day': 'Wed, Feb 25', 'price': 140.60},
      ],
    },
    {
      'city': 'Taipei',
      'country': 'China',
      'highlight': null,
      'image': 'asset/images/flight_anywhere.jpg',
      'dates': [
        {'day': 'Mon, Feb 16', 'price': 142.10},
        {'day': 'Tue, Feb 17', 'price': 153.10},
      ],
    },
    {
      'city': 'Kuala Lumpur',
      'country': 'Malaysia',
      'highlight': 'Dewan Perdana Felda',
      'image': 'asset/images/flight_trending.jpg',
      'dates': [],
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black87),
          onPressed: () => Get.back(),
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: const [
            Text(
              'To: Anywhere',
              style: TextStyle(
                color: Colors.black87,
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
            SizedBox(height: 2),
            Text(
              'From: Tokyo',
              style: TextStyle(
                color: Colors.grey,
                fontSize: 13,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit, color: Colors.black),
            onPressed: () => Get.toNamed('/edit-search'),
          ),
          Padding(
            padding: const EdgeInsets.only(right: 8),
            child: IconButton(
              icon: const Icon(Icons.currency_exchange, color: Colors.black),
              onPressed: () => Get.snackbar('Currency', 'Change currency'),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Horizontal category chips – now using assets
            SizedBox(
              height: 110,
              child: ListView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
                children: [
                  _buildCategoryChip(
                    label: 'Anywhere',
                    assetPath: 'asset/images/flight_anywhere.jpg',
                    // isSelected: true,
                  ),
                  _buildCategoryChip(
                    label: 'Cheap flights',
                    assetPath: 'asset/images/flight_cheap.jpg',
                  ),
                  _buildCategoryChip(
                    label: 'Trending',
                    assetPath: 'asset/images/flight_trending.jpg',
                  ),
                  _buildCategoryChip(
                    label: 'Beach',
                    assetPath: 'asset/images/flight_beach.jpg',
                  ),
                ],
              ),
            ),

            // Date & filter bar
            Container(
              color: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Row(
                children: [
                  Expanded(child: _DateField(hint: 'Feb 10')),
                  const SizedBox(width: 12),
                  Expanded(child: _DateField(hint: 'Return date')),
                  const SizedBox(width: 12),
                  _buildFilterButton(),
                ],
              ),
            ),

            // Destination cards
            ...destinations.map((dest) => _buildDestinationCard(dest)).toList(),

            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoryChip({
    required String label,
    required String assetPath,
    bool isSelected = false,
  }) {
    return GestureDetector(
      onTap: () {
        Get.snackbar('Category tapped', label);
      },
      child: Container(
        width: 100,
        margin: const EdgeInsets.only(right: 12),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(5),
          color: isSelected ? const Color(0xFF006CFF) : Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Stack(
          alignment: Alignment.center,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(5),
              child: Image.asset(
                assetPath,
                height: 100,
                width: 100,
                fit: BoxFit.cover,
                color: isSelected ? Colors.black.withOpacity(0.38) : null,
                colorBlendMode: isSelected ? BlendMode.darken : null,
                errorBuilder: (context, error, stackTrace) => Container(
                  color: Colors.grey[300],
                  child: const Icon(Icons.image_not_supported, size: 40),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(8,16,8,4),
              child: Text(
                label,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: isSelected ? Colors.blue : Colors.white,
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  height: 1.2,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterButton() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(8),
      ),
      child: const Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.filter_list, size: 12, color: Color(0xFF006CFF)),
          SizedBox(width: 6),
          Text(
            'Filters',
            style: TextStyle(
              color: Colors.grey,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDestinationCard(Map<String, dynamic> dest) {
    return GestureDetector(
      onTap: () => Get.toNamed('/destination-detail', arguments: dest),
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.06),
              blurRadius: 10,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
              child: Stack(
                children: [
                  Image.asset(
                    dest['image'] ?? 'assets/image/no-flight.jpg',
                    height: 140,
                    width: double.infinity,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Image.asset(
                        'asset/images/nothing_flight.png',
                        height: 140,
                        width: double.infinity,
                        fit: BoxFit.cover,
                      );
                    },
                  ),
                  Positioned(
                    bottom: 12,
                    left: 16,
                    child: Text(
                      '${dest['city']} ${dest['country']}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        shadows: [Shadow(blurRadius: 4, color: Colors.black54)],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      if (dest['highlight'] != null)
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                          decoration: BoxDecoration(
                            color: const Color(0xFFE6F0FF),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            dest['highlight'],
                            style: const TextStyle(
                              color: Color(0xFF006CFF),
                              fontSize: 13,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      const Spacer(),
                      GestureDetector(
                        onTap: () {
                          // Should go to flight list for this destination
                          Get.toNamed('/flights-list', arguments: dest);
                        },
                        child: const Text(
                          'More flights >',
                          style: TextStyle(
                            color: Color(0xFF006CFF),
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  if (dest['dates'] != null && (dest['dates'] as List).isNotEmpty)
                    ... (dest['dates'] as List).map<Widget>((date) => Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            date['day'],
                            style: const TextStyle(fontSize: 15, color: Colors.black87),
                          ),
                          Text(
                            '\$${date['price'].toStringAsFixed(2)}',
                            style: const TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF006CFF),
                            ),
                          ),
                        ],
                      ),
                    ))
                  else
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 8),
                      child: Text(
                        'No dates available',
                        style: TextStyle(color: Colors.grey),
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

class _DateField extends StatelessWidget {
  final String hint;

  const _DateField({required this.hint});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          const Icon(Icons.calendar_today_outlined, size: 12, color: Color(0xFF006CFF)),
          const SizedBox(width: 5),
          Text(
            hint,
            style: const TextStyle(
              fontSize: 12,
              color: Colors.black54,
            ),
          ),
        ],
      ),
    );
  }
}