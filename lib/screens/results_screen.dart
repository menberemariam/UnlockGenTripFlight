import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';
import '../data/mock_data.dart';
import '../providers/booking_provider.dart';
import 'fare_selection_screen.dart';

class ResultsScreen extends StatelessWidget {
  const ResultsScreen({super.key});
  @override
  Widget build(BuildContext context) {
    final bookingProvider = context.watch<BookingProvider>();
    final searchParams = bookingProvider.bookingData.searchParams;

    final flights = MockData.getFlights(
      searchParams?.from ?? 'Bangkok',
      searchParams?.to ?? 'Istanbul',
    );

    return Scaffold(
      appBar: AppBar(
        title: Text('${searchParams?.from ?? ''} → ${searchParams?.to ?? ''}'),
        actions: [
          IconButton(icon: const Icon(Icons.notifications_outlined), onPressed: () {}),
          IconButton(icon: const Icon(Icons.more_vert), onPressed: () {}),
        ],
      ),
      body: Column(
        children: [
          _buildDateSelector(),
          _buildPriceInfo(),
          _buildFilters(),
          Expanded(
            child: ListView.builder(
              itemCount: flights.length,
              itemBuilder: (context, index) => _buildFlightCard(context, flights[index]),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDateSelector() {
    return Container(
      height: 80,
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: ListView(
        scrollDirection: Axis.horizontal,
        children: [
          _buildDateChip('Thu, 26', '£68', true),
          _buildDateChip('Fri, 27', '£94', true),
          _buildDateChip('Sat, Feb 28', '£95', false),
          _buildDateChip('Sun, 1', '£90', false),
        ],
      ),
    );
  }

  Widget _buildDateChip(String date, String price, bool selected) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 4),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: selected ? Color(0xFFFFC107) : Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            date,
            style: TextStyle(
              color: selected ? Colors.white : Colors.black,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            price,
            style: TextStyle(
              color: selected ? Colors.white : Color(0xFF9B8E35),
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPriceInfo() {
    return Container(
      padding: const EdgeInsets.all(12),
      color: Colors.grey.shade100,
      child: const Text(
        'Average one-way price per passenger, taxes and fees included',
        style: TextStyle(fontSize: 12, color: Colors.grey),
        textAlign: TextAlign.center,
      ),
    );
  }

  Widget _buildFilters() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          _buildFilterChip('Filters', Icons.filter_list),
          const SizedBox(width: 8),
          _buildFilterChip('Checked baggage included', null),
          const SizedBox(width: 8),
          _buildFilterChip('Direct', Icons.flight),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String label, IconData? icon) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 16),
            const SizedBox(width: 4),
          ],
          Text(label, style: const TextStyle(fontSize: 12)),
        ],
      ),
    );
  }

  Widget _buildFlightCard(BuildContext context, flight) {
    return InkWell(
      onTap: () {
        context.read<BookingProvider>().selectFlight(flight);
        Get.to(() => const FareSelectionScreen());
      },
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey.shade300),
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
                      flight.departureTime,
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      '${flight.departureCode} T2',
                      style: TextStyle(color: Colors.grey.shade600),
                    ),
                  ],
                ),
                Column(
                  children: [
                    Text(
                      flight.duration,
                      style: TextStyle(color: Colors.grey.shade600),
                    ),
                    Container(
                      width: 60,
                      height: 2,
                      color: Colors.grey.shade300,
                      margin: const EdgeInsets.symmetric(vertical: 4),
                    ),
                  ],
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      flight.arrivalTime,
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      flight.arrivalCode,
                      style: TextStyle(color: Colors.grey.shade600),
                    ),
                  ],
                ),
                Text(
                  '£${flight.price.toInt()}',
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF9B8E35),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Text(
                  flight.airline,
                  style: TextStyle(color: Colors.grey.shade600),
                ),
                const SizedBox(width: 8),
                Text(
                  flight.aircraft,
                  style: TextStyle(color: Colors.grey.shade600),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                if (flight.carryOnIncluded)
                  const Icon(Icons.work_outline, size: 16, color: Colors.teal),
                if (flight.carryOnIncluded)
                  const Text(
                    ' Carry-on baggage included',
                    style: TextStyle(color: Color(0xFFBAAA33), fontSize: 12),
                  ),
                if (flight.co2Reduction.isNotEmpty) ...[
                  const SizedBox(width: 12),
                  Icon(Icons.eco, size: 16, color: Colors.green.shade700),
                  Text(
                    ' ${flight.co2Reduction}',
                    style: TextStyle(color: Colors.green.shade700, fontSize: 12),
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }
}
