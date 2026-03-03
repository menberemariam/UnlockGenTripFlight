import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:get/get.dart';
import '../data/mock_data.dart';
import '../providers/booking_provider.dart';
import 'passenger_info_screen.dart';

class FareSelectionScreen extends StatelessWidget {
  const FareSelectionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final bookingProvider = context.watch<BookingProvider>();
    final flight = bookingProvider.bookingData.selectedFlight;
    final searchParams = bookingProvider.bookingData.searchParams;
    final fareTypes = MockData.getFareTypes();

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
            _buildFlightInfo(flight, searchParams),
            _buildWarningMessage(),
            _buildFareSelector(context, fareTypes),
            _buildInfoBanner(),
          ],
        ),
      ),
    );
  }

  Widget _buildFlightInfo(flight, searchParams) => Container(
    padding: const EdgeInsets.all(16),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '${DateFormat('EEE, MMM dd').format(searchParams?.date ?? DateTime.now())}  ${flight?.duration ?? ''}',
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        Text(
          'Please pay attention to your departure date and arrive at the airport in advance on Fri, Feb 27',
          style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Container(
              width: 4,
              height: 60,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Colors.grey.shade400, Colors.grey.shade400],
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${flight?.departureTime ?? ''}  ${flight?.departureCode ?? ''} Mumbai Chhatrapati Shivaji Maharaj Intl. T2',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Text(
                        '— ${flight?.airline ?? ''}',
                        style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'VZ761',
                        style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        flight?.aircraft ?? '',
                        style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
                      ),
                    ],
                  ),
                  TextButton.icon(
                    onPressed: () {},
                    icon: const Icon(Icons.eco, size: 14),
                    label: const Text('CO2e', style: TextStyle(fontSize: 12)),
                    style: TextButton.styleFrom(
                      padding: EdgeInsets.zero,
                      minimumSize: const Size(0, 0),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '${flight?.arrivalTime ?? ''}  ${flight?.arrivalCode ?? ''} Bangkok Suvarnabhumi',
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

  Widget _buildFareSelector(BuildContext context, List fareTypes) {
    return Container(
      margin: const EdgeInsets.all(16),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: _buildFareTab('Economy', true),
              ),
              Expanded(
                child: _buildFareTab('Premium Economy', false),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ...fareTypes.map((fare) => _buildFareCard(context, fare)),
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
            color: selected ? Color(0xFF9B8E35) : Colors.transparent,
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

  Widget _buildFareCard(BuildContext context, fare) {
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
                    '£${fare.price.toInt()}',
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF9B8E35),
                    ),
                  ),
                  const Text(
                    '/person',
                    style: TextStyle(color: Colors.grey),
                  ),
                ],
              ),
              ElevatedButton(
                onPressed: () {
                  context.read<BookingProvider>().selectFare(fare);
                  Get.to(() => const PassengerInfoScreen());
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color(0xFFFFC107),
                  padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                ),
                child: const Text('Select', style: TextStyle(color: Colors.black)),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildFareFeature(Icons.shopping_bag, 'Personal item: Included', Color(0xFFEAA21B)),
          _buildFareFeature(Icons.work_outline, 'Carry-on baggage: 1 piece', Color(0xFFEAA21B)),
          _buildFareFeature(Icons.luggage, 'Checked baggage: ${fare.checkedBag}',Color(0xFFEAA21B)),
          _buildFareFeature(
            Icons.close,
            fare.refundable ? 'Refundable' : 'Non-refundable',
            fare.refundable ? Color(0xFFEAA21B) : Colors.red,
          ),
          _buildFareFeature(Icons.sync, 'Change fee: ${fare.changeFee}', Color(0xFFEAA21B)),
          ...fare.benefits.map((benefit) => _buildFareFeature(
            Icons.check,
            benefit,
            Color(0xFFEAA21B),
          )),
          const SizedBox(height: 8),
          TextButton(
            onPressed: () {},
            child: Text('${fare.name} | View details'),
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
          Expanded(
            child: Text(
              text,
              style: TextStyle(color: Colors.grey.shade700),
            ),
          ),
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
