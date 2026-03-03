import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../controllers/booking_controllers/flight_booking_controller.dart';
import '../../controllers/passenger_controllers/passengers_class_controller.dart';
import '../../providers/booking_provider.dart';
import '../../model/booking.dart';
import '../passenger_Widgets/passengers_class_widget.dart';
import '../Flight_hotel_widgets/flight_hotel_section_widget.dart';
import '../search_widget/search_button_widget.dart';
import '../search_widget/recent_search_widget.dart';
import '../../routes/app_routes.dart';
class RoundTripForm extends StatelessWidget {
  RoundTripForm({super.key});

  final FlightBookingController controller = Get.find<FlightBookingController>();
  final passengersController = Get.find<PassengersClassController>();
  final flightHotelController = Get.put(FlightHotelSectionController());

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        GestureDetector(
          onTap: () => controller.selectCity(true), // true = Departure
          behavior: HitTestBehavior.opaque,
          child: Obx(() => controller.buildLocationField(
            icon: Icons.flight_takeoff,
            label: controller.departureCity.value,
          )),
        ),

        controller.buildLineReversField(),

        GestureDetector(
          onTap: () => controller.selectCity(false), // false = Destination
          behavior: HitTestBehavior.opaque,
          child: Obx(() => controller.buildLocationField(
            icon: Icons.flight_land,
            label: controller.destinationCity.value,
          )),
        ),

        controller.buildDividerField(),
        GestureDetector(
          onTap: () => controller.goToRoundTripCalendar(),
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
                  displayDate = "${DateFormat('EEE, MMM d').format(start)} - ${DateFormat('EEE, MMM d, yyyy').format(end)}";
                }
                else if (start != null) {
                  displayDate = "${DateFormat('EEE, MMM d').format(start)} - Select Return";
                }

                return Text(
                  displayDate,
                  style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w500),
                );
              }),
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
              debugPrint("Searching Round Trip: ${controller.departureCity.value} to ${controller.destinationCity.value}");

              final searchParams = SearchParams(
                from: controller.departureCity.value,
                to: controller.destinationCity.value,
                date: controller.selectedDate.value,
                adults: passengersController.adults.value,
                children: passengersController.children.value,
                infants: passengersController.infants.value,
                cabinClass: passengersController.selectedClass.value,
                tripType: 'Round-trip',
              );

              context.read<BookingProvider>().setSearchParams(searchParams);
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