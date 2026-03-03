// models/flight.dart
class CheapBestFlight {
  final String departureTime;
  final String arrivalTime;
  final String duration;
  final int price;
  final String airline;
  final String aircraft;
  final String departureCode;
  final String arrivalCode;
  final String destinationCity;
  final DateTime date;
  final int stops;
  final List<String> stopoverCities;
  final bool isNonstop;
  final bool hasCheckedBaggage;
  final int? co2; // optional CO2 emission value

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

  CheapBestFlight({
    required this.departureTime,
    required this.arrivalTime,
    required this.duration,
    required this.price,
    required this.airline,
    required this.aircraft,
    required this.departureCode,
    required this.arrivalCode,
    required this.destinationCity,
    required this.date,
    this.stops = 0,
    this.stopoverCities = const [],
    this.isNonstop = true,
    this.hasCheckedBaggage = false,
    this.co2,
  });
}