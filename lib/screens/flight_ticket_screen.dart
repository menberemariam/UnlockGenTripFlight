import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:trip/screens/seat_screen.dart';

const Color kAccentColor = Color(0xFFEAA21B);

class BookingController extends GetxController {
  final box = GetStorage();

  // Contact
  final contactNameCtrl = TextEditingController();
  final phoneCtrl = TextEditingController();
  final emailCtrl = TextEditingController();

  // Passenger 1
  final givenNameCtrl = TextEditingController();
  final surnameCtrl = TextEditingController();
  final RxString gender = ''.obs;
  final RxString nationality = 'Ethiopia'.obs;
  final Rx<DateTime?> dob = Rx<DateTime?>(null);
  final RxString idType = 'Passport'.obs;

  @override
  void onInit() {
    super.onInit();
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
    if (!GetUtils.isEmail(emailCtrl.text.trim())) return "Invalid email format";

    if (givenNameCtrl.text.trim().isEmpty) return "Given name(s) required";
    if (surnameCtrl.text.trim().isEmpty) return "Surname required";
    if (gender.value.isEmpty) return "Please select gender";
    if (dob.value == null) return "Date of birth required";
    if (nationality.value.isEmpty) return "Nationality required";

    return null;
  }
}

class FlightTicketScreen extends StatelessWidget {
  const FlightTicketScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final ctrl = Get.put(BookingController());

    final theme = Theme.of(context).copyWith(
      primaryColor: kAccentColor,
      colorScheme: Theme.of(context).colorScheme.copyWith(primary: kAccentColor),
    );

    return Theme(
      data: theme,
      child: Scaffold(
        appBar: AppBar(
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => Get.back(),
          ),
          title: const Text("Passenger Details"),
          centerTitle: true,
          actions: [
            Padding(
              padding: const EdgeInsets.only(right: 16),
              child: Center(
                child: Text(
                  "① Passenger ② Review ③ Payment ④ Done",
                  style: theme.textTheme.bodySmall?.copyWith(color: Colors.grey[700]),
                ),
              ),
            ),
          ],
        ),
        body: Stack(
          children: [
            SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 160),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildUrgentBanner(),
                  const SizedBox(height: 24),
                  _buildFlightSummaryCard(theme),
                  const SizedBox(height: 24),
                  _buildProtectionCard(),
                  const SizedBox(height: 32),
                  Text("Passenger", style: theme.textTheme.titleLarge),
                  const SizedBox(height: 12),
                  _buildPassengerForm(ctrl, theme),
                  const SizedBox(height: 40),
                  Text("Contact Information", style: theme.textTheme.titleLarge),
                  const SizedBox(height: 12),
                  _buildContactSection(ctrl, theme),
                  const SizedBox(height: 100),
                ],
              ),
            ),
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: _buildBottomPriceBar(ctrl, theme),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildUrgentBanner() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF8E1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: kAccentColor, width: 1.5),
      ),
      child: Row(
        children: [
          Icon(Icons.warning_amber_rounded, color: kAccentColor, size: 28),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              "Only a few seats left at this price – book now!",
              style: TextStyle(
                color: kAccentColor.withOpacity(0.9),
                fontWeight: FontWeight.w600,
                fontSize: 15,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFlightSummaryCard(ThemeData theme) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(
                  "Tokyo → Beijing",
                  style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                ),
                const Spacer(),
                Chip(
                  label: const Text("Direct", style: TextStyle(fontSize: 12)),
                  backgroundColor: Colors.green[100],
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              "Thu, Mar 12  •  18:00 – 21:30  •  ~3h 30m",
              style: theme.textTheme.bodyMedium?.copyWith(color: Colors.grey[700]),
            ),
            const Divider(height: 32),
            InkWell(
              borderRadius: BorderRadius.circular(8),
              onTap: () {
                Get.snackbar("Baggage & Policies", "23 kg checked baggage included\n8 kg cabin bag allowed\nExtra options available.");
              },
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 6),
                child: Row(
                  children: [
                    Icon(Icons.luggage_outlined, color: kAccentColor, size: 22),
                    const SizedBox(width: 10),
                    Text(
                      "Baggage & Fare Rules",
                      style: TextStyle(color: kAccentColor, fontWeight: FontWeight.w600),
                    ),
                    const Spacer(),
                    Icon(Icons.chevron_right, color: Colors.grey[600]),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProtectionCard() {
    return Card(
      color: const Color(0xFFF5F9FF),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: ListTile(
        leading: Icon(Icons.verified, color: kAccentColor, size: 28),
        title: const Text(
          "Add TripFlex – Free changes & cancellation",
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
        subtitle: const Text("From \$12.90 per passenger"),
        trailing: const Icon(Icons.chevron_right),
        onTap: () {
          Get.bottomSheet(
            Container(
              padding: const EdgeInsets.all(24),
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "TripFlex Protection",
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: kAccentColor),
                  ),
                  const SizedBox(height: 16),
                  const Text("• Free date & name changes\n• Cancel up to 24h before departure\n• Full refund if airline cancels"),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildPassengerForm(BookingController ctrl, ThemeData theme) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Obx(() => Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text("Passenger 1", style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
                const Spacer(),
                Text("(Main traveler)", style: theme.textTheme.bodySmall?.copyWith(color: Colors.grey[600])),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              "Name must match passport/ID exactly",
              style: theme.textTheme.bodySmall?.copyWith(color: Colors.grey[600]),
            ),
            const SizedBox(height: 24),

            _buildTextField(ctrl.givenNameCtrl, "Given name(s)", theme),
            const SizedBox(height: 16),
            _buildTextField(ctrl.surnameCtrl, "Surname / Family name", theme),
            const SizedBox(height: 24),

            Text("Gender", style: theme.textTheme.titleSmall),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(child: _buildGenderTile(ctrl, "Male", theme)),
                const SizedBox(width: 12),
                Expanded(child: _buildGenderTile(ctrl, "Female", theme)),
              ],
            ),
            const SizedBox(height: 24),

            _buildSelectorTile(
              title: "Nationality",
              value: ctrl.nationality.value,
              onTap: () => Get.snackbar("Country Picker", "Open country list dialog here (e.g. country_picker package)"),
            ),
            const SizedBox(height: 16),

            _buildSelectorTile(
              title: "Date of birth",
              value: ctrl.dob.value != null
                  ? "${ctrl.dob.value!.day.toString().padLeft(2, '0')}/${ctrl.dob.value!.month.toString().padLeft(2, '0')}/${ctrl.dob.value!.year}"
                  : "Select date",
              onTap: () async {
                final date = await showDatePicker(
                  context: Get.context!,
                  initialDate: ctrl.dob.value ?? DateTime(1995),
                  firstDate: DateTime(1900),
                  lastDate: DateTime.now().subtract(const Duration(days: 365 * 12)),
                  builder: (context, child) => Theme(
                    data: Theme.of(context).copyWith(
                      colorScheme: ColorScheme.light(primary: kAccentColor),
                    ),
                    child: child!,
                  ),
                );
                if (date != null) ctrl.dob.value = date;
              },
            ),
            const SizedBox(height: 24),

            _buildSelectorTile(
              title: "ID / Document type",
              value: ctrl.idType.value,
              onTap: () {
                Get.bottomSheet(
                  Container(
                    color: Colors.white,
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: ["Passport", "National ID", "Other"]
                          .map((type) => ListTile(
                        title: Text(type),
                        onTap: () {
                          ctrl.idType.value = type;
                          Get.back();
                        },
                      ))
                          .toList(),
                    ),
                  ),
                );
              },
            ),

            const SizedBox(height: 32),
            Text(
              "Frequent Flyer / Loyalty Program (optional)",
              style: theme.textTheme.bodyMedium?.copyWith(color: Colors.grey[700]),
            ),
            const SizedBox(height: 8),
            TextField(
              decoration: InputDecoration(
                hintText: "Airline + Number (e.g. ET 12345678)",
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              ),
            ),
          ],
        )),
      ),
    );
  }

  Widget _buildGenderTile(BookingController ctrl, String value, ThemeData theme) {
    final selected = ctrl.gender.value == value;
    return GestureDetector(
      onTap: () => ctrl.gender.value = value,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          border: Border.all(color: selected ? kAccentColor : Colors.grey[300]!, width: 1.5),
          borderRadius: BorderRadius.circular(12),
          color: selected ? kAccentColor.withOpacity(0.12) : null,
        ),
        child: Center(
          child: Text(
            value,
            style: TextStyle(
              fontWeight: selected ? FontWeight.w600 : FontWeight.normal,
              color: selected ? kAccentColor : Colors.black87,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSelectorTile({
    required String title,
    required String value,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey[300]!),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: const TextStyle(fontSize: 12, color: Colors.grey)),
                  const SizedBox(height: 4),
                  Text(value, style: const TextStyle(fontWeight: FontWeight.w500)),
                ],
              ),
            ),
            Icon(Icons.keyboard_arrow_down, color: Colors.grey[600]),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField(TextEditingController ctrl, String label, ThemeData theme) {
    return TextField(
      controller: ctrl,
      textCapitalization: TextCapitalization.words,
      decoration: InputDecoration(
        labelText: label,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      ),
    );
  }

  Widget _buildContactSection(BookingController ctrl, ThemeData theme) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            _buildTextField(ctrl.contactNameCtrl, "Contact full name", theme),
            const SizedBox(height: 16),
            TextField(
              controller: ctrl.phoneCtrl,
              keyboardType: TextInputType.phone,
              decoration: InputDecoration(
                labelText: "Phone number",
                prefixText: "+251 ",
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: ctrl.emailCtrl,
              keyboardType: TextInputType.emailAddress,
              decoration: InputDecoration(
                labelText: "Email address",
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Icon(Icons.info_outline, size: 16, color: Colors.grey[600]),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    "We'll send confirmation & updates here",
                    style: theme.textTheme.bodySmall?.copyWith(color: Colors.grey[600]),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomPriceBar(BookingController ctrl, ThemeData theme) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.08), blurRadius: 16, offset: const Offset(0, -4)),
        ],
      ),
      child: Row(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("Total", style: theme.textTheme.bodyMedium?.copyWith(color: Colors.grey[700])),
              Text(
                "\$114.70",
                style: theme.textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: kAccentColor,
                ),
              ),
            ],
          ),
          const Spacer(),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 48, vertical: 16),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              backgroundColor: kAccentColor,
            ),
            onPressed: () {
              final error = ctrl.validateForm();
              if (error != null) {
                Get.snackbar("Missing Information", error, backgroundColor: Colors.red[50], colorText: Colors.red[900]);
                return;
              }
              ctrl.saveContactInfo();
              Get.snackbar(
                "Saved!",
                "Passenger details saved • Ready for review",
                backgroundColor: Colors.green[50],
                colorText: Colors.green[900],
              );
              Get.to(() => const FlightSeatSelectionScreen());
            },
            child: const Text(
              "Continue",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }
}