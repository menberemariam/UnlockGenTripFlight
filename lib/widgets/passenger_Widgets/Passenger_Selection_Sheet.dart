import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/passengers_class_controller.dart';
import 'Booking_Instructions_Page.dart';
class PassengerSelectionSheet extends StatelessWidget {
  const PassengerSelectionSheet({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<PassengersClassController>();

    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Header Row
          Stack(
            children: [
              Align(
                alignment: Alignment.centerLeft,
                child: IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Get.back(),
                ),
              ),
              const Align(
                alignment: Alignment.center,
                child: Padding(
                  padding: EdgeInsets.only(top: 12),
                  child: Text("Passengers",
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          _buildCounterRow(controller, "Adults", "12+ years old", "adults"),
          const Divider(),
          _buildCounterRow(controller, "Children", "2-11 years old", "children"),
          const Divider(),
          _buildCounterRow(controller, "Infants on lap", "Under 2 years at time of travel", "infants"),

          const SizedBox(height: 20),
          GestureDetector(
            onTap: () {
              Get.to(() => const BookingInstructionsPage(), transition: Transition.rightToLeft);
            },
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFFE8F0FF),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Icon(Icons.info_outline, color: Color(0xFFFFC107), size: 18),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          "Results show avg. price/passenger (incl. taxes). Prices may vary by passenger type.",
                          style: TextStyle(fontSize: 12, color: Colors.grey[800]),
                        ),
                      ),
                    ],
                  ),
                  const Padding(
                    padding: EdgeInsets.only(left: 26, top: 4),
                    child: Text(
                      "Booking instructions for children/infants",
                      style: TextStyle(
                        fontSize: 12,
                        color: Color(0xFF1E5EFF),
                        fontWeight: FontWeight.w500,
                        decoration: TextDecoration.none,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 24),

          // Confirm Button
          SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFFFC107),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
              onPressed: () => Get.back(),
              child: const Text("Confirm",
                  style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 16)),
            ),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildCounterRow(PassengersClassController controller, String title, String sub, String type) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              Text(sub, style: TextStyle(color: Colors.grey[600], fontSize: 13)),
            ],
          ),
          Row(
            children: [
              IconButton(
                onPressed: () => controller.updateCount(type, -1),
                icon: const Icon(Icons.remove_circle_outline, color: Color(0xFFFFC107)),
              ),
              SizedBox(
                width: 30,
                child: Center(
                  child: Obx(() {
                    int count = (type == 'adults') ? controller.adults.value :
                    (type == 'children') ? controller.children.value : controller.infants.value;
                    return Text("$count", style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold));
                  }),
                ),
              ),
              IconButton(
                onPressed: () => controller.updateCount(type, 1),
                icon: const Icon(Icons.add_circle, color: Color(0xFFFFC107)),
              ),
            ],
          ),
        ],
      ),
    );
  }
}