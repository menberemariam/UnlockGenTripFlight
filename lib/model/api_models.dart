// =============================================================================
//  API Models — mapped directly from Postman response structures
//
//  SHOPPING RESPONSE (STEP 2):
//  data.qrFlights.offers[] → List<ApiOffer>
//
//  Each ApiOffer:
//    offerId          → unique offer ID used in offer-price & hold
//    provider         → airline provider code (e.g. "CP")
//    priceClassName   → fare class name (e.g. "ECONOMY")
//    flights[]        → List<ApiFlightJourney>
//                       flights[0] = outbound leg
//                       flights[1] = return leg (round-trip only)
//    pricing          → ApiPricing { total, baseFare, taxes, currency }
//    baggageServices  → List<ApiBaggageService>
//    ruleSet          → { ticketTimeLimit, penaltyInfo }
//
//  Each ApiFlightJourney (one leg):
//    originCode       → e.g. "DXB"
//    destinationCode  → e.g. "ADD"
//    duration         → ISO 8601 e.g. "PT4H20M" → formatted "4h 20m"
//    productId        → used in itineraryIdList for offer-price & hold
//    segments[]       → List<ApiSegment> (one per flight segment/stop)
//
//  Each ApiSegment (one flight segment):
//    airlineCode          → e.g. "ET"
//    airlineName          → e.g. "Ethiopian Airlines"
//    operatingAirlineCode → e.g. "ET"  (used to filter ET-only offers)
//    flightNumber         → e.g. "613"
//    departureAirport     → IATA code e.g. "DXB"
//    departureAirportName → full name e.g. "Dubai Intl."
//    arrivalAirport       → IATA code e.g. "ADD"
//    arrivalAirportName   → full name e.g. "Addis Ababa"
//    departureDateTime    → e.g. "2026-04-25T05:40:00"
//    arrivalDateTime      → e.g. "2026-04-25T09:00:00"
//    classOfService       → e.g. "Q" (RBD code)
//    rbd                  → same as classOfService
//
//  ApiPricing:
//    total    → full price per passenger (e.g. 911.22)
//    baseFare → base fare before taxes (e.g. 609.00)
//    taxes    → tax amount (e.g. 302.22)
//    currency → e.g. "EUR"
//
//  ApiBaggageService:
//    typeCode       → e.g. "Checked"
//    totalQuantity  → e.g. 2
//    description    → e.g. "2 PC"
// =============================================================================

// ─── ApiOffer ─────────────────────────────────────────────────────────────────
// Maps to: data.qrFlights.offers[] in STEP 2 shopping response

class ApiOffer {
  /// Unique offer ID — used as executionId in STEP 3 (offer-price)
  final String offerId;

  /// Provider code — e.g. "CP" — used in all subsequent API calls
  final String provider;

  /// Flight legs: [0]=outbound, [1]=return (round-trip only)
  final List<ApiFlightJourney> flights;

  /// Pricing: total, baseFare, taxes, currency
  final ApiPricing pricing;

  /// Fare class name — e.g. "ECONOMY"
  final String priceClassName;

  /// Baggage allowances — e.g. [{ typeCode:"Checked", totalQuantity:2, description:"2 PC" }]
  final List<ApiBaggageService> baggageServices;

  /// Fare features/descriptions from priceClassDescriptions[]
  final List<ApiPriceClassDescription> priceClassDescriptions;

  /// True if this offer matches data.qrFlights.cheapestOffer.offerId
  final bool isCheapest;

  /// From ruleSet.ticketTimeLimit — deadline to issue ticket
  final String? ticketTimeLimit;

  /// From ruleSet.penaltyInfo — cancellation/change penalty info
  final String? penaltyInfo;

  ApiOffer({
    required this.offerId,
    required this.provider,
    required this.flights,
    required this.pricing,
    required this.priceClassName,
    required this.baggageServices,
    required this.priceClassDescriptions,
    this.isCheapest = false,
    this.ticketTimeLimit,
    this.penaltyInfo,
  });

  factory ApiOffer.fromJson(Map<String, dynamic> json, {bool isCheapest = false}) {
    final ruleSet = json['ruleSet'] as Map<String, dynamic>?;
    return ApiOffer(
      offerId:              json['offerId']       ?? '',
      provider:             json['provider']      ?? '',
      flights:              (json['flights'] as List? ?? [])
                                .map((f) => ApiFlightJourney.fromJson(f)).toList(),
      pricing:              ApiPricing.fromJson(json['pricing'] ?? {}),
      priceClassName:       json['priceClassName'] ?? '',
      baggageServices:      (json['baggageServices'] as List? ?? [])
                                .map((b) => ApiBaggageService.fromJson(b)).toList(),
      priceClassDescriptions: (json['priceClassDescriptions'] as List? ?? [])
                                .map((d) => ApiPriceClassDescription.fromJson(d)).toList(),
      isCheapest:           isCheapest,
      ticketTimeLimit:      ruleSet?['ticketTimeLimit'] as String?,
      penaltyInfo:          ruleSet?['penaltyInfo']     as String?,
    );
  }

  // ── Convenience getters ────────────────────────────────────────────────────

  /// Outbound leg — flights[0]
  ApiFlightJourney? get outboundFlight =>
      flights.isNotEmpty ? flights.first : null;

  /// Return leg — flights[1] (round-trip only, null for one-way)
  ApiFlightJourney? get returnFlight =>
      flights.length > 1 ? flights[1] : null;

  /// First segment of outbound leg
  ApiSegment? get firstSegment =>
      outboundFlight?.segments.isNotEmpty == true
          ? outboundFlight!.segments.first : null;

  /// Airline name from first segment — e.g. "Ethiopian Airlines"
  String get airlineName => firstSegment?.airlineName ?? '';

  /// Departure time of outbound — e.g. "05:40"
  String get departureTime {
    final dt = firstSegment?.departureDateTime;
    if (dt == null) return '';
    return '${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
  }

  /// Arrival time of outbound last segment — e.g. "09:00"
  String get arrivalTime {
    final dt = outboundFlight?.segments.last.arrivalDateTime;
    if (dt == null) return '';
    return '${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
  }

  /// Formatted duration of outbound — e.g. "4h 20m"
  String get duration => outboundFlight?.formattedDuration ?? '';

  /// Origin IATA code — e.g. "DXB"
  String get originCode => outboundFlight?.originCode ?? '';

  /// Destination IATA code — e.g. "ADD"
  String get destinationCode => outboundFlight?.destinationCode ?? '';

  /// First baggage description — e.g. "2 PC"
  String get baggageInfo =>
      baggageServices.isNotEmpty ? baggageServices.first.description : '';
}

// ─── ApiFlightJourney ─────────────────────────────────────────────────────────
// One flight leg (outbound or return)
// Maps to: offer.flights[] in shopping response

class ApiFlightJourney {
  final String paxJourneyRefId;

  /// ISO 8601 duration — e.g. "PT4H20M"
  final String duration;

  /// Origin IATA code — e.g. "DXB"
  final String originCode;

  /// Destination IATA code — e.g. "ADD"
  final String destinationCode;

  /// Flight segments (one per stop — direct flight has 1 segment)
  final List<ApiSegment> segments;

  /// Used in itineraryIdList for offer-price & hold API calls
  final String productId;

  ApiFlightJourney({
    required this.paxJourneyRefId,
    required this.duration,
    required this.originCode,
    required this.destinationCode,
    required this.segments,
    required this.productId,
  });

  factory ApiFlightJourney.fromJson(Map<String, dynamic> json) {
    return ApiFlightJourney(
      paxJourneyRefId: json['paxJourneyRefId'] ?? '',
      duration:        json['duration']        ?? '',
      originCode:      json['originCode']      ?? '',
      destinationCode: json['destinationCode'] ?? '',
      segments:        (json['segments'] as List? ?? [])
                           .map((s) => ApiSegment.fromJson(s)).toList(),
      productId:       json['productId']       ?? '',
    );
  }

  /// Converts ISO 8601 duration to readable string
  /// e.g. "PT4H20M" → "4h 20m"
  String get formattedDuration {
    final match = RegExp(r'PT(?:(\d+)H)?(?:(\d+)M)?').firstMatch(duration);
    if (match == null) return duration;
    return '${match.group(1) ?? '0'}h ${match.group(2) ?? '0'}m';
  }
}

// ─── ApiSegment ───────────────────────────────────────────────────────────────
// One flight segment (one takeoff/landing pair)
// Maps to: offer.flights[].segments[] in shopping response
// Also maps to: holdBookingResponse.segments[] in confirm response

class ApiSegment {
  /// Marketing carrier code — e.g. "ET"
  final String airlineCode;

  /// Marketing carrier name — e.g. "Ethiopian Airlines"
  final String airlineName;

  /// Operating carrier code — e.g. "ET"
  /// Used to filter ET-only offers (they work reliably with hold API)
  final String operatingAirlineCode;

  /// Flight number — e.g. "613"
  final String flightNumber;

  /// Departure airport IATA — e.g. "DXB"
  final String departureAirport;

  /// Departure airport full name — e.g. "Dubai Intl."
  final String departureAirportName;

  /// Arrival airport IATA — e.g. "ADD"
  final String arrivalAirport;

  /// Arrival airport full name — e.g. "Addis Ababa"
  final String arrivalAirportName;

  /// Departure date/time — e.g. "2026-04-25T05:40:00"
  final DateTime? departureDateTime;

  /// Arrival date/time — e.g. "2026-04-25T09:00:00"
  final DateTime? arrivalDateTime;

  /// Booking class / RBD code — e.g. "Q"
  final String classOfService;

  /// Same as classOfService
  final String rbd;

  ApiSegment({
    required this.airlineCode,
    required this.airlineName,
    required this.operatingAirlineCode,
    required this.flightNumber,
    required this.departureAirport,
    required this.departureAirportName,
    required this.arrivalAirport,
    required this.arrivalAirportName,
    this.departureDateTime,
    this.arrivalDateTime,
    required this.classOfService,
    required this.rbd,
  });

  factory ApiSegment.fromJson(Map<String, dynamic> json) {
    return ApiSegment(
      airlineCode:          json['airlineCode']          ?? '',
      airlineName:          json['airlineName']          ?? '',
      operatingAirlineCode: json['operatingArlineCode']  ?? '', // note: typo in API
      flightNumber:         json['flightNumber']         ?? '',
      departureAirport:     json['departureAirport']     ?? '',
      departureAirportName: json['departureAirportName'] ?? '',
      arrivalAirport:       json['arrivalAirport']       ?? '',
      arrivalAirportName:   json['arrivalAirportName']   ?? '',
      departureDateTime:    json['departureDateTime'] != null
                                ? DateTime.tryParse(json['departureDateTime']) : null,
      arrivalDateTime:      json['arrivalDateTime'] != null
                                ? DateTime.tryParse(json['arrivalDateTime']) : null,
      classOfService:       json['classOfService'] ?? '',
      rbd:                  json['rbd']            ?? '',
    );
  }
}

// ─── ApiPricing ───────────────────────────────────────────────────────────────
// Maps to: offer.pricing in shopping response
// Also maps to: holdBookingResponse.pricing in confirm response

class ApiPricing {
  /// Total price per passenger including taxes — e.g. 911.22
  final double total;

  /// Base fare before taxes — e.g. 609.00
  final double baseFare;

  /// Total taxes — e.g. 302.22
  final double taxes;

  /// Currency code — e.g. "EUR"
  final String currency;

  ApiPricing({
    required this.total,
    required this.baseFare,
    required this.taxes,
    required this.currency,
  });

  factory ApiPricing.fromJson(Map<String, dynamic> json) {
    return ApiPricing(
      total:    (json['total']    ?? 0).toDouble(),
      baseFare: (json['baseFare'] ?? 0).toDouble(),
      taxes:    (json['taxes']    ?? 0).toDouble(),
      currency:  json['currency'] ?? 'EUR',
    );
  }
}

// ─── ApiBaggageService ────────────────────────────────────────────────────────
// Maps to: offer.baggageServices[] in shopping response
// Example from Postman: { typeCode:"Checked", totalQuantity:2, description:"2 PC" }

class ApiBaggageService {
  /// e.g. "Checked"
  final String typeCode;

  /// e.g. 2
  final int totalQuantity;

  /// e.g. "2 PC" — shown on flight card
  final String description;

  ApiBaggageService({
    required this.typeCode,
    required this.totalQuantity,
    required this.description,
  });

  factory ApiBaggageService.fromJson(Map<String, dynamic> json) {
    return ApiBaggageService(
      typeCode:      json['typeCode']      ?? '',
      totalQuantity: json['totalQuantity'] ?? 0,
      description:   json['description']  ?? '',
    );
  }
}

// ─── ApiPriceClassDescription ─────────────────────────────────────────────────
// Maps to: offer.priceClassDescriptions[] in shopping response
// Contains fare feature descriptions shown on fare selection screen

class ApiPriceClassDescription {
  final String descId;

  /// Feature text — e.g. "Carry-on baggage: 1 × 7 kg"
  final String descText;

  ApiPriceClassDescription({required this.descId, required this.descText});

  factory ApiPriceClassDescription.fromJson(Map<String, dynamic> json) {
    return ApiPriceClassDescription(
      descId:   json['descId']   ?? '',
      descText: json['descText'] ?? '',
    );
  }
}

// ─── ShoppingResponse ─────────────────────────────────────────────────────────
// Parses the full STEP 2 shopping API response
// Response path: data.qrFlights.offers[]
//
// Sorting: ET (Ethiopian Airlines) offers sorted first
// because they work reliably with the hold API.
// Other airlines may cause "Segment sell failed" on STEP 4.

class ShoppingResponse {
  final List<ApiOffer> offers;

  /// Total offers count from API — data.qrFlights.totalOffers
  final int totalOffers;

  /// Cheapest offer — data.qrFlights.cheapestOffer
  final ApiOffer? cheapestOffer;

  ShoppingResponse({
    required this.offers,
    required this.totalOffers,
    this.cheapestOffer,
  });

  factory ShoppingResponse.fromJson(Map<String, dynamic> json) {
    final data = json['data'] as Map<String, dynamic>?;
    final qr   = data?['qrFlights'] as Map<String, dynamic>? ?? {};

    final cheapestId = (qr['cheapestOffer'] as Map<String, dynamic>?)?['offerId'];

    // Primary path: data.qrFlights.offers
    List<dynamic> offersList = qr['offers'] as List? ?? [];
    // Fallback: data.offers
    if (offersList.isEmpty) offersList = data?['offers'] as List? ?? [];
    // Fallback: root offers
    if (offersList.isEmpty) offersList = json['offers'] as List? ?? [];

    final allOffers = offersList
        .map((o) => ApiOffer.fromJson(o as Map<String, dynamic>,
            isCheapest: o['offerId'] == cheapestId))
        .toList();

    // Sort ET first (reliable hold API), then by price ascending
    allOffers.sort((a, b) {
      final aET = a.flights.any((f) => f.segments.any((s) => s.operatingAirlineCode == 'ET'));
      final bET = b.flights.any((f) => f.segments.any((s) => s.operatingAirlineCode == 'ET'));
      if (aET && !bET) return -1;
      if (!aET && bET) return 1;
      return a.pricing.total.compareTo(b.pricing.total);
    });

    return ShoppingResponse(
      offers:       allOffers,
      totalOffers:  (qr['totalOffers'] as int?) ?? allOffers.length,
      cheapestOffer: qr['cheapestOffer'] != null
          ? ApiOffer.fromJson(qr['cheapestOffer'] as Map<String, dynamic>)
          : null,
    );
  }
}
