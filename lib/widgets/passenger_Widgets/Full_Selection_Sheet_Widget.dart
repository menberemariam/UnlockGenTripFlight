import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/passengers_class_controller.dart';

class ClassSelectionSheet extends StatelessWidget {
  const ClassSelectionSheet({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<PassengersClassController>();

    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Padding(
            padding: EdgeInsets.all(16.0),
            child: Text("Class", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          ),
          const Divider(height: 1),
          // List of classes
          ListView.builder(
            shrinkWrap: true,
            itemCount: controller.flightClasses.length,
            itemBuilder: (context, index) {
              final className = controller.flightClasses[index];
              return Obx(() {
                final isSelected = controller.selectedClass.value == className;
                return ListTile(
                  title: Text(
                    className,
                    style: TextStyle(
                      color: isSelected ? const Color(0xFF1E5EFF) : Colors.black,
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                    ),
                  ),
                  trailing: isSelected
                      ? const Icon(Icons.check, color: Color(0xFF1E5EFF))
                      : null,
                  onTap: () => controller.selectClass(className),
                );
              });
            },
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }
}