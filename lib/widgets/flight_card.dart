// widgets/flight_card.dart
import 'package:flutter/material.dart';

class FlightCard extends StatelessWidget {
  final String departureTime;
  final String duration;
  final String arrivalTime;
  final String price;
  final String airline;
  final String aircraft;
  final String departureCode;
  final String arrivalCode;
  final bool isCheapest;
  final VoidCallback onBook;

  const FlightCard({
    super.key,
    required this.departureTime,
    required this.duration,
    required this.arrivalTime,
    required this.price,
    required this.airline,
    required this.aircraft,
    required this.departureCode,
    required this.arrivalCode,
    this.isCheapest = false,
    required this.onBook,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12, left: 12, right: 12),
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (isCheapest)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                decoration: BoxDecoration(
                  color: const Color(0xFFECBC62),
                  borderRadius: BorderRadius.circular(3),
                ),
                child: const Text(
                  "Cheapest",
                  style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold),
                ),
              ),
            const SizedBox(height: 10),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(departureTime, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 4),
                    Text(departureCode, style: const TextStyle(color: Colors.grey, fontSize: 13)),
                  ],
                ),
                Column(
                  children: [
                    Text(duration, style: const TextStyle(color: Colors.grey, fontSize: 15)),
                    const Icon(Icons.arrow_forward, size: 24, color: Colors.grey),
                  ],
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(arrivalTime, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 4),
                    Text(arrivalCode, style: const TextStyle(color: Colors.grey, fontSize: 13)),
                  ],
                ),
                Text(
                  price,
                  style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Color(0xFFEAA21B)),
                ),
              ],
            ),

            const SizedBox(height: 16),

            Row(
              children: [
                const Icon(Icons.flight_takeoff, size: 18, color: Color(0xFFEAA21B)),
                const SizedBox(width: 8),
                Text("$airline  •  $aircraft", style: const TextStyle(fontSize: 14)),
              ],
            ),

            const SizedBox(height: 16),

            Align(
              alignment: Alignment.centerRight,
              child: ElevatedButton(
                onPressed: onBook,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFEAA21B),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 12),
                ),
                child: const Text("Book now", style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}