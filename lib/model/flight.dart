class Flight {
  final String id;
  final String airline;
  final String departureTime;
  final String arrivalTime;
  final String departureCode;
  final String arrivalCode;
  final String duration;
  final double price;
  final String aircraft;
  final bool carryOnIncluded;
  final bool checkedBagIncluded;
  final String co2Reduction;

  Flight({
    required this.id,
    required this.airline,
    required this.departureTime,
    required this.arrivalTime,
    required this.departureCode,
    required this.arrivalCode,
    required this.duration,
    required this.price,
    required this.aircraft,
    this.carryOnIncluded = false,
    this.checkedBagIncluded = false,
    this.co2Reduction = '',
  });
}

class FareType {
  final String name;
  final double price;
  final bool personalItem;
  final bool carryOn;
  final String checkedBag;
  final bool refundable;
  final String changeFee;
  final List<String> benefits;

  FareType({
    required this.name,
    required this.price,
    required this.personalItem,
    required this.carryOn,
    required this.checkedBag,
    required this.refundable,
    required this.changeFee,
    required this.benefits,
  });
}
