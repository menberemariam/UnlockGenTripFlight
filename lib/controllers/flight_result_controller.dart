// controllers/flight_result_controller.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../model/cheap_best_flight.dart';

enum SortOption { recommended, cheapest, nonstopFirst }

class FlightResultsController extends GetxController {
  final String destination;
  final selectedDate = DateTime(2026, 2, 20).obs;

  // Filters
  final nonstopOnly = false.obs;
  final baggageIncluded = false.obs;
  final maxStops = 0.obs; // 0 = nonstop only, 1 = up to 1 stop, etc.
  final selectedStopoverCities = <String>[].obs;
  final selectedDepartureAirports = <String>[].obs;
  final selectedArrivalAirports = <String>[].obs;
  final selectedAirlines = <String>[].obs;
  final selectedAircraftTypes = <String>[].obs;
  final selectedCabins = <String>[].obs;
  final departureTimeRange = RangeValues(0, 24).obs;
  final arrivalTimeRange = RangeValues(0, 24).obs;
  final stopoverDurationRange = RangeValues(30, 690).obs;
  final tripDurationRange = RangeValues(120, 1020).obs;

  final sortBy = SortOption.recommended.obs; // default to recommended
  final _allFlights = <CheapBestFlight>[].obs;

  FlightResultsController({required this.destination});

  @override
  void onInit() {
    super.onInit();
    _loadDummyFlights();
  }

  void _loadDummyFlights() {
    _allFlights.assignAll([
      // Flights to Sapporo on Feb 20
      CheapBestFlight(
        departureTime: "07:30",
        arrivalTime: "09:50",
        duration: "2h 20m",
        price: 45,
        airline: "Peach Aviation",
        aircraft: "Airbus A320",
        departureCode: "NRT",
        arrivalCode: "CTS",
        destinationCity: "Sapporo",
        date: DateTime(2026, 2, 20),
        stops: 0,
        isNonstop: true,
        hasCheckedBaggage: false,
        co2: 120, // added for recommended sort
      ),
      CheapBestFlight(
        departureTime: "06:25",
        arrivalTime: "08:55",
        duration: "2h 30m",
        price: 47,
        airline: "Jetstar Japan",
        aircraft: "Airbus A320",
        departureCode: "NRT",
        arrivalCode: "CTS",
        destinationCity: "Sapporo",
        date: DateTime(2026, 2, 20),
        stops: 1,
        stopoverCities: ["Osaka"],
        isNonstop: false,
        hasCheckedBaggage: true,
        co2: 150,
      ),
      // Flights to Osaka on Feb 20
      CheapBestFlight(
        departureTime: "08:05",
        arrivalTime: "10:25",
        duration: "2h 20m",
        price: 51,
        airline: "Jetstar Japan",
        aircraft: "Airbus A320",
        departureCode: "NRT",
        arrivalCode: "ITM",
        destinationCity: "Osaka",
        date: DateTime(2026, 2, 20),
        stops: 0,
        isNonstop: true,
        hasCheckedBaggage: true,
        co2: 110,
      ),
      // Flights to Fukuoka on Feb 20
      CheapBestFlight(
        departureTime: "09:00",
        arrivalTime: "11:20",
        duration: "2h 20m",
        price: 55,
        airline: "Peach Aviation",
        aircraft: "Airbus A320",
        departureCode: "NRT",
        arrivalCode: "FUK",
        destinationCity: "Fukuoka",
        date: DateTime(2026, 2, 20),
        stops: 0,
        isNonstop: true,
        hasCheckedBaggage: true,
        co2: 115,
      ),
      CheapBestFlight(
        departureTime: "10:30",
        arrivalTime: "13:50",
        duration: "3h 20m",
        price: 68,
        airline: "Jetstar Japan",
        aircraft: "Airbus A320",
        departureCode: "NRT",
        arrivalCode: "FUK",
        destinationCity: "Fukuoka",
        date: DateTime(2026, 2, 20),
        stops: 0,
        isNonstop: true,
        hasCheckedBaggage: true,
        co2: 180,
      ),
      // Flights to Okinawa on Feb 20
      CheapBestFlight(
        departureTime: "11:15",
        arrivalTime: "14:35",
        duration: "3h 20m",
        price: 72,
        airline: "ANA",
        aircraft: "Boeing 787",
        departureCode: "HND",
        arrivalCode: "OKA",
        destinationCity: "Okinawa",
        date: DateTime(2026, 2, 20),
        stops: 0,
        isNonstop: true,
        hasCheckedBaggage: true,
        co2: 200,
      ),
      // Flights to Sapporo on Feb 21 (different date)
      CheapBestFlight(
        departureTime: "07:30",
        arrivalTime: "09:50",
        duration: "2h 20m",
        price: 49,
        airline: "Peach Aviation",
        aircraft: "Airbus A320",
        departureCode: "NRT",
        arrivalCode: "CTS",
        destinationCity: "Sapporo",
        date: DateTime(2026, 2, 21),
        stops: 0,
        isNonstop: true,
        hasCheckedBaggage: false,
        co2: 120,
      ),
      CheapBestFlight(
        departureTime: "06:25",
        arrivalTime: "08:55",
        duration: "2h 30m",
        price: 50,
        airline: "Jetstar Japan",
        aircraft: "Airbus A320",
        departureCode: "NRT",
        arrivalCode: "CTS",
        destinationCity: "Sapporo",
        date: DateTime(2026, 2, 21),
        stops: 1,
        stopoverCities: ["Osaka"],
        isNonstop: false,
        hasCheckedBaggage: true,
        co2: 150,
      ),
      // Flights to Fukuoka on Feb 21
      CheapBestFlight(
        departureTime: "09:00",
        arrivalTime: "11:20",
        duration: "2h 20m",
        price: 58,
        airline: "Peach Aviation",
        aircraft: "Airbus A320",
        departureCode: "NRT",
        arrivalCode: "FUK",
        destinationCity: "Fukuoka",
        date: DateTime(2026, 2, 21),
        stops: 0,
        isNonstop: true,
        hasCheckedBaggage: true,
        co2: 115,
      ),
    ]);
  }

  List<CheapBestFlight> get displayedFlights {
    var list = _allFlights.where((f) => f.destinationCity == destination).toList();

    // Filter by selected date
    list = list.where((f) =>
    f.date.year == selectedDate.value.year &&
        f.date.month == selectedDate.value.month &&
        f.date.day == selectedDate.value.day).toList();

    // Apply filters
    if (nonstopOnly.value) list = list.where((f) => f.isNonstop).toList();
    if (baggageIncluded.value) list = list.where((f) => f.hasCheckedBaggage).toList();
    if (maxStops.value >= 0) {
      list = list.where((f) => f.stops <= maxStops.value).toList();
    }
    if (selectedStopoverCities.isNotEmpty) {
      list = list.where((f) =>
          f.stopoverCities.any((city) => selectedStopoverCities.contains(city))).toList();
    }
    if (selectedDepartureAirports.isNotEmpty) {
      list = list.where((f) => selectedDepartureAirports.contains(f.departureCode)).toList();
    }
    if (selectedArrivalAirports.isNotEmpty) {
      list = list.where((f) => selectedArrivalAirports.contains(f.arrivalCode)).toList();
    }
    if (selectedAirlines.isNotEmpty) {
      list = list.where((f) => selectedAirlines.contains(f.airline)).toList();
    }
    // Aircraft type and cabin filters would require additional fields; omitted for simplicity.

    // Sorting
    switch (sortBy.value) {
      case SortOption.cheapest:
        list.sort((a, b) => a.price.compareTo(b.price));
        break;
      case SortOption.nonstopFirst:
        list.sort((a, b) {
          if (a.isNonstop && !b.isNonstop) return -1;
          if (!a.isNonstop && b.isNonstop) return 1;
          return a.price.compareTo(b.price);
        });
        break;
      case SortOption.recommended:
      // Recommended: lower price, shorter duration, lower CO2 – weighted score
        list.sort((a, b) {
          final scoreA = a.price * 0.4 + a.durationInMinutes * 0.3 + (a.co2 ?? 0) * 0.3;
          final scoreB = b.price * 0.4 + b.durationInMinutes * 0.3 + (b.co2 ?? 0) * 0.3;
          return scoreA.compareTo(scoreB);
        });
        break;
    }
    return list;
  }

  void changeDate(DateTime newDate) => selectedDate.value = newDate;

  void toggleNonstop() => nonstopOnly.toggle();
  void toggleBaggage() => baggageIncluded.toggle();
  void setSortMode(SortOption mode) => sortBy.value = mode;

  // Filter update methods
  void updateMaxStops(int stops) => maxStops.value = stops;
  void updateStopoverCities(List<String> cities) => selectedStopoverCities.assignAll(cities);
  void updateDepartureAirports(List<String> airports) => selectedDepartureAirports.assignAll(airports);
  void updateArrivalAirports(List<String> airports) => selectedArrivalAirports.assignAll(airports);
  void updateAirlines(List<String> airlines) => selectedAirlines.assignAll(airlines);
  void updateAircraftTypes(List<String> types) => selectedAircraftTypes.assignAll(types);
  void updateCabins(List<String> cabins) => selectedCabins.assignAll(cabins);
  void updateDepartureTimeRange(RangeValues range) => departureTimeRange.value = range;
  void updateArrivalTimeRange(RangeValues range) => arrivalTimeRange.value = range;
  void updateStopoverDurationRange(RangeValues range) => stopoverDurationRange.value = range;
  void updateTripDurationRange(RangeValues range) => tripDurationRange.value = range;

  void resetAllFilters() {
    nonstopOnly(false);
    baggageIncluded(false);
    maxStops(0);
    selectedStopoverCities.clear();
    selectedDepartureAirports.clear();
    selectedArrivalAirports.clear();
    selectedAirlines.clear();
    selectedAircraftTypes.clear();
    selectedCabins.clear();
    departureTimeRange(RangeValues(0, 24));
    arrivalTimeRange(RangeValues(0, 24));
    stopoverDurationRange(RangeValues(30, 690));
    tripDurationRange(RangeValues(120, 1020));
  }
}