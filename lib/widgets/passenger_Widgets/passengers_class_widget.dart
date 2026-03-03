import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/passenger_controllers/passengers_class_controller.dart';
import 'Full_Selection_Sheet_Widget.dart';

class PassengersClassWidget extends StatelessWidget {
  final PassengersClassController controller;

  const PassengersClassWidget({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<PassengersClassController>();
    return Obx(() {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 12.0),
        child: Row(
          children: [
            GestureDetector(
              onTap: () => controller.showPassengersSheet(),
              behavior: HitTestBehavior.opaque,
              child: Row(
                children: [
                  const Icon(Icons.person_outline, color: Color(0xFFD4AF37) , size: 22),
                  const SizedBox(width: 4),
                  Text('${controller.adults.value}',
                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  const SizedBox(width: 14),
                  const Icon(Icons.work_outline, color: Color(0xFFD4AF37) , size: 20),
                  const SizedBox(width: 4),
                  Text('${controller.children.value}',
                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  const SizedBox(width: 14),
                  const Icon(Icons.face_outlined, color: Color(0xFFD4AF37) , size: 20),
                  const SizedBox(width: 4),
                  Text('${controller.infants.value}',
                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                ],
              ),
            ),

            const SizedBox(width: 12),
            const Text('|', style: TextStyle(color: Colors.grey, fontSize: 18)),
            const SizedBox(width: 12),

            // --- FLIGHT CLASS SECTION
            Expanded(
              child: GestureDetector(
                onTap: () => _showClassPicker(),
                behavior: HitTestBehavior.opaque,
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        controller.selectedClass.value,
                        style: const TextStyle(fontSize: 14, color: Colors.black87),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const Icon(Icons.keyboard_arrow_down, color: Colors.grey),
                  ],
                ),
              ),
            ),
          ],
        ),
      );
    });
  }

  void _showClassPicker() {
    Get.bottomSheet(
      const ClassSelectionSheet(),
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
    );
  }
}