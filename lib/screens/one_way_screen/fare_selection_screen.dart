import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:get/get.dart';
import '../../controllers/flight_search_controller.dart';
import 'passenger_info_screen.dart';

class FareSelectionScreen extends StatelessWidget {
  const FareSelectionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final searchCtrl = Get.find<FlightSearchController>();
    final offer = searchCtrl.selectedOffer.value;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Select fare'),
        actions: [
          IconButton(icon: const Icon(Icons.notifications_outlined), onPressed: () {}),
          IconButton(icon: const Icon(Icons.more_vert), onPressed: () {}),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildFlightInfo(offer),
            _buildWarningMessage(),
            _buildFareSelector(context, searchCtrl),
            _buildInfoBanner(),
          ],
        ),
      ),
    );
  }

  Widget _buildFlightInfo(offer) {
    if (offer == null) {
      return const Padding(
        padding: EdgeInsets.all(16),
        child: Text('No flight selected'),
      );
    }
    final seg = offer.firstSegment;
    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            seg?.departureDateTime != null
                ? DateFormat('EEE, MMM dd').format(seg!.departureDateTime!)
                : '',
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text(
            'Please pay attention to your departure date and arrive at the airport in advance.',
            style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Container(
                width: 4,
                height: 60,
                color: Colors.grey.shade400,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${offer.departureTime}  ${offer.originCode}  ${seg?.departureAirportName ?? ''}',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '— ${offer.airlineName}  ${seg?.flightNumber ?? ''}',
                      style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '${offer.arrivalTime}  ${offer.destinationCode}  ${offer.outboundFlight?.segments.last.arrivalAirportName ?? ''}',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildWarningMessage() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.orange.shade50,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.orange.shade200),
      ),
      child: Row(
        children: [
          Icon(Icons.info_outline, color: Colors.orange.shade700),
          const SizedBox(width: 8),
          const Expanded(
            child: Text(
              'Know before you go 1 message',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          const Icon(Icons.chevron_right),
        ],
      ),
    );
  }

  Widget _buildFareSelector(BuildContext context, FlightSearchController searchCtrl) {
    return Container(
      margin: const EdgeInsets.all(16),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(child: _buildFareTab('Economy', true)),
              Expanded(child: _buildFareTab('Premium Economy', false)),
            ],
          ),
          const SizedBox(height: 16),
          _buildFareCard(context, searchCtrl),
        ],
      ),
    );
  }

  Widget _buildFareTab(String label, bool selected) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: selected ? const Color(0xFF9B8E35) : Colors.transparent,
            width: 2,
          ),
        ),
      ),
      child: Text(
        label,
        textAlign: TextAlign.center,
        style: TextStyle(
          fontWeight: selected ? FontWeight.bold : FontWeight.normal,
        ),
      ),
    );
  }

  Widget _buildFareCard(BuildContext context, FlightSearchController searchCtrl) {
    final offer = searchCtrl.selectedOffer.value;
    if (offer == null) return const SizedBox.shrink();

    final price = offer.pricing.total;
    final currency = offer.pricing.currency;
    final features = offer.priceClassDescriptions;
    final baggage = offer.baggageServices;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '$currency ${price.toStringAsFixed(0)}',
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF9B8E35),
                    ),
                  ),
                  const Text('/person', style: TextStyle(color: Colors.grey)),
                ],
              ),
              Obx(() => ElevatedButton(
                onPressed: searchCtrl.isLoading.value
                    ? null
                    : () async {
                        final ok = await searchCtrl.priceOffer(offer);
                        if (ok) {
                          Get.to(() => const PassengerInfoScreen());
                        } else {
                          Get.snackbar('Error', searchCtrl.errorMessage.value,
                              snackPosition: SnackPosition.BOTTOM);
                        }
                      },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFFFC107),
                  padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                ),
                child: searchCtrl.isLoading.value
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2, color: Colors.black),
                      )
                    : const Text('Select', style: TextStyle(color: Colors.black)),
              )),
            ],
          ),
          const SizedBox(height: 16),
          // Baggage info from API
          if (baggage.isNotEmpty)
            _buildFareFeature(Icons.luggage, baggage.first.description, const Color(0xFFEAA21B)),
          // Price class features from API
          ...features.map((f) => _buildFareFeature(Icons.check, f.descText, const Color(0xFFEAA21B))),
          // Fallback features if API returns none
          if (features.isEmpty) ...[
            _buildFareFeature(Icons.shopping_bag, 'Personal item: Included', const Color(0xFFEAA21B)),
            _buildFareFeature(Icons.work_outline, 'Carry-on baggage: 1 piece', const Color(0xFFEAA21B)),
          ],
          const SizedBox(height: 8),
          Text(
            offer.priceClassName.isNotEmpty ? offer.priceClassName : 'Economy',
            style: const TextStyle(color: Color(0xFF9B8E35), fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }

  Widget _buildFareFeature(IconData icon, String text, Color color) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Icon(icon, size: 18, color: color),
          const SizedBox(width: 8),
          Expanded(child: Text(text, style: TextStyle(color: Colors.grey.shade700))),
        ],
      ),
    );
  }

  Widget _buildInfoBanner() {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.blue.shade50,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(Icons.help_outline, color: Colors.blue.shade700),
          const SizedBox(width: 12),
          const Expanded(
            child: Text(
              'Why are flight ticket prices always changing?',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }
}
