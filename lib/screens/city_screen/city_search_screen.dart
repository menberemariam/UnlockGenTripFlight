import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/city_search_controller.dart';

class CitySearchScreen extends StatelessWidget {
  const CitySearchScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(CitySearchController());

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close, color: Colors.black),
          onPressed: () => Get.back(),
        ),
        title: const Text(
          "Multiple Departure Cities",
          style: TextStyle(
              color: Colors.black,
              fontWeight: FontWeight.w600,
              fontSize: 16),
        ),
        actions: [
          Obx(() => Switch(
            value: controller.isMultipleDeparture.value,
            onChanged: controller.toggleMultipleDeparture,
          )),
          const SizedBox(width: 10),
        ],
      ),
      body: Column(
        children: [
          // SEARCH
          Padding(
            padding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: TextField(
              onChanged: controller.updateSearch,
              decoration: InputDecoration(
                hintText: "Country, city, or airport",
                prefixIcon: const Icon(Icons.search),
                filled: true,
                fillColor: Colors.grey[100],
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(6),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),

          // LOCATION BANNER
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 16),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.grey[100],
              borderRadius: BorderRadius.circular(4),
            ),
            child: const Row(
              children: [
                Icon(Icons.refresh, size: 18),
                SizedBox(width: 10),
                Text("Location services not enabled"),
              ],
            ),
          ),

          const SizedBox(height: 16),

          Expanded(
            child: Obx(() {
              if (controller.isSearching) {
                final results = controller.filteredResults;

                if (results.isEmpty) {
                  return const Center(
                    child: Text("No results found"),
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: results.length,
                  itemBuilder: (_, i) {
                    final city = results[i];
                    return ListTile(
                      title: Text(city),
                      onTap: () =>
                          controller.selectCity(city),
                    );
                  },
                );
              }

              return Row(
                children: [
                  // SIDEBAR
                  Container(
                    width: 110,
                    color: Colors.grey[100],
                    child: ListView.builder(
                      itemCount: controller.regions.length,
                      itemBuilder: (_, i) {
                        final region =
                        controller.regions[i];

                        return Obx(() {
                          final selected =
                              controller.selectedRegion
                                  .value ==
                                  region;

                          return GestureDetector(
                            onTap: () => controller
                                .changeRegion(region),
                            child: Padding(
                              padding:
                              const EdgeInsets
                                  .symmetric(
                                  vertical: 18),
                              child: Center(
                                child: Text(
                                  region,
                                  style: TextStyle(
                                    color: selected
                                        ? Color(0xFFD4AF37)
                                        : Colors.black87,
                                    fontWeight:
                                    selected
                                        ? FontWeight
                                        .w600
                                        : FontWeight
                                        .normal,
                                  ),
                                ),
                              ),
                            ),
                          );
                        });
                      },
                    ),
                  ),

                  // RIGHT SIDE
                  Expanded(
                    child: SingleChildScrollView(
                      padding:
                      const EdgeInsets.only(
                          left: 16, right: 8),
                      child: Column(
                        crossAxisAlignment:
                        CrossAxisAlignment.start,
                        children: [
                          // RECENT - Always show this section header
                          Obx(() {
                            return Column(
                              crossAxisAlignment:
                              CrossAxisAlignment
                                  .start,
                              children: [
                                Row(
                                  mainAxisAlignment:
                                  MainAxisAlignment
                                      .spaceBetween,
                                  children: [
                                    const Text(
                                      "Recent Searches",
                                      style: TextStyle(
                                          fontWeight:
                                          FontWeight
                                              .bold,
                                          fontSize:
                                          16),
                                    ),
                                    if (controller.recentSearches.isNotEmpty)
                                      IconButton(
                                        icon: const Icon(
                                            Icons
                                                .delete_outline),
                                        onPressed:
                                        controller
                                            .clearAllRecent,
                                      )
                                  ],
                                ),
                                const SizedBox(
                                    height: 10),
                                if (controller.recentSearches.isEmpty)
                                // Show empty state
                                  Container(
                                    padding: const EdgeInsets.symmetric(vertical: 8),
                                    child: const Text(
                                      "No recent searches",
                                      style: TextStyle(
                                        color: Colors.grey,
                                        fontSize: 14,
                                      ),
                                    ),
                                  )
                                else
                                  Wrap(
                                    spacing: 8,
                                    runSpacing: 8,
                                    children: controller
                                        .recentSearches
                                        .map((city) =>
                                        GestureDetector(
                                          onTap: () =>
                                              controller
                                                  .selectCity(
                                                  city),
                                          child:
                                          Container(
                                            padding: const EdgeInsets
                                                .symmetric(
                                                horizontal:
                                                12,
                                                vertical:
                                                8),
                                            decoration:
                                            BoxDecoration(
                                              color: Colors
                                                  .grey[
                                              200],
                                              borderRadius:
                                              BorderRadius.circular(
                                                  4),
                                            ),
                                            child:
                                            Text(
                                                city),
                                          ),
                                        ))
                                        .toList(),
                                  ),
                                const SizedBox(
                                    height: 24),
                              ],
                            );
                          }),

                          // POPULAR
                          const Text(
                            "Popular cities",
                            style: TextStyle(
                                fontWeight:
                                FontWeight.bold,
                                fontSize: 16),
                          ),
                          const SizedBox(height: 12),
                          _buildGrid(
                              controller.popularCities,
                              controller),

                          const Divider(height: 40),

                          // REGION DATA
                          ...controller
                              .currentRegionData
                              .entries
                              .map((entry) {
                            return Column(
                              crossAxisAlignment:
                              CrossAxisAlignment
                                  .start,
                              children: [
                                Padding(
                                  padding:
                                  const EdgeInsets
                                      .symmetric(
                                      vertical:
                                      12),
                                  child: Text(
                                    entry.key,
                                    style:
                                    const TextStyle(
                                      fontWeight:
                                      FontWeight
                                          .bold,
                                      fontSize: 16,
                                    ),
                                  ),
                                ),
                                _buildGrid(
                                    entry.value,
                                    controller,
                                    countryName:
                                    entry.key),
                                const SizedBox(
                                    height: 24),
                              ],
                            );
                          }).toList(),
                        ],
                      ),
                    ),
                  )
                ],
              );
            }),
          )
        ],
      ),
    );
  }

  Widget _buildGrid(
      List<String> cities,
      CitySearchController controller, {
        String? countryName,
      }) {
    // Check if we need to show expand/collapse functionality
    final bool hasExpandable = countryName != null && cities.length > 3;
    // Return the grid without wrapping in Obx if no expandable functionality needed
    if (!hasExpandable) {
      return _buildGridContent(cities, controller, isExpanded: false, countryName: countryName);
    }
    // Wrap only the expandable part in Obx
    return Obx(() {
      final isExpanded = controller.isExpanded(countryName);
      return _buildGridContent(cities, controller, isExpanded: isExpanded, countryName: countryName);
    });
  }

  Widget _buildGridContent(
      List<String> cities,
      CitySearchController controller, {
        required bool isExpanded,
        String? countryName,
      }) {
    final displayList = isExpanded ? cities : cities.take(3).toList();

    return Column(
      children: [
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: displayList.length,
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3,
            mainAxisSpacing: 8,
            crossAxisSpacing: 8,
            childAspectRatio: 3,
          ),
          itemBuilder: (_, i) {
            final city = displayList[i];
            return GestureDetector(
              onTap: () => controller.selectCity(city),
              child: Container(
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: Colors.grey[200],
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(city),
              ),
            );
          },
        ),
        if (cities.length > 3 && countryName != null)
          GestureDetector(
            onTap: () => controller.toggleExpanded(countryName),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(isExpanded ? "Show less" : "Show more"),
                  const SizedBox(width: 4),
                  Icon(isExpanded
                      ? Icons.keyboard_arrow_up
                      : Icons.keyboard_arrow_down),
                ],
              ),
            ),
          )
      ],
    );
  }
}
