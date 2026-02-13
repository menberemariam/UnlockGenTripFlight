import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

class FlightBookingController extends GetxController {
  final box = GetStorage();

  // Form controllers
  final contactNameCtrl = TextEditingController();
  final phoneCtrl = TextEditingController();
  final emailCtrl = TextEditingController();

  // Passenger 1 (main passenger)
  final givenNameCtrl = TextEditingController();
  final surnameCtrl = TextEditingController();
  final RxString gender = ''.obs;
  final RxString nationality = 'Ethiopia'.obs;
  final Rx<DateTime?> dob = Rx<DateTime?>(null);

  @override
  void onInit() {
    super.onInit();
    // Load saved contact if exists
    contactNameCtrl.text = box.read('contactName') ?? '';
    phoneCtrl.text = box.read('phone') ?? '';
    emailCtrl.text = box.read('email') ?? 'menberemariam123@gmail.com';
  }

  void saveContactInfo() {
    box.write('contactName', contactNameCtrl.text.trim());
    box.write('phone', phoneCtrl.text.trim());
    box.write('email', emailCtrl.text.trim());
  }

  String? validateForm() {
    if (contactNameCtrl.text.trim().isEmpty) return "Contact name is required";
    if (emailCtrl.text.trim().isEmpty) return "Email is required";
    if (!GetUtils.isEmail(emailCtrl.text.trim())) return "Invalid email";

    if (givenNameCtrl.text.trim().isEmpty) return "Given names required";
    if (surnameCtrl.text.trim().isEmpty) return "Surname required";
    if (gender.value.isEmpty) return "Gender required";
    if (dob.value == null) return "Date of birth required";

    return null;
  }
}

class FlightTicketScreen extends StatelessWidget {
  const FlightTicketScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final ctrl = Get.put(FlightBookingController());

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Get.back(),
        ),
        title: const Text("Enter info"),
        actions: const [
          Padding(
            padding: EdgeInsets.only(right: 16),
            child: Center(child: Text("①-②-③-④")),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 120),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ─── Urgent banner ───
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.green.shade50,
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Row(
                children: [
                  Icon(Icons.check_circle, color: Colors.green),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      "Act fast to lock in the current price and cabin",
                      style: TextStyle(color: Colors.green, fontWeight: FontWeight.w600),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Flight info card
            Card(
              elevation: 1,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Tokyo → Beijing",
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      "Thu, Mar 12   6:00 PM – 9:30 PM",
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                    const SizedBox(height: 12),
                    InkWell(
                      onTap: () {/* show baggage & policies */},
                      child: const Row(
                        children: [
                          Text("Notice 1 | Baggage & policies", style: TextStyle(color: Colors.blue)),
                          Icon(Icons.chevron_right, color: Colors.blue, size: 20),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            // TripFlex banner
            Card(
              color: Colors.blue.shade50,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              child: ListTile(
                leading: const Icon(Icons.verified_user, color: Colors.blue),
                title: const Text(
                  "TripFlex · EasyCancel & Change: No fees for ...",
                  style: TextStyle(fontWeight: FontWeight.w600),
                ),
                trailing: const Icon(Icons.chevron_right),
                onTap: () {/* show details */},
              ),
            ),
            const SizedBox(height: 32),

            // ─── Passengers Section ───
            Text("Passengers", style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 16),

            // Passenger form (only one passenger for simplicity)
            _buildPassengerForm(ctrl),
            const SizedBox(height: 32),

            // ─── Contact Section ───
            Text("Contact", style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 16),

            TextField(
              controller: ctrl.contactNameCtrl,
              decoration: const InputDecoration(
                labelText: "Contact name",
                hintText: "Full name",
              ),
              textCapitalization: TextCapitalization.words,
            ),
            const SizedBox(height: 16),

            TextField(
              controller: ctrl.phoneCtrl,
              decoration: const InputDecoration(
                labelText: "Phone number",
                prefixText: "+251 ",
              ),
              keyboardType: TextInputType.phone,
            ),
            const SizedBox(height: 16),

            TextField(
              controller: ctrl.emailCtrl,
              decoration: const InputDecoration(labelText: "Email"),
              keyboardType: TextInputType.emailAddress,
            ),
            const SizedBox(height: 40),

            // Price & Continue
            Container(
              padding: const EdgeInsets.symmetric(vertical: 16),
              decoration: BoxDecoration(
                border: Border(top: BorderSide(color: Colors.grey.shade300)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text("Average price per person", style: TextStyle(color: Colors.grey)),
                      Text(
                        "\$114.70",
                        style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: Colors.blue.shade800,
                        ),
                      ),
                    ],
                  ),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 16),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    onPressed: () {
                      final error = ctrl.validateForm();
                      if (error != null) {
                        Get.snackbar("Error", error, backgroundColor: Colors.red[100]);
                        return;
                      }
                      ctrl.saveContactInfo();
                      Get.snackbar("Success", "Information saved! Ready to continue.",
                          backgroundColor: Colors.green[100]);
                      // → next step (payment / review)
                    },
                    child: const Text("Continue", style: TextStyle(fontSize: 16)),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPassengerForm(FlightBookingController ctrl) {
    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Passenger 1",
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            const SizedBox(height: 4),
            const Text(
              "Enter passenger's name exactly as it appears on their ID",
              style: TextStyle(fontSize: 12, color: Colors.grey),
            ),
            const SizedBox(height: 16),

            TextField(
              controller: ctrl.givenNameCtrl,
              decoration: const InputDecoration(labelText: "Given names"),
              textCapitalization: TextCapitalization.words,
            ),
            const SizedBox(height: 16),

            TextField(
              controller: ctrl.surnameCtrl,
              decoration: const InputDecoration(labelText: "Last name (surname)"),
              textCapitalization: TextCapitalization.words,
            ),
            const SizedBox(height: 16),

            // Gender
            Obx(() => Row(
              children: [
                Expanded(
                  child: RadioListTile<String>(
                    title: const Text("Male"),
                    value: "Male",
                    groupValue: ctrl.gender.value,
                    onChanged: (v) => ctrl.gender.value = v!,
                    dense: true,
                    contentPadding: EdgeInsets.zero,
                  ),
                ),
                Expanded(
                  child: RadioListTile<String>(
                    title: const Text("Female"),
                    value: "Female",
                    groupValue: ctrl.gender.value,
                    onChanged: (v) => ctrl.gender.value = v!,
                    dense: true,
                    contentPadding: EdgeInsets.zero,
                  ),
                ),
              ],
            )),
            const SizedBox(height: 8),

            ListTile(
              title: const Text("Nationality (country/region)"),
              trailing: Text(ctrl.nationality.value),
              onTap: () {
                // You can show country picker here
                Get.snackbar("Info", "Country picker would open here");
              },
            ),

            ListTile(
              title: const Text("Date of birth"),
              trailing: Text(
                ctrl.dob.value == null
                    ? "Select date"
                    : "${ctrl.dob.value!.day}/${ctrl.dob.value!.month}/${ctrl.dob.value!.year}",
              ),
              onTap: () async {
                final date = await showDatePicker(
                  context: Get.context!,
                  initialDate: DateTime(1995),
                  firstDate: DateTime(1950),
                  lastDate: DateTime.now(),
                );
                if (date != null) ctrl.dob.value = date;
              },
            ),

            const Divider(height: 32),

            ListTile(
              title: const Text("ID type"),
              trailing: const Icon(Icons.chevron_right),
              onTap: () {/* show ID picker */},
            ),

            const SizedBox(height: 8),
            const Text("Frequent flyer program (optional)", style: TextStyle(color: Colors.grey)),
          ],
        ),
      ),
    );
  }
}