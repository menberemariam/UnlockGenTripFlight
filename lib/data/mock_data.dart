import '../model/flight.dart';

class MockData {
  static List<Flight> getFlights(String from, String to) {
    final routeKey = '$from-$to';
    
    switch (routeKey) {
      case 'Mumbai-Bangkok':
      case 'BOM-BKK':
        return _getMumbaiBangkokFlights();
      case 'Bangkok-Istanbul':
      case 'BKK-IST':
        return _getBangkokIstanbulFlights();
      case 'London-Paris':
      case 'LHR-CDG':
        return _getLondonParisFlights();
      case 'New York-Tokyo':
      case 'JFK-NRT':
        return _getNewYorkTokyoFlights();
      default:
        return _getDefaultFlights(from, to);
    }
  }

  static List<Flight> _getMumbaiBangkokFlights() {
    return [
      Flight(
        id: '1',
        airline: 'Thai Vietjet Air',
        departureTime: '00:55',
        arrivalTime: '06:40',
        departureCode: 'BOM',
        arrivalCode: 'BKK',
        duration: '4h 15m',
        price: 96,
        aircraft: 'Airbus A320',
        carryOnIncluded: true,
      ),
      Flight(
        id: '2',
        airline: 'Thai Airways',
        departureTime: '23:20',
        arrivalTime: '05:05',
        departureCode: 'BOM',
        arrivalCode: 'BKK',
        duration: '4h 15m',
        price: 145,
        aircraft: 'Airbus A330-300',
        carryOnIncluded: true,
        checkedBagIncluded: true,
        co2Reduction: '- 20% CO2e',
      ),
      Flight(
        id: '3',
        airline: 'Thai Airways',
        departureTime: '02:40',
        arrivalTime: '08:25',
        departureCode: 'BOM',
        arrivalCode: 'BKK',
        duration: '4h 15m',
        price: 147,
        aircraft: 'Airbus A320',
        carryOnIncluded: true,
        checkedBagIncluded: true,
      ),
      Flight(
        id: '4',
        airline: 'IndiGo',
        departureTime: '15:10',
        arrivalTime: '21:05',
        departureCode: 'BOM',
        arrivalCode: 'BKK',
        duration: '4h 25m',
        price: 110,
        aircraft: 'Airbus A321neo',
        carryOnIncluded: true,
        checkedBagIncluded: true,
        co2Reduction: '- 25% CO2e',
      ),
    ];
  }

  static List<Flight> _getBangkokIstanbulFlights() {
    return [
      Flight(
        id: '5',
        airline: 'Turkish Airlines',
        departureTime: '01:30',
        arrivalTime: '07:15',
        departureCode: 'BKK',
        arrivalCode: 'IST',
        duration: '10h 45m',
        price: 450,
        aircraft: 'Boeing 777-300ER',
        carryOnIncluded: true,
        checkedBagIncluded: true,
      ),
      Flight(
        id: '6',
        airline: 'Emirates',
        departureTime: '09:20',
        arrivalTime: '16:30',
        departureCode: 'BKK',
        arrivalCode: 'IST',
        duration: '11h 10m',
        price: 520,
        aircraft: 'Airbus A380',
        carryOnIncluded: true,
        checkedBagIncluded: true,
        co2Reduction: '- 15% CO2e',
      ),
      Flight(
        id: '7',
        airline: 'Qatar Airways',
        departureTime: '14:45',
        arrivalTime: '21:20',
        departureCode: 'BKK',
        arrivalCode: 'IST',
        duration: '10h 35m',
        price: 485,
        aircraft: 'Boeing 787-9',
        carryOnIncluded: true,
        checkedBagIncluded: true,
        co2Reduction: '- 18% CO2e',
      ),
    ];
  }

  static List<Flight> _getLondonParisFlights() {
    return [
      Flight(
        id: '8',
        airline: 'British Airways',
        departureTime: '07:00',
        arrivalTime: '09:15',
        departureCode: 'LHR',
        arrivalCode: 'CDG',
        duration: '1h 15m',
        price: 85,
        aircraft: 'Airbus A320',
        carryOnIncluded: true,
      ),
      Flight(
        id: '9',
        airline: 'Air France',
        departureTime: '11:30',
        arrivalTime: '13:45',
        departureCode: 'LHR',
        arrivalCode: 'CDG',
        duration: '1h 15m',
        price: 92,
        aircraft: 'Airbus A319',
        carryOnIncluded: true,
        checkedBagIncluded: true,
      ),
      Flight(
        id: '10',
        airline: 'EasyJet',
        departureTime: '16:20',
        arrivalTime: '18:35',
        departureCode: 'LHR',
        arrivalCode: 'CDG',
        duration: '1h 15m',
        price: 68,
        aircraft: 'Airbus A320',
        carryOnIncluded: true,
      ),
    ];
  }

  static List<Flight> _getNewYorkTokyoFlights() {
    return [
      Flight(
        id: '11',
        airline: 'Japan Airlines',
        departureTime: '13:00',
        arrivalTime: '16:30',
        departureCode: 'JFK',
        arrivalCode: 'NRT',
        duration: '14h 30m',
        price: 850,
        aircraft: 'Boeing 787-9',
        carryOnIncluded: true,
        checkedBagIncluded: true,
        co2Reduction: '- 22% CO2e',
      ),
      Flight(
        id: '12',
        airline: 'ANA',
        departureTime: '17:45',
        arrivalTime: '21:15',
        departureCode: 'JFK',
        arrivalCode: 'NRT',
        duration: '14h 30m',
        price: 820,
        aircraft: 'Boeing 777-300ER',
        carryOnIncluded: true,
        checkedBagIncluded: true,
      ),
      Flight(
        id: '13',
        airline: 'United Airlines',
        departureTime: '10:30',
        arrivalTime: '14:00',
        departureCode: 'JFK',
        arrivalCode: 'NRT',
        duration: '14h 30m',
        price: 780,
        aircraft: 'Boeing 787-10',
        carryOnIncluded: true,
        checkedBagIncluded: true,
        co2Reduction: '- 20% CO2e',
      ),
    ];
  }

  static List<Flight> _getDefaultFlights(String from, String to) {
    return [
      Flight(
        id: 'default1',
        airline: 'International Airways',
        departureTime: '10:00',
        arrivalTime: '14:00',
        departureCode: from,
        arrivalCode: to,
        duration: '4h 00m',
        price: 250,
        aircraft: 'Boeing 737',
        carryOnIncluded: true,
      ),
      Flight(
        id: 'default2',
        airline: 'Global Airlines',
        departureTime: '15:30',
        arrivalTime: '19:30',
        departureCode: from,
        arrivalCode: to,
        duration: '4h 00m',
        price: 280,
        aircraft: 'Airbus A320',
        carryOnIncluded: true,
        checkedBagIncluded: true,
      ),
      Flight(
        id: 'default3',
        airline: 'Global Airlines',
        departureTime: '15:30',
        arrivalTime: '19:30',
        departureCode: from,
        arrivalCode: to,
        duration: '4h 00m',
        price: 280,
        aircraft: 'Airbus A320',
        carryOnIncluded: true,
        checkedBagIncluded: true,
      ),
      Flight(
        id: 'default4',
        airline: 'Global Airlines',
        departureTime: '15:30',
        arrivalTime: '19:30',
        departureCode: from,
        arrivalCode: to,
        duration: '4h 00m',
        price: 280,
        aircraft: 'Airbus A320',
        carryOnIncluded: true,
        checkedBagIncluded: true,
      ),
      Flight(
        id: 'default5',
        airline: 'Global Airlines',
        departureTime: '15:30',
        arrivalTime: '19:30',
        departureCode: from,
        arrivalCode: to,
        duration: '4h 00m',
        price: 280,
        aircraft: 'Airbus A320',
        carryOnIncluded: true,
        checkedBagIncluded: true,
      ),
      Flight(
        id: 'default6',
        airline: 'Global Airlines',
        departureTime: '15:30',
        arrivalTime: '19:30',
        departureCode: from,
        arrivalCode: to,
        duration: '4h 00m',
        price: 280,
        aircraft: 'Airbus A320',
        carryOnIncluded: true,
        checkedBagIncluded: true,
      ),
    ];
  }

  static List<FareType> getFareTypes() {
    return [
      FareType(
        name: 'Economy',
        price: 559,
        personalItem: true,
        carryOn: true,
        checkedBag: '30 kg',
        refundable: false,
        changeFee: 'from £383',
        benefits: [
          'Free premium seats',
          'Meals and drinks provided',
          'Priority boarding',
          'Airline miles: at least 2,240',
        ],
      ),
      FareType(
        name: 'Premium Economy',
        price: 759,
        personalItem: true,
        carryOn: true,
        checkedBag: '40 kg',
        refundable: true,
        changeFee: 'Free',
        benefits: [
          'Extra legroom',
          'Premium meals',
          'Priority check-in',
          'Lounge access',
          'Airline miles: at least 3,500',
        ],
      ),
    ];
  }

  static Map<String, String> getCityAirportCodes() {
    return {
      'Bangkok': 'BKK',
      'Istanbul': 'IST',
      'Mumbai': 'BOM',
      'London': 'LHR',
      'Paris': 'CDG',
      'New York': 'JFK',
      'Tokyo': 'NRT',
      'Dubai': 'DXB',
      'Singapore': 'SIN',
      'Hong Kong': 'HKG',
    };
  }
}
