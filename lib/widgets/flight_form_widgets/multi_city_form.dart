import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../../controllers/flight_booking_controller.dart';
import '../../controllers/passengers_class_controller.dart';
import '../passenger_Widgets/passengers_class_widget.dart';
import '../search_widget/search_button_widget.dart';
import '../search_widget/recent_search_widget.dart';

class MultiCityForm extends StatelessWidget {
  MultiCityForm({super.key});

  final FlightBookingController flightController = Get.find<FlightBookingController>();
  final PassengersClassController passengersController = Get.find<PassengersClassController>();

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Dynamic Flight List
          ...List.generate(flightController.multiCityDepartures.length, (index) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Flight ${index + 1}',

                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                    if (index > 1) // Only show delete for flight 3 and beyond
                      IconButton(
                        icon: const Icon(Icons.remove_circle_outline, color: Colors.red),
                        onPressed: () => flightController.removeFlight(index),
                      ),
                  ],
                ),
                const SizedBox(height: 12),
                GestureDetector(
                  onTap: () => flightController.selectMultiCity(index, true),
                  behavior: HitTestBehavior.opaque,
                  child: flightController.buildLocationField(
                    icon: Icons.flight_takeoff,
                    label: flightController.multiCityDepartures[index],
                  ),
                ),

                _buildSwapRow(index),
                GestureDetector(
                  onTap: () => flightController.selectMultiCity(index, false),
                  behavior: HitTestBehavior.opaque,
                  child: flightController.buildLocationField(
                    icon: Icons.flight_land,
                    label: flightController.multiCityArrivals[index],
                  ),
                ),

                flightController.buildDividerField(),

                const SizedBox(height: 10),
                GestureDetector(
                  onTap: () => flightController.goToMultiCityCalendar(index),
                  behavior: HitTestBehavior.opaque,
                  child: Row(
                    children: [
                      const Icon(Icons.calendar_today, color: Colors.grey, size: 20),
                      const SizedBox(width: 20),
                       const SizedBox(height: 30),
                      Text(
                        DateFormat('EEE, MMM d yyyy').format(flightController.multiCityDates[index]),
                        style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w500),
                      ),

                    ],
                  ),
                ),

                flightController.buildDividerField(),
              ],
            );
          }),


          Center(
            child: TextButton.icon(
              onPressed: () => flightController.addFlight(),
              icon: const Icon(Icons.add_circle_outline, color: Color(0xFFFFC107)),
              label: const Text('Add another flight',
                  style: TextStyle(color: Color(0xFFFFC107), fontSize: 15, fontWeight: FontWeight.w500)),
            ),
          ),
          flightController.buildDividerField(),
          PassengersClassWidget(controller: passengersController),
          const SizedBox(height: 20),
          SearchButtonWidget(onPressed: () {
            for (int i = 0; i < flightController.multiCityDepartures.length; i++) {
              final from = flightController.multiCityDepartures[i].trim();
              final to = flightController.multiCityArrivals[i].trim();
              final leg = i + 1;

              if (from.isEmpty) {
                Get.snackbar('Required', 'Flight $leg: please select a departure city',
                    snackPosition: SnackPosition.BOTTOM,
                    backgroundColor: const Color(0xFFFFEBEE),
                    colorText: const Color(0xFFD32F2F));
                return;
              }
              if (to.isEmpty) {
                Get.snackbar('Required', 'Flight $leg: please select a destination city',
                    snackPosition: SnackPosition.BOTTOM,
                    backgroundColor: const Color(0xFFFFEBEE),
                    colorText: const Color(0xFFD32F2F));
                return;
              }
              if (from == to) {
                Get.snackbar('Invalid', 'Flight $leg: departure and destination cannot be the same',
                    snackPosition: SnackPosition.BOTTOM,
                    backgroundColor: const Color(0xFFFFEBEE),
                    colorText: const Color(0xFFD32F2F));
                return;
              }
            }
            // Navigate to one-way results using first leg
            Get.find<FlightBookingController>().departureCity.value =
                flightController.multiCityDepartures.first;
            Get.find<FlightBookingController>().destinationCity.value =
                flightController.multiCityArrivals.first;
            Get.find<FlightBookingController>().selectedDate.value =
                flightController.multiCityDates.first;
            Get.toNamed('/results');
          }),
          const SizedBox(height: 10),
          const RecentSearchWidget(),
        ],
      );
    });
  }

  Widget _buildSwapRow(int index) {
    return Row(
      children: [
        const Expanded(child: Divider(thickness: 0.8)),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8.0),
          child: GestureDetector(
            onTap: () => flightController.swapMultiCity(index),
            child: Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: Colors.white,
                border: Border.all(color: Colors.grey[300]!),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(Icons.swap_vert, color: Color(0xFFFFC107), size: 22),
            ),
          ),
        ),
      ],
    );
  }
}