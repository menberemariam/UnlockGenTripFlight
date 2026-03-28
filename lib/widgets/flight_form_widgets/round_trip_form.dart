import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../controllers/flight_booking_controller.dart';
import '../../controllers/passengers_class_controller.dart';
import '../../providers/booking_provider.dart';
import '../../model/booking.dart';
import '../passenger_Widgets/passengers_class_widget.dart';
import '../Flight_hotel_widgets/flight_hotel_section_widget.dart';
import '../search_widget/search_button_widget.dart';
import '../search_widget/recent_search_widget.dart';
import '../../routes/app_routes.dart';

class RoundTripForm extends StatelessWidget {
  RoundTripForm({super.key});

  final FlightBookingController controller =
  Get.find<FlightBookingController>();

  final PassengersClassController passengersController =
  Get.find<PassengersClassController>();

  final flightHotelController =
  Get.put(FlightHotelSectionController());

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [

        //Departure
        GestureDetector(
          onTap: () => controller.selectCity(true),
          behavior: HitTestBehavior.opaque,
          child: Obx(() => controller.buildLocationField(
            icon: Icons.flight_takeoff,
            label: controller.departureCity.value,
          )),
        ),

        controller.buildLineReversField(),

        //Destination
        GestureDetector(
          onTap: () => controller.selectCity(false),
          behavior: HitTestBehavior.opaque,
          child: Obx(() => controller.buildLocationField(
            icon: Icons.flight_land,
            label: controller.destinationCity.value,
          )),
        ),

        controller.buildDividerField(),

        //Date Range
        GestureDetector(
          onTap: controller.goToRoundTripCalendar,
          behavior: HitTestBehavior.opaque,
          child: Row(
            children: [
              const Icon(Icons.calendar_today, color: Colors.grey),
              const SizedBox(width: 12),
              Obx(() {
                final start = controller.rangeStart.value;
                final end = controller.rangeEnd.value;

                String displayDate = 'Select Departure - Return';

                if (start != null && end != null) {
                  displayDate =
                  "${DateFormat('EEE, MMM d').format(start)} - "
                      "${DateFormat('EEE, MMM d, yyyy').format(end)}";
                } else if (start != null) {
                  displayDate =
                  "${DateFormat('EEE, MMM d').format(start)} - Select Return";
                }

                return Text(
                  displayDate,
                  style: const TextStyle(
                      fontSize: 15, fontWeight: FontWeight.w500),
                );
              }),
            ],
          ),
        ),

        controller.buildDividerField(),

        // Passengers & Class
        PassengersClassWidget(controller: passengersController),

        controller.buildDividerField(),

        // Flight + Hotel Option
        FlightHotelSectionWidget(controller: flightHotelController),

        const SizedBox(height: 20),

        // SEARCH BUTTON
        Builder(
          builder: (context) {
            return SearchButtonWidget(
              onPressed: () {
                final from = controller.departureCity.value.trim();
                final to = controller.destinationCity.value.trim();
                final start = controller.rangeStart.value;
                final end = controller.rangeEnd.value;

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
                if (start == null) {
                  Get.snackbar('Required', 'Please select a departure date',
                      snackPosition: SnackPosition.BOTTOM,
                      backgroundColor: const Color(0xFFFFEBEE),
                      colorText: const Color(0xFFD32F2F));
                  return;
                }
                if (end == null) {
                  Get.snackbar('Required', 'Please select a return date',
                      snackPosition: SnackPosition.BOTTOM,
                      backgroundColor: const Color(0xFFFFEBEE),
                      colorText: const Color(0xFFD32F2F));
                  return;
                }
                if (!end.isAfter(start)) {
                  Get.snackbar('Invalid', 'Return date must be after departure date',
                      snackPosition: SnackPosition.BOTTOM,
                      backgroundColor: const Color(0xFFFFEBEE),
                      colorText: const Color(0xFFD32F2F));
                  return;
                }

                final searchParams = SearchParams(
                  from: from,
                  to: to,
                  departureDate: start,
                  returnDate: end,
                  adults: passengersController.adults.value,
                  children: passengersController.children.value,
                  infants: passengersController.infants.value,
                  cabinClass: passengersController.selectedClass.value,
                  tripType: 'Round-trip',
                );

                context.read<BookingProvider>().setSearchParams(searchParams);

                // Mark trip type as round-trip in the booking controller
                controller.setTripType(1);

                //  LOAD FLIGHTS BEFORE NAVIGATION
                controller.loadRoundTripFlights();

                // Navigate to Departure Results
                Get.toNamed(AppRoutes.departureResults);
              },
            );
          },
        ),

        const SizedBox(height: 15),

        const RecentSearchWidget(),
      ],
    );
  }
}