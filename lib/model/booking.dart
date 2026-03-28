import 'flight.dart';
class SearchParams {
  final String from;
  final String to;

  // One-way date
  final DateTime? date;

  // Round-trip dates
  final DateTime? departureDate;
  final DateTime? returnDate;
  Flight? selectedOutboundFlight;
  Flight? selectedReturnFlight;
  final int adults;
  final int children;
  final int infants;
  final String cabinClass;
  final String tripType; // 'One-way' or 'Round-trip'
  final bool includeHotel;

  SearchParams({
    required this.from,
    required this.to,
    this.date,
    this.departureDate,
    this.returnDate,
    this.adults = 1,
    this.children = 0,
    this.infants = 0,
    this.cabinClass = 'Economy',
    this.tripType = 'One-way',
    this.includeHotel = false,
  });

  //Helper: Get effective departure date
  DateTime? get effectiveDepartureDate {
    if (tripType == 'Round-trip') {
      return departureDate;
    }
    return date;
  }


  //Helper: Check if round trip
  bool get isRoundTrip => tripType == 'Round-trip';
}


// PASSENGER MODEL

class Passenger {
  final String firstName;
  final String lastName;
  final String type; // Adult / Child / Infant

  Passenger({
    required this.firstName,
    required this.lastName,
    this.type = 'Adult',
  });
}
// BOOKING DATA (Main Booking State)

class BookingData {
  SearchParams? searchParams;

  // One-way flight
  Flight? selectedFlight;

  // Round-trip flights
  Flight? selectedOutboundFlight;
  Flight? selectedReturnFlight;

  FareType? selectedFare;

  List<Passenger> passengers = [];

  String? contactName;
  String? phoneNumber;
  String? email;

  String? selectedInsurance;
  String? selectedSeat;

  List<String> addOns = [];
  double get totalPrice {
    double base = 0;

    // One-way
    if (selectedFlight != null) {
      base += selectedFlight!.price;
    }

    // Round-trip
    if (selectedOutboundFlight != null) {
      base += selectedOutboundFlight!.price;
    }

    if (selectedReturnFlight != null) {
      base += selectedReturnFlight!.price;
    }

    // Fare price (if separate pricing model)
    if (selectedFare != null) {
      base += selectedFare!.price;
    }

    // Insurance
    if (selectedInsurance == 'travel') base += 35.03;
    if (selectedInsurance == 'cancellation') base += 25.70;

    return base;
  }

  // Clear booking
  void reset() {
    searchParams = null;
    selectedFlight = null;
    selectedOutboundFlight = null;
    selectedReturnFlight = null;
    selectedFare = null;
    passengers.clear();
    contactName = null;
    phoneNumber = null;
    email = null;
    selectedInsurance = null;
    selectedSeat = null;
    addOns.clear();
  }
}