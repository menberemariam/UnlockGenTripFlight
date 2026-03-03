import 'package:flutter/material.dart';
import 'package:get/get.dart';

class SpecialAssistanceScreen extends StatelessWidget {
  const SpecialAssistanceScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFEEF4FF),
      appBar: AppBar(
        backgroundColor: const Color(0xFFEAA21B),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Get.back(),
        ),
        title: const Text(
          'Special Assistance',
          style: TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Card(
              elevation: 2,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'We are here to help',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFFEAA21B),
                      ),
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      'Please inform us at least 48 hours before departure if you require any of the following services:',
                      style: TextStyle(fontSize: 15, height: 1.4),
                    ),
                    const SizedBox(height: 20),
                    _buildAssistanceItem(
                      icon: Icons.accessible,
                      title: 'Wheelchair assistance',
                      description: 'From check-in to boarding & arrival',
                    ),
                    _buildAssistanceItem(
                      icon: Icons.blind,
                      title: 'Visual / hearing impairment',
                      description: 'Guide assistance, priority boarding, special briefings',
                    ),
                    _buildAssistanceItem(
                      icon: Icons.child_care,
                      title: 'Unaccompanied minors (5–11 years)',
                      description: 'Dedicated escort service throughout journey',
                    ),
                    _buildAssistanceItem(
                      icon: Icons.medical_services,
                      title: 'Medical oxygen or stretcher',
                      description: 'Requires medical clearance & advance request',
                    ),
                    _buildAssistanceItem(
                      icon: Icons.pets,
                      title: 'Traveling with service animal',
                      description: 'Documentation required – contact us early',
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            Card(
              color: const Color(0xFFFFF8E1),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    const Icon(
                      Icons.phone_in_talk,
                      size: 40,
                      color: Color(0xFFEAA21B),
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'Need special assistance?',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      'Contact our Special Assistance team\nat least 48 hours before your flight',
                      style: TextStyle(
                        fontSize: 15,
                        color: Colors.black87,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton.icon(
                      onPressed: () {
                        // TODO: open phone dialer or contact page
                        Get.snackbar('Contact', 'Call +251 911 123 456');
                      },
                      icon: const Icon(Icons.phone),
                      label: const Text('Contact Us'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFEAA21B),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 14),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildAssistanceItem({
    required IconData icon,
    required String title,
    required String description,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: const Color(0xFFE6F0FF),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: const Color(0xFFEAA21B), size: 28),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[700],
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