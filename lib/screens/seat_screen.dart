import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/seat_controller.dart';
import '../utils/extensions.dart';
import '../widgets/seat_widgets.dart';

class FlightSeatSelectionScreen extends StatelessWidget {
  const FlightSeatSelectionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final ctrl = Get.put(SeatController());
    const brand = Color(0xFFEAA21B);

    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      appBar: AppBar(
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
        title: const Text("Select seat"),
        actions: const [
          Padding(
            padding: EdgeInsets.only(right: 16),
            child: Text("1/4", style: TextStyle(fontSize: 16)),
          ),
        ],
      ),
      body: Column(
        children: [
          // Price banner
          Container(
            width: double.infinity,
            color: brand.withOpacity(0.12),
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "\$12.60 - \$20.50",
                  style: TextStyle(
                    color: brand.darker(0.1),
                    fontWeight: FontWeight.w700,
                    fontSize: 15,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Text(
                    "Not available",
                    style: TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                ),
              ],
            ),
          ),

          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12), // ← reduced horizontal padding
              child: Column(
                children: [
                  // Legend
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _buildLegendItem(brand, "Selected"),
                      const SizedBox(width: 20),
                      _buildLegendItem(Colors.grey.shade700, "Occupied"),
                      const SizedBox(width: 20),
                      _buildLegendItem(Colors.white, "Available"),
                    ],
                  ),
                  const SizedBox(height: 24),

                  ..._buildSeatSection(ctrl, 1, 7, brand),
                  const SizedBox(height: 32),
                  ..._buildSeatSection(ctrl, 11, 19, brand),
                  const SizedBox(height: 32),
                  ..._buildSeatSection(ctrl, 22, 30, brand),
                ],
              ),
            ),
          ),

          // Bottom bar (already fixed in previous message)
          Container(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 28),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.08),
                  blurRadius: 12,
                  offset: const Offset(0, -2),
                ),
              ],
            ),
            child: Row(
              children: [
                Expanded(
                  child: Obx(() => Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        ctrl.selectedSeats.isEmpty
                            ? "No seat selected"
                            : "${ctrl.selectedSeats.length} seat${ctrl.selectedSeats.length > 1 ? 's' : ''}",
                        style: const TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 15,
                        ),
                      ),
                      Text(
                        "Total (1 adult)  \$${ctrl.basePrice.toStringAsFixed(2)}",
                        style: const TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  )),
                ),
                ElevatedButton(
                  onPressed: () => Get.snackbar("Skipped", "Proceeding without seat selection"),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: brand,
                    foregroundColor: Colors.black87,
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: const Text(
                    "Skip seat selection",
                    style: TextStyle(fontWeight: FontWeight.w700),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLegendItem(Color color, String text) {
    return Row(
      children: [
        Container(
          width: 16,
          height: 16,
          decoration: BoxDecoration(
            color: color,
            border: Border.all(color: Colors.grey.shade400),
            borderRadius: BorderRadius.circular(4),
          ),
        ),
        const SizedBox(width: 6),
        Text(text, style: const TextStyle(fontSize: 13)),
      ],
    );
  }

  List<Widget> _buildSeatSection(SeatController ctrl, int startRow, int endRow, Color brand) {
    return List.generate(endRow - startRow + 1, (i) {
      final row = startRow + i;
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center, // ← helps centering
          mainAxisSize: MainAxisSize.min,
          children: [
            // Left block A B C
            ...["A", "B", "C"].map((letter) {
              final seat = "$row$letter";
              return Obx(() => SeatWidget(  // ← added Obx here → now rebuilds on selection change
                label: letter,
                isSelected: ctrl.isSelected(seat),
                isOccupied: ctrl.isOccupied(seat),
                brandColor: brand,
                onTap: () {
                  if (ctrl.isOccupied(seat)) {
                    Get.snackbar(
                      "Occupied",
                      "This seat is already taken",
                      snackPosition: SnackPosition.BOTTOM,
                      duration: const Duration(seconds: 2),
                    );
                    return;
                  }
                  ctrl.toggleSeat(seat);
                },
              ));
            }),

            const SizedBox(width: 32), // aisle – reduced from 40

            // Right block D E F
            ...["D", "E", "F"].map((letter) {
              final seat = "$row$letter";
              return Obx(() => SeatWidget(
                label: letter,
                isSelected: ctrl.isSelected(seat),
                isOccupied: ctrl.isOccupied(seat),
                brandColor: brand,
                onTap: () {
                  if (ctrl.isOccupied(seat)) {
                    Get.snackbar(
                      "Occupied",
                      "This seat is already taken",
                      snackPosition: SnackPosition.BOTTOM,
                      duration: const Duration(seconds: 2),
                    );
                    return;
                  }
                  ctrl.toggleSeat(seat);
                },
              ));
            }),

            const SizedBox(width: 12),
            SizedBox(
              width: 32, // fixed width for row number → prevents push/overflow
              child: Text(
                "$row",
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                  color: Colors.grey,
                ),
              ),
            ),
          ],
        ),
      );
    });
  }
}