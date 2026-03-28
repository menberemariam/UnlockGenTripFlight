import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../../controllers/flight_booking_controller.dart';
import '../../controllers/flight_search_controller.dart';
import '../../model/api_models.dart';
import '../../routes/app_routes.dart';

class ReturnResultsScreen extends StatefulWidget {
  const ReturnResultsScreen({super.key});

  @override
  State<ReturnResultsScreen> createState() => _ReturnResultsScreenState();
}

class _ReturnResultsScreenState extends State<ReturnResultsScreen> {
  late FlightSearchController searchCtrl;
  late FlightBookingController bookingCtrl;
  final _dateScrollCtrl = ScrollController();

  // Filter & sort state
  bool _directOnly = false;
  String _sortBy = 'price';
  final Set<String> _selectedAirlines = {};
  RangeValues _priceRange = const RangeValues(0, 5000);
  double _maxPrice = 5000;

  @override
  void initState() {
    super.initState();
    searchCtrl = Get.find<FlightSearchController>();
    bookingCtrl = Get.find<FlightBookingController>();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_dateScrollCtrl.hasClients) {
        _dateScrollCtrl.jumpTo(8 * 74.0 - 100);
      }
    });
  }

  @override
  void dispose() {
    _dateScrollCtrl.dispose();
    super.dispose();
  }

  void _retriggerSearch() {
    searchCtrl.searchFlights(
      fromCity: bookingCtrl.departureCity.value,
      toCity: bookingCtrl.destinationCity.value,
      departureDate: bookingCtrl.rangeStart.value ?? DateTime.now(),
      returnDate: bookingCtrl.rangeEnd.value,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      body: SafeArea(
        child: Obx(() {
          if (searchCtrl.isLoading.value) {
            return const Center(child: CircularProgressIndicator(color: Color(0xFFFFD700)));
          }
          // subscribe to offers
          searchCtrl.offers.length;

          final roundTripOffers = searchCtrl.offers.where((o) => o.returnFlight != null).toList();
          if (roundTripOffers.isEmpty) {
            return const Center(child: Text('No return flights available'));
          }
          return _buildBody(context, roundTripOffers);
        }),
      ),
    );
  }

  Widget _buildBody(BuildContext context, List<ApiOffer> allOffers) {
    // Apply filters
    final filtered = allOffers.where((o) {
      final ret = o.returnFlight!;
      if (_directOnly && ret.segments.length > 1) return false;
      if (_selectedAirlines.isNotEmpty) {
        final airline = ret.segments.isNotEmpty ? ret.segments.first.airlineName : o.airlineName;
        if (!_selectedAirlines.contains(airline)) return false;
      }
      if (o.pricing.total > _priceRange.end || o.pricing.total < _priceRange.start) return false;
      return true;
    }).toList();

    filtered.sort((a, b) {
      if (_sortBy == 'duration') {
        return (a.returnFlight?.duration ?? '').compareTo(b.returnFlight?.duration ?? '');
      } else if (_sortBy == 'departure') {
        final aDep = a.returnFlight?.segments.firstOrNull?.departureDateTime ?? DateTime(2100);
        final bDep = b.returnFlight?.segments.firstOrNull?.departureDateTime ?? DateTime(2100);
        return aDep.compareTo(bDep);
      }
      return a.pricing.total.compareTo(b.pricing.total);
    });

    return Column(
      children: [
        _buildHeader(bookingCtrl),
        _buildDateStrip(),
        _buildFilterBar(),
        if (filtered.isEmpty)
          const Expanded(child: Center(child: Text('No flights match your filters')))
        else
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: filtered.length,
              itemBuilder: (context, index) => _buildFlightCard(searchCtrl, filtered[index], index),
            ),
          ),
        _buildBottomBar(searchCtrl),
      ],
    );
  }

  Widget _buildFilterBar() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 8, offset: const Offset(0, 2))],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          GestureDetector(
            onTap: () => setState(() => _sortBy = _sortBy == 'duration' ? 'price' : 'duration'),
            child: Row(children: [
              Icon(Icons.speed, color: _sortBy == 'duration' ? const Color(0xFFD4AF37) : Colors.grey),
              const SizedBox(width: 8),
              Text('Fastest', style: TextStyle(
                  fontWeight: FontWeight.w600,
                  color: _sortBy == 'duration' ? const Color(0xFFD4AF37) : const Color(0xFF2C2C2C))),
              if (_sortBy == 'duration') ...[const SizedBox(width: 4), const Icon(Icons.check, size: 14, color: Color(0xFFD4AF37))],
            ]),
          ),
          GestureDetector(
            onTap: () => setState(() => _directOnly = !_directOnly),
            child: Row(children: [
              Icon(Icons.flight, color: _directOnly ? const Color(0xFFD4AF37) : Colors.grey),
              const SizedBox(width: 8),
              Text('Direct', style: TextStyle(
                  fontWeight: FontWeight.w600,
                  color: _directOnly ? const Color(0xFFD4AF37) : const Color(0xFF2C2C2C))),
              if (_directOnly) ...[const SizedBox(width: 4), const Icon(Icons.check, size: 14, color: Color(0xFFD4AF37))],
            ]),
          ),
          GestureDetector(
            onTap: _showFilterSheet,
            child: Row(children: [
              Icon(Icons.filter_alt_outlined,
                  color: (_selectedAirlines.isNotEmpty || _priceRange.end < _maxPrice)
                      ? const Color(0xFFD4AF37) : Colors.grey),
              const SizedBox(width: 8),
              Text('Filters', style: TextStyle(
                  fontWeight: FontWeight.w600,
                  color: (_selectedAirlines.isNotEmpty || _priceRange.end < _maxPrice)
                      ? const Color(0xFFD4AF37) : const Color(0xFF2C2C2C))),
            ]),
          ),
        ],
      ),
    );
  }

  void _showFilterSheet() {
    final offers = searchCtrl.offers.where((o) => o.returnFlight != null).toList();
    final Map<String, int> airlineCounts = {};
    for (final o in offers) {
      final name = o.returnFlight?.segments.isNotEmpty == true
          ? o.returnFlight!.segments.first.airlineName : o.airlineName;
      if (name.isNotEmpty) airlineCounts[name] = (airlineCounts[name] ?? 0) + 1;
    }
    final airlines = airlineCounts.keys.toList()..sort();
    final prices = offers.map((o) => o.pricing.total).toList();
    final minP = prices.isEmpty ? 0.0 : prices.reduce((a, b) => a < b ? a : b);
    final maxP = prices.isEmpty ? 5000.0 : prices.reduce((a, b) => a > b ? a : b);
    if (_maxPrice == 5000 && maxP != 5000) { _maxPrice = maxP; _priceRange = RangeValues(minP, maxP); }
    final currency = offers.isNotEmpty ? offers.first.pricing.currency : 'EUR';

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: const Color(0xFFFFF8E6),
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (_) => StatefulBuilder(
        builder: (ctx, setSheet) => DraggableScrollableSheet(
          expand: false, initialChildSize: 0.75, maxChildSize: 0.92,
          builder: (_, scrollCtrl) => Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 12, 24, 0),
                child: Column(children: [
                  Center(child: Container(width: 40, height: 4,
                      decoration: BoxDecoration(color: Colors.grey.shade300, borderRadius: BorderRadius.circular(2)))),
                  const SizedBox(height: 16),
                  Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                    const Text('Sort & Filter', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    TextButton(
                      onPressed: () { setSheet(() {}); setState(() { _sortBy = 'price'; _selectedAirlines.clear(); _priceRange = RangeValues(minP, maxP); }); },
                      child: const Text('Reset all', style: TextStyle(color: Color(0xFFD4AF37))),
                    ),
                  ]),
                ]),
              ),
              Expanded(
                child: ListView(controller: scrollCtrl, padding: const EdgeInsets.fromLTRB(24, 8, 24, 0), children: [
                  const Text('Sort by', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 10),
                  _sortOption(setSheet, 'price', 'Lowest price', Icons.attach_money),
                  const SizedBox(height: 8),
                  _sortOption(setSheet, 'duration', 'Shortest duration', Icons.timer_outlined),
                  const SizedBox(height: 8),
                  _sortOption(setSheet, 'departure', 'Earliest departure', Icons.flight_takeoff_outlined),
                  const SizedBox(height: 24),
                  Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                    const Text('Price range', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
                    Text('$currency ${_priceRange.start.toStringAsFixed(0)} – ${_priceRange.end.toStringAsFixed(0)}',
                        style: const TextStyle(color: Color(0xFFD4AF37), fontWeight: FontWeight.w600)),
                  ]),
                  RangeSlider(
                    values: _priceRange, min: minP, max: maxP == minP ? minP + 1 : maxP,
                    divisions: maxP == minP ? 1 : 20, activeColor: const Color(0xFFD4AF37), inactiveColor: const Color(0xFFE0D090),
                    onChanged: (v) { setSheet(() => _priceRange = v); setState(() => _priceRange = v); },
                  ),
                  if (airlines.isNotEmpty) ...[
                    const SizedBox(height: 16),
                    const Text('Airlines', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 10),
                    ...airlines.map((airline) {
                      final selected = _selectedAirlines.contains(airline);
                      final count = airlineCounts[airline] ?? 0;
                      return GestureDetector(
                        onTap: () { setSheet(() {}); setState(() => selected ? _selectedAirlines.remove(airline) : _selectedAirlines.add(airline)); },
                        child: Container(
                          margin: const EdgeInsets.only(bottom: 8),
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                          decoration: BoxDecoration(
                            color: selected ? const Color(0xFFFFF8E6) : Colors.white,
                            border: Border.all(color: selected ? const Color(0xFFD4AF37) : Colors.transparent),
                            borderRadius: BorderRadius.circular(14),
                            boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 6, offset: const Offset(0, 2))],
                          ),
                          child: Row(children: [
                            Container(padding: const EdgeInsets.all(6),
                                decoration: BoxDecoration(color: const Color(0xFFFFF8E6), borderRadius: BorderRadius.circular(8)),
                                child: const Icon(Icons.flight, size: 16, color: Color(0xFFD4AF37))),
                            const SizedBox(width: 12),
                            Expanded(child: Text(airline, style: TextStyle(fontSize: 14,
                                fontWeight: selected ? FontWeight.bold : FontWeight.normal,
                                color: selected ? const Color(0xFFD4AF37) : Colors.black87))),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                              decoration: BoxDecoration(color: selected ? const Color(0xFFD4AF37) : Colors.grey.shade100, borderRadius: BorderRadius.circular(12)),
                              child: Text('$count flight${count != 1 ? 's' : ''}',
                                  style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: selected ? Colors.white : Colors.grey.shade600)),
                            ),
                            const SizedBox(width: 8),
                            Icon(selected ? Icons.check_circle : Icons.circle_outlined,
                                color: selected ? const Color(0xFFD4AF37) : Colors.grey.shade300, size: 22),
                          ]),
                        ),
                      );
                    }),
                  ],
                  const SizedBox(height: 16),
                ]),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
                child: SizedBox(width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () => Navigator.pop(ctx),
                    style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFFFD700),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                        padding: const EdgeInsets.symmetric(vertical: 16), elevation: 0),
                    child: const Text('Apply', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 16)),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _sortOption(StateSetter setSheet, String value, String label, IconData icon) {
    final selected = _sortBy == value;
    return GestureDetector(
      onTap: () { setSheet(() {}); setState(() => _sortBy = value); },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        decoration: BoxDecoration(
          color: selected ? const Color(0xFFFFF8E6) : Colors.white,
          border: Border.all(color: selected ? const Color(0xFFD4AF37) : Colors.transparent),
          borderRadius: BorderRadius.circular(14),
          boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 6, offset: const Offset(0, 2))],
        ),
        child: Row(children: [
          Icon(icon, size: 20, color: selected ? const Color(0xFFD4AF37) : Colors.grey),
          const SizedBox(width: 12),
          Expanded(child: Text(label, style: TextStyle(fontSize: 15,
              fontWeight: selected ? FontWeight.bold : FontWeight.normal,
              color: selected ? const Color(0xFFD4AF37) : Colors.black87))),
          if (selected) const Icon(Icons.check, color: Color(0xFFD4AF37), size: 20),
        ]),
      ),
    );
  }

  Widget _buildDateStrip() {
    return Obx(() {
      final base = bookingCtrl.rangeEnd.value ?? DateTime.now();
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
                  bookingCtrl.rangeEnd.value = date;
                  _retriggerSearch();
                },
                child: Container(
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                  decoration: BoxDecoration(
                    gradient: isSelected
                        ? const LinearGradient(colors: [Color(0xFFFFD700), Color(0xFFFFC107)])
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

  Widget _buildHeader(FlightBookingController bookingCtrl) {
    return Container(
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFFFFD700), Color(0xFFFFC107)],
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFFFD700).withValues(alpha: 0.3),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: IconButton(
                  icon: const Icon(Icons.arrow_back, color: Colors.white),
                  onPressed: () => Get.back(),
                ),
              ),
              const SizedBox(width: 12),
              Obx(() => Text(
                    '${bookingCtrl.destinationCity.value} ⇄ ${bookingCtrl.departureCity.value}',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  )),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              _stepBox('2', 'Select return flight', true),
            ],
          ),
        ],
      ),
    );
  }

  Widget _stepBox(String number, String title, bool active) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          gradient: active
              ? const LinearGradient(colors: [Colors.white, Color(0xFFFFFDF7)])
              : null,
          color: active ? null : Colors.white.withValues(alpha: 0.3),
          borderRadius: BorderRadius.circular(12),
          boxShadow: active
              ? [BoxShadow(color: Colors.black.withValues(alpha: 0.1), blurRadius: 4, offset: const Offset(0, 2))]
              : null,
        ),
        child: Row(
          children: [
            Container(
              width: 28,
              height: 28,
              decoration: BoxDecoration(
                gradient: active
                    ? const LinearGradient(colors: [Color(0xFFFFD700), Color(0xFFFFC107)])
                    : null,
                color: active ? null : Colors.white.withValues(alpha: 0.5),
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Text(number,
                    style: TextStyle(
                        color: active ? Colors.white : Colors.white70,
                        fontSize: 14,
                        fontWeight: FontWeight.bold)),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(title,
                  style: TextStyle(
                      color: active ? const Color(0xFF2C2C2C) : Colors.white,
                      fontWeight: active ? FontWeight.bold : FontWeight.normal,
                      fontSize: 14)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFlightCard(FlightSearchController searchCtrl, ApiOffer offer, int index) {
    final returnJourney = offer.returnFlight!;
    final seg = returnJourney.segments.isNotEmpty ? returnJourney.segments.first : null;
    final lastSeg = returnJourney.segments.isNotEmpty ? returnJourney.segments.last : null;
    final depDt = seg?.departureDateTime;
    final arrDt = lastSeg?.arrivalDateTime;
    final depTime = depDt != null
        ? '${depDt.hour.toString().padLeft(2, '0')}:${depDt.minute.toString().padLeft(2, '0')}' : '--:--';
    final arrTime = arrDt != null
        ? '${arrDt.hour.toString().padLeft(2, '0')}:${arrDt.minute.toString().padLeft(2, '0')}' : '--:--';
    final stops = returnJourney.segments.length - 1;
    final depAirport = seg?.departureAirportName.isNotEmpty == true
        ? seg!.departureAirportName : returnJourney.originCode;
    final arrAirport = lastSeg?.arrivalAirportName.isNotEmpty == true
        ? lastSeg!.arrivalAirportName : returnJourney.destinationCode;
    final flightNumber = seg?.flightNumber ?? '';
    final cabinClass = seg?.classOfService.isNotEmpty == true ? seg!.classOfService : 'Economy';

    return Obx(() {
      final selected = searchCtrl.selectedOffer.value?.offerId == offer.offerId;
      return GestureDetector(
        onTap: () => searchCtrl.selectedOffer.value = offer,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          margin: const EdgeInsets.only(bottom: 16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: selected ? const Color(0xFFFFD700) : Colors.transparent,
              width: 2,
            ),
            boxShadow: [
              BoxShadow(
                color: selected
                    ? const Color(0xFFFFD700).withValues(alpha: 0.3)
                    : Colors.black.withValues(alpha: 0.06),
                blurRadius: selected ? 12 : 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            children: [
              if (index == 0)
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(colors: [Color(0xFF00BFA5), Color(0xFF00897B)]),
                    borderRadius: BorderRadius.vertical(top: Radius.circular(14)),
                  ),
                  child: const Text('Cheapest option',
                      style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold)),
                ),
              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(depTime, style: const TextStyle(fontSize: 26, fontWeight: FontWeight.bold)),
                            Text(returnJourney.originCode, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
                            SizedBox(width: 90, child: Text(depAirport, maxLines: 2,
                                style: const TextStyle(fontSize: 11, color: Color(0xFF9E9E9E)))),
                          ],
                        ),
                        Expanded(
                          child: Column(
                            children: [
                              const SizedBox(height: 4),
                              Text(returnJourney.formattedDuration, textAlign: TextAlign.center,
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
                            ],
                          ),
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(arrTime, style: const TextStyle(fontSize: 26, fontWeight: FontWeight.bold)),
                            Text(returnJourney.destinationCode, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
                            SizedBox(width: 90, child: Text(arrAirport, maxLines: 2, textAlign: TextAlign.end,
                                style: const TextStyle(fontSize: 11, color: Color(0xFF9E9E9E)))),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    const Divider(height: 1, color: Color(0xFFF0F0F0)),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(6),
                          decoration: BoxDecoration(color: const Color(0xFFFFF8E6), borderRadius: BorderRadius.circular(8)),
                          child: const Icon(Icons.flight, size: 16, color: Color(0xFFD4AF37)),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(seg?.airlineName ?? offer.airlineName,
                                  style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
                              if (flightNumber.isNotEmpty)
                                Text(flightNumber, style: const TextStyle(fontSize: 11, color: Color(0xFF9E9E9E))),
                            ],
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(color: const Color(0xFFF5F5F5), borderRadius: BorderRadius.circular(8)),
                          child: Text(cabinClass, style: const TextStyle(fontSize: 11, color: Color(0xFF757575))),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        if (offer.baggageInfo.isNotEmpty) ...[
                          const Icon(Icons.luggage, size: 15, color: Color(0xFF00BFA5)),
                          const SizedBox(width: 4),
                          Text(offer.baggageInfo,
                              style: const TextStyle(fontSize: 12, color: Color(0xFF00BFA5), fontWeight: FontWeight.w500)),
                        ],
                        const Spacer(),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text('${offer.pricing.currency} ${offer.pricing.total.toStringAsFixed(0)}',
                                style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFFD4AF37))),
                            Text('Base ${offer.pricing.baseFare.toStringAsFixed(0)} + Tax ${offer.pricing.taxes.toStringAsFixed(0)}',
                                style: const TextStyle(fontSize: 10, color: Color(0xFF9E9E9E))),
                          ],
                        ),
                      ],
                    ),
                    if (selected)
                      Padding(
                        padding: const EdgeInsets.only(top: 10),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            const Icon(Icons.check_circle, color: Color(0xFFD4AF37), size: 18),
                            const SizedBox(width: 4),
                            const Text('Selected', style: TextStyle(color: Color(0xFFD4AF37), fontWeight: FontWeight.bold, fontSize: 13)),
                          ],
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),
        ),
      );
    });
  }

  Widget _buildBottomBar(FlightSearchController searchCtrl) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(24),
          topRight: Radius.circular(24),
        ),
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 0.1), blurRadius: 16, offset: const Offset(0, -4)),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Obx(() {
          final currency = searchCtrl.displayCurrency;
          final total = searchCtrl.totalDisplayPrice;

          return Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      '$currency ${total.toStringAsFixed(2)}',
                      style: const TextStyle(
                          fontSize: 26, fontWeight: FontWeight.bold, color: Color(0xFFD4AF37)),
                    ),
                    const Text('Total price',
                        style: TextStyle(fontSize: 13, color: Color(0xFF757575))),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              Container(
                decoration: BoxDecoration(
                  gradient: const LinearGradient(colors: [Color(0xFFFFD700), Color(0xFFFFC107)]),
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFFFFD700).withValues(alpha: 0.4),
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: ElevatedButton(
                  onPressed: () {
                    if (searchCtrl.selectedOffer.value == null) {
                      Get.snackbar(
                        'Select a flight',
                        'Please select a return flight to continue',
                        backgroundColor: const Color(0xFFFFEBEE),
                        colorText: const Color(0xFFD32F2F),
                        snackPosition: SnackPosition.BOTTOM,
                        margin: const EdgeInsets.all(16),
                        borderRadius: 12,
                      );
                      return;
                    }
                    Get.toNamed(AppRoutes.selectFare);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.transparent,
                    shadowColor: Colors.transparent,
                    padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: const Text('Continue',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
                ),
              ),
            ],
          );
        }),
      ),
    );
  }
}
