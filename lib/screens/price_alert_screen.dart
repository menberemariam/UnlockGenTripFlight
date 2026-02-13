import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:get/get_instance/src/extension_instance.dart';
import 'package:get/get_navigation/src/extension_navigation.dart';
import 'package:get/get_state_manager/src/rx_flutter/rx_obx_widget.dart';
import '../controllers/price_alert_controller.dart';

class PriceAlertScreen extends StatelessWidget {
  const PriceAlertScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final ctrl = Get.put(PriceAlertController());

    return Scaffold(
      appBar: AppBar(
        leading: const BackButton(),
        title: const Text("Price Alerts"),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Hint banner
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.blue.shade50,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      "Choose more dates, boost your\nchances of hitting the target price!",
                      style: TextStyle(
                        color: Colors.blue.shade800,
                        fontSize: 14,
                      ),
                    ),
                  ),
                  const Icon(Icons.airplanemode_active, color: Colors.blue),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // One-way / Round-trip toggle
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.06),
                    blurRadius: 10,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Obx(
                          () => _TripTypeButton(
                        text: "One-way",
                        selected: !ctrl.isRoundTrip.value,
                        onTap: () => ctrl.toggleRoundTrip(false),
                      ),
                    ),
                  ),
                  Expanded(
                    child: Obx(
                          () => _TripTypeButton(
                        text: "Round-trip",
                        selected: ctrl.isRoundTrip.value,
                        onTap: () => ctrl.toggleRoundTrip(true),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // Cities & Dates
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(color: Colors.black12, blurRadius: 6),
                ],
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _CityDateColumn(
                        city: "Tokyo",
                        date: "Sat, Feb 14",
                      ),
                      const Icon(Icons.flight, color: Colors.blue, size: 32),
                      _CityDateColumn(
                        city: "Los Angeles",
                        date: "Sat, Feb 14",
                        isArrival: true,
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      const Text("Nonstop", style: TextStyle(fontSize: 15)),
                      const Spacer(),
                      Obx(
                            () => Switch(
                          value: ctrl.nonstop.value,
                          onChanged: ctrl.toggleNonstop,
                          activeColor: Colors.blue,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Price alert card
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(color: Colors.black.withOpacity(0.08), blurRadius: 12),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Notify me when the price is <\$ ${ctrl.alertPrice.toStringAsFixed(2)}",
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Price slider simulation
                  Column(
                    children: [
                      Stack(
                        alignment: Alignment.center,
                        children: [
                          Container(
                            height: 8,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(4),
                              gradient: const LinearGradient(
                                colors: [Colors.red, Colors.orange, Colors.yellow, Colors.green],
                              ),
                            ),
                          ),
                          Align(
                            alignment: Alignment(
                              // rough mapping: 718 → -0.8 , 773 → ~0.3
                              ((ctrl.currentPrice - 700) / (800 - 700) * 2 - 1).clamp(-1.0, 1.0),
                              0,
                            ),
                            child: const Icon(Icons.star, color: Colors.blue, size: 32),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text("\$${ctrl.currentPrice.toStringAsFixed(2)}",
                              style: const TextStyle(color: Colors.green)),
                          Text("Recommended: \$${ctrl.recommendedPrice.toStringAsFixed(2)}",
                              style: TextStyle(color: Colors.blue.shade700)),
                        ],
                      ),
                      const SizedBox(height: 4),
                      const Text("High chances of success 😊",
                          style: TextStyle(color: Colors.green, fontSize: 13)),
                    ],
                  ),

                  const SizedBox(height: 20),

                  Row(
                    children: [
                      Obx(
                            () => Switch(
                          value: ctrl.emailAlerts.value,
                          onChanged: ctrl.toggleEmail,
                          activeColor: Colors.blue,
                        ),
                      ),
                      const SizedBox(width: 8),
                      const Text("Receive price alerts by email"),
                    ],
                  ),

                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Text(
                        ctrl.email,
                        style: const TextStyle(color: Colors.blue),
                      ),
                      const Spacer(),
                      TextButton(
                        onPressed: () {
                          Get.snackbar("Edit", "Email edit not implemented in demo");
                        },
                        child: const Text("Edit"),
                      ),
                    ],
                  ),

                  const SizedBox(height: 16),

                  SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      onPressed: () {
                        Get.snackbar("Success", "Price alert added!");
                      },
                      child: const Text(
                        "Add a price alert",
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }
}

// ──────────────────────────────────────────────── Helper Widgets ───

class _TripTypeButton extends StatelessWidget {
  final String text;
  final bool selected;
  final VoidCallback onTap;

  const _TripTypeButton({
    required this.text,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: selected ? Colors.blue : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Center(
          child: Text(
            text,
            style: TextStyle(
              color: selected ? Colors.white : Colors.black87,
              fontWeight: selected ? FontWeight.w600 : FontWeight.normal,
            ),
          ),
        ),
      ),
    );
  }
}

class _CityDateColumn extends StatelessWidget {
  final String city;
  final String date;
  final bool isArrival;

  const _CityDateColumn({
    required this.city,
    required this.date,
    this.isArrival = false,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment:
      isArrival ? CrossAxisAlignment.end : CrossAxisAlignment.start,
      children: [
        Text(
          city,
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 4),
        Text(
          date,
          style: TextStyle(fontSize: 14, color: Colors.grey[700]),
        ),
      ],
    );
  }
}