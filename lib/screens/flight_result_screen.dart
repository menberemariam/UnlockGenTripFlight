import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../controllers/flight_result_controller.dart';
import 'select_fare_screen.dart'; // Make sure this file exists or comment out navigation for now

class FlightResultsScreen extends StatelessWidget {
  const FlightResultsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(FlightResultsController());

    return Scaffold(
      appBar: AppBar(
        leading: const BackButton(),
        title: Obx(
              () => Text(
            "Tokyo → Fukuoka ${controller.selectedDate.value.day}",
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
      body: Column(
        children: [
          // Date selector
          Container(
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
                        color: isSelected ? Color(0xFFEAA21B) : Colors.transparent,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: isSelected ? Color(0xFFEAA21B) : Colors.grey.shade300,
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

          // Average price banner (dynamic)
          Container(
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
                    "\$${minPrice} – \$${maxPrice}",
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ],
              );
            }),
          ),

          // Filters
          Container(
            color: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            child: Row(
              children: [
                _FilterChip(
                  label: "Filters",
                  icon: Icons.filter_list,
                  onTap: () => Get.snackbar("Filters", "More filters coming soon"),
                ),
                const SizedBox(width: 8),
                Obx(
                      () => _FilterChip(
                    label: "Nonstop",
                    icon: Icons.flight,
                    active: controller.nonstopOnly.value,
                    onTap: controller.toggleNonstop,
                  ),
                ),
                const SizedBox(width: 8),
                Obx(
                      () => _FilterChip(
                    label: "Checked baggage",
                    active: controller.baggageIncluded.value,
                    onTap: controller.toggleBaggage,
                  ),
                ),
              ],
            ),
          ),

          // Sort tabs
          Container(
            color: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            child: Obx(() => Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _SortTab(
                  "Recommended",
                  isActive: controller.sortBy.value == SortOption.recommended,
                  onTap: () => controller.setSortMode(SortOption.recommended),
                ),
                _SortTab(
                  "Nonstop first",
                  isActive: controller.sortBy.value == SortOption.nonstopFirst,
                  onTap: () => controller.setSortMode(SortOption.nonstopFirst),
                ),
                _SortTab(
                  "Cheapest",
                  isActive: controller.sortBy.value == SortOption.cheapest,
                  onTap: () => controller.setSortMode(SortOption.cheapest),
                ),
              ],
            )),
          ),

          // Flight list
          Expanded(
            child: Obx(() {
              final flights = controller.displayedFlights;

              if (flights.isEmpty) {
                return const Center(child: Text("No flights found"));
              }

              final minPrice = flights.map((f) => f.price).reduce((a, b) => a < b ? a : b);

              return ListView.builder(
                padding: const EdgeInsets.all(12),
                itemCount: flights.length,
                itemBuilder: (context, index) {
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
              );
            }),
          ),
        ],
      ),
    );
  }
}

// ────────────────────────────────────────────────
// Reusable widgets
// ────────────────────────────────────────────────

class _FilterChip extends StatelessWidget {
  final String label;
  final IconData? icon;
  final bool active;
  final VoidCallback onTap;

  const _FilterChip({
    required this.label,
    this.icon,
    this.active = false,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: active ? Colors.blue.withOpacity(0.1) : null,
          border: Border.all(color: active ? Color(0xFFEAA21B) : Colors.grey.shade300),
          borderRadius: BorderRadius.circular(5),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (icon != null) ...[
              Icon(icon, size: 18, color: active ? Color(0xFFEAA21B) : Colors.grey[700]),
              const SizedBox(width: 6),
            ],
            Text(
              label,
              style: TextStyle(
                fontSize: 14,
                color: active ? Color(0xFFEAA21B) : Colors.black87,
                fontWeight: active ? FontWeight.w600 : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SortTab extends StatelessWidget {
  final String label;
  final bool isActive;
  final VoidCallback onTap;

  const _SortTab(this.label, {required this.isActive, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Text(
            label,
            style: TextStyle(
              color: isActive ? Color(0xFFEAA21B) : Colors.grey[800],
              fontWeight: isActive ? FontWeight.bold : FontWeight.w500,
              fontSize: 15,
            ),
          ),
          const SizedBox(height: 6),
          AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            height: 3,
            width: isActive ? 36 : 0,
            decoration: BoxDecoration(
              color: Color(0xFFEAA21B),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
        ],
      ),
    );
  }
}

class FlightCard extends StatelessWidget {
  final String departureTime;
  final String duration;
  final String arrivalTime;
  final String price;
  final String airline;
  final String aircraft;
  final String departureCode;
  final String arrivalCode;
  final bool isCheapest;
  final VoidCallback onBook;

  const FlightCard({
    super.key,
    required this.departureTime,
    required this.duration,
    required this.arrivalTime,
    required this.price,
    required this.airline,
    required this.aircraft,
    required this.departureCode,
    required this.arrivalCode,
    this.isCheapest = false,
    required this.onBook,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (isCheapest)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                decoration: BoxDecoration(
                  color: Color(0xFFECBC62),
                  borderRadius: BorderRadius.circular(3),
                ),
                child: const Text(
                  "Cheapest",
                  style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold),
                ),
              ),
            const SizedBox(height: 10),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(departureTime, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 4),
                    Text(departureCode, style: const TextStyle(color: Colors.grey, fontSize: 13)),
                  ],
                ),
                Column(
                  children: [
                    Text(duration, style: const TextStyle(color: Colors.grey, fontSize: 15)),
                    const Icon(Icons.arrow_forward, size: 24, color: Colors.grey),
                  ],
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(arrivalTime, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 4),
                    Text(arrivalCode, style: const TextStyle(color: Colors.grey, fontSize: 13)),
                  ],
                ),
                Text(
                  price,
                  style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Color(0xFFEAA21B)),
                ),
              ],
            ),

            const SizedBox(height: 16),

            Row(
              children: [
                const Icon(Icons.flight_takeoff, size: 18, color: Color(0xFFEAA21B)),
                const SizedBox(width: 8),
                Text("$airline  •  $aircraft", style: const TextStyle(fontSize: 14)),
              ],
            ),

            const SizedBox(height: 16),

            Align(
              alignment: Alignment.centerRight,
              child: ElevatedButton(
                onPressed: onBook,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color(0xFFEAA21B),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 12),
                ),
                child: const Text("Book now", style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}