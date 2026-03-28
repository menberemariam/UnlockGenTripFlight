import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../controllers/flight_search_controller.dart';
import '../../controllers/flight_booking_controller.dart';
import '../../controllers/passengers_class_controller.dart';
import '../../model/api_models.dart';
import '../../providers/booking_provider.dart';
import '../../routes/app_routes.dart';

class ResultsScreen extends StatefulWidget {
  const ResultsScreen({super.key});

  @override
  State<ResultsScreen> createState() => _ResultsScreenState();
}

class _ResultsScreenState extends State<ResultsScreen> {
  late FlightSearchController _searchCtrl;
  late FlightBookingController _bookingCtrl;

  final _dateScrollCtrl = ScrollController();
  bool _directOnly = false;
  String _sortBy = 'price'; // 'price' | 'duration' | 'departure'
  final Set<String> _selectedAirlines = {};
  RangeValues _priceRange = const RangeValues(0, 5000);
  double _maxPrice = 5000;
  final Set<String> _expandedOfferIds = {}; // track expanded cards

  @override
  void dispose() {
    _dateScrollCtrl.dispose();
    super.dispose();
  }


  @override
  void initState() {
    super.initState();
    _searchCtrl = Get.find<FlightSearchController>();
    _bookingCtrl = Get.find<FlightBookingController>();
    _triggerSearch();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_dateScrollCtrl.hasClients) {
        _dateScrollCtrl.jumpTo(8 * 74.0 - 100);
      }
    });
  }

  void _triggerSearch() {
    final pax = Get.find<PassengersClassController>();
    _searchCtrl.searchFlights(
      fromCity: _bookingCtrl.departureCity.value,
      toCity: _bookingCtrl.destinationCity.value,
      departureDate: _bookingCtrl.selectedDate.value,
      adults: pax.adults.value,
      children: pax.children.value,
      infants: pax.infants.value,
      cabinClass: pax.selectedClass.value,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        title: Obx(() => Text(
              '${_bookingCtrl.departureCity.value} → ${_bookingCtrl.destinationCity.value}',
              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
            )),
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFFFFD700), Color(0xFFFFC107)],
            ),
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_outlined, color: Colors.white),
            onPressed: () {},
          ),
        ],
      ),
      body: Obx(() {
        final loading = _searchCtrl.isLoading.value;
        final error = _searchCtrl.errorMessage.value;
        // access offers inside Obx so it rebuilds on new search results
        _searchCtrl.offers.length;

        if (loading) {
          return const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CircularProgressIndicator(color: Color(0xFFFFD700)),
                SizedBox(height: 16),
                Text('Searching flights...', style: TextStyle(color: Color(0xFF757575))),
              ],
            ),
          );
        }

        if (error.isNotEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.flight_takeoff_outlined, size: 64, color: Color(0xFFD4AF37)),
                const SizedBox(height: 16),
                Text(error, textAlign: TextAlign.center, style: const TextStyle(color: Color(0xFF757575))),
                const SizedBox(height: 24),
                ElevatedButton.icon(
                  onPressed: _triggerSearch,
                  icon: const Icon(Icons.refresh),
                  label: const Text('Retry'),
                ),
              ],
            ),
          );
        }

        if (_searchCtrl.offers.isEmpty) {
          return const Center(child: Text('No flights available'));
        }

        return _buildBody(context);
      }),
    );
  }

  // Separate method so setState() rebuilds this directly
  Widget _buildBody(BuildContext context) {
    final offers = _searchCtrl.offers;

    // Apply filters — runs on every setState (Direct toggle, airline select, price slider)
    final filtered = offers.where((o) {
      if (_directOnly && (o.outboundFlight?.segments.length ?? 0) > 1) return false;
      if (_selectedAirlines.isNotEmpty && !_selectedAirlines.contains(o.airlineName)) return false;
      if (o.pricing.total > _priceRange.end || o.pricing.total < _priceRange.start) return false;
      return true;
    }).toList();

    // Sort
    filtered.sort((a, b) {
      if (_sortBy == 'duration') {
        return (a.outboundFlight?.duration ?? '').compareTo(b.outboundFlight?.duration ?? '');
      } else if (_sortBy == 'departure') {
        final aDep = a.firstSegment?.departureDateTime ?? DateTime(2100);
        final bDep = b.firstSegment?.departureDateTime ?? DateTime(2100);
        return aDep.compareTo(bDep);
      }
      return a.pricing.total.compareTo(b.pricing.total);
    });

    return Column(
      children: [
        _buildPriceInfo(),
        _buildDateStrip(),
        _buildFilters(),
        if (filtered.isEmpty)
          const Expanded(child: Center(child: Text('No flights match your filters')))
        else
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: filtered.length,
              itemBuilder: (context, index) =>
                  _buildFlightCard(context, filtered[index], index),
            ),
          ),
      ],
    );
  }

  Widget _buildPriceInfo() {
    return Obx(() {
      final count = _searchCtrl.offers.length;
      return Container(
        padding: const EdgeInsets.all(12),
        color: const Color(0xFFFFF8E6),
        child: Text(
          count > 0
              ? '$count flight${count != 1 ? 's' : ''} found · Average one-way price per passenger, taxes included'
              : 'Average one-way price per passenger, taxes and fees included',
          style: const TextStyle(fontSize: 12, color: Color(0xFF757575)),
          textAlign: TextAlign.center,
        ),
      );
    });
  }

  Widget _buildDateStrip() {
    return Obx(() {
      final base = _bookingCtrl.selectedDate.value;
      final dates = List.generate(17, (i) => base.subtract(Duration(days: 8 - i)));
      return Container(
        color: Colors.white,
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          controller: _dateScrollCtrl,
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: Row(
            children: dates.map((date) {
              final isSelected = date.year == base.year &&
                  date.month == base.month &&
                  date.day == base.day;
              return GestureDetector(
                onTap: () {
                  _bookingCtrl.selectedDate.value = date;
                  _triggerSearch();
                },
                child: Container(
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                  decoration: BoxDecoration(
                    gradient: isSelected
                        ? const LinearGradient(
                            colors: [Color(0xFFFFD700), Color(0xFFFFC107)])
                        : null,
                    color: isSelected ? null : const Color(0xFFF5F5F5),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        DateFormat('MMM').format(date).toUpperCase(),
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                          color: isSelected ? Colors.white : const Color(0xFF9E9E9E),
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        DateFormat('d').format(date),
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: isSelected ? Colors.white : const Color(0xFF2C2C2C),
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        DateFormat('EEE').format(date).toUpperCase(),
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w500,
                          color: isSelected ? Colors.white : const Color(0xFF9E9E9E),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }).toList(),
          ),
        ),
      );
    });
  }

  Widget _buildFilters() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: Row(
        children: [
          GestureDetector(
            onTap: _showFilterSheet,
            child: _buildFilterChip('Filters', Icons.filter_list,
                _selectedAirlines.isNotEmpty || _sortBy != 'price' || _priceRange.end < _maxPrice),
          ),
          const SizedBox(width: 8),
          GestureDetector(
            onTap: () => setState(() => _directOnly = !_directOnly),
            child: _buildFilterChip('Direct', Icons.flight, _directOnly),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String label, IconData icon, bool active) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        border: Border.all(color: const Color(0xFFD4AF37)),
        borderRadius: BorderRadius.circular(20),
        color: active ? const Color(0xFFD4AF37) : const Color(0xFFFFF8E6),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: active ? Colors.white : const Color(0xFFD4AF37)),
          const SizedBox(width: 4),
          Text(label,
              style: TextStyle(
                  fontSize: 12,
                  color: active ? Colors.white : const Color(0xFFD4AF37),
                  fontWeight: active ? FontWeight.bold : FontWeight.normal)),
        ],
      ),
    );
  }

  void _showFilterSheet() {
    final offers = _searchCtrl.offers;

    // Build airline → flight count map
    final Map<String, int> airlineCounts = {};
    for (final o in offers) {
      final name = o.airlineName;
      if (name.isNotEmpty) airlineCounts[name] = (airlineCounts[name] ?? 0) + 1;
    }
    final airlines = airlineCounts.keys.toList()..sort();

    // Price bounds
    final prices = offers.map((o) => o.pricing.total).toList();
    final minP = prices.isEmpty ? 0.0 : prices.reduce((a, b) => a < b ? a : b);
    final maxP = prices.isEmpty ? 5000.0 : prices.reduce((a, b) => a > b ? a : b);
    if (_maxPrice == 5000 && maxP != 5000) {
      _maxPrice = maxP;
      _priceRange = RangeValues(minP, maxP);
    }
    final currency = offers.isNotEmpty ? offers.first.pricing.currency : 'EUR';

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: const Color(0xFFFFF8E6),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) => StatefulBuilder(
        builder: (ctx, setSheetState) => DraggableScrollableSheet(
          expand: false,
          initialChildSize: 0.75,
          maxChildSize: 0.92,
          builder: (_, scrollCtrl) => Column(
            children: [
              // Handle + header
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 12, 24, 0),
                child: Column(
                  children: [
                    Center(
                      child: Container(
                        width: 40, height: 4,
                        decoration: BoxDecoration(
                          color: Colors.grey.shade300,
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Sort by',
                            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                        TextButton(
                          onPressed: () {
                            setSheetState(() {});
                            setState(() {
                              _sortBy = 'price';
                              _selectedAirlines.clear();
                              _priceRange = RangeValues(minP, maxP);
                            });
                          },
                          child: const Text('Reset all',
                              style: TextStyle(color: Color(0xFFD4AF37))),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              // Scrollable content
              Expanded(
                child: ListView(
                  controller: scrollCtrl,
                  padding: const EdgeInsets.fromLTRB(24, 8, 24, 0),
                  children: [
                    // ── Sort options (match image style) ──────────────
                    _sortOption(ctx, setSheetState, 'price', 'Lowest price', Icons.attach_money),
                    const SizedBox(height: 8),
                    _sortOption(ctx, setSheetState, 'duration', 'Shortest duration', Icons.timer_outlined),
                    const SizedBox(height: 8),
                    _sortOption(ctx, setSheetState, 'departure', 'Earliest departure', Icons.flight_takeoff_outlined),

                    const SizedBox(height: 24),

                    // ── Price range ───────────────────────────────────
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Price range',
                            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                        Text(
                          '$currency ${_priceRange.start.toStringAsFixed(0)} – ${_priceRange.end.toStringAsFixed(0)}',
                          style: const TextStyle(
                              color: Color(0xFFD4AF37), fontWeight: FontWeight.w600),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    RangeSlider(
                      values: _priceRange,
                      min: minP,
                      max: maxP == minP ? minP + 1 : maxP,
                      divisions: maxP == minP ? 1 : 20,
                      activeColor: const Color(0xFFD4AF37),
                      inactiveColor: const Color(0xFFE0D090),
                      onChanged: (v) {
                        setSheetState(() => _priceRange = v);
                        setState(() => _priceRange = v);
                      },
                    ),

                    const SizedBox(height: 24),

                    // ── Airlines ──────────────────────────────────────
                    if (airlines.isNotEmpty) ...[
                      const Text('Airlines',
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 12),
                      ...airlines.map((airline) {
                        final selected = _selectedAirlines.contains(airline);
                        final count = airlineCounts[airline] ?? 0;
                        return GestureDetector(
                          onTap: () {
                            setSheetState(() {});
                            setState(() {
                              selected
                                  ? _selectedAirlines.remove(airline)
                                  : _selectedAirlines.add(airline);
                            });
                          },
                          child: Container(
                            margin: const EdgeInsets.only(bottom: 8),
                            padding: const EdgeInsets.symmetric(
                                horizontal: 16, vertical: 14),
                            decoration: BoxDecoration(
                              color: selected
                                  ? const Color(0xFFFFF8E6)
                                  : Colors.white,
                              border: Border.all(
                                color: selected
                                    ? const Color(0xFFD4AF37)
                                    : Colors.transparent,
                              ),
                              borderRadius: BorderRadius.circular(14),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.04),
                                  blurRadius: 6,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(6),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFFFF8E6),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: const Icon(Icons.flight,
                                      size: 16, color: Color(0xFFD4AF37)),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Text(airline,
                                      style: TextStyle(
                                          fontSize: 14,
                                          fontWeight: selected
                                              ? FontWeight.bold
                                              : FontWeight.normal,
                                          color: selected
                                              ? const Color(0xFFD4AF37)
                                              : Colors.black87)),
                                ),
                                // Flight count badge
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 10, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: selected
                                        ? const Color(0xFFD4AF37)
                                        : Colors.grey.shade100,
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Text(
                                    '$count flight${count != 1 ? 's' : ''}',
                                    style: TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w600,
                                        color: selected
                                            ? Colors.white
                                            : Colors.grey.shade600),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Icon(
                                  selected
                                      ? Icons.check_circle
                                      : Icons.circle_outlined,
                                  color: selected
                                      ? const Color(0xFFD4AF37)
                                      : Colors.grey.shade300,
                                  size: 22,
                                ),
                              ],
                            ),
                          ),
                        );
                      }),
                    ],
                    const SizedBox(height: 16),
                  ],
                ),
              ),
              // Apply button
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
                child: SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () => Navigator.pop(ctx),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFFFD700),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14)),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      elevation: 0,
                    ),
                    child: const Text('Apply',
                        style: TextStyle(
                            color: Colors.black,
                            fontWeight: FontWeight.bold,
                            fontSize: 16)),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _sortOption(BuildContext ctx, StateSetter setSheetState,
      String value, String label, IconData icon) {
    final selected = _sortBy == value;
    return GestureDetector(
      onTap: () {
        setSheetState(() {});
        setState(() => _sortBy = value);
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        decoration: BoxDecoration(
          color: selected ? const Color(0xFFFFF8E6) : Colors.white,
          border: Border.all(
            color: selected ? const Color(0xFFD4AF37) : Colors.transparent,
          ),
          borderRadius: BorderRadius.circular(14),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            Icon(icon,
                size: 20,
                color: selected ? const Color(0xFFD4AF37) : Colors.grey),
            const SizedBox(width: 12),
            Expanded(
              child: Text(label,
                  style: TextStyle(
                      fontSize: 15,
                      fontWeight:
                          selected ? FontWeight.bold : FontWeight.normal,
                      color: selected
                          ? const Color(0xFFD4AF37)
                          : Colors.black87)),
            ),
            if (selected)
              const Icon(Icons.check,
                  color: Color(0xFFD4AF37), size: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildFlightCard(BuildContext context, ApiOffer offer, int index) {
    final seg = offer.firstSegment;
    final lastSeg = offer.outboundFlight?.segments.last;
    final depTime = offer.departureTime;
    final arrTime = offer.arrivalTime;
    final duration = offer.duration;
    final price = offer.pricing.total;
    final baseFare = offer.pricing.baseFare;
    final taxes = offer.pricing.taxes;
    final currency = offer.pricing.currency;
    final baggage = offer.baggageInfo;
    final stops = (offer.outboundFlight?.segments.length ?? 1) - 1;
    final flightNumber = seg?.flightNumber ?? '';
    final depAirport = seg?.departureAirportName.isNotEmpty == true
        ? seg!.departureAirportName : offer.originCode;
    final arrAirport = lastSeg?.arrivalAirportName.isNotEmpty == true
        ? lastSeg!.arrivalAirportName : offer.destinationCode;
    final cabinClass = seg?.classOfService.isNotEmpty == true
        ? seg!.classOfService : 'Economy';
    final ticketLimit = offer.ticketTimeLimit;
    final penaltyInfo = offer.penaltyInfo;
    final isExpanded = _expandedOfferIds.contains(offer.offerId);
    final segments = offer.outboundFlight?.segments ?? [];

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.06), blurRadius: 10, offset: const Offset(0, 4))],
      ),
      child: Column(
        children: [
          if (offer.isCheapest)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
              decoration: const BoxDecoration(
                gradient: LinearGradient(colors: [Color(0xFF00BFA5), Color(0xFF00897B)]),
                borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
              ),
              child: const Text('Cheapest option',
                  style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold)),
            ),

          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ── Times row ─────────────────────────────────────
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Text(depTime, style: const TextStyle(fontSize: 26, fontWeight: FontWeight.bold)),
                      Text(offer.originCode, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
                      SizedBox(width: 90, child: Text(depAirport, maxLines: 2,
                          style: const TextStyle(fontSize: 11, color: Color(0xFF9E9E9E)))),
                    ]),
                    Expanded(child: Column(children: [
                      const SizedBox(height: 4),
                      Text(duration, textAlign: TextAlign.center,
                          style: const TextStyle(fontSize: 12, color: Color(0xFFD4AF37), fontWeight: FontWeight.w600)),
                      const SizedBox(height: 4),
                      Stack(alignment: Alignment.center, children: [
                        Container(height: 1.5, color: const Color(0xFFD4AF37)),
                        const Icon(Icons.flight, size: 16, color: Color(0xFFD4AF37)),
                      ]),
                      const SizedBox(height: 4),
                      Text(stops == 0 ? 'Direct' : '$stops stop${stops > 1 ? 's' : ''}',
                          textAlign: TextAlign.center,
                          style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600,
                              color: stops == 0 ? const Color(0xFF00BFA5) : Colors.orange)),
                    ])),
                    Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
                      Text(arrTime, style: const TextStyle(fontSize: 26, fontWeight: FontWeight.bold)),
                      Text(offer.destinationCode, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
                      SizedBox(width: 90, child: Text(arrAirport, maxLines: 2, textAlign: TextAlign.end,
                          style: const TextStyle(fontSize: 11, color: Color(0xFF9E9E9E)))),
                    ]),
                  ],
                ),

                const SizedBox(height: 12),
                const Divider(height: 1, color: Color(0xFFF0F0F0)),
                const SizedBox(height: 10),

                // ── Airline + cabin ────────────────────────────────
                Row(children: [
                  Container(padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(color: const Color(0xFFFFF8E6), borderRadius: BorderRadius.circular(8)),
                      child: const Icon(Icons.flight, size: 16, color: Color(0xFFD4AF37))),
                  const SizedBox(width: 8),
                  Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Text(offer.airlineName, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
                    if (flightNumber.isNotEmpty)
                      Text(flightNumber, style: const TextStyle(fontSize: 11, color: Color(0xFF9E9E9E))),
                  ])),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(color: const Color(0xFFF5F5F5), borderRadius: BorderRadius.circular(8)),
                    child: Text(cabinClass, style: const TextStyle(fontSize: 11, color: Color(0xFF757575))),
                  ),
                ]),

                const SizedBox(height: 10),

                // ── Baggage + price ────────────────────────────────
                Row(children: [
                  if (baggage.isNotEmpty) ...[
                    const Icon(Icons.luggage, size: 15, color: Color(0xFF00BFA5)),
                    const SizedBox(width: 4),
                    Text(baggage, style: const TextStyle(fontSize: 12, color: Color(0xFF00BFA5), fontWeight: FontWeight.w500)),
                  ],
                  const Spacer(),
                  Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
                    Text('$currency ${price.toStringAsFixed(0)}',
                        style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFFD4AF37))),
                    Text('Base ${baseFare.toStringAsFixed(0)} + Tax ${taxes.toStringAsFixed(0)}',
                        style: const TextStyle(fontSize: 10, color: Color(0xFF9E9E9E))),
                  ]),
                ]),

                // ── Ticket limit / penalty ─────────────────────────
                if (ticketLimit != null || penaltyInfo != null) ...[
                  const SizedBox(height: 8),
                  Row(children: [
                    if (ticketLimit != null) ...[
                      const Icon(Icons.access_time, size: 13, color: Color(0xFFE57373)),
                      const SizedBox(width: 4),
                      Flexible(child: Text('Ticket by: $ticketLimit',
                          style: const TextStyle(fontSize: 11, color: Color(0xFFE57373)),
                          overflow: TextOverflow.ellipsis)),
                    ],
                    if (ticketLimit != null && penaltyInfo != null) const SizedBox(width: 12),
                    if (penaltyInfo != null) ...[
                      const Icon(Icons.info_outline, size: 13, color: Color(0xFF9E9E9E)),
                      const SizedBox(width: 4),
                      Flexible(child: Text(penaltyInfo,
                          style: const TextStyle(fontSize: 11, color: Color(0xFF9E9E9E)),
                          overflow: TextOverflow.ellipsis)),
                    ],
                  ]),
                ],

                const SizedBox(height: 10),
                const Divider(height: 1, color: Color(0xFFF0F0F0)),

                // ── Action row: Details | Share | Price Alert | Book ─
                Row(children: [
                  // Expand/collapse details
                  GestureDetector(
                    onTap: () => setState(() => isExpanded
                        ? _expandedOfferIds.remove(offer.offerId)
                        : _expandedOfferIds.add(offer.offerId)),
                    child: Row(children: [
                      Icon(isExpanded ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down,
                          size: 18, color: const Color(0xFFD4AF37)),
                      Text(isExpanded ? 'Hide details' : 'Flight details',
                          style: const TextStyle(fontSize: 12, color: Color(0xFFD4AF37), fontWeight: FontWeight.w600)),
                    ]),
                  ),
                  const SizedBox(width: 12),
                  // Share
                  GestureDetector(
                    onTap: () {
                      final text = '✈ ${offer.originCode} → ${offer.destinationCode}\n'
                          '$depTime – $arrTime | $duration\n'
                          '${offer.airlineName} $flightNumber\n'
                          '$currency ${price.toStringAsFixed(0)}';
                      Get.snackbar('Share', text,
                          snackPosition: SnackPosition.BOTTOM,
                          duration: const Duration(seconds: 3));
                    },
                    child: const Row(children: [
                      Icon(Icons.share_outlined, size: 16, color: Color(0xFF9E9E9E)),
                      SizedBox(width: 4),
                      Text('Share', style: TextStyle(fontSize: 12, color: Color(0xFF9E9E9E))),
                    ]),
                  ),
                  const Spacer(),
                  // Book button
                  ElevatedButton(
                    onPressed: () {
                      _searchCtrl.selectedOffer.value = offer;
                      context.read<BookingProvider>().setSearchParams(
                          context.read<BookingProvider>().bookingData.searchParams!);
                      Get.toNamed(AppRoutes.fareSelection);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFFFD700),
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      elevation: 0,
                    ),
                    child: const Text('Book', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 13)),
                  ),
                ]),

                // ── Expanded segment details ───────────────────────
                if (isExpanded && segments.isNotEmpty) ...[
                  const SizedBox(height: 12),
                  const Divider(height: 1, color: Color(0xFFF0F0F0)),
                  const SizedBox(height: 12),
                  const Text('Flight segments',
                      style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Color(0xFF2C2C2C))),
                  const SizedBox(height: 10),
                  ...segments.asMap().entries.map((e) {
                    final i = e.key;
                    final s = e.value;
                    final sDep = s.departureDateTime;
                    final sArr = s.arrivalDateTime;
                    final sDepTime = sDep != null
                        ? '${sDep.hour.toString().padLeft(2, '0')}:${sDep.minute.toString().padLeft(2, '0')}' : '--:--';
                    final sArrTime = sArr != null
                        ? '${sArr.hour.toString().padLeft(2, '0')}:${sArr.minute.toString().padLeft(2, '0')}' : '--:--';
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (i > 0)
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 8),
                            child: Row(children: [
                              const Icon(Icons.transfer_within_a_station, size: 14, color: Colors.orange),
                              const SizedBox(width: 4),
                              Text('Transit: ${s.departureAirportName.isNotEmpty ? s.departureAirportName : s.departureAirport}',
                                  style: const TextStyle(fontSize: 11, color: Colors.orange, fontWeight: FontWeight.w600)),
                            ]),
                          ),
                        Row(children: [
                          Column(children: [
                            Container(width: 8, height: 8,
                                decoration: const BoxDecoration(color: Color(0xFFD4AF37), shape: BoxShape.circle)),
                            Container(width: 1, height: 40, color: const Color(0xFFD4AF37)),
                            Container(width: 8, height: 8,
                                decoration: const BoxDecoration(color: Color(0xFFD4AF37), shape: BoxShape.circle)),
                          ]),
                          const SizedBox(width: 12),
                          Expanded(child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                                Text(sDepTime, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                                Text(s.departureAirport, style: const TextStyle(fontSize: 12, color: Color(0xFF9E9E9E))),
                              ]),
                              Padding(
                                padding: const EdgeInsets.symmetric(vertical: 4),
                                child: Text('${s.airlineName} ${s.flightNumber} · ${s.classOfService}',
                                    style: const TextStyle(fontSize: 11, color: Color(0xFF9E9E9E))),
                              ),
                              Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                                Text(sArrTime, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                                Text(s.arrivalAirport, style: const TextStyle(fontSize: 12, color: Color(0xFF9E9E9E))),
                              ]),
                            ],
                          )),
                        ]),
                        const SizedBox(height: 8),
                      ],
                    );
                  }),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}
