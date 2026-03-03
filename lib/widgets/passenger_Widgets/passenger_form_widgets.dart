import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/passenger_controllers/passenger_controller.dart';
import '../../data/countries_data.dart';

class PassengerInfoSection extends StatelessWidget {
  const PassengerInfoSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      color: Colors.grey.shade100,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildInfoItem(
            "Enter passenger's name exactly as it appears on their ID",
            linkText: 'Passenger info guidelines',
          ),
          const SizedBox(height: 8),
          _buildInfoItem(
            "To ensure your trip goes smoothly, please make sure that the passenger's travel document is valid for at least 6 months from the date the trip ends",
          ),
        ],
      ),
    );
  }

  Widget _buildInfoItem(String text, {String? linkText}) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.only(top: 4),
          child: Icon(Icons.circle, size: 6, color: Colors.grey),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: RichText(
            text: TextSpan(
              style: const TextStyle(fontSize: 13, color: Colors.black87),
              children: [
                TextSpan(text: text),
                if (linkText != null)
                  TextSpan(
                    text: ' $linkText',
                    style: const TextStyle(
                      color: Colors.blue,
                      decoration: TextDecoration.underline,
                    ),
                  ),
              ],
            ),
          ),
        ),
        if (linkText != null)
          const Icon(Icons.info_outline, size: 16, color: Colors.blue),
      ],
    );
  }
}

class PassengerFormFields extends StatelessWidget {
  final PassengerController controller;

  const PassengerFormFields({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Passengers',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              TextButton.icon(
                onPressed: () {},
                icon: const Icon(Icons.camera_alt, size: 18),
                label: const Text('Autofill with passport'),
                style: TextButton.styleFrom(foregroundColor: Color(0xFFFFC107)
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildTextField(
            label: 'Given names *',
            controller: controller.givenNamesController,
            hint: 'e.g. MARY ISABELLE',
          ),
          const SizedBox(height: 16),
          _buildTextField(
            label: 'Surname (Last Name) *',
            controller: controller.surnameController,
            hint: 'e.g. SMITH',
          ),
          const SizedBox(height: 16),
          GenderSelector(controller: controller),
          const SizedBox(height: 16),
          NationalityField(controller: controller),
          const SizedBox(height: 16),
          DateOfBirthField(controller: controller),
        ],
      ),
    );
  }

  Widget _buildTextField({
    required String label,
    required TextEditingController controller,
    required String hint,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(color: Colors.grey.shade400),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          ),
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Please enter ${label.toLowerCase()}';
            }
            return null;
          },
        ),
      ],
    );
  }
}

class GenderSelector extends StatelessWidget {
  final PassengerController controller;

  const GenderSelector({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Gender on ID *', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(child: _buildGenderOption('Male')),
            const SizedBox(width: 12),
            Expanded(child: _buildGenderOption('Female')),
          ],
        ),
      ],
    );
  }

  Widget _buildGenderOption(String gender) {
    return Obx(() {
      final isSelected = controller.selectedGender.value == gender;
      return InkWell(
        onTap: () => controller.selectGender(gender),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 14),
          decoration: BoxDecoration(
            border: Border.all(
              color: isSelected ? Colors.blue : Colors.grey.shade300,
              width: isSelected ? 2 : 1,
            ),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Radio<String>(
                value: gender,
                groupValue: controller.selectedGender.value,
                onChanged: (value) => controller.selectGender(value!),
              ),
              Text(
                gender,
                style: TextStyle(
                  fontSize: 15,
                  color: isSelected ? Colors.blue : Colors.black,
                ),
              ),
            ],
          ),
        ),
      );
    });
  }
}

class NationalityField extends StatelessWidget {
  final PassengerController controller;

  const NationalityField({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Nationality (country/region) *', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
        const SizedBox(height: 8),
        InkWell(
          onTap: () => _showNationalityPicker(context),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey.shade300),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Obx(() => Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  controller.nationality.value.isEmpty
                      ? 'Nationality (country/region)'
                      : controller.nationality.value,
                  style: TextStyle(
                    color: controller.nationality.value.isEmpty
                        ? Colors.grey.shade400
                        : Colors.black,
                  ),
                ),
                const Icon(Icons.chevron_right, color: Colors.grey),
              ],
            )),
          ),
        ),
      ],
    );
  }

  void _showNationalityPicker(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.7,
        minChildSize: 0.5,
        maxChildSize: 0.95,
        expand: false,
        builder: (context, scrollController) => Column(
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                border: Border(bottom: BorderSide(color: Colors.grey.shade200)),
              ),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.pop(context),
                  ),
                  const Expanded(
                    child: Text(
                      'Select Nationality',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  const SizedBox(width: 48),
                ],
              ),
            ),
            Expanded(
              child: ListView.builder(
                controller: scrollController,
                itemCount: CountriesData.countries.length,
                itemBuilder: (context, index) {
                  final country = CountriesData.countries[index];
                  final isSelected = controller.nationalityController.text == country;
                  return ListTile(
                    leading: Text(country.split(' ')[0], style: const TextStyle(fontSize: 24)),
                    title: Text(
                      country.substring(country.indexOf(' ') + 1),
                      style: TextStyle(
                        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                        color: isSelected ? Color(0xFFFFC107)
                            : Colors.black,
                      ),
                    ),
                    trailing: isSelected ? const Icon(Icons.check, color: Color(0xFFFFC107)
                    ) : null,
                    onTap: () {
                      controller.selectNationality(country);
                      Navigator.pop(context);
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class DateOfBirthField extends StatelessWidget {
  final PassengerController controller;

  const DateOfBirthField({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Date of birth *', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
        const SizedBox(height: 8),
        InkWell(
          onTap: () => controller.pickDateOfBirth(context),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey.shade300),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Obx(() => Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  controller.dob.value.isEmpty
                      ? 'Date of birth'
                      : controller.dob.value,
                  style: TextStyle(
                    color: controller.dob.value.isEmpty
                        ? Colors.grey.shade400
                        : Colors.black,
                  ),
                ),
                const Icon(Icons.calendar_today, color: Colors.grey, size: 20),
              ],
            )),
          ),
        ),
      ],
    );
  }
}

class FrequentFlyerSection extends StatelessWidget {
  final PassengerController controller;

  const FrequentFlyerSection({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border(top: BorderSide(color: Colors.grey.shade200, width: 8)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          InkWell(
            onTap: controller.toggleFrequentFlyer,
            child: Obx(() => Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Frequent flyer program (optional)',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                Icon(
                  controller.showFrequentFlyer.value
                      ? Icons.keyboard_arrow_up
                      : Icons.keyboard_arrow_down,
                ),
              ],
            )),
          ),
          Obx(() {
            if (!controller.showFrequentFlyer.value) return const SizedBox.shrink();
            return Column(
              children: [
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade50,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: const [
                      Padding(
                        padding: EdgeInsets.only(top: 2),
                        child: Icon(Icons.circle, size: 6, color: Colors.grey),
                      ),
                      SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          "Add this passenger's frequent flyer details to earn airline miles/points",
                          style: TextStyle(fontSize: 13, color: Colors.black87),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            );
          }),
        ],
      ),
    );
  }
}
