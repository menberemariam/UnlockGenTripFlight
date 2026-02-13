import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:get/get_instance/src/extension_instance.dart';
import 'package:get/get_navigation/src/extension_navigation.dart';
import 'package:get/get_state_manager/src/rx_flutter/rx_obx_widget.dart';
import 'package:trip/screens/select_fare_screen.dart';

import '../controllers/flight_result_controller.dart';

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
            onPressed: () => Get.snackbar("Price Alerts", "Set up alerts"),
          ),
          IconButton(
            icon: const Icon(Icons.more_vert),
            onPressed: () {},
          ),
        ],
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
        elevation: 0,
      ),
      body: Column(
        children: [
          // Date selector row
          Container(
            color: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: List.generate(5, (index) {
                  final date = DateTime(2025, 3, 6 + index);
                  final isSelected = date.day == controller.selectedDate.value.day;

                  return GestureDetector(
                    onTap: () => controller.selectedDate.value = date,
                    child: Container(
                      margin: const EdgeInsets.symmetric(horizontal: 4),
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                      decoration: BoxDecoration(
                        color: isSelected ? Colors.blue : Colors.transparent,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: isSelected ? Colors.blue : Colors.grey.shade300),
                      ),
                      child: Column(
                        children: [
                          Text(
                            ["Fri", "Sat", "Sun", "Mon", "Tue"][index],
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
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }),
              ),
            ),
          ),

          // Average price info
          Container(
            color: Colors.white,
            padding: const EdgeInsets.all(12),
            child: const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Average one-way price per passenger, taxes and fees included",
                  style: TextStyle(fontSize: 13, color: Colors.grey),
                ),
                SizedBox(height: 4),
                Text(
                  "Average one-way price per passenger, taxes and fees included",
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
                ),
              ],
            ),
          ),

          // Filters row
          Container(
            color: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            child: Row(
              children: [
                _FilterChip(label: "Filters", icon: Icons.filter_list),
                const SizedBox(width: 8),
                _FilterChip(label: "Nonstop", icon: Icons.flight),
                const SizedBox(width: 8),
                _FilterChip(label: "Checked baggage included"),
              ],
            ),
          ),

          // Sort tabs
          Container(
            color: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _SortTab("Recommended", isActive: false),
                _SortTab("Nonstop first", isActive: false),
                _SortTab("Cheapest", isActive: true),
              ],
            ),
          ),

          // Flight list
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(12),
              children: [
                FlightCard(
                  departureTime: "7:30 AM",
                  duration: "2h 20m",
                  arrivalTime: "9:50 AM",
                  price: "\$45",
                  airline: "Peach Aviation",
                  aircraft: "Airbus A320",
                  departureCode: "NRT T1",
                  arrivalCode: "FUK D",
                  isCheapest: true,
                ),
                FlightCard(
                  departureTime: "6:25 AM",
                  duration: "2h 30m",
                  arrivalTime: "8:55 AM",
                  price: "\$47",
                  airline: "Jetstar Japan",
                  aircraft: "Airbus A320",
                  departureCode: "NRT T3",
                  arrivalCode: "FUK D",
                ),
                FlightCard(
                  departureTime: "7:15 AM",
                  duration: "2h 30m",
                  arrivalTime: "9:45 AM",
                  price: "\$47",
                  airline: "Jetstar Japan",
                  aircraft: "Airbus A320",
                  departureCode: "NRT T3",
                  arrivalCode: "FUK D",
                ),
                FlightCard(
                  departureTime: "8:05 AM",
                  duration: "2h 20m",
                  arrivalTime: "10:25 AM",
                  price: "\$51",
                  airline: "Jetstar Japan",
                  aircraft: "Airbus A320",
                  departureCode: "NRT T3",
                  arrivalCode: "FUK D",
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
// Reusable widgets

class _FilterChip extends StatelessWidget {
  final String label;
  final IconData? icon;

  const _FilterChip({required this.label, this.icon});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 16, color: Colors.grey[700]),
            const SizedBox(width: 4),
          ],
          Text(label, style: const TextStyle(fontSize: 13)),
        ],
      ),
    );
  }
}

class _SortTab extends StatelessWidget {
  final String label;
  final bool isActive;

  const _SortTab(this.label, {required this.isActive});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          label,
          style: TextStyle(
            color: isActive ? Colors.blue : Colors.grey[700],
            fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
          ),
        ),
        if (isActive)
          Container(
            margin: const EdgeInsets.only(top: 4),
            height: 3,
            width: 40,
            color: Colors.blue,
          ),
      ],
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
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (isCheapest)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.blue,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: const Text(
                  "Cheapest",
                  style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold),
                ),
              ),

            const SizedBox(height: 8),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  departureTime,
                  style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                Column(
                  children: [
                    Text(duration, style: const TextStyle(color: Colors.grey)),
                    const Icon(Icons.arrow_forward, size: 20, color: Colors.grey),
                  ],
                ),
                Text(
                  arrivalTime,
                  style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                Text(
                  price,
                  style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.blue),
                ),
              ],
            ),

            const SizedBox(height: 8),

            Text(
              "$departureCode → $arrivalCode",
              style: const TextStyle(color: Colors.grey),
            ),

            const SizedBox(height: 12),

            Row(
              children: [
                const Icon(Icons.flight, size: 16, color: Colors.grey),
                const SizedBox(width: 6),
                Text("$airline | $aircraft", style: const TextStyle(fontSize: 14)),
              ],
            ),

            const SizedBox(height: 8),

            Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.reorder_sharp),
                  onPressed: () { Get.to(SelectFareScreen());
                    },
                iconSize: 16,
                  color: Colors.blue,

                ),
                const SizedBox(width: 4),
                const Text("Book now", style: TextStyle(fontSize: 16, color: Colors.blue,
                ),
                )
              ],
            ),
          ],
        ),
      ),
    );
  }
}