// screens/filter_screen.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/flight_result_controller.dart';

class FilterScreen extends StatelessWidget {
  const FilterScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<FlightResultsController>();
    return DefaultTabController(
      length: 5,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Filters'),
          bottom: const TabBar(
            isScrollable: true,
            tabs: [
              Tab(text: 'Stops'),
              Tab(text: 'Stopover cities'),
              Tab(text: 'Airports'),
              Tab(text: 'Aircrafts'),
              Tab(text: 'Cabin'),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                controller.resetAllFilters();
                Get.back(); // optional: close after reset
              },
              child: const Text('Reset'),
            ),
          ],
        ),
        body: TabBarView(
          children: [
            _StopsTab(controller),
            _StopoverCitiesTab(controller),
            _AirportsTab(controller),
            _AircraftsTab(controller),
            _CabinTab(controller),
          ],
        ),
        bottomNavigationBar: Container(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () {
                    controller.resetAllFilters();
                    Get.back();
                  },
                  child: const Text('Reset'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton(
                  onPressed: () => Get.back(),
                  child: const Text('Show flights'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ---------- Stops Tab ----------
class _StopsTab extends StatelessWidget {
  final FlightResultsController controller;
  const _StopsTab(this.controller);

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        RadioListTile<int>(
          title: const Text('Nonstop only'),
          value: 0,
          groupValue: controller.maxStops.value,
          onChanged: (v) => controller.updateMaxStops(v!),
        ),
        RadioListTile<int>(
          title: const Text('1 stop or fewer'),
          value: 1,
          groupValue: controller.maxStops.value,
          onChanged: (v) => controller.updateMaxStops(v!),
        ),
        // Add more as needed
      ],
    );
  }
}

// ---------- Stopover Cities Tab ----------
class _StopoverCitiesTab extends StatelessWidget {
  final FlightResultsController controller;
  final List<Map<String, dynamic>> cities = const [
    {'name': 'Atlanta', 'price': 124},
    {'name': 'Detroit', 'price': 146},
    {'name': 'Orlando', 'price': 114},
    {'name': 'Fort Lauderdale', 'price': 114},
  ];

  _StopoverCitiesTab(this.controller);

  @override
  Widget build(BuildContext context) {
    return Obx(() => ListView(
      padding: const EdgeInsets.all(16),
      children: [
        ...cities.map((city) => CheckboxListTile(
          title: Text(city['name']),
          subtitle: Text('\$${city['price']}'),
          value: controller.selectedStopoverCities.contains(city['name']),
          onChanged: (checked) {
            if (checked == true) {
              controller.selectedStopoverCities.add(city['name']);
            } else {
              controller.selectedStopoverCities.remove(city['name']);
            }
          },
        )),
        TextButton(
          onPressed: () {},
          child: const Text('Show more ▼'),
        ),
      ],
    ));
  }
}

// ---------- Airports Tab ----------
class _AirportsTab extends StatelessWidget {
  final FlightResultsController controller;
  final List<Map<String, dynamic>> departureAirports = const [
    {'code': 'ORD', 'name': "O'Hare International Airport", 'price': 56},
    {'code': 'MDW', 'name': 'Midway International Airport', 'price': 124},
  ];
  final List<Map<String, dynamic>> arrivalAirports = const [
    {'code': 'EWR', 'name': 'Newark Liberty International Airport', 'price': 56},
    {'code': 'LGA', 'name': 'LaGuardia Airport', 'price': 56},
    {'code': 'JFK', 'name': 'John F. Kennedy International Airport', 'price': 103},
  ];

  _AirportsTab(this.controller);

  @override
  Widget build(BuildContext context) {
    return Obx(() => ListView(
      padding: const EdgeInsets.all(16),
      children: [
        const Text('Depart from Chicago', style: TextStyle(fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        ...departureAirports.map((ap) => CheckboxListTile(
          title: Text('${ap['code']} ${ap['name']}'),
          subtitle: Text('\$${ap['price']}'),
          value: controller.selectedDepartureAirports.contains(ap['code']),
          onChanged: (checked) {
            if (checked == true) {
              controller.selectedDepartureAirports.add(ap['code']);
            } else {
              controller.selectedDepartureAirports.remove(ap['code']);
            }
          },
        )),
        const Divider(height: 32),
        const Text('Arrive in New York', style: TextStyle(fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        ...arrivalAirports.map((ap) => CheckboxListTile(
          title: Text('${ap['code']} ${ap['name']}'),
          subtitle: Text('\$${ap['price']}'),
          value: controller.selectedArrivalAirports.contains(ap['code']),
          onChanged: (checked) {
            if (checked == true) {
              controller.selectedArrivalAirports.add(ap['code']);
            } else {
              controller.selectedArrivalAirports.remove(ap['code']);
            }
          },
        )),
      ],
    ));
  }
}

// ---------- Aircrafts Tab ----------
class _AircraftsTab extends StatelessWidget {
  final FlightResultsController controller;
  const _AircraftsTab(this.controller);

  @override
  Widget build(BuildContext context) {
    return Obx(() => ListView(
      padding: const EdgeInsets.all(16),
      children: [
        CheckboxListTile(
          title: const Text('Midsize aircraft'),
          subtitle: const Text('\$56'),
          value: controller.selectedAircraftTypes.contains('Midsize'),
          onChanged: (checked) {
            if (checked == true) {
              controller.selectedAircraftTypes.add('Midsize');
            } else {
              controller.selectedAircraftTypes.remove('Midsize');
            }
          },
        ),
        CheckboxListTile(
          title: const Text('Small aircraft'),
          subtitle: const Text('\$140'),
          value: controller.selectedAircraftTypes.contains('Small'),
          onChanged: (checked) {
            if (checked == true) {
              controller.selectedAircraftTypes.add('Small');
            } else {
              controller.selectedAircraftTypes.remove('Small');
            }
          },
        ),
      ],
    ));
  }
}

// ---------- Cabin Tab ----------
class _CabinTab extends StatelessWidget {
  final FlightResultsController controller;
  final List<String> cabinOptions = const [
    'Economy',
    'Economy/premium economy',
    'Premium Economy',
    'Business/First',
    'Business',
  ];

  _CabinTab(this.controller);

  @override
  Widget build(BuildContext context) {
    return Obx(() => ListView(
      padding: const EdgeInsets.all(16),
      children: cabinOptions.map((cabin) {
        if (cabin == 'Economy/premium economy') {
          return CheckboxListTile(
            title: Row(
              children: [
                Text(cabin),
                const SizedBox(width: 8),
                const Icon(Icons.check, color: Colors.green, size: 20),
              ],
            ),
            value: controller.selectedCabins.contains(cabin),
            onChanged: (checked) {
              if (checked == true) {
                controller.selectedCabins.add(cabin);
              } else {
                controller.selectedCabins.remove(cabin);
              }
            },
          );
        }
        return CheckboxListTile(
          title: Text(cabin),
          value: controller.selectedCabins.contains(cabin),
          onChanged: (checked) {
            if (checked == true) {
              controller.selectedCabins.add(cabin);
            } else {
              controller.selectedCabins.remove(cabin);
            }
          },
        );
      }).toList(),
    ));
  }
}