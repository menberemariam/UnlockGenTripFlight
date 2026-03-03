import 'package:flutter/material.dart';
import 'package:get/get.dart';

class FlightHotelSectionController extends GetxController {
  var isChecked = false.obs;

  void toggleChecked(bool? value) {
    if (value != null) isChecked.value = value;
  }
}

class FlightHotelSectionWidget extends StatelessWidget {
  final FlightHotelSectionController controller;

  const FlightHotelSectionWidget({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              decoration: BoxDecoration(
                color: Colors.pink,
                borderRadius: BorderRadius.circular(4),
              ),
              child: const Text(
                'Save 6% on avg.',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 10,
                  fontWeight: FontWeight.normal,
                ),
              ),
            ),
          ],
        ),
        Align(
          alignment: Alignment.centerLeft, // aligns the container to the left
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.grey[200],
              borderRadius: BorderRadius.circular(8),
            ),
            child: Obx(
                  () => Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Checkbox(
                    value: controller.isChecked.value,
                    onChanged: (value) => controller.toggleChecked(value),
                    activeColor: const Color(0xFFFFC107),
                  ),
                  const SizedBox(width: 4),
                  const Text(
                    'Flight + Hotel',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ),
        )
      ],
    );
  }
}
