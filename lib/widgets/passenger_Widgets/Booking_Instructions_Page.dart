import 'package:flutter/material.dart';
import 'package:get/get.dart';

class BookingInstructionsPage extends StatelessWidget {
  const BookingInstructionsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => Get.back(),
        ),
        title: const Text("Booking Instructions",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        elevation: 0,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text("Booking Instructions for Child/Infant Tickets",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF001D4A))),
            const SizedBox(height: 16),
            _buildInstructionText("Children and infants need to have (and be able to show) a valid passport or local ID to book tickets."),
            _buildInstructionText("One flight insurance policy can be booked at the same time when purchasing a child/infant ticket."),
            _buildInstructionText("Adult tickets can be purchased for children/infants but this varies according to airline policies."),
            _buildInstructionText("Adults and children must purchase tickets from the same cabin class, otherwise boarding may be denied."),

            const SizedBox(height: 24),
            const Text("Infant tickets (Under 2 years old)",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF001D4A))),
            const SizedBox(height: 8),
            _buildInstructionText("Infant ticket fare: Taxes and fees for infants may be charged at a reduced rate. Note: Infants do not get their own seat."),

            const SizedBox(height: 24),
            const Text("Child tickets (2-11 years old)",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF001D4A))),
            const SizedBox(height: 8),
            _buildInstructionText("A child ticket is for passengers 2-11 years old on the date of departure, as verified by a valid ID."),
            _buildInstructionText("Children/infants must be accompanied by an adult during the flight.if  unaccompanied, tickets must be booked with the airline directly."),
          ],
        ),
      ),
    );
  }

  Widget _buildInstructionText(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Text(text, style: TextStyle(fontSize: 14, color: Colors.grey[800], height: 1.5)),
    );
  }
}