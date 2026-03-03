import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:get/get.dart';
import '../model/booking.dart';
import '../providers/booking_provider.dart';
import 'results_screen.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  String tripType = 'One-way';
  String from = 'Bangkok';
  String to = 'Istanbul';
  DateTime selectedDate = DateTime(2026, 2, 28);
  int adults = 5;
  int children = 3;
  int infants = 1;
  String cabinClass = 'Economy/premium economy';
  bool includeHotel = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF1A237E), Color(0xFF3949AB)],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              _buildHeader(),
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      _buildSearchCard(),
                      _buildBottomSection(),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              IconButton(
                icon: const Icon(Icons.arrow_back, color: Colors.white),
                onPressed: () => Navigator.pop(context),
              ),
              const Text(
                'Trip.com | ',
                style: TextStyle(color: Colors.white, fontSize: 16),
              ),
              const Icon(Icons.flight, color: Colors.white, size: 16),
              const Text(
                ' AirEuropa',
                style: TextStyle(color: Colors.white, fontSize: 16),
              ),
            ],
          ),
          const SizedBox(height: 8),
          const Padding(
            padding: EdgeInsets.only(left: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Explore the world with Air Europa',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  'Find exclusive prices today!',
                  style: TextStyle(color: Colors.white70, fontSize: 14),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchCard() {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          _buildTripTypeSelector(),
          const SizedBox(height: 20),
          _buildLocationField(Icons.flight_takeoff, from, true),
          const SizedBox(height: 12),
          _buildLocationField(Icons.flight_land, to, false),
          const SizedBox(height: 12),
          _buildDateField(),
          const SizedBox(height: 12),
          _buildPassengerField(),
          const SizedBox(height: 16),
          _buildHotelOption(),
          const SizedBox(height: 20),
          _buildSearchButton(),
        ],
      ),
    );
  }

  Widget _buildTripTypeSelector() {
    return Row(
      children: [
        _buildTripTypeTab('One-way'),
        _buildTripTypeTab('Round-trip'),
        _buildTripTypeTab('Multi-city'),
      ],
    );
  }

  Widget _buildTripTypeTab(String type) {
    final isSelected = tripType == type;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => tripType = type),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            border: Border(
              bottom: BorderSide(
                color: isSelected ? Colors.blue : Colors.transparent,
                width: 2,
              ),
            ),
          ),
          child: Text(
            type,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: isSelected ? Colors.blue : Colors.grey,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLocationField(IconData icon, String location, bool isFrom) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Icon(icon, color: Colors.grey),
          const SizedBox(width: 12),
          Text(
            location,
            style: const TextStyle(fontSize: 16),
          ),
          const Spacer(),
          if (!isFrom)
            IconButton(
              icon: const Icon(Icons.swap_vert),
              onPressed: () {
                setState(() {
                  final temp = from;
                  from = to;
                  to = temp;
                });
              },
            ),
        ],
      ),
    );
  }

  Widget _buildDateField() {
    return InkWell(
      onTap: () async {
        final date = await showDatePicker(
          context: context,
          initialDate: selectedDate,
          firstDate: DateTime.now(),
          lastDate: DateTime.now().add(const Duration(days: 365)),
        );
        if (date != null) setState(() => selectedDate = date);
      },
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey.shade300),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          children: [
            const Icon(Icons.calendar_today, color: Colors.grey),
            const SizedBox(width: 12),
            Text(
              DateFormat('EEE, MMM dd').format(selectedDate),
              style: const TextStyle(fontSize: 16),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPassengerField() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          const Icon(Icons.person, color: Colors.grey),
          const SizedBox(width: 4),
          Text('$adults', style: const TextStyle(fontSize: 16)),
          const SizedBox(width: 12),
          const Icon(Icons.child_care, color: Colors.grey),
          const SizedBox(width: 4),
          Text('$children', style: const TextStyle(fontSize: 16)),
          const SizedBox(width: 12),
          const Icon(Icons.baby_changing_station, color: Colors.grey),
          const SizedBox(width: 4),
          Text('$infants', style: const TextStyle(fontSize: 16)),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              cabinClass,
              style: const TextStyle(fontSize: 14),
            ),
          ),
          const Icon(Icons.arrow_drop_down),
        ],
      ),
    );
  }

  Widget _buildHotelOption() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.pink.shade50,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
            decoration: BoxDecoration(
              color: Colors.pink,
              borderRadius: BorderRadius.circular(4),
            ),
            child: const Text(
              'Save 6% on avg.',
              style: TextStyle(color: Colors.white, fontSize: 12),
            ),
          ),
          const SizedBox(width: 8),
          Checkbox(
            value: includeHotel,
            onChanged: (val) => setState(() => includeHotel = val ?? false),
          ),
          const Text('Flight + Hotel'),
        ],
      ),
    );
  }

  Widget _buildSearchButton() {
    return SizedBox(
      width: double.infinity,
      child: Builder(
        builder: (context) {
          return ElevatedButton(
            onPressed: () {
              final searchParams = SearchParams(
                from: from,
                to: to,
                date: selectedDate,
                adults: adults,
                children: children,
                infants: infants,
                cabinClass: cabinClass,
                tripType: tripType,
                includeHotel: includeHotel,
              );
              context.read<BookingProvider>().setSearchParams(searchParams);
              Get.to(() => const ResultsScreen());
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: const Text(
              'Search',
              style: TextStyle(fontSize: 18, color: Colors.white),
            ),
          );
        },
      ),
    );
  }

  Widget _buildBottomSection() {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildBottomOption(Icons.public, 'Anywhere'),
              _buildBottomOption(Icons.notifications, 'Price alerts'),
              _buildBottomOption(Icons.more_horiz, 'More'),
            ],
          ),
          const SizedBox(height: 24),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                Image.network(
                  'https://via.placeholder.com/50',
                  width: 50,
                  height: 50,
                ),
                const SizedBox(width: 12),
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Business class top picks',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      Text(
                        'Discover luxury options for less',
                        style: TextStyle(color: Colors.grey),
                      ),
                    ],
                  ),
                ),
                TextButton(
                  onPressed: () {},
                  child: const Text('Explore'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomOption(IconData icon, String label) {
    return Column(
      children: [
        CircleAvatar(
          backgroundColor: Colors.white.withOpacity(0.2),
          child: Icon(icon, color: Colors.white),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: const TextStyle(color: Colors.white, fontSize: 12),
        ),
      ],
    );
  }
}
