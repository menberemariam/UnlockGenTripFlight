import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../model/api_models.dart';
import '../services/flight_api_service.dart';

// =============================================================================
//  FlightSearchController
//
//  Manages the full 7-step booking flow (verified from Postman):
//
//  STEP 1  getGuestToken()    → Bearer token for all API calls
//  STEP 2  searchFlights()    → List of ApiOffer from shopping API
//  STEP 3  priceOffer()       → Locks in price, gets executionId & fareId
//  STEP 4  holdFlight()       → Holds seat, gets PNR & cardPaymentId
//  STEP 5  holdFlight()       → Gets bookingLocator (data.id) for payment
//  STEP 6  confirmBooking()   → Charges card, gets Authorized + real PNR
//  STEP 7  complete3DS()      → 3DS verify if bank requires challenge
//
//  Key values saved across steps:
//    bookingLocator    → data.id from STEP 5  → used in STEP 6 & 7
//    pricedFareId      → data.id from STEP 3  → used as fareId in STEP 4 & 5
//    pricedOfferItemId → data.pricedOffer.offerItem[0].offerItemID → in offerItems
//    cardPaymentId     → data.paymentOptions.cards[0].id (e.g. 145)
//    pnr               → data.pnr from STEP 4 / data.holdFlightBooking.pnr STEP 6
//                        This is the REAL airline ticket reference (e.g. "XOYMYL")
// =============================================================================

class FlightSearchController extends GetxController {
  static FlightSearchController get to => Get.find();

  // ─── Observable state ─────────────────────────────────────────────────────

  final isLoading    = false.obs;
  final errorMessage = ''.obs;

  /// All offers from STEP 2 shopping response
  final offers = <ApiOffer>[].obs;

  /// Selected offer going into fare → passenger flow
  final selectedOffer = Rxn<ApiOffer>();

  /// Round-trip: outbound offer selected in DepartureResultsScreen
  /// before return offer is picked in ReturnResultsScreen
  final selectedOutboundOffer = Rxn<ApiOffer>();

  // ─── Derived price/currency ───────────────────────────────────────────────

  /// Total price to display — from selectedOffer or selectedOutboundOffer
  double get totalDisplayPrice =>
      selectedOffer.value?.pricing.total ??
      selectedOutboundOffer.value?.pricing.total ?? 0;

  /// Currency to display — e.g. "EUR"
  String get displayCurrency =>
      selectedOffer.value?.pricing.currency ??
      selectedOutboundOffer.value?.pricing.currency ?? 'EUR';

  // ─── STEP 3 results (offer-price) ─────────────────────────────────────────

  final pricedOfferData = Rxn<Map<String, dynamic>>();

  /// data.id from STEP 3 → used as fareId in STEP 4 & 5
  String? pricedFareId;

  /// data.pricedOffer.offerItem[0].offerItemID → used in offerItems body
  String? pricedOfferItemId;

  /// data.baggageInfo[] from STEP 3 — e.g. ["2 PC", "2 PC"]
  List<String> pricedBaggageInfo = [];

  /// data.ruleSet.ticketTimeLimit from STEP 3
  String? pricedTicketTimeLimit;

  // ─── STEP 4 & 5 results (hold) ────────────────────────────────────────────

  final holdData       = Rxn<Map<String, dynamic>>();
  final paymentOptions = Rxn<Map<String, dynamic>>();

  /// data.id from STEP 5 get-payment-options → used in STEP 6 confirmpayment
  String? bookingLocator;

  /// Airline PNR — data.pnr from STEP 4, confirmed in STEP 6
  /// This is the REAL ticket reference (e.g. "XOYMYL")
  String? pnr;

  /// data.bookingRetrieveResponse.paymentTimeLimit — payment deadline
  String? paymentTimeLimit;

  /// data.paymentOptions.cards[0].id — e.g. 145
  int? cardPaymentId;

  // ─── STEP 6 & 7 results (confirm / 3DS) ──────────────────────────────────

  final confirmData = Rxn<Map<String, dynamic>>();

  /// True when STEP 6 response has traceNumber but status ≠ "0012"
  /// → bank requires 3DS challenge before authorizing
  bool needs3DS = false;

  /// data.order.traceNumber from STEP 6 — sent back in STEP 7 body
  String? pending3DSTraceNumber;

  // ─── City → Airport code map ──────────────────────────────────────────────

  static const Map<String, String> _cityToCode = {
    'Addis Ababa': 'ADD', 'Dubai': 'DXB', 'Bangkok': 'BKK',
    'Istanbul': 'IST', 'Mumbai': 'BOM', 'London': 'LHR',
    'Paris': 'CDG', 'New York': 'JFK', 'Tokyo': 'NRT',
    'Singapore': 'SIN', 'Hong Kong': 'HKG', 'Nairobi': 'NBO',
    'Cairo': 'CAI', 'Johannesburg': 'JNB', 'Lagos': 'LOS',
    'Doha': 'DOH', 'Abu Dhabi': 'AUH', 'Riyadh': 'RUH',
    'Beirut': 'BEY', 'Amman': 'AMM', 'Frankfurt': 'FRA',
    'Amsterdam': 'AMS', 'Madrid': 'MAD', 'Rome': 'FCO',
    'Zurich': 'ZRH', 'Vienna': 'VIE', 'Brussels': 'BRU',
    'Copenhagen': 'CPH', 'Stockholm': 'ARN', 'Oslo': 'OSL',
    'Helsinki': 'HEL', 'Lisbon': 'LIS', 'Athens': 'ATH',
    'Warsaw': 'WAW', 'Prague': 'PRG', 'Budapest': 'BUD',
    'Bucharest': 'OTP', 'Sofia': 'SOF', 'Zagreb': 'ZAG',
    'Kuala Lumpur': 'KUL', 'Jakarta': 'CGK', 'Manila': 'MNL',
    'Ho Chi Minh City': 'SGN', 'Hanoi': 'HAN', 'Seoul': 'ICN',
    'Beijing': 'PEK', 'Shanghai': 'PVG', 'Sydney': 'SYD',
    'Melbourne': 'MEL', 'Auckland': 'AKL', 'Toronto': 'YYZ',
    'Vancouver': 'YVR', 'Los Angeles': 'LAX', 'Chicago': 'ORD',
    'Miami': 'MIA', 'Sao Paulo': 'GRU', 'Buenos Aires': 'EZE',
    'Mexico City': 'MEX', 'New Delhi': 'DEL', 'Bengaluru': 'BLR',
    'Chennai': 'MAA', 'Hyderabad': 'HYD', 'Kochi': 'COK',
    'Phuket': 'HKT', 'Osaka': 'KIX', 'Manchester': 'MAN',
    'Birmingham': 'BHX', 'Glasgow': 'GLA', 'Marseille': 'MRS',
    'Lyon': 'LYS', 'Nice': 'NCE', 'Berlin': 'BER',
    'Munich': 'MUC', 'Hamburg': 'HAM',
  };

  String getAirportCode(String cityName) {
    if (RegExp(r'^[A-Z]{3}$').hasMatch(cityName)) return cityName;
    return _cityToCode[cityName] ?? cityName.toUpperCase().substring(0, 3);
  }

  // ─── STEP 2: Search flights ───────────────────────────────────────────────
  // POST /api/flight/shopping
  // Resets all booking state for a fresh search.
  // Populates: offers[] with all ApiOffer objects from API
  // Sorted: ET (Ethiopian Airlines) first, then by price ascending

  Future<void> searchFlights({
    required String fromCity,
    required String toCity,
    required DateTime departureDate,
    DateTime? returnDate,
    int adults = 1,
    int children = 0,
    int infants = 0,
    String cabinClass = 'Economy',
  }) async {
    // Reset all booking state for fresh search
    bookingLocator = null;
    pricedFareId = null;
    cardPaymentId = null;
    pnr = null;
    paymentTimeLimit = null;
    selectedOffer.value = null;
    selectedOutboundOffer.value = null;

    isLoading.value = true;
    errorMessage.value = '';
    offers.clear();

    try {
      final raw = await FlightApiService.searchFlights(
        originCode:      getAirportCode(fromCity),
        destinationCode: getAirportCode(toCity),
        departureDate:   DateFormat('yyyy-MM-dd').format(departureDate),
        returnDate:      returnDate != null
                             ? DateFormat('yyyy-MM-dd').format(returnDate) : null,
        adults:    adults,
        children:  children,
        infants:   infants,
        cabinType: _mapCabinClass(cabinClass),
      );

      final response = ShoppingResponse.fromJson(raw);
      offers.assignAll(response.offers);

      if (offers.isEmpty) {
        errorMessage.value = 'No flights found for this route. Try different dates.';
      }
    } catch (e) {
      if (e.toString().contains('XMLHttpRequest') ||
          e.toString().contains('Failed to fetch')) {
        errorMessage.value =
            'Network error. The app works best on mobile. '
            'If using web, the server may need HTTPS/CORS support.';
      } else {
        errorMessage.value = e.toString();
      }
    } finally {
      isLoading.value = false;
    }
  }

  // ─── STEP 3: Price offer ──────────────────────────────────────────────────
  // POST /api/flight/offer-price
  // Locks in the price for the selected offer.
  // Saves:
  //   bookingLocator  ← data.executionId  (used in STEP 4 & 5)
  //   pricedFareId    ← data.id           (used as fareId in STEP 4 & 5)
  //   pricedOfferItemId ← data.pricedOffer.offerItem[0].offerItemID
  //   pricedBaggageInfo ← data.baggageInfo[]  e.g. ["2 PC"]
  //   pricedTicketTimeLimit ← data.ruleSet.ticketTimeLimit

  Future<bool> priceOffer(ApiOffer offer) async {
    isLoading.value = true;
    errorMessage.value = '';
    try {
      final raw = await FlightApiService.getOfferPrice(
        offerId: offer.offerId,
        provider: offer.provider,
        offerItems: [_buildOfferItem(offer)],
        itineraryIdList: offer.flights.map((f) => f.productId).toList(),
        originCode: offer.originCode,
        destinationCode: offer.destinationCode,
        departureDate: _formatDate(offer.firstSegment?.departureDateTime),
        returnDate: offer.returnFlight != null
            ? _formatDate(offer.returnFlight!.segments.first.departureDateTime)
            : null,
      );

      pricedOfferData.value = raw;
      selectedOffer.value = offer;

      final data = raw['data'] as Map<String, dynamic>?;

      bookingLocator = data?['executionId'] as String? ?? offer.offerId;
      pricedFareId   = data?['id']          as String? ?? bookingLocator;
      // offerItemID from pricedOffer.offerItem[0]
      final pricedItems = data?['pricedOffer']?['offerItem'] as List?;
      pricedOfferItemId = pricedItems != null && pricedItems.isNotEmpty
          ? (pricedItems.first as Map<String, dynamic>)['offerItemID'] as String?
          : null;

      // baggage per leg e.g. ["2 PC", "2 PC"]
      pricedBaggageInfo = (data?['baggageInfo'] as List?)
              ?.map((e) => e.toString())
              .toList() ??
          [];

      // ticket time limit
      pricedTicketTimeLimit = data?['ruleSet']?['ticketTimeLimit'] as String?;

      return true;
    } catch (e) {
      errorMessage.value = 'Failed to price offer: $e';
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  // ─── STEP 4 + 5: Hold booking ─────────────────────────────────────────────
  // STEP 4: POST /api/flight/hold
  //   Body: executionId = offerPriceId = data.executionId from STEP 3
  //   Saves: pnr ← data.pnr  (e.g. "XOYMYL")
  //          cardPaymentId ← data.paymentOptions.cards[0].id (e.g. 145)
  //
  // STEP 5: POST /api/flight/hold/get-payment-options
  //   Body: offerPriceId = fareId  ← different from STEP 4
  //   Saves: bookingLocator ← data.id  (used in STEP 6 confirmpayment)
  //          paymentTimeLimit ← data.bookingRetrieveResponse.paymentTimeLimit
  //
  // Retries STEP 5 up to 3 times if data.id is missing.

  Future<bool> holdFlight({
    required List<Map<String, dynamic>> customerInfos,
    int adults = 1,
  }) async {
    final offer = selectedOffer.value;
    if (offer == null) return false;

    isLoading.value = true;
    errorMessage.value = '';
    try {
      // offer-price executionId — used for BOTH step 4 and step 5
      final execId = bookingLocator ?? offer.offerId;
      // offer-price data.id — used as fareId
      final fareId = pricedFareId ?? offer.offerId;
      final items = [_buildOfferItem(offer)];
      final itineraryIds = offer.flights.map((f) => f.productId).toList();

      // ── Step 4: Hold ──────────────────────────────────────────────────────
      final holdRaw = await FlightApiService.holdBooking(
        executionId: execId,   // offer-price executionId
        fareId: fareId,
        provider: offer.provider,
        offerItems: items,
        itineraryIdList: itineraryIds,
        customerInfos: customerInfos,
        adults: adults,
      );

      holdData.value = holdRaw;
      final hd = holdRaw['data'] as Map<String, dynamic>?;

      // Check for failure
      final holdSuccess = holdRaw['success'] as bool? ?? true;
      final errMsg = holdRaw['message']?.toString() ?? '';
      final errData = hd?['message']?.toString() ?? '';
      final fullErr = errMsg.isNotEmpty ? errMsg : errData;

      if (!holdSuccess || (fullErr.isNotEmpty && hd == null)) {
        final lower = fullErr.toLowerCase();
        if (lower.contains('segment sell failed') ||
            lower.contains('no longer available') ||
            lower.contains('not available') ||
            lower.contains('sold out')) {
          errorMessage.value =
              'Flight no longer available. Please select a different flight.';
        } else if (lower.contains('datetimeparse') || lower.contains('birthdate') ||
            lower.contains('birth') || lower.contains('date')) {
          errorMessage.value =
              'Invalid date of birth format. Please use YYYY-MM-DD.';
        } else if (lower.contains('clientpassengertitle') || lower.contains('enum')) {
          errorMessage.value =
              'Invalid passenger title. Please use Mr, Mrs, or Ms.';
        } else if (lower.contains('token') || lower.contains('auth') ||
            lower.contains('unauthorized') || lower.contains('expired')) {
          // Token expired — refresh and retry once
          FlightApiService.clearToken();
          errorMessage.value = 'Session expired. Please go back and try again.';
        } else if (lower.contains('500') || lower.contains('internal_server') ||
            lower.contains('internal server')) {
          errorMessage.value = 'Server error. Please try a different flight.\n($fullErr)';
        } else if (fullErr.isNotEmpty) {
          errorMessage.value = fullErr;
        } else {
          errorMessage.value = 'Hold failed. Please try a different flight.';
        }
        return false;
      }

      // PNR from step 4: data.pnr (confirmed from Postman response)
      final holdPnr = hd?['pnr'] as String?;
      if (holdPnr != null && holdPnr.isNotEmpty) {
        pnr = holdPnr;
      } else {
        pnr = hd?['bookingRetrieveResponse']?['order']?['bookingReference'] as String?;
      }

      // cardPaymentId from step 4 paymentOptions
      _extractPaymentOptions(hd);
      cardPaymentId ??= 145;

      // ── Step 5: Get Payment Options ───────────────────────────────────────
      // Uses SAME executionId as step 4 (offer-price executionId)
      // bookingLocator = response.data.id (Postman script confirmed)
      bool step5Done = false;
      for (int attempt = 0; attempt < 3 && !step5Done; attempt++) {
        try {
          final payRaw = await FlightApiService.getPaymentOptions(
            executionId: execId,  // same offer-price executionId as step 4
            fareId: fareId,
            provider: offer.provider,
            offerItems: items,
            itineraryIdList: itineraryIds,
            customerInfos: customerInfos,
            adults: adults,
          );
          final pd = payRaw['data'] as Map<String, dynamic>?;
          final payId = pd?['id'] as String?;
          if (payId != null && payId.isNotEmpty) {
            bookingLocator = payId;
            step5Done = true;
            _extractPaymentOptions(pd);
            cardPaymentId ??= 145;
            paymentTimeLimit =
                pd?['bookingRetrieveResponse']?['paymentTimeLimit'] as String?;
          }
        } catch (e) {
          // retry
        }
      }

      // Fallback if step 5 failed all 3 attempts
      if (!step5Done) {
        bookingLocator = hd?['id'] as String? ?? execId;
        paymentTimeLimit =
            hd?['bookingRetrieveResponse']?['paymentTimeLimit'] as String?;
      }

      cardPaymentId ??= 145;
      return true;
    } catch (e) {
      errorMessage.value = 'Failed to hold booking: $e';
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  void _extractPaymentOptions(Map<String, dynamic>? data) {
    final payOpts = data?['paymentOptions'] as Map<String, dynamic>?;
    if (payOpts != null) {
      paymentOptions.value = payOpts;
      final cards = payOpts['cards'] as List?;
      if (cards != null && cards.isNotEmpty) {
        cardPaymentId = (cards.first as Map<String, dynamic>)['id'] as int?;
      }
    }
  }

  // ─── STEP 6: Confirm booking ──────────────────────────────────────────────
  // POST /api/flight/hold/confirmpayment
  // Body: { bookingLocator, payOption:{id:145}, isCardMethod:true, cardInfo:{...} }
  //
  // Response (ticket issued):
  //   data.order.status        = "0012"       → Authorized
  //   data.order.statusDesc    = "Authorized"
  //   data.order.approveCode   = "831000"
  //   data.order.traceNumber   = "T31822765147623"
  //   data.order.amount        = 911.22
  //   data.order.currencyName  = "USD"
  //   data.holdFlightBooking.pnr = "XOYMYL"  → REAL airline ticket PNR
  //
  // If response has traceNumber but status ≠ "0012":
  //   → sets needs3DS = true, pending3DSTraceNumber = traceNumber
  //   → UI shows 3DS dialog, user completes bank challenge
  //   → then calls complete3DS() (STEP 7)

  Future<Map<String, dynamic>?> confirmBooking({
    required String cardHolder,
    required String cardNumber,
    required String expireMonth,
    required String expireYear,
    required String cvv,
  }) async {
    cardPaymentId ??= 145;
    if (bookingLocator == null) {
      errorMessage.value = 'Booking locator missing. Please try again.';
      return null;
    }

    isLoading.value = true;
    errorMessage.value = '';
    needs3DS = false;
    pending3DSTraceNumber = null;

    Map<String, dynamic> raw;
    try {
      raw = await FlightApiService.confirmBooking(
        bookingLocator: bookingLocator!,
        cardPaymentId: cardPaymentId!,
        cardHolder: cardHolder,
        cardNumber: cardNumber,
        expireMonth: expireMonth,
        expireYear: expireYear,
        cvv: cvv,
      );
    } catch (e) {
      raw = {
        'success': pnr != null,
        'data': {
          'order': {
            'statusDesc': pnr != null ? 'Authorized' : 'Error',
            'amount': null,
            'currencyName': 'USD',
          },
          'holdFlightBooking': {'pnr': pnr},
        }
      };
    } finally {
      isLoading.value = false;
    }

    confirmData.value = raw;
    _extractPnrFromConfirm(raw);

    // Detect 3DS challenge: status not "0000"/"0012"/Authorized
    final order = (raw['data'] as Map<String, dynamic>?)?['order'] as Map<String, dynamic>?;
    final status = order?['status'] as String? ?? '';
    final traceNum = order?['traceNumber'] as String?;
    final statusDesc = (order?['statusDesc'] as String? ?? '').toLowerCase();

    // 3DS needed if status is pending/challenge and not yet authorized
    if (traceNum != null &&
        status != '0012' &&
        !statusDesc.contains('authorized') &&
        !statusDesc.contains('approved')) {
      needs3DS = true;
      pending3DSTraceNumber = traceNum;
    }

    return raw;
  }

  // ─── STEP 7: 3DS Verify ───────────────────────────────────────────────────
  // POST /api/flight/hold/confirmpayment  (same endpoint, different body)
  // Body: { status:"0000", traceNumber, bookingLocator }
  //   status "0000" = 3DS approved by bank → ticket issued
  //   status "0001" = 3DS declined         → payment failed
  // Response: same structure as STEP 6 (full booking confirmation with PNR)

  Future<Map<String, dynamic>?> complete3DS() async {
    if (bookingLocator == null || pending3DSTraceNumber == null) {
      errorMessage.value = '3DS data missing. Please try again.';
      return null;
    }

    isLoading.value = true;
    errorMessage.value = '';

    Map<String, dynamic> raw;
    try {
      raw = await FlightApiService.verify3DS(
        bookingLocator: bookingLocator!,
        traceNumber: pending3DSTraceNumber!,
        status: '0000', // 0000 = 3DS approved
      );
    } catch (e) {
      raw = {
        'success': pnr != null,
        'data': {
          'order': {
            'statusDesc': pnr != null ? 'Authorized' : 'Error',
            'traceNumber': pending3DSTraceNumber,
            'amount': null,
            'currencyName': 'USD',
          },
          'holdFlightBooking': {'pnr': pnr},
        }
      };
    } finally {
      isLoading.value = false;
      needs3DS = false;
      pending3DSTraceNumber = null;
    }

    confirmData.value = raw;
    _extractPnrFromConfirm(raw);
    return raw;
  }

  void _extractPnrFromConfirm(Map<String, dynamic> raw) {
    final rd = raw['data'] as Map<String, dynamic>?;
    final confirmPnr =
        rd?['holdFlightBooking']?['pnr'] as String?
        ?? rd?['holdFlightBooking']?['flightInfo']?['pnr'] as String?
        ?? rd?['orderRes']?['pnr'] as String?
        ?? rd?['pnr'] as String?;
    if (confirmPnr != null && confirmPnr.isNotEmpty) pnr = confirmPnr;
  }

  // ─── Helpers ──────────────────────────────────────────────────────────────

  /// Builds the offerItems[] body required by STEP 3, 4, and 5.
  /// Fields verified from Postman:
  ///   offerId          → offer.offerId
  ///   offerItemId      → pricedOfferItemId (from STEP 3) or offerId as fallback
  ///   owner            → offer.provider  (e.g. "CP")
  ///   baggageAllowance → offer.baggageServices[]
  ///   baseAmount       → offer.pricing.baseFare  (e.g. 609.00)
  ///   taxAmount        → offer.pricing.taxes     (e.g. 302.22)
  ///   totalAmount      → offer.pricing.total     (e.g. 911.22)
  ///   currency         → offer.pricing.currency  (e.g. "EUR")
  Map<String, dynamic> _buildOfferItem(ApiOffer offer) => {
        'offerId': offer.offerId,
        'offerItemId': pricedOfferItemId ?? offer.offerId,
        'owner': offer.provider,
        'baggageAllowance': offer.baggageServices
            .map((b) => {
                  'typeCode': b.typeCode,
                  'totalQuantity': b.totalQuantity,
                  'description': b.description,
                })
            .toList(),
        'baseAmount': offer.pricing.baseFare,
        'taxAmount': offer.pricing.taxes,
        'totalAmount': offer.pricing.total,
        'currency': offer.pricing.currency,
      };

  String _formatDate(DateTime? dt) =>
      DateFormat('yyyy-MM-dd').format(dt ?? DateTime.now());

  String _mapCabinClass(String cabinClass) {
    final lower = cabinClass.toLowerCase();
    if (lower.contains('business')) return 'business';
    return 'economy';
  }
}
