import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/passenger_info_controller.dart';
import '../../controllers/flight_booking_controller.dart';
import '../../controllers/flight_search_controller.dart';
import '../../data/countries_data.dart';
import '../../widgets/insurance_widgets.dart';
import '../../widgets/passenger_info_widgets.dart';
import 'addons_screen.dart';
import 'add_passenger_screen.dart';

class PassengerInfoScreen extends StatelessWidget {
  const PassengerInfoScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final passengerController = Get.put(PassengerInfoController(), permanent: true);
    final flightController = Get.find<FlightBookingController>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Enter info'),
        actions: const [StepIndicator(currentStep: 1)],
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              child: Form(
                key: passengerController.formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildFlightSummary(flightController),
                    _buildPassengerCards(passengerController),
                    _buildTravelDocSection(passengerController),
                    _buildContactSection(passengerController),
                    InsuranceSection(controller: passengerController),
                  ],
                ),
              ),
            ),
          ),
          Obx(() => BookingBottomBar(
                passengerCount: passengerController.passengerCount,
                totalPrice: passengerController.totalPrice,
                currency: passengerController.priceCurrency,
                onContinue: () {
                  if (passengerController.validateForm()) {
                    Get.to(() => const AddonsScreen());
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Please fill in all required fields correctly'),
                        backgroundColor: Colors.red,
                      ),
                    );
                  }
                },
              )),
        ],
      ),
    );
  }

  Widget _buildFlightSummary(FlightBookingController flightController) {
    final searchCtrl = Get.find<FlightSearchController>();
    final offer = searchCtrl.selectedOffer.value;
    final isRoundTrip = flightController.isRoundTrip;

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
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          const SizedBox(height: 12),
          if (offer != null) ...[
            // Outbound leg
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('${offer.originCode} → ${offer.destinationCode}',
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                Text('${offer.departureTime} – ${offer.arrivalTime}',
                    style: TextStyle(color: Colors.grey.shade700)),
              ],
            ),
            const SizedBox(height: 4),
            Text('${offer.airlineName} • ${offer.duration}',
                style: TextStyle(color: Colors.grey.shade700, fontSize: 13)),
            // Return leg
            if (isRoundTrip) ...[
              const Divider(height: 20),
              if (offer.returnFlight != null) ...[
                // Combined offer: both legs in one offer object
                _buildReturnLegRow(
                  from: offer.destinationCode,
                  to: offer.originCode,
                  duration: offer.returnFlight!.formattedDuration,
                  airline: offer.returnFlight!.segments.isNotEmpty
                      ? offer.returnFlight!.segments.first.airlineName
                      : offer.airlineName,
                  depTime: offer.returnFlight!.segments.isNotEmpty &&
                          offer.returnFlight!.segments.first.departureDateTime != null
                      ? _formatTime(offer.returnFlight!.segments.first.departureDateTime!)
                      : '',
                  arrTime: offer.returnFlight!.segments.isNotEmpty &&
                          offer.returnFlight!.segments.last.arrivalDateTime != null
                      ? _formatTime(offer.returnFlight!.segments.last.arrivalDateTime!)
                      : '',
                ),
              ] else ...[
                // Separate outbound offer stored before return was selected
                _buildReturnLegFromOutbound(searchCtrl, flightController),
              ],
            ],
          ] else
            Text(
              '${flightController.departureCity.value} → ${flightController.destinationCity.value}',
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
        ],
      ),
    );
  }

  Widget _buildReturnLegRow({
    required String from,
    required String to,
    required String duration,
    required String airline,
    required String depTime,
    required String arrTime,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('$from → $to',
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            if (depTime.isNotEmpty && arrTime.isNotEmpty)
              Text('$depTime – $arrTime',
                  style: TextStyle(color: Colors.grey.shade700))
            else
              Text(duration, style: TextStyle(color: Colors.grey.shade700)),
          ],
        ),
        const SizedBox(height: 4),
        Text('$airline • $duration',
            style: TextStyle(color: Colors.grey.shade700, fontSize: 13)),
      ],
    );
  }

  Widget _buildReturnLegFromOutbound(
      FlightSearchController searchCtrl, FlightBookingController flightCtrl) {
    // selectedOffer is the return leg offer (set in ReturnResultsScreen)
    // selectedOutboundOffer is the outbound (set in DepartureResultsScreen)
    final returnOffer = searchCtrl.selectedOffer.value;
    if (returnOffer == null) {
      return Text(
        '${flightCtrl.destinationCity.value} → ${flightCtrl.departureCity.value}',
        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
      );
    }
    // The return offer's outboundFlight IS the return leg in this flow
    return _buildReturnLegRow(
      from: returnOffer.originCode,
      to: returnOffer.destinationCode,
      duration: returnOffer.duration,
      airline: returnOffer.airlineName,
      depTime: returnOffer.departureTime,
      arrTime: returnOffer.arrivalTime,
    );
  }

  String _formatTime(DateTime dt) =>
      '${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';

  Widget _buildPassengerCards(PassengerInfoController controller) {
    return Container(
      padding: const EdgeInsets.all(16),
      color: Colors.white,
      margin: const EdgeInsets.only(top: 8),
      child: Obx(() => Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Passengers',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 4),
              Text(
                '${controller.passengerCount} passenger${controller.passengerCount > 1 ? 's' : ''} — tap each to fill details',
                style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
              ),
              const SizedBox(height: 12),
              PassengerCard(
                name: controller.firstNameController.text.isNotEmpty
                    ? '${controller.firstNameController.text} ${controller.lastNameController.text}'
                    : 'Passenger 1 — tap to fill',
                isChecked: controller.firstNameController.text.isNotEmpty,
                onEdit: () async {
                  final result = await Get.to(() => const AddPassengerScreen());
                  if (result != null) {
                    controller.firstNameController.text = result['givenNames'] ?? '';
                    controller.lastNameController.text = result['surname'] ?? '';
                    controller.selectedGender.value =
                        result['gender'] == 'Female' ? 'FEMALE' : 'MALE';
                    controller.birthDateController.text = result['dob'] ?? '';
                    controller.passportController.text = result['passport'] ?? '';
                    if (result['nationality'] != null) {
                      controller.countryController.text = result['nationality'] ?? '';
                    }
                  }
                },
              ),
              ...controller.additionalPassengers.asMap().entries.map((entry) {
                final index = entry.key;
                final passenger = entry.value;
                return Padding(
                  padding: const EdgeInsets.only(top: 12),
                  child: PassengerCard(
                    name: '${passenger['givenNames'] ?? ''} ${passenger['surname'] ?? ''}'
                                .trim()
                                .isEmpty
                        ? 'Passenger ${index + 2} — tap to fill'
                        : '${passenger['givenNames']} ${passenger['surname']}',
                    isChecked: (passenger['givenNames'] ?? '').isNotEmpty,
                    onEdit: () async {
                      final result = await Get.to(() => AddPassengerScreen(
                            existingPassenger: passenger,
                            passengerIndex: index,
                          ));
                      if (result != null) controller.updatePassenger(index, result);
                    },
                    onDelete: () => controller.removePassenger(index),
                  ),
                );
              }),
              const SizedBox(height: 12),
              OutlinedButton.icon(
                onPressed: () async {
                  final result = await Get.to(() => const AddPassengerScreen());
                  if (result != null) controller.addPassenger(result);
                },
                icon: const Icon(Icons.add_circle_outline, color: Color(0xFFC9A227)),
                label: const Text('Add Passenger',
                    style: TextStyle(
                        color: Color(0xFFC9A227), fontWeight: FontWeight.bold)),
                style: OutlinedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 48),
                  side: const BorderSide(color: Color(0xFFFFC107)),
                ),
              ),
            ],
          )),
    );
  }

  Widget _buildTravelDocSection(PassengerInfoController controller) {
    return Container(
      padding: const EdgeInsets.all(16),
      color: Colors.white,
      margin: const EdgeInsets.only(top: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Passenger Details',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 4),
          Text('Names must match passport exactly',
              style: TextStyle(fontSize: 12, color: Colors.grey.shade600)),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: Obx(() => DropdownButtonFormField<String>(
                      initialValue: controller.selectedTitle.value,
                      decoration: InputDecoration(
                        labelText: 'Title',
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8)),
                        contentPadding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 14),
                      ),
                      items: ['Mr', 'Mrs', 'Ms']
                          .map((t) => DropdownMenuItem(value: t, child: Text(t)))
                          .toList(),
                      onChanged: (v) => controller.selectedTitle.value = v!,
                    )),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Obx(() => DropdownButtonFormField<String>(
                      initialValue: controller.selectedGender.value,
                      decoration: InputDecoration(
                        labelText: 'Gender',
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8)),
                        contentPadding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 14),
                      ),
                      items: ['MALE', 'FEMALE']
                          .map((g) => DropdownMenuItem(value: g, child: Text(g)))
                          .toList(),
                      onChanged: (v) => controller.selectedGender.value = v!,
                    )),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: TextFormField(
                  controller: controller.firstNameController,
                  textCapitalization: TextCapitalization.characters,
                  decoration: InputDecoration(
                    labelText: 'First Name',
                    border:
                        OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                    contentPadding:
                        const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  ),
                  validator: (v) => v == null || v.isEmpty ? 'Required' : null,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: TextFormField(
                  controller: controller.lastNameController,
                  textCapitalization: TextCapitalization.characters,
                  decoration: InputDecoration(
                    labelText: 'Last Name',
                    border:
                        OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                    contentPadding:
                        const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  ),
                  validator: (v) => v == null || v.isEmpty ? 'Required' : null,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          TextFormField(
            controller: controller.passportController,
            textCapitalization: TextCapitalization.characters,
            decoration: InputDecoration(
              labelText: 'Passport Number',
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              prefixIcon: const Icon(Icons.credit_card),
            ),
            validator: (v) => v == null || v.isEmpty ? 'Required' : null,
          ),
          const SizedBox(height: 12),
          TextFormField(
            controller: controller.birthDateController,
            decoration: InputDecoration(
              labelText: 'Date of Birth (YYYY-MM-DD)',
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              prefixIcon: const Icon(Icons.calendar_today),
              hintText: '1990-01-25',
            ),
            keyboardType: TextInputType.datetime,
            validator: (v) {
              if (v == null || v.isEmpty) return 'Required';
              final dateRegex = RegExp(r'^\d{4}-\d{1,2}-\d{1,2}$');
              if (!dateRegex.hasMatch(v)) return 'Use format YYYY-MM-DD';
              return null;
            },
          ),
          const SizedBox(height: 12),
          TextFormField(
            controller: controller.countryController,
            textCapitalization: TextCapitalization.characters,
            decoration: InputDecoration(
              labelText: 'Country Code (e.g. ET, AE, ZA)',
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              prefixIcon: const Icon(Icons.flag),
            ),
            validator: (v) => v == null || v.isEmpty ? 'Required' : null,
          ),
        ],
      ),
    );
  }

  Widget _buildContactSection(PassengerInfoController controller) {
    return Container(
      padding: const EdgeInsets.all(16),
      color: Colors.white,
      margin: const EdgeInsets.only(top: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Contact Info',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 4),
          Text('We\'ll send your booking confirmation here',
              style: TextStyle(fontSize: 12, color: Colors.grey.shade600)),
          const SizedBox(height: 12),
          // Contact name — read-only display built from first+last name fields
          ValueListenableBuilder<TextEditingValue>(
            valueListenable: controller.firstNameController,
            builder: (_, __, ___) {
              final first = controller.firstNameController.text;
              final last = controller.lastNameController.text;
              final name = '$first $last'.trim();
              return Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey.shade300),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.person_outline, color: Colors.grey),
                    const SizedBox(width: 12),
                    Text(
                      name.isEmpty ? 'Fill passenger details above' : name,
                      style: TextStyle(
                        fontSize: 15,
                        color: name.isEmpty ? Colors.grey.shade400 : Colors.black,
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
          const SizedBox(height: 12),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Obx(() {
                final selected = controller.selectedCountry.value;
                return GestureDetector(
                  onTap: () => _showDialCodePicker(controller),
                  child: Container(
                    height: 52,
                    padding: const EdgeInsets.symmetric(horizontal: 10),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey.shade400),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          selected != null
                              ? '${selected['flag']} ${selected['dial']}'
                              : '🌍 +??',
                          style: const TextStyle(fontSize: 14),
                        ),
                        const Icon(Icons.arrow_drop_down, size: 18),
                      ],
                    ),
                  ),
                );
              }),
              const SizedBox(width: 8),
              Expanded(
                child: TextFormField(
                  controller: controller.phoneController,
                  keyboardType: TextInputType.phone,
                  decoration: InputDecoration(
                    labelText: 'Phone Number',
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8)),
                    contentPadding:
                        const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  ),
                  validator: (v) => v == null || v.isEmpty ? 'Required' : null,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          TextFormField(
            controller: controller.emailController,
            keyboardType: TextInputType.emailAddress,
            decoration: InputDecoration(
              labelText: 'Email Address',
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              prefixIcon: const Icon(Icons.email_outlined),
            ),
            validator: (v) {
              if (v == null || v.isEmpty) return 'Required';
              if (!v.contains('@') || !v.contains('.')) return 'Enter a valid email';
              return null;
            },
          ),
        ],
      ),
    );
  }

  void _showDialCodePicker(PassengerInfoController controller) {
    List<Map<String, String>> filtered = List.from(CountriesData.countries);
    showModalBottomSheet(
      context: Get.context!,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setState) => SizedBox(
          height: MediaQuery.of(ctx).size.height * 0.85,
          child: Column(
            children: [
              const SizedBox(height: 12),
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 12),
              const Text('Select Country Code',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 12),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: TextField(
                  autofocus: true,
                  decoration: InputDecoration(
                    hintText: 'Search country or dial code...',
                    prefixIcon: const Icon(Icons.search),
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12)),
                    contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 12),
                  ),
                  onChanged: (q) => setState(() {
                    final lower = q.toLowerCase();
                    filtered = CountriesData.countries
                        .where((c) =>
                            (c['name'] ?? '').toLowerCase().contains(lower) ||
                            (c['dial'] ?? '').contains(q) ||
                            (c['code'] ?? '').toLowerCase().contains(lower))
                        .toList();
                  }),
                ),
              ),
              const SizedBox(height: 8),
              Expanded(
                child: ListView.builder(
                  itemCount: filtered.length,
                  itemBuilder: (_, i) {
                    final c = filtered[i];
                    return ListTile(
                      leading: Text(c['flag'] ?? '',
                          style: const TextStyle(fontSize: 24)),
                      title: Text(c['name'] ?? ''),
                      trailing: Text(c['dial'] ?? '',
                          style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Color(0xFFD4AF37))),
                      onTap: () {
                        controller.selectCountry(c);
                        controller.phoneController.text = c['dial'] ?? '';
                        controller.phoneController.selection =
                            TextSelection.fromPosition(TextPosition(
                                offset:
                                    controller.phoneController.text.length));
                        Navigator.pop(ctx);
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
