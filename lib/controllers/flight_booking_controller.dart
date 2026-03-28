import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../screens/calender_screen/full_calendar_screen.dart';
import '../screens/city_screen/city_search_screen.dart';
import '../model/flight.dart';

class FlightBookingController extends GetxController
    with GetSingleTickerProviderStateMixin {

  var departureCity = 'Dubai'.obs;
  var destinationCity = 'Addis Ababa'.obs;

  var multiCityDepartures = <String>['Dubai', 'Addis Ababa'].obs;
  var multiCityArrivals = <String>['Addis Ababa', 'Dubai'].obs;

  var multiCityDates = <DateTime>[
    DateTime.now(),
    DateTime.now().add(const Duration(days: 3)),
  ].obs;

  var selectedDate = DateTime.now().add(const Duration(days: 1)).obs;
  var rangeStart = Rxn<DateTime>()..value = DateTime.now().add(const Duration(days: 1));
  var rangeEnd = Rxn<DateTime>()..value = DateTime.now().add(const Duration(days: 8));
  var selectedTripType = 1.obs;

  bool get isOneWay => selectedTripType.value == 0;
  bool get isRoundTrip => selectedTripType.value == 1;
  bool get isMultiCity => selectedTripType.value == 2;

  void setTripType(int index) {
    selectedTripType.value = index;
    clearFlightSelection();
  }


  // ROUND TRIP STATE


  var outboundFlights = <Flight>[].obs;
  var returnFlights = <Flight>[].obs;

  Rxn<Flight> selectedOutboundFlight = Rxn<Flight>();
  Rxn<Flight> selectedReturnFlight = Rxn<Flight>();

  double get totalPrice {
    final outbound = selectedOutboundFlight.value?.price ?? 0;
    final inbound = selectedReturnFlight.value?.price ?? 0;
    return outbound + inbound;
  }


  double get oneWayPrice {
    return selectedOutboundFlight.value?.price ?? 0;
  }


  // 🆕 FINAL PAYABLE PRICE (NEW)


  double get finalPrice {
    if (isRoundTrip) return totalPrice;
    return oneWayPrice;
  }


  // CITY SWAP


  void swapCities() {
    String temp = departureCity.value;
    departureCity.value = destinationCity.value;
    destinationCity.value = temp;
  }

  void swapMultiCity(int index) {
    String temp = multiCityDepartures[index];
    multiCityDepartures[index] = multiCityArrivals[index];
    multiCityArrivals[index] = temp;
    multiCityDepartures.refresh();
    multiCityArrivals.refresh();
  }

  Future<void> selectCity(bool isDeparture) async {
    final result = await Get.to(() => const CitySearchScreen());
    if (result != null && result is String) {
      if (isDeparture) {
        departureCity.value = result;
      } else {
        destinationCity.value = result;
      }
    }
  }

  Future<void> selectMultiCity(int index, bool isDeparture) async {
    final result = await Get.to(() => const CitySearchScreen());
    if (result != null && result is String) {
      if (isDeparture) {
        multiCityDepartures[index] = result;
      } else {
        multiCityArrivals[index] = result;
      }
    }
  }


  // MULTI CITY ADD / REMOVE


  void addFlight() {
    if (multiCityDepartures.length >= 5) {
      Get.snackbar(
        "Limit Reached",
        "You can add maximum 5 flights",
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    multiCityDepartures.add(multiCityArrivals.last);
    multiCityArrivals.add('Select City');
    multiCityDates.add(
      multiCityDates.last.add(const Duration(days: 2)),
    );
  }

  void removeFlight(int index) {
    if (multiCityDepartures.length <= 2) {
      Get.snackbar(
        "Minimum Required",
        "At least 2 flights are required",
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    multiCityDepartures.removeAt(index);
    multiCityArrivals.removeAt(index);
    multiCityDates.removeAt(index);
  }


  // CALENDAR


  void goToCalendar() async {
    final DateTime? result = await Get.to(() => FullCalendarScreen(
      initialStart: selectedDate.value,
      isRangePicker: false,
    ));
    if (result != null) selectedDate.value = result;
  }

  void goToRoundTripCalendar() async {
    final result = await Get.to(() => FullCalendarScreen(
      initialStart: rangeStart.value,
      initialEnd: rangeEnd.value,
      isRangePicker: true,
    ));
    if (result != null && result is Map<String, DateTime?>) {
      rangeStart.value = result['start'];
      rangeEnd.value = result['end'];
    }
  }

  void goToMultiCityCalendar(int index) async {
    final DateTime? result = await Get.to(() => FullCalendarScreen(
      initialStart: multiCityDates[index],
      isRangePicker: false,
    ));
    if (result != null) multiCityDates[index] = result;
  }


  // LOAD ROUND TRIP FLIGHTS


  void loadRoundTripFlights() {
    selectedOutboundFlight.value = null;
    selectedReturnFlight.value = null;
  }

  void clearFlightSelection() {
    selectedOutboundFlight.value = null;
    selectedReturnFlight.value = null;
  }

  // VALIDATION BEFORE PASSENGER PAGE


  bool canContinueToPassenger() {
    if (isRoundTrip) {
      return selectedOutboundFlight.value != null &&
          selectedReturnFlight.value != null;
    } else {
      return selectedOutboundFlight.value != null;
    }
  }
  // UI HELPERS (UNCHANGED)

  Widget buildLocationField({
    required IconData icon,
    required String label,
    bool isPlaceholder = false,
  }) {
    return Row(
      children: [
        Icon(icon, color: Colors.grey[700]),
        const SizedBox(width: 12),
        Text(
          label,
          style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w500,
            color: isPlaceholder ? Colors.grey[400] : Colors.black,
          ),
        ),
      ],
    );
  }

  Widget buildLineReversField({int? index, bool isMultiCity = false}) {
    return Row(
      children: [
        Expanded(child: Container(height: 1, color: Colors.grey[300])),
        const SizedBox(width: 8),
        GestureDetector(
          onTap: () {
            if (isMultiCity && index != null) {
              swapMultiCity(index);
            } else {
              swapCities();
            }
          },
          child: Container(
            height: 30,
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border.all(color: Colors.grey[300]!),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(
              Icons.swap_vert,
              color: Color(0xFFFFC107),
              size: 20,
            ),
          ),
        ),
      ],
    );
  }

  Widget buildDividerField() =>
      const Divider(color: Colors.grey, thickness: 0.3);


  late AnimationController animationController;
  final PageController pageController = PageController();

  @override
  void onInit() {
    super.onInit();
    animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    loadRoundTripFlights();
  }

  @override
  void onClose() {
    pageController.dispose();
    animationController.dispose();
    super.onClose();
  }
}