import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'flight_ticket_screen.dart';

class SelectFareScreen extends StatelessWidget {
  const SelectFareScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: const BackButton(),
        title: const Text("Select fare"),
        actions: const [
          IconButton(
            icon: Icon(Icons.notifications_outlined),
            onPressed: null, // Price alerts
          ),
          IconButton(
            icon: Icon(Icons.more_vert),
            onPressed: null,
          ),
        ],
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Flight summary header
            Container(
              color: Colors.white,
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Sun, Mar 8 • 2h 30m",
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 16),

                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            "6:25 AM",
                            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 4),
                          const Text(
                            "NRT",
                            style: TextStyle(fontSize: 14, color: Colors.grey),
                          ),
                          const Text(
                            "Tokyo Narita Intl. T3",
                            style: TextStyle(fontSize: 13, color: Colors.grey),
                          ),
                        ],
                      ),
                      const Expanded(
                        child: Column(
                          children: [
                            Icon(Icons.arrow_downward, size: 28, color: Colors.grey),
                            Text(
                              "Jetstar Japan GK519",
                              style: TextStyle(fontSize: 12, color: Colors.grey),
                              textAlign: TextAlign.center,
                            ),
                            Text(
                              "Airbus A320",
                              style: TextStyle(fontSize: 12, color: Colors.grey),
                            ),
                          ],
                        ),
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          const Text(
                            "8:55 AM",
                            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 4),
                          const Text(
                            "FUK",
                            style: TextStyle(fontSize: 14, color: Colors.grey),
                          ),
                          const Text(
                            "Fukuoka Airport D",
                            style: TextStyle(fontSize: 13, color: Colors.grey),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 12),

            // Fare options
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Basic fare
                  _FareOptionCard(
                    price: "\$50 /person",
                    isSelected: true,
                    items: const [
                      _FareItem(icon: Icons.card_travel, text: "Personal item: Included", included: true),
                      _FareItem(icon: Icons.luggage, text: "Carry-on baggage: 1 piece", included: true),
                      _FareItem(icon: Icons.close, text: "No free checked baggage", included: false),
                      _FareItem(icon: Icons.close, text: "Non-refundable", included: false),
                      _FareItem(
                        icon: Icons.change_circle_outlined,
                        text: "Change fee: from \$38",
                        included: true,
                        color: Colors.blue,
                      ),
                    ],
                    footer: const Text(
                      "Economy class • View details >",
                      style: TextStyle(color: Colors.blue, fontSize: 14),
                    ),

                    // ── Added navigation ──
                    onSelect: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const FlightTicketScreen()),
                      );
                    },
                  ),

                  const SizedBox(height: 16),

                  // TripFlex option
                  _FareOptionCard(
                    title: "TripFlex • EasyCancel & Change",
                    price: "+\$9 /person",
                    buttonText: "Select",
                    buttonColor: Colors.blue,
                    isHighlighted: true,
                    items: const [
                      _FareItem(
                        icon: Icons.check_circle,
                        text: "Cancellation fee: Free \$50",
                        included: true,
                        color: Colors.blue,
                      ),
                      _FareItem(
                        icon: Icons.check_circle,
                        text: "Change fee: Free from \$38",
                        included: true,
                        color: Colors.blue,
                      ),
                    ],
                    note: "* Valid before departure of the first flight. Not transferable to changed flights.",
                    extraInfo: Row(
                      children: const [
                        CircleAvatar(
                          radius: 12,
                          backgroundColor: Colors.purple,
                          child: Text("A", style: TextStyle(color: Colors.white, fontSize: 12)),
                        ),
                        SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            "A*** just saved \$1,962.62 with this service",
                            style: TextStyle(fontSize: 13, color: Colors.grey),
                          ),
                        ),
                      ],
                    ),

                    onSelect: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const FlightTicketScreen()),
                      );
                    },
                  ),

                  const SizedBox(height: 16),

                  _FareOptionCard(
                    price: "+\$0 /person",
                    buttonText: "Select",
                    buttonColor: Colors.grey.shade400,
                    items: const [
                      _FareItem(
                        icon: Icons.block,
                        text: "No flexibility",
                        included: false,
                        color: Colors.grey,
                      ),
                    ],
                    // ── Added navigation ──
                    onSelect: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const FlightTicketScreen()),
                      );
                    },
                  ),

                  const SizedBox(height: 80),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ──────────── Reusable Widgets ──────────

class _FareOptionCard extends StatelessWidget {
  final String? title;
  final String price;
  final List<_FareItem> items;
  final Widget? footer;
  final String? note;
  final Widget? extraInfo;
  final String? buttonText;
  final Color? buttonColor;
  final bool isSelected;
  final bool isHighlighted;
  final VoidCallback? onSelect;

  const _FareOptionCard({
    required this.price,
    required this.items,
    this.title,
    this.footer,
    this.note,
    this.extraInfo,
    this.buttonText = "Select",
    this.buttonColor = Colors.blue,
    this.isSelected = false,
    this.isHighlighted = false,
    this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: isSelected || isHighlighted
            ? Border.all(color: Colors.blue, width: 2)
            : Border.all(color: Colors.grey.shade300),
        boxShadow: isHighlighted
            ? [BoxShadow(color: Colors.teal.withOpacity(0.15), blurRadius: 10, offset: const Offset(0, 4))]
            : null,
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (title != null)
                        Text(
                          title!,
                          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                      const SizedBox(height: 4),
                      Text(
                        price,
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: buttonColor,
                        ),
                      ),
                    ],
                  ),
                ),
                if (buttonText != null)
                  ElevatedButton(
                    onPressed: onSelect ?? () {Get.to(FlightTicketScreen());},
                    style: ElevatedButton.styleFrom(
                      backgroundColor: buttonColor,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                    child: Text(buttonText!),
                  ),
              ],
            ),

            const SizedBox(height: 16),

            ...items,

            if (note != null) ...[
              const SizedBox(height: 12),
              Text(
                note!,
                style: const TextStyle(fontSize: 12, color: Colors.grey, fontStyle: FontStyle.italic),
              ),
            ],

            if (extraInfo != null) ...[
              const SizedBox(height: 12),
              extraInfo!,
            ],

            if (footer != null) ...[
              const SizedBox(height: 12),
              footer!,
            ],
          ],
        ),
      ),
    );
  }
}

class _FareItem extends StatelessWidget {
  final IconData icon;
  final String text;
  final bool included;
  final Color? color;

  const _FareItem({
    required this.icon,
    required this.text,
    required this.included,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Icon(
            icon,
            size: 18,
            color: included ? (color ?? Colors.blue) : Colors.red,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                color: included ? Colors.black87 : Colors.grey.shade700,
                fontSize: 14,
              ),
            ),
          ),
        ],
      ),
    );
  }
}