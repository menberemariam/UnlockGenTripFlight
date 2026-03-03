import 'flight.dart';

class SearchParams {
  final String from;
  final String to;
  final DateTime date;
  final int adults;
  final int children;
  final int infants;
  final String cabinClass;
  final String tripType;
  final bool includeHotel;

  SearchParams({
    required this.from,
    required this.to,
    required this.date,
    this.adults = 1,
    this.children = 0,
    this.infants = 0,
    this.cabinClass = 'Economy',
    this.tripType = 'One-way',
    this.includeHotel = false,
  });
}

class Passenger {
  final String firstName;
  final String lastName;
  final String type;

  Passenger({
    required this.firstName,
    required this.lastName,
    this.type = 'Adult',
  });
}

class BookingData {
  SearchParams? searchParams;
  Flight? selectedFlight;
  FareType? selectedFare;
  List<Passenger> passengers = [];
  String? contactName;
  String? phoneNumber;
  String? email;
  String? selectedInsurance;
  String? selectedSeat;
  List<String> addOns = [];

  double get totalPrice {
    double base = selectedFare?.price ?? 0;
    if (selectedInsurance == 'travel') base += 35.03;
    if (selectedInsurance == 'cancellation') base += 25.70;
    return base;
  }
}
