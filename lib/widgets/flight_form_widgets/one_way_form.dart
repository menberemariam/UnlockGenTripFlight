import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../controllers/flight_booking_controller.dart';
import '../../controllers/passengers_class_controller.dart';
import '../../providers/booking_provider.dart';
import '../../model/booking.dart';
import '../../routes/app_routes.dart';
import '../passenger_Widgets/passengers_class_widget.dart';
import '../Flight_hotel_widgets/flight_hotel_section_widget.dart';
import '../search_widget/search_button_widget.dart';
import '../search_widget/recent_search_widget.dart';

class OneWayForm extends StatelessWidget {
  OneWayForm({super.key});
  final FlightBookingController controller = Get.find<FlightBookingController>();
  final passengersController = Get.find<PassengersClassController>();
  final flightHotelController = Get.put(FlightHotelSectionController());

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        GestureDetector(
          onTap: () => controller.selectCity(true), // Opens search for Departure
          behavior: HitTestBehavior.opaque,
          child: Obx(() => controller.buildLocationField(
            icon: Icons.flight_takeoff,
            label: controller.departureCity.value,
          )),
        ),
        controller.buildLineReversField(),
        GestureDetector(
          onTap: () => controller.selectCity(false), // Opens search for Destination
          behavior: HitTestBehavior.opaque,
          child: Obx(() => controller.buildLocationField(
            icon: Icons.flight_land,
            label: controller.destinationCity.value,
          )),
        ),

        controller.buildDividerField(),
        GestureDetector(
          onTap: () => controller.goToCalendar(),
          behavior: HitTestBehavior.opaque,
          child: Row(
            children: [
              const Icon(Icons.calendar_today, color: Colors.grey, size: 22),
              const SizedBox(width: 12),
              Obx(() => Text(
                DateFormat('EEE, MMM d yyyy').format(controller.selectedDate.value),
                style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w500),
              )),
            ],
          ),
        ),

        controller.buildDividerField(),
        PassengersClassWidget(controller: passengersController),
        controller.buildDividerField(),
        FlightHotelSectionWidget(controller: flightHotelController),
        const SizedBox(height: 15),
        Builder(
          builder: (context) {
            return SearchButtonWidget(onPressed: () {
              final from = controller.departureCity.value.trim();
              final to = controller.destinationCity.value.trim();

              if (from.isEmpty) {
                Get.snackbar('Required', 'Please select a departure city',
                    snackPosition: SnackPosition.BOTTOM,
                    backgroundColor: const Color(0xFFFFEBEE),
                    colorText: const Color(0xFFD32F2F));
                return;
              }
              if (to.isEmpty) {
                Get.snackbar('Required', 'Please select a destination city',
                    snackPosition: SnackPosition.BOTTOM,
                    backgroundColor: const Color(0xFFFFEBEE),
                    colorText: const Color(0xFFD32F2F));
                return;
              }
              if (from == to) {
                Get.snackbar('Invalid', 'Departure and destination cannot be the same',
                    snackPosition: SnackPosition.BOTTOM,
                    backgroundColor: const Color(0xFFFFEBEE),
                    colorText: const Color(0xFFD32F2F));
                return;
              }

              final searchParams = SearchParams(
                from: from,
                to: to,
                date: controller.selectedDate.value,
                adults: passengersController.adults.value,
                children: passengersController.children.value,
                infants: passengersController.infants.value,
                cabinClass: passengersController.selectedClass.value,
                tripType: 'One-way',
              );
              context.read<BookingProvider>().setSearchParams(searchParams);
              controller.setTripType(0);
              Get.toNamed(AppRoutes.results);
            });
          },
        ),

        const SizedBox(height: 10),

        const RecentSearchWidget(),
      ],
    );
  }
}