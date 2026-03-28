import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/flight_search_controller.dart';
import '../../routes/app_routes.dart';

class SelectFareScreen extends StatelessWidget {
  const SelectFareScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final searchCtrl = Get.find<FlightSearchController>();
    final offer = searchCtrl.selectedOffer.value;

    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              _buildHeader(),
              _buildFlightSummary(offer),
              _buildClassTabs(),
              _buildFareCard(searchCtrl),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(16),
      color: Colors.white,
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => Get.back(),
          ),
          const SizedBox(width: 10),
          const Text(
            "Select fare",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const Spacer(),
          const Icon(Icons.notifications_none),
        ],
      ),
    );
  }

  Widget _buildFlightSummary(offer) {
    if (offer == null) {
      return const Padding(
        padding: EdgeInsets.all(16),
        child: Text('No flight selected'),
      );
    }

    final outbound = offer.outboundFlight;
    final returnFlight = offer.returnFlight;
    final outSeg = outbound?.segments.isNotEmpty == true ? outbound!.segments.first : null;
    final retSeg = returnFlight?.segments.isNotEmpty == true ? returnFlight!.segments.first : null;

    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Depart  ${offer.duration}",
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 10),
          _timelineRow(offer.departureTime, '${offer.originCode}  ${outSeg?.departureAirportName ?? ''}'),
          const SizedBox(height: 8),
          Text(
            '${offer.airlineName}  ${outSeg?.flightNumber ?? ''}',
            style: const TextStyle(color: Colors.grey),
          ),
          const SizedBox(height: 8),
          _timelineRow(offer.arrivalTime, '${offer.destinationCode}  ${outbound?.segments.last.arrivalAirportName ?? ''}'),

          if (returnFlight != null) ...[
            const Divider(height: 30),
            Text(
              "Return  ${returnFlight.formattedDuration}",
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            _timelineRow(
              retSeg?.departureDateTime != null
                  ? '${retSeg!.departureDateTime!.hour.toString().padLeft(2, '0')}:${retSeg.departureDateTime!.minute.toString().padLeft(2, '0')}'
                  : '',
              '${returnFlight.originCode}  ${retSeg?.departureAirportName ?? ''}',
            ),
            const SizedBox(height: 8),
            Text(
              '${retSeg?.airlineName ?? offer.airlineName}  ${retSeg?.flightNumber ?? ''}',
              style: const TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 8),
            _timelineRow(
              returnFlight.segments.last.arrivalDateTime != null
                  ? '${returnFlight.segments.last.arrivalDateTime!.hour.toString().padLeft(2, '0')}:${returnFlight.segments.last.arrivalDateTime!.minute.toString().padLeft(2, '0')}'
                  : '',
              '${returnFlight.destinationCode}  ${returnFlight.segments.last.arrivalAirportName}',
            ),
          ],
        ],
      ),
    );
  }

  Widget _timelineRow(String time, String airport) {
    return Row(
      children: [
        Text(time, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        const SizedBox(width: 12),
        Expanded(child: Text(airport)),
      ],
    );
  }

  Widget _buildClassTabs() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.grey.shade200,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Expanded(
            child: Container(
              padding: const EdgeInsets.all(14),
              decoration: const BoxDecoration(
                border: Border(bottom: BorderSide(width: 3, color: Colors.black)),
              ),
              child: const Center(child: Text("Economy")),
            ),
          ),
          Expanded(
            child: Container(
              padding: const EdgeInsets.all(14),
              child: const Center(child: Text("Premium Economy")),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFareCard(FlightSearchController searchCtrl) {
    final offer = searchCtrl.selectedOffer.value;
    if (offer == null) return const SizedBox.shrink();

    final total = searchCtrl.totalDisplayPrice;
    final currency = searchCtrl.displayCurrency;
    final features = offer.priceClassDescriptions;
    final baggage = offer.baggageServices;

    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (offer.isCheapest)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.teal.shade100,
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Text("Lowest price", style: TextStyle(fontSize: 12)),
            ),
          const SizedBox(height: 16),
          Row(
            children: [
              Text(
                '$currency ${total.toStringAsFixed(0)}',
                style: const TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFFD4AF37),
                ),
              ),
              const Spacer(),
              Obx(() => ElevatedButton(
                onPressed: searchCtrl.isLoading.value
                    ? null
                    : () async {
                        final ok = await searchCtrl.priceOffer(offer);
                        if (ok) {
                          Get.toNamed(AppRoutes.passengerInfo);
                        } else {
                          Get.snackbar('Error', searchCtrl.errorMessage.value,
                              snackPosition: SnackPosition.BOTTOM);
                        }
                      },
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 12),
                ),
                child: searchCtrl.isLoading.value
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Text("Select"),
              )),
            ],
          ),
          const SizedBox(height: 20),
          if (baggage.isNotEmpty)
            _featureRow(Icons.luggage, baggage.first.description),
          ...features.map((f) => _featureRow(Icons.check, f.descText)),
          if (features.isEmpty) ...[
            _featureRow(Icons.work_outline, "Personal item: Included"),
            _featureRow(Icons.luggage, "Carry-on baggage: 1 × 7 kg"),
            _featureRow(Icons.restaurant, "Hot meals provided"),
          ],
        ],
      ),
    );
  }

  Widget _featureRow(IconData icon, String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        children: [
          Icon(icon, size: 18),
          const SizedBox(width: 8),
          Expanded(child: Text(text)),
        ],
      ),
    );
  }
}
