import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/passenger_controllers/passenger_controller.dart';
import '../../widgets/passenger_Widgets/passenger_form_widgets.dart';

class AddPassengerScreen extends StatelessWidget {
  final Map<String, String>? existingPassenger;
  final int? passengerIndex;

  const AddPassengerScreen({
    super.key,
    this.existingPassenger,
    this.passengerIndex,
  });

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(PassengerController());

    // Load existing data if editing
    WidgetsBinding.instance.addPostFrameCallback((_) {
      controller.loadPassengerData(existingPassenger);
    });

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Get.back(),
        ),
        title: const Text('Add Passenger'),
        actions: [
          TextButton(
            onPressed: () {
              final result = controller.savePassenger(context, passengerIndex);
              if (result != null) {
                Get.back(result: result);
              }
            },
            child: const Text(
              'Save',
              style: TextStyle(
                color: Color(0xFFEAA21B),
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Form(
          key: controller.formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const PassengerInfoSection(),
              const SizedBox(height: 16),
              PassengerFormFields(controller: controller),
              FrequentFlyerSection(controller: controller),
            ],
          ),
        ),
      ),
    );
  }
}
