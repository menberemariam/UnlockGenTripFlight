import 'package:get/get.dart';

enum SortOption {
  recommended,
  cheapest,
  nonstopFirst,
}

class FlightResultsController extends GetxController {
  // Date Selection
  final selectedDate = Rx<DateTime>(DateTime(2026, 2, 20));

  // Filters
  final nonstopOnly = false.obs;
  final baggageIncluded = false.obs;

  // Sorting
  final sortBy = SortOption.cheapest.obs;

  // Flight data (dummy)
  final _allFlights = <Flight>[].obs;

  @override
  void onInit() {
    super.onInit();
    _loadDummyFlights();
  }

  void _loadDummyFlights() {
    _allFlights.assignAll([
      Flight(
        departureTime: "07:30",
        arrivalTime: "09:50",
        duration: "2h 20m",
        price: 45,
        airline: "Peach Aviation",
        aircraft: "Airbus A320",
        departureCode: "NRT T1",
        arrivalCode: "FUK D",
        isNonstop: true,
        hasCheckedBaggage: false,
      ),
      Flight(
        departureTime: "06:25",
        arrivalTime: "08:55",
        duration: "2h 30m",
        price: 47,
        airline: "Jetstar Japan",
        aircraft: "Airbus A320",
        departureCode: "NRT T3",
        arrivalCode: "FUK D",
        isNonstop: true,
        hasCheckedBaggage: true,
      ),
      Flight(
        departureTime: "07:15",
        arrivalTime: "09:45",
        duration: "2h 30m",
        price: 47,
        airline: "Jetstar Japan",
        aircraft: "Airbus A320",
        departureCode: "NRT T3",
        arrivalCode: "FUK D",
        isNonstop: true,
        hasCheckedBaggage: false,
      ),
      Flight(
        departureTime: "08:05",
        arrivalTime: "10:25",
        duration: "2h 20m",
        price: 51,
        airline: "Jetstar Japan",
        aircraft: "Airbus A320",
        departureCode: "NRT T3",
        arrivalCode: "FUK D",
        isNonstop: true,
        hasCheckedBaggage: true,
      ),
      Flight(
        departureTime: "05:40",
        arrivalTime: "12:15",
        duration: "6h 35m",
        price: 89,
        airline: "ANA",
        aircraft: "Boeing 787",
        departureCode: "HND",
        arrivalCode: "FUK",
        isNonstop: false,
        hasCheckedBaggage: true,
      ),
    ]);
  }

  // Computed: filtered & sorted flights
  List<Flight> get displayedFlights {
    var list = _allFlights.toList();

    // Filters
    if (nonstopOnly.value) {
      list = list.where((f) => f.isNonstop).toList();
    }
    if (baggageIncluded.value) {
      list = list.where((f) => f.hasCheckedBaggage).toList();
    }

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
        list.sort((a, b) => (a.price + a.durationInMinutes * 0.5)
            .compareTo(b.price + b.durationInMinutes * 0.5));
        break;
    }

    return list;
  }

  // Actions
  void changeDate(DateTime newDate) {
    selectedDate.value = newDate;
    // → Here you would typically trigger a new flight search in a real app
  }

  void toggleNonstop() => nonstopOnly.toggle();

  void toggleBaggage() => baggageIncluded.toggle();

  void setSortMode(SortOption mode) {
    sortBy.value = mode;
  }
}

// Flight model
class Flight {
  final String departureTime;
  final String arrivalTime;
  final String duration;
  final int price;
  final String airline;
  final String aircraft;
  final String departureCode;
  final String arrivalCode;
  final bool isNonstop;
  final bool hasCheckedBaggage;

  int get durationInMinutes {
    final parts = duration.split(RegExp(r'(\d+)'));
    int minutes = 0;
    for (int i = 0; i < parts.length; i++) {
      if (parts[i].isNotEmpty) {
        final num = int.tryParse(parts[i]) ?? 0;
        if (duration.contains('h') && i < parts.length - 1) {
          minutes += num * 60;
        } else {
          minutes += num;
        }
      }
    }
    return minutes;
  }

  Flight({
    required this.departureTime,
    required this.arrivalTime,
    required this.duration,
    required this.price,
    required this.airline,
    required this.aircraft,
    required this.departureCode,
    required this.arrivalCode,
    this.isNonstop = true,
    this.hasCheckedBaggage = false,
  });
}