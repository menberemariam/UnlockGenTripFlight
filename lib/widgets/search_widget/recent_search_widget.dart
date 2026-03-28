import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/city_search_controller.dart';

class RecentSearchWidget extends StatelessWidget {
  const RecentSearchWidget({super.key});

  @override
  Widget build(BuildContext context) {
    // Use existing CitySearchController if available, else skip
    final CitySearchController? ctrl = Get.isRegistered<CitySearchController>()
        ? Get.find<CitySearchController>()
        : null;

    if (ctrl == null) return const SizedBox.shrink();

    return Obx(() {
      if (ctrl.recentSearches.isEmpty) return const SizedBox.shrink();
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 8),
          Text('Recent searches',
              style: TextStyle(fontSize: 13, color: Colors.grey.shade600)),
          const SizedBox(height: 6),
          Wrap(
            spacing: 8,
            runSpacing: 4,
            children: ctrl.recentSearches
                .take(5)
                .map((city) => GestureDetector(
                      onTap: () => ctrl.selectCity(city),
                      child: Chip(
                        label: Text(city,
                            style: const TextStyle(fontSize: 12)),
                        backgroundColor: Colors.grey.shade100,
                        side: BorderSide(color: Colors.grey.shade300),
                        padding: EdgeInsets.zero,
                      ),
                    ))
                .toList(),
          ),
        ],
      );
    });
  }
}
