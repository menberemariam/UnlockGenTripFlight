import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:get/get.dart';
import '../../providers/booking_provider.dart';
import '../../controllers/flight_booking_controller.dart';
import '../../controllers/flight_search_controller.dart';

class AddonsScreen extends StatefulWidget {
  const AddonsScreen({super.key});

  @override
  State<AddonsScreen> createState() => _AddonsScreenState();
}

class _AddonsScreenState extends State<AddonsScreen> {
  String? selectedSeat;
  bool showSeatMap = false;
  @override
  Widget build(BuildContext context) {
    final bookingProvider = context.watch<BookingProvider>();
    final fare = bookingProvider.bookingData.selectedFare;
    final flightController = Get.find<FlightBookingController>();
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Select seat'),
        actions: [
          _buildStepIndicator(),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  _buildFlightSummary(flightController),
                  if (showSeatMap) _buildSeatMap() else _buildAddonsOptions(),
                ],
              ),
            ),
          ),
          _buildBottomBar(context, fare),
        ],
      ),
    );
  }

  Widget _buildFlightSummary(FlightBookingController flightController) {
    final isRoundTrip = flightController.isRoundTrip;
    final departure = flightController.selectedOutboundFlight.value;
    final returnFlight = flightController.selectedReturnFlight.value;

    return Container(
      padding: const EdgeInsets.all(16),
      color: const Color(0xFFFFF8E6),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.flight_takeoff, color: Color(0xFFEAA21B)),
              const SizedBox(width: 8),
              Text(
                isRoundTrip ? 'Round Trip' : 'One Way',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          
          // Departure Flight Info
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '${flightController.departureCity.value} → ${flightController.destinationCity.value}',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              if (departure != null)
                Text(
                  '${departure.departureTime} - ${departure.arrivalTime}',
                  style: TextStyle(color: Colors.grey.shade700),
                ),
            ],
          ),
          
          if (departure != null) ...[
            const SizedBox(height: 4),
            Text(
              '${departure.airline} • ${departure.duration}',
              style: TextStyle(color: Colors.grey.shade700, fontSize: 13),
            ),
          ],

          // Return Flight Info (only for round trip)
          if (isRoundTrip && returnFlight != null) ...[
            const Divider(height: 20, thickness: 1),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '${flightController.destinationCity.value} → ${flightController.departureCity.value}',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  '${returnFlight.departureTime} - ${returnFlight.arrivalTime}',
                  style: TextStyle(color: Colors.grey.shade700),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              '${returnFlight.airline} • ${returnFlight.duration}',
              style: TextStyle(color: Colors.grey.shade700, fontSize: 13),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildStepIndicator() {
    return Padding(
      padding: const EdgeInsets.only(right: 16),
      child: Row(
        children: [
          _buildStep(1, true),
          _buildStep(2, true),
          _buildStep(3, false),
          _buildStep(4, false),
        ],
      ),
    );
  }

  Widget _buildStep(int number, bool active) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 4),
      width: 24,
      height: 24,
      decoration: BoxDecoration(
        color: active ? Color(0xFFD4AF37) : Colors.grey.shade300,
        shape: BoxShape.circle,
      ),
      child: Center(
        child: Text(
          '$number',
          style: TextStyle(
            color: active ? Colors.white : Colors.grey.shade600,
            fontSize: 12,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  Widget _buildSeatMap() {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildLegendItem('Free', Colors.cyan.shade100),
              const SizedBox(width: 16),
              _buildLegendItem('Not available', Colors.grey.shade200),
            ],
          ),
          const SizedBox(height: 8),
          const Text(
            'Premium economy class',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          _buildSeatGrid(),
        ],
      ),
    );
  }

  Widget _buildLegendItem(String label, Color color) {
    return Row(
      children: [
        Container(
          width: 20,
          height: 20,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(4),
          ),
        ),
        const SizedBox(width: 4),
        Text(label, style: const TextStyle(fontSize: 12)),
      ],
    );
  }

  Widget _buildSeatGrid() {
    const rows = 8;
    const cols = ['A', 'B', 'C', '', 'D', 'E', 'F'];

    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: cols.map((col) => SizedBox(
                width: 40,
                child: Text(
                  col,
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              )).toList(),
        ),
        ...List.generate(rows, (row) {
          final unavailable = row >= 5;
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 4),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ...cols.take(3).map((col) => _buildSeat('$col${row + 1}', unavailable)),
                SizedBox(
                  width: 40,
                  child: Text(
                    '${row + 1}',
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
                ...cols.skip(4).map((col) => _buildSeat('$col${row + 1}', unavailable)),
              ],
            ),
          );
        }),
      ],
    );
  }

  Widget _buildSeat(String seatId, bool unavailable) {
    final isSelected = selectedSeat == seatId;
    return GestureDetector(
      onTap: unavailable ? null : () => setState(() => selectedSeat = seatId),
      child: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: unavailable
              ? Colors.grey.shade200
              : isSelected
                  ? Color(0xFFD4AF37)
              : Colors.cyan.shade100,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isSelected ? Color(0xFFEAA21B) : Colors.grey.shade300,
          ),
        ),
        child: Center(
          child: unavailable
              ? Icon(Icons.close, color: Colors.grey.shade400, size: 20)
              : null,
        ),
      ),
    );
  }

  Widget _buildAddonsOptions() {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Enhance your journey',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          _buildAddonCard(
            'Select your seat',
            'Choose your preferred seat for comfort',
            Icons.airline_seat_recline_normal,
            () => setState(() => showSeatMap = true),
          ),
          _buildAddonCard(
            'In-flight meals',
            'Pre-order delicious meals starting from £2.90',
            Icons.restaurant,
            () {},
          ),
          _buildAddonCard(
            'Extra baggage',
            'Add more checked baggage allowance',
            Icons.luggage,
            () {},
          ),
          _buildAddonCard(
            'VIP Lounge Access',
            'Relax before your flight for £16.20',
            Icons.weekend,
            () {},
          ),
          _buildAddonCard(
            'Travel insurance',
            'Protect your trip with comprehensive coverage',
            Icons.shield,
            () {},
          ),
        ],
      ),
    );
  }

  Widget _buildAddonCard(String title, String description, IconData icon, VoidCallback onTap) {
    return Card(
      color: const Color(0xFFFFF8E6),
      margin: const EdgeInsets.only(bottom: 12),

      child: ListTile(
        leading: Icon(icon, color: Color(0xFFEAA21B), size: 32),
        title: Text(
          title,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Text(description),
        trailing: const Icon(Icons.chevron_right),
        onTap: onTap,
      ),
    );
  }

  Widget _buildBottomBar(BuildContext context, fare) {
    final searchCtrl = Get.find<FlightSearchController>();
    final total = searchCtrl.totalDisplayPrice;
    final currency = searchCtrl.displayCurrency;
    final displayPrice = total > 0
        ? '$currency ${total.toStringAsFixed(2)}'
        : '£${fare?.price.toStringAsFixed(2) ?? '0.00'}';

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.grey.shade300,
            blurRadius: 4,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Total (1 adult)',
                style: TextStyle(fontSize: 12, color: Colors.grey),
              ),
              Row(
                children: [
                  Text(
                    displayPrice,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(width: 4),
                  const Icon(Icons.info_outline, size: 16, color: Colors.grey),
                ],
              ),
            ],
          ),
          ElevatedButton(
            onPressed: () {
              if (selectedSeat != null) {
                context.read<BookingProvider>().setSeat(selectedSeat);
              }
              Get.toNamed('/payment');
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Color(0xFFEAA21B),
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
            ),
            child: Text(
              showSeatMap ? 'Continue to Payment' : 'Skip to Payment',
              style: const TextStyle(fontSize: 16, color: Colors.black),
            ),
          ),
        ],
      ),
    );
  }
}
