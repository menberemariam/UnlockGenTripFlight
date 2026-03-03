// screens/flight_results_screen.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/flight_result_controller.dart';
import '../widgets/filter_chip.dart';
import '../widgets/sort_tab.dart';
import '../widgets/flight_card.dart';
import 'filter_screen.dart';
import 'select_fare_screen.dart';

class FlightResultsScreen extends StatelessWidget {
  const FlightResultsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final Map<String, String>? selectedDestination = Get.arguments;
    final String destinationCity = selectedDestination?['name'] ?? 'Fukuoka';
    final controller = Get.put(FlightResultsController(destination: destinationCity));

    return Scaffold(
      appBar: AppBar(
        leading: const BackButton(),
        title: Obx(
              () => Text(
            "Tokyo → $destinationCity ${controller.selectedDate.value.day}",
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_outlined),
            onPressed: () {
              Get.snackbar("Price Alerts", "Price alerts feature coming soon");
            },
          ),
          IconButton(
            icon: const Icon(Icons.more_vert),
            onPressed: () {
              Get.snackbar("Menu", "Options: Share • Help • Settings");
            },
          ),
        ],
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
        elevation: 0,
      ),
      body: CustomScrollView(
        slivers: [
          // Date selector
          SliverToBoxAdapter(
            child: Container(
              color: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Obx(() => Row(
                  children: List.generate(7, (index) {
                    final baseDate = DateTime(2026, 2, 18);
                    final date = baseDate.add(Duration(days: index));
                    final isSelected = date.day == controller.selectedDate.value.day &&
                        date.month == controller.selectedDate.value.month;

                    return GestureDetector(
                      onTap: () => controller.changeDate(date),
                      child: Container(
                        margin: const EdgeInsets.symmetric(horizontal: 4),
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                        decoration: BoxDecoration(
                          color: isSelected ? const Color(0xFFEAA21B) : Colors.transparent,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: isSelected ? const Color(0xFFEAA21B) : Colors.grey.shade300,
                            width: 1.5,
                          ),
                        ),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              ["Tue", "Wed", "Thu", "Fri", "Sat", "Sun", "Mon"][index],
                              style: TextStyle(
                                color: isSelected ? Colors.white : Colors.grey[700],
                                fontSize: 13,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              "${date.day}",
                              style: TextStyle(
                                color: isSelected ? Colors.white : Colors.black87,
                                fontSize: 17,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  }),
                )),
              ),
            ),
          ),

          // Average price banner
          SliverToBoxAdapter(
            child: Container(
              color: Colors.white,
              padding: const EdgeInsets.all(12),
              child: Obx(() {
                final flights = controller.displayedFlights;
                if (flights.isEmpty) {
                  return const Text(
                    "No flights available",
                    style: TextStyle(color: Colors.grey),
                  );
                }
                final prices = flights.map((f) => f.price).toList();
                final minPrice = prices.reduce((a, b) => a < b ? a : b);
                final maxPrice = prices.reduce((a, b) => a > b ? a : b);

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "Average one-way price per passenger, taxes and fees included",
                      style: TextStyle(fontSize: 13, color: Colors.grey),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      "\$$minPrice – \$$maxPrice",
                      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                  ],
                );
              }),
            ),
          ),

          // Filter chips
          SliverToBoxAdapter(
            child: Container(
              color: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              child: Row(
                children: [
                  FilterChipWidget(
                    label: "Filters",
                    icon: Icons.filter_list,
                    onTap: () => Get.to(() => const FilterScreen()),
                  ),
                  const SizedBox(width: 4),
                  Obx(
                        () => FilterChipWidget(
                      label: "Nonstop",
                      icon: Icons.flight,
                      active: controller.nonstopOnly.value,
                      onTap: controller.toggleNonstop,
                    ),
                  ),
                  const SizedBox(width: 4),
                  Obx(
                        () => FilterChipWidget(
                      label: "Checked baggage",
                      active: controller.baggageIncluded.value,
                      onTap: controller.toggleBaggage,
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Sort tabs
          SliverToBoxAdapter(
            child: Container(
              color: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              child: Obx(() => Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  SortTab(
                    "Recommended",
                    isActive: controller.sortBy.value == SortOption.recommended,
                    onTap: () => controller.setSortMode(SortOption.recommended),
                  ),
                  SortTab(
                    "Nonstop first",
                    isActive: controller.sortBy.value == SortOption.nonstopFirst,
                    onTap: () => controller.setSortMode(SortOption.nonstopFirst),
                  ),
                  SortTab(
                    "Cheapest",
                    isActive: controller.sortBy.value == SortOption.cheapest,
                    onTap: () => controller.setSortMode(SortOption.cheapest),
                  ),
                ],
              )),
            ),
          ),

          // Flight list
          Obx(() {
            final flights = controller.displayedFlights;
            if (flights.isEmpty) {
              return const SliverToBoxAdapter(
                child: Center(child: Text("No flights found")),
              );
            }
            final minPrice = flights.map((f) => f.price).reduce((a, b) => a < b ? a : b);
            return SliverList(
              delegate: SliverChildBuilderDelegate(
                    (context, index) {
                  final flight = flights[index];
                  return FlightCard(
                    departureTime: flight.departureTime,
                    duration: flight.duration,
                    arrivalTime: flight.arrivalTime,
                    price: "\$${flight.price}",
                    airline: flight.airline,
                    aircraft: flight.aircraft,
                    departureCode: flight.departureCode,
                    arrivalCode: flight.arrivalCode,
                    isCheapest: flight.price == minPrice,
                    onBook: () => Get.to(() => const SelectFareScreen()),
                  );
                },
                childCount: flights.length,
              ),
            );
          }),
        ],
      ),
    );
  }
}