import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:intl/intl.dart';
import 'package:trip/screens/special_sssistance_screen.dart';

import 'flyer_guide_screen.dart'; // ← add this to pubspec.yaml for nice date formatting

class FlightStatus extends StatefulWidget {
  FlightStatus({super.key});

  @override
  State<FlightStatus> createState() => _FlightStatusState();
}

class _FlightStatusState extends State<FlightStatus> {
  final _flightNumberController = TextEditingController();
  final _dateController = TextEditingController();
  final _box = GetStorage();

  DateTime _selectedDate = DateTime.now();

  @override
  void initState() {
    super.initState();
    // Load saved date or use today
    final savedDateStr = _box.read('last_flight_date') as String?;
    if (savedDateStr != null) {
      try {
        _selectedDate = DateTime.parse(savedDateStr);
      } catch (_) {}
    }
    _updateDateText();
  }

  void _updateDateText() {
    _dateController.text = DateFormat('EEE, MMM d, yyyy').format(_selectedDate);
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: const Color(0xFFEAA21B),
              onPrimary: Colors.black,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
        _updateDateText();
        _box.write('last_flight_date', picked.toIso8601String());
      });
    }
  }

  void _setQuickDate(int daysOffset) {
    setState(() {
      _selectedDate = DateTime.now().add(Duration(days: daysOffset));
      _updateDateText();
      _box.write('last_flight_date', _selectedDate.toIso8601String());
    });
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor: const Color(0xFFEEF4FF),
        appBar: AppBar(
          backgroundColor: const Color(0xFFEAA21B),
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () => Get.back(),
          ),
          title: const Text(
            'Flight status',
            style: TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.w600,
            ),
          ),
          actions: [
            IconButton(
              icon: const Icon(Icons.search, color: Colors.white),
              onPressed: () => Get.toNamed('/flight-search'),
            ),
          ],
          bottom: const TabBar(
            indicatorColor: Colors.white,
            labelColor: Colors.white,
            unselectedLabelColor: Colors.white70,
            tabs: [
              Tab(text: 'Flight no.'),
              Tab(text: 'Route / Airport'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            // Tab 1: By Flight Number (your original form + enhancements)
            _buildFlightNumberTab(),

            // Tab 2: By Route / Airport (placeholder — extend later)
            _buildRouteTab(),
          ],
        ),
        floatingActionButton: FloatingActionButton(
          backgroundColor: const Color(0xFFEAA21B),
          child: const Icon(Icons.history, color: Colors.white),
          onPressed: () {
            // TODO: show recent searches / saved flights bottom sheet or page
            Get.snackbar('Recent Searches', 'Coming soon...');
          },
          tooltip: 'Recent searches',
        ),
      ),
    );
  }

  Widget _buildFlightNumberTab() {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            margin: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.08),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Flight number',
                  style: TextStyle(
                    color: Colors.black87,
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 6),
                TextField(
                  controller: _flightNumberController,
                  textCapitalization: TextCapitalization.characters,
                  decoration: InputDecoration(
                    hintText: 'e.g. ET501 or UA123',
                    hintStyle: TextStyle(color: Colors.grey[400], fontSize: 15),
                    helperText: 'Airline code + number (3-4 digits)',
                    helperStyle: TextStyle(color: Colors.grey[500], fontSize: 13),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide(color: Colors.grey[300]!),
                    ),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                  ),
                ),
                const SizedBox(height: 24),

                const Text(
                  'Departure date (local time)',
                  style: TextStyle(
                    color: Colors.black87,
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 6),

                // Quick date buttons
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      _buildQuickDateChip('Today', 0),
                      const SizedBox(width: 12),
                      _buildQuickDateChip('Tomorrow', 1),
                      const SizedBox(width: 12),
                      _buildQuickDateChip('Yesterday', -1),
                      const SizedBox(width: 12),
                      _buildQuickDateChip('Other...', null),
                    ],
                  ),
                ),
                const SizedBox(height: 12),

                GestureDetector(
                  onTap: _pickDate,
                  child: AbsorbPointer(
                    child: TextField(
                      controller: _dateController,
                      decoration: InputDecoration(
                        suffixIcon: const Icon(Icons.calendar_today, color: Color(0xFFEAA21B)),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide(color: Colors.grey[300]!),
                        ),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 28),

                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: ElevatedButton(
                    onPressed: () {
                      final flight = _flightNumberController.text.trim().toUpperCase();
                      final dateStr = DateFormat('yyyy-MM-dd').format(_selectedDate);

                      if (flight.isEmpty) {
                        Get.snackbar('Error', 'Please enter flight number');
                        return;
                      }
                      if (flight.length < 4) {
                        Get.snackbar('Error', 'Flight number too short');
                        return;
                      }

                      // Save last used flight number (optional)
                      _box.write('last_flight_number', flight);

                      Get.toNamed('/flight-status-result', arguments: {
                        'flight': flight,
                        'date': dateStr,
                      });
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFEAA21B),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      elevation: 0,
                    ),
                    child: const Text(
                      'Check flight status',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Travel tips remains the same
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 12, 16, 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Travel tips',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 12),
                _buildTipItem(
                  icon: Icons.flight_takeoff,
                  title: 'Flyer guide',
                  onTap: () => Get.to(FlyerGuideScreen()),
                ),
                const SizedBox(height: 4),
                _buildTipItem(
                  icon: Icons.accessible,
                  title: 'Special assistance',
                  onTap: () => Get.to(SpecialAssistanceScreen()),
                ),
                const SizedBox(height: 4),
                _buildTipItem(
                  icon: Icons.info_outline,
                  title: 'Baggage rules & delays',
                  onTap: () => Get.toNamed('/baggage-info'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickDateChip(String label, int? offset) {
    return ActionChip(
      label: Text(label),
      backgroundColor: offset == null ? const Color(0xFFEAA21B).withOpacity(0.1) : null,
      labelStyle: TextStyle(
        color: offset == null ? const Color(0xFFEAA21B) : Colors.black87,
      ),
      onPressed: () {
        if (offset != null) {
          _setQuickDate(offset);
        } else {
          _pickDate();
        }
      },
    );
  }

  Widget _buildRouteTab() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.map_outlined, size: 80, color: Colors.grey[400]),
            const SizedBox(height: 16),
            const Text(
              'Search by departure & arrival airports',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            const Text(
              'Coming soon...\n(You can add origin/destination fields here later)',
              style: TextStyle(color: Colors.grey),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTipItem({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 4),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: const Color(0xFFE6F0FF),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: const Color(0xFFEAA21B), size: 26),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                title,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: Colors.black87,
                ),
              ),
            ),
            const Icon(Icons.chevron_right, color: Colors.grey),
          ],
        ),
      ),
    );
  }
}