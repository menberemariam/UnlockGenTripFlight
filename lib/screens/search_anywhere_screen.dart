import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../controllers/flight_search_controller.dart';

class SearchAnyWhere extends StatelessWidget {
  const SearchAnyWhere({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(FlightSearchController());

    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black87),
          onPressed: () => Get.back(),
        ),
        title: const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'To: Anywhere',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
            ),
            Text(
              'From: Los Angeles',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit, color: Colors.black),
            onPressed: () {
              // edit search
            },
          ),
          Padding(
            padding: const EdgeInsets.only(right: 8),
            child: IconButton(
              icon: const Icon(Icons.currency_exchange, color: Colors.black),
              onPressed: () {
                // edit search
              },
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          // Category chips (horizontal scroll)
          Container(
            height: 110,
            color: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 12),
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 12),
              children: [
                _buildCategoryChip(
                  label: 'Anywhere',
                  assetPath: 'assets/images/flight_anywhere.jpg',
                  // isSelected: true,
                ),
                _buildCategoryChip(
                  label: 'Cheap flights',
                  assetPath: 'assets/images/flight_cheap.jpg',
                ),
                _buildCategoryChip(
                  label: 'Trending',
                  assetPath: 'assets/images/flight_trending.jpg',
                ),
                _buildCategoryChip(
                  label: 'Beach',
                  assetPath: 'assets/images/flight_beach.jpg',
                ),
              ],
            ),
          ),

          // Date + Filters row
          Container(
            color: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              children: [
                Expanded(
                  child: _DateField(hint: 'Feb 10'),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _DateField(hint: 'Return date'),
                ),
                const SizedBox(width: 12),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey.shade300),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.filter_list, size: 18, color: Color(0xFF0066FF)),
                      SizedBox(width: 4),
                      Text(
                        'Filters',
                        style: TextStyle(
                          color: Color(0xFF0066FF),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Main content
          Expanded(
            child: Obx(() {
              if (controller.isLoading.value) {
                return const Center(child: CircularProgressIndicator());
              }

              if (!controller.hasResults.value) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Image.asset(
                        'assets/icons/icon_nothing_found.png',
                        width: 220,
                        height: 220,

                      ),
                      const SizedBox(height: 24),
                      const Text(
                        'No matching flights found',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w600,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'Please adjust your search terms and try again',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 15,
                          color: Colors.grey,
                          height: 1.4,
                        ),
                      ),
                    ],
                  ),
                );
              }

              // When there ARE results (placeholder)
              return const Center(child: Text('Flights would appear here...'));
            }),
          ),
        ],
      ),
    );
  }
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

class _DateField extends StatelessWidget {
  final String hint;

  const _DateField({required this.hint});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey.shade300),
            borderRadius: BorderRadius.circular(4),
          ),
          child: Row(
            children: [
              const Icon(Icons.calendar_today_outlined, size: 12, color: Color(0xFF0066FF)),
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
        ),
      ],
    );
  }
}