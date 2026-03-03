import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';
import '../controllers/passenger_controllers/passenger_info.dart';
import '../providers/booking_provider.dart';
import '../widgets/insurance_widgets.dart';
import '../widgets/passenger_Widgets/passenger_info_widgets.dart';
import 'addons_screen.dart';
import 'home/add_passenger_screen.dart';

class PassengerInfoScreen extends StatelessWidget {
  const PassengerInfoScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(PassengerInfoController());
    final bookingProvider = context.watch<BookingProvider>();
    final flight = bookingProvider.bookingData.selectedFlight;
    final fare = bookingProvider.bookingData.selectedFare;
    final searchParams = bookingProvider.bookingData.searchParams;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Enter info'),
        actions: const [
          StepIndicator(currentStep: 1),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              child: Form(
                key: controller.formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    FlightSummary(flight: flight, searchParams: searchParams),
                    _buildPassengerSection(controller),
                    ContactFormFields(
                      nameController: controller.nameController,
                      phoneController: controller.phoneController,
                      emailController: controller.emailController,
                      onDone: () {
                        if (controller.validateForm()) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Contact info saved')),
                          );
                        }
                      },
                    ),
                    InsuranceSection(controller: controller),
                  ],
                ),
              ),
            ),
          ),
          Obx(() => BookingBottomBar(
            passengerCount: controller.passengerCount,
            totalPrice: controller.calculateTotalPrice(fare?.price),
            onContinue: () {
              if (controller.validateForm()) {
                context.read<BookingProvider>().setContactInfo(
                  controller.nameController.text,
                  controller.phoneController.text,
                  controller.emailController.text,
                );
                context.read<BookingProvider>().setInsurance(controller.selectedInsurance.value);
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

  Widget _buildPassengerSection(PassengerInfoController controller) {
    return Container(
      padding: const EdgeInsets.all(16),
      color: Colors.white,
      child: Obx(() => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Selected: ${controller.passengerCount} adult${controller.passengerCount > 1 ? 's' : ''}',
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          InkWell(
            onTap: () {},
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: Color(0xFFFFF8E6),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: const [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'ID notice',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      Text(
                        'Names must match ID • 6-month Validity',
                        style: TextStyle(fontSize: 12, color: Colors.grey),
                      ),
                    ],
                  ),
                  Icon(Icons.chevron_right, size: 20),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),

          // First passenger (default)
          PassengerCard(
            name: controller.nameController.text,
            isChecked: true,
            onEdit: () async {
              final result = await Get.to(() => AddPassengerScreen(
                existingPassenger: {
                  'givenNames': controller.nameController.text.split(' ').first,
                  'surname': controller.nameController.text.split(' ').last,
                  'gender': 'Male',
                  'nationality': '🇬🇧 United Kingdom',
                  'dob': '01/01/1990',
                },
                passengerIndex: -1,
              ));
              if (result != null) {
                controller.updateMainPassengerName(
                  result['givenNames'],
                  result['surname'],
                );
              }
            },
          ),
          ...controller.additionalPassengers.asMap().entries.map((entry) {
            final index = entry.key;
            final passenger = entry.value;
            return Padding(
              padding: const EdgeInsets.only(top: 12),
              child: PassengerCard(
                name: '${passenger['givenNames']} ${passenger['surname']}',
                isChecked: true,
                onEdit: () async {
                  final result = await Get.to(() => AddPassengerScreen(
                    existingPassenger: passenger,
                    passengerIndex: index,
                  ));
                  if (result != null) {
                    controller.updatePassenger(index, {
                      'givenNames': result['givenNames'],
                      'surname': result['surname'],
                      'gender': result['gender'],
                      'nationality': result['nationality'],
                      'dob': result['dob'],
                    });
                  }
                },
                onDelete: () => controller.removePassenger(index),
              ),
            );
          }),

          const SizedBox(height: 12),


          OutlinedButton.icon(
            onPressed: () async {
              final result = await Get.to(() => const AddPassengerScreen());
              if (result != null) {
                controller.addPassenger({
                  'givenNames': result['givenNames'],
                  'surname': result['surname'],
                  'gender': result['gender'],
                  'nationality': result['nationality'],
                  'dob': result['dob'],
                });
              }
            },
            icon: const Icon(Icons.add_circle_outline),
            label: const Text(
              'Add Passengers',
              style: TextStyle(
                color: Color(0xFFC9A227),
                fontWeight: FontWeight.bold,
              ),
            ),
            style: OutlinedButton.styleFrom(
              minimumSize: const Size(double.infinity, 48),
              side: BorderSide(color: Color(0xFFFFC107)),
            ),
          ),
        ],
      )),
    );
  }
}
