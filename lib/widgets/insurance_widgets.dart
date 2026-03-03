import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/passenger_controllers/passenger_info.dart';

class InsuranceSection extends StatelessWidget {
  final PassengerInfoController controller;

  const InsuranceSection({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      color: Colors.grey.shade50,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Add Insurance',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          const SizedBox(height: 16),
          InsuranceOption(
            controller: controller,
            value: 'no_protection',
            title: "I'm okay with no protection",
            price: null,
            bgColor: Colors.orange.shade50,
            icon: Icons.warning_amber,
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.cyan.shade50,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.shield, color: Colors.cyan.shade700),
                    const SizedBox(width: 8),
                    const Text(
                      'Protection Plans',
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                InsuranceOption(
                  controller: controller,
                  value: 'travel',
                  title: 'Travel Insurance',
                  price: 35.03,
                  bgColor: Colors.cyan.shade700,
                  benefits: const [
                    'Up to £1,000,000 of emergency medical expenses',
                    'Up to £1,000 of baggage loss, theft or accidental damage',
                    'Up to £1,000 of prepaid trip costs if you cancel',
                    'Up to £500 if you miss your departure',
                    'Up to £250 of Trip delay for delays 4 hours or longer',
                    '24/7 emergency medical assistance',
                  ],
                ),
                const SizedBox(height: 12),
                InsuranceOption(
                  controller: controller,
                  value: 'cancellation',
                  title: 'Travel Cancellation Insurance',
                  price: 25.70,
                  bgColor: Colors.cyan.shade700,
                  benefits: const ['Total 2 benefits'],
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.blue.shade50,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                Icon(Icons.info_outline, color: Colors.blue.shade700, size: 20),
                const SizedBox(width: 8),
                const Expanded(
                  child: Text(
                    'Great coverage when travelling',
                    style: TextStyle(fontSize: 12),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class InsuranceOption extends StatelessWidget {
  final PassengerInfoController controller;
  final String value;
  final String title;
  final double? price;
  final Color bgColor;
  final IconData? icon;
  final List<String>? benefits;

  const InsuranceOption({
    super.key,
    required this.controller,
    required this.value,
    required this.title,
    required this.price,
    required this.bgColor,
    this.icon,
    this.benefits,
  });

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final isSelected = controller.selectedInsurance.value == value;
      return GestureDetector(
        onTap: () => controller.selectInsurance(value),
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: bgColor,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: isSelected ? Color(0xFFFFC107)  : Colors.grey.shade300,
              width: isSelected ? 2 : 1,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  if (icon != null) ...[
                    Icon(icon, color: Colors.orange.shade700, size: 20),
                    const SizedBox(width: 8),
                  ],
                  Expanded(
                    child: Text(
                      title,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                  Radio<String>(
                    value: value,
                    groupValue: controller.selectedInsurance.value,
                    onChanged: (val) => controller.selectInsurance(val!),
                  ),
                ],
              ),
              if (benefits != null) ...[
                const SizedBox(height: 8),
                ...benefits!.map((benefit) => Padding(
                  padding: const EdgeInsets.symmetric(vertical: 2),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Icon(Icons.check, size: 16, color: Colors.teal),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          benefit,
                          style: const TextStyle(fontSize: 12),
                        ),
                      ),
                    ],
                  ),
                )),
                if (price != null) ...[
                  const SizedBox(height: 8),
                  Text(
                    '£${price!.toStringAsFixed(2)}/adult',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const Text(
                    'Only available to residents of: UK',
                    style: TextStyle(fontSize: 11, color: Colors.white),
                  ),
                ],
              ],
            ],
          ),
        ),
      );
    });
  }
}

class FlightSummary extends StatelessWidget {
  final dynamic flight;
  final dynamic searchParams;

  const FlightSummary({
    super.key,
    required this.flight,
    required this.searchParams,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.blue.shade50,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                Icon(Icons.lock_clock, color: Color(0xFFFFC107)
                    , size: 20),
                const SizedBox(width: 8),
                const Expanded(
                  child: Text(
                    'Act fast to lock in the current price and cabin',
                    style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '${searchParams?.from ?? ''} → ${searchParams?.to ?? ''}',
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              const Icon(Icons.expand_more),
            ],
          ),
          Text(
            '${searchParams?.date != null ? "${searchParams!.date.day}/${searchParams!.date.month}" : ""}  ${flight?.departureTime ?? ''}–${flight?.arrivalTime ?? ''}',
            style: TextStyle(color: Colors.grey.shade600),
          ),
          const SizedBox(height: 8),
          InkWell(
            onTap: () {},
            child: Row(
              children: [
                Text(
                  'Notices 3',
                  style: TextStyle(color: Colors.grey.shade600),
                ),
                const SizedBox(width: 16),
                Text(
                  'Baggage & policies',
                  style: TextStyle(color: Colors.grey.shade600),
                ),
                const Spacer(),
                const Icon(Icons.chevron_right, size: 20),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class StepIndicator extends StatelessWidget {
  final int currentStep;
  final int totalSteps;

  const StepIndicator({
    super.key,
    required this.currentStep,
    this.totalSteps = 4,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 16),
      child: Row(
        children: List.generate(
          totalSteps,
              (index) => _buildStep(index + 1, index + 1 == currentStep),
        ),
      ),
    );
  }

  Widget _buildStep(int number, bool active) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 4),
      width: 24,
      height: 24,
      decoration: BoxDecoration(
        color: active ? Color(0xFFFFC107)
            : Colors.grey.shade300,
        shape: BoxShape.circle,
      ),
      child: Center(
        child: Text(
          '$number',
          style: TextStyle(
            color: active ? Colors.white : Colors.grey.shade600,
            fontSize: 12,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}
