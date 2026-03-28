import 'dart:convert';
import 'package:http/http.dart' as http;

// =============================================================================
//  FlightApiService
//  Base URL : http://3.11.26.231/fannos
//
//  FULL BOOKING FLOW (verified from Postman):
//
//  STEP 1 ─ GET GUEST TOKEN
//    POST /api/auth/guest-token
//    Body : {}
//    Response : { "guestToken": "eyJ..." }
//    → Store token, attach as Bearer on every subsequent request
//
//  STEP 2 ─ FLIGHT SHOPPING
//    POST /api/flight/shopping
//    Body : { originDestinations, travellers, preference.cabinPreferences }
//    Response : { data: { qrFlights: { offers: [...], totalOffers, cheapestOffer } } }
//    → Each offer contains: offerId, provider, flights[], pricing, baggageServices
//    → flights[0] = outbound leg, flights[1] = return leg (round-trip only)
//    → Each flight has segments[] with airlineName, flightNumber, times, airports
//
//  STEP 3 ─ OFFER PRICE
//    POST /api/flight/offer-price
//    Body : { executionId (=offerId), provider, offerItems, travellers,
//             originDestinations, fareId (=offerId), itineraryIdList }
//    Response : { data: { executionId, id, pricedOffer, baggageInfo, ruleSet } }
//    → Save: data.executionId  → used as executionId in STEP 4 & 5
//    → Save: data.id           → used as fareId / pricedFareId
//    → Save: data.pricedOffer.offerItem[0].offerItemID → pricedOfferItemId
//    → Save: data.baggageInfo  → e.g. ["2 PC"]
//    → Save: data.ruleSet.ticketTimeLimit
//
//  STEP 4 ─ HOLD BOOKING
//    POST /api/flight/hold
//    Body : { bookingHold:true, executionId, offerPriceId (=executionId),
//             provider, offerItems, customerInfos[], travellers,
//             verifyRequest: { fareId, itineraryIdList } }
//    Response : { data: { pnr, id, paymentOptions, bookingRetrieveResponse } }
//    → Save: data.pnr                                    → airline PNR (e.g. "XOYMYL")
//    → Save: data.paymentOptions.cards[0].id             → cardPaymentId (e.g. 145)
//    → Save: data.bookingRetrieveResponse.paymentTimeLimit
//
//  STEP 5 ─ GET PAYMENT OPTIONS
//    POST /api/flight/hold/get-payment-options
//    Body : same as STEP 4 but offerPriceId = fareId (not executionId)
//    Response : { data: { id, paymentOptions, bookingRetrieveResponse } }
//    → Save: data.id → bookingLocator (used in STEP 6)
//    → Save: data.paymentOptions.cards[0].id → cardPaymentId
//    → Save: data.bookingRetrieveResponse.paymentTimeLimit
//
//  STEP 6 ─ CONFIRM PAYMENT (normal card)
//    POST /api/flight/hold/confirmpayment
//    Body : { bookingLocator, payOption: { id: cardPaymentId },
//             isCardMethod: true, cardInfo: { cardHolder, cardNumber,
//             expireMonth, expireYear, cvv } }
//    Response : {
//      success: true,
//      data: {
//        order: {
//          amount: 911.22, currencyName: "USD",
//          traceNumber: "T31822765147623",
//          status: "0012", statusDesc: "Authorized",
//          approveCode: "831000",
//          paymentChannel: "Card"
//        },
//        holdFlightBooking: {
//          pnr: "XOYMYL",
//          holdBookingResponse: {
//            order: { bookingReference: "XOYMYL", orderId: "ET_XOYMYL" },
//            passengers: [{ firstName, lastName, birthdate, ptc }],
//            journeys: [{ originCode, destinationCode, departureDateTime,
//                         arrivalDateTime, duration }],
//            segments: [{ marketingCarrier: { flightNumber, carrierCode },
//                         aircraftType, departureDateTime, arrivalDateTime }],
//            pricing: { totalAmount, baseAmount, totalTaxes, currency }
//          },
//          bookingRetrieveResponse: {
//            paymentTimeLimit: "2026-04-25T23:59:00",
//            order: { bookingReference: "XOYMYL" }
//          }
//        }
//      }
//    }
//    → PNR "XOYMYL" is the REAL airline ticket reference
//    → status "0012" = Authorized (ticket issued)
//
//  STEP 7 ─ 3DS VERIFY (only if bank requires 3D Secure challenge)
//    POST /api/flight/hold/confirmpayment   ← same endpoint, different body
//    Body : { status: "0000", traceNumber: "T31822765147623",
//             bookingLocator: "{{bookingLocator}}" }
//    status codes: "0000" = 3DS approved  |  "0001" = 3DS declined
//    Response : same structure as STEP 6
//    → Triggered when STEP 6 response has traceNumber but status ≠ "0012"
// =============================================================================

class FlightApiService {
  static const String _baseUrl = 'http://3.11.26.231/fannos';
  static String? _guestToken;

  static void clearToken() => _guestToken = null;

  // ─── Internal HTTP helper ─────────────────────────────────────────────────

  static Future<Map<String, dynamic>> _post(
    String path, {
    Map<String, dynamic>? body,
    bool withAuth = true,
  }) async {
    final uri = Uri.parse('$_baseUrl$path');
    final headers = <String, String>{'Content-Type': 'application/json'};
    if (withAuth && _guestToken != null) {
      headers['Authorization'] = 'Bearer $_guestToken';
    }
    final response = await http
        .post(uri, headers: headers, body: body != null ? jsonEncode(body) : null)
        .timeout(const Duration(seconds: 30));
    try {
      return jsonDecode(response.body) as Map<String, dynamic>;
    } catch (e) {
      throw Exception('JSON parse error: $e  body=${response.body}');
    }
  }

  // Retry once on auth/token errors only (not on 500 server errors)
  static Future<Map<String, dynamic>> _postWithRetry(
    String path, {
    Map<String, dynamic>? body,
  }) async {
    var result = await _post(path, body: body);
    final msg = result['message']?.toString().toLowerCase() ?? '';
    final isAuthError = result['success'] == false &&
        result['data'] == null &&
        (msg.contains('token') || msg.contains('auth') ||
         msg.contains('unauthorized') || msg.contains('expired') || msg.isEmpty);
    if (isAuthError) {
      _guestToken = null;
      await getGuestToken();
      result = await _post(path, body: body);
    }
    return result;
  }

  // ─── STEP 1: Guest Token ──────────────────────────────────────────────────
  // POST /api/auth/guest-token
  // Body    : {}
  // Response: { "guestToken": "eyJ..." }

  static Future<String?> getGuestToken({bool forceRefresh = false}) async {
    if (_guestToken != null && !forceRefresh) return _guestToken;
    try {
      final res = await _post('/api/auth/guest-token', withAuth: false, body: {});
      _guestToken = res['guestToken'] as String?;
      if (_guestToken == null) throw Exception('Token field missing: $res');
      return _guestToken;
    } catch (e) {
      throw Exception('Auth token error: $e');
    }
  }

  // ─── STEP 2: Flight Shopping ──────────────────────────────────────────────
  // POST /api/flight/shopping
  // Body:
  //   originDestinations: [
  //     { departure: { airportCode: "DXB", date: "2026-04-25" },
  //       arrival:   { airportCode: "ADD" } },
  //     // round-trip adds return leg:
  //     { departure: { airportCode: "ADD", date: "2026-04-28" },
  //       arrival:   { airportCode: "DXB" } }
  //   ]
  //   travellers: { adt: 1, chd: 0, inf: 0 }
  //   preference: { cabinPreferences: { cabinType: { code: "economy" } } }
  //
  // Response:
  //   data.qrFlights.offers[]         → list of ApiOffer objects
  //   data.qrFlights.totalOffers      → total count from API
  //   data.qrFlights.cheapestOffer    → cheapest offer object
  //   Each offer:
  //     offerId, provider, priceClassName
  //     flights[0]  → outbound leg (ApiFlightJourney)
  //     flights[1]  → return leg   (round-trip only)
  //     pricing: { total, baseFare, taxes, currency }
  //     baggageServices[]: { typeCode, totalQuantity, description }
  //     ruleSet: { ticketTimeLimit, penaltyInfo }

  static Future<Map<String, dynamic>> searchFlights({
    required String originCode,
    required String destinationCode,
    required String departureDate,   // "yyyy-MM-dd"
    String? returnDate,              // "yyyy-MM-dd" — round-trip only
    int adults = 1,
    int children = 0,
    int infants = 0,
    String cabinType = 'economy',    // "economy" | "business"
  }) async {
    final token = await getGuestToken();
    if (token == null) throw Exception('Failed to get auth token');

    final originDestinations = <Map<String, dynamic>>[
      {
        'departure': {'airportCode': originCode, 'date': departureDate},
        'arrival':   {'airportCode': destinationCode},
      },
    ];
    if (returnDate != null) {
      originDestinations.add({
        'departure': {'airportCode': destinationCode, 'date': returnDate},
        'arrival':   {'airportCode': originCode},
      });
    }

    return _post('/api/flight/shopping', body: {
      'originDestinations': originDestinations,
      'travellers': {'adt': adults, 'chd': children, 'inf': infants},
      'preference': {
        'cabinPreferences': {
          'cabinType': {'code': cabinType.toLowerCase()},
        },
      },
    });
  }

  // ─── STEP 3: Offer Price ──────────────────────────────────────────────────
  // POST /api/flight/offer-price
  // Body:
  //   executionId      = offerId from shopping response
  //   fareId           = same as executionId
  //   provider         = offer.provider (e.g. "CP")
  //   offerItems[]     = [{ offerId, offerItemId, owner, baggageAllowance[],
  //                         baseAmount, taxAmount, totalAmount, currency }]
  //   itineraryIdList  = offer.flights[].productId
  //   travellers       = { adt, chd, inf, ins, unn }
  //   originDestinations = same as shopping
  //   metadata         = { country, currency, locale, user, traceId }
  //
  // Response:
  //   data.executionId                          → save as executionId for STEP 4 & 5
  //   data.id                                   → save as pricedFareId
  //   data.pricedOffer.offerItem[0].offerItemID → save as pricedOfferItemId
  //   data.baggageInfo[]                        → e.g. ["2 PC", "2 PC"]
  //   data.ruleSet.ticketTimeLimit              → ticket issuance deadline

  static Future<Map<String, dynamic>> getOfferPrice({
    required String offerId,
    required String provider,
    required List<Map<String, dynamic>> offerItems,
    required List<String> itineraryIdList,
    required String originCode,
    required String destinationCode,
    required String departureDate,
    String? returnDate,
    int adults = 1,
  }) async {
    final token = await getGuestToken();
    if (token == null) throw Exception('Failed to get auth token');

    final originDestinations = <Map<String, dynamic>>[
      {
        'departure': {'airportCode': originCode, 'date': departureDate},
        'arrival':   {'airportCode': destinationCode},
      },
    ];
    if (returnDate != null) {
      originDestinations.add({
        'departure': {'airportCode': destinationCode, 'date': returnDate},
        'arrival':   {'airportCode': originCode},
      });
    }

    return _post('/api/flight/offer-price', body: {
      'executionId':     offerId,   // offerId from STEP 2
      'fareId':          offerId,   // same value
      'provider':        provider,
      'metadata': {
        'country':  'ET',
        'currency': 'USD',
        'locale':   'en-US',
        'user':     'tadesse@flocash.com',
        'traceId':  null,
      },
      'offerItems':       offerItems,
      'travellers':       {'adt': adults, 'chd': 0, 'inf': 0, 'ins': 0, 'unn': 0},
      'originDestinations': originDestinations,
      'itineraryIdList':  itineraryIdList,
    });
  }

  // ─── STEP 4: Hold Booking ─────────────────────────────────────────────────
  // POST /api/flight/hold
  // Body:
  //   bookingHold    = true
  //   executionId    = data.executionId from STEP 3
  //   offerPriceId   = same as executionId  ← important: NOT fareId here
  //   provider       = offer.provider
  //   offerItems[]   = same as STEP 3
  //   customerInfos[]= [{ gender, birthDate, title, phoneNo, firstName,
  //                       lastName, country, passPort, email, notify,
  //                       paxType:"ADT", paxId:"PAX1" }]
  //   travellers     = { adt, chd, inf, ins, unn }
  //   verifyRequest  = { fareId: pricedFareId, itineraryIdList }
  //
  // Response:
  //   data.pnr                                    → airline PNR (e.g. "XOYMYL")
  //   data.id                                     → internal booking id
  //   data.paymentOptions.cards[0].id             → cardPaymentId (e.g. 145)
  //   data.bookingRetrieveResponse.paymentTimeLimit
  //   data.bookingRetrieveResponse.order.bookingReference → same as PNR

  static Future<Map<String, dynamic>> holdBooking({
    required String executionId,     // from STEP 3: data.executionId
    required String fareId,          // from STEP 3: data.id
    required String provider,
    required List<Map<String, dynamic>> offerItems,
    required List<String> itineraryIdList,
    required List<Map<String, dynamic>> customerInfos,
    int adults = 1,
  }) async {
    final token = await getGuestToken();
    if (token == null) throw Exception('Failed to get auth token');

    return _postWithRetry('/api/flight/hold', body: {
      'bookingHold':  true,
      'executionId':  executionId,
      'offerPriceId': executionId,   // same as executionId for STEP 4
      'provider':     provider,
      'offerItems':   offerItems,
      'customerInfos': customerInfos,
      'travellers':   {'adt': adults, 'chd': 0, 'inf': 0, 'ins': 0, 'unn': 0},
      'verifyRequest': {
        'fareId':          fareId,   // pricedFareId from STEP 3
        'itineraryIdList': itineraryIdList,
      },
    });
  }

  // ─── STEP 5: Get Payment Options ──────────────────────────────────────────
  // POST /api/flight/hold/get-payment-options
  // Body: same as STEP 4 EXCEPT:
  //   offerPriceId = fareId  ← different from STEP 4 (uses fareId not executionId)
  //
  // Response:
  //   data.id                          → bookingLocator (used in STEP 6)
  //   data.paymentOptions.cards[0].id  → cardPaymentId (e.g. 145)
  //   data.bookingRetrieveResponse.paymentTimeLimit → e.g. "2026-04-25T23:59:00"

  static Future<Map<String, dynamic>> getPaymentOptions({
    required String executionId,
    required String fareId,
    required String provider,
    required List<Map<String, dynamic>> offerItems,
    required List<String> itineraryIdList,
    required List<Map<String, dynamic>> customerInfos,
    int adults = 1,
  }) async {
    final token = await getGuestToken();
    if (token == null) throw Exception('Failed to get auth token');

    return _postWithRetry('/api/flight/hold/get-payment-options', body: {
      'bookingHold':  true,
      'executionId':  executionId,
      'offerPriceId': fareId,        // fareId here (different from STEP 4)
      'provider':     provider,
      'offerItems':   offerItems,
      'customerInfos': customerInfos,
      'travellers':   {'adt': adults, 'chd': 0, 'inf': 0, 'ins': 0, 'unn': 0},
      'verifyRequest': {
        'fareId':          fareId,
        'itineraryIdList': itineraryIdList,
      },
    });
  }

  // ─── STEP 6: Confirm Payment ──────────────────────────────────────────────
  // POST /api/flight/hold/confirmpayment
  // Body:
  //   bookingLocator = data.id from STEP 5
  //   payOption      = { id: cardPaymentId }   (e.g. 145)
  //   isCardMethod   = true
  //   cardInfo       = { cardHolder, cardNumber, expireMonth, expireYear, cvv }
  //
  // Response (success):
  //   success: true
  //   data.order.status        = "0012"         → Authorized
  //   data.order.statusDesc    = "Authorized"
  //   data.order.approveCode   = "831000"
  //   data.order.traceNumber   = "T31822765147623"
  //   data.order.amount        = 911.22
  //   data.order.currencyName  = "USD"
  //   data.holdFlightBooking.pnr = "XOYMYL"     → REAL airline ticket PNR
  //   data.holdFlightBooking.holdBookingResponse.order.bookingReference = "XOYMYL"
  //   data.holdFlightBooking.holdBookingResponse.journeys[]  → flight legs
  //   data.holdFlightBooking.holdBookingResponse.passengers[] → passenger names
  //   data.holdFlightBooking.holdBookingResponse.pricing     → base/tax/total
  //   data.holdFlightBooking.bookingRetrieveResponse.paymentTimeLimit
  //
  // Note: status "0012" = ticket issued. If traceNumber present but status ≠ "0012"
  //       → 3DS challenge required → call STEP 7

  static Future<Map<String, dynamic>> confirmBooking({
    required String bookingLocator,  // data.id from STEP 5
    required int cardPaymentId,      // data.paymentOptions.cards[0].id (e.g. 145)
    required String cardHolder,
    required String cardNumber,
    required String expireMonth,     // "MM"
    required String expireYear,      // "YY"
    required String cvv,
  }) async {
    final token = await getGuestToken();
    if (token == null) throw Exception('Failed to get auth token');

    return _postWithRetry('/api/flight/hold/confirmpayment', body: {
      'bookingLocator': bookingLocator,
      'payOption':      {'id': cardPaymentId},
      'isCardMethod':   true,
      'cardInfo': {
        'cardHolder':   cardHolder,
        'cardNumber':   cardNumber,
        'expireMonth':  expireMonth,
        'expireYear':   expireYear,
        'cvv':          cvv,
      },
    });
  }

  // ─── STEP 7: 3DS Verify ───────────────────────────────────────────────────
  // POST /api/flight/hold/confirmpayment  ← same endpoint, different body
  //
  // Triggered when: STEP 6 response has traceNumber but status ≠ "0012"
  // (bank requires 3D Secure challenge before authorizing)
  //
  // Body:
  //   status          = "0000"                  → 3DS approved by bank
  //   traceNumber     = "T31822765147623"        → from STEP 6 response
  //   bookingLocator  = bookingLocator from STEP 5
  //
  // Status codes:
  //   "0000" = 3DS approved  → proceed, ticket issued
  //   "0001" = 3DS declined  → payment failed
  //
  // Response: same structure as STEP 6 (full booking confirmation with PNR)

  static Future<Map<String, dynamic>> verify3DS({
    required String bookingLocator,
    required String traceNumber,     // from STEP 6 response: data.order.traceNumber
    String status = '0000',          // "0000" = approved
  }) async {
    final token = await getGuestToken();
    if (token == null) throw Exception('Failed to get auth token');

    return _postWithRetry('/api/flight/hold/confirmpayment', body: {
      'status':         status,
      'traceNumber':    traceNumber,
      'bookingLocator': bookingLocator,
    });
  }
}
