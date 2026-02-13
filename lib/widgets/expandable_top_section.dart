// lib/screens/home/widgets/expandable_top_bar.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:trip/screens/price_alert_screen.dart';
import 'package:trip/screens/search_anywhere_screen.dart';
import '../controllers/booking_middle_controller.dart';
import '../screens/flight_status_screen.dart';
import '../screens/frequent_flyer_programs.dart';
import '../screens/my_booking_screen.dart';

class ExpandableTopBar extends StatelessWidget {
  final HomeController controller;

  const ExpandableTopBar({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Obx(
              () => Container(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _ActionButton(
                  icon: Icons.public,
                  label: 'Search anywhere',
                  onTap: () => Get.to(SearchAnyWhere())
                ),
                _ActionButton(
                  icon: Icons.show_chart,
                  label: 'Flight status',
                  onTap: () => Get.to(FlightStatus())
                ),
                _ActionButton(
                  icon: controller.isExpanded.value
                      ? Icons.keyboard_arrow_up
                      : Icons.keyboard_arrow_down,
                  label: controller.isExpanded.value ? 'Show less' : 'More',
                  onTap: controller.toggleExpanded,
                ),
              ],
            ),
          ),
        ),

        Obx(
              () => controller.isExpanded.value
              ? Container(
            margin: const EdgeInsets.symmetric(horizontal: 16),
            decoration: BoxDecoration(
              color: const Color(0xFFEFF3FF),
              borderRadius: BorderRadius.circular(3),
            ),
            child: Column(
              children: [
                _ExpandableItem(
                  icon: Icons.notification_add,
                  title: 'Flight Alert',
                  route: PriceAlertScreen(),
                ),
                const Divider(height: 1, color: Colors.grey),
                _ExpandableItem(
                  icon: Icons.calendar_today,
                  title: 'My bookings',
                  route: MyBookingsScreen(),
                ),
                const Divider(height: 1, color: Colors.grey),
                _ExpandableItem(
                  icon: Icons.credit_card,
                  title: 'Frequent flyer programs',
                  route: FrequentFlyerScreen(),
                ),
              ],
            ),
          )
              : const SizedBox.shrink(),
        ),
      ],
    );
  }
}

class _ActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _ActionButton({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: const Color(0xFFEBF4FF),
            ),
            child: Icon(icon, color: const Color(0xFF007AFF), size: 24),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: const TextStyle(fontSize: 12, color: Colors.black),
          ),
        ],
      ),
    );
  }
}

class _ExpandableItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final Widget route;

  const _ExpandableItem({
    required this.icon,
    required this.title,
    required this.route,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => Get.to(route),
      child: ListTile(
        leading: Icon(icon, color: Colors.blue, size: 16,),
        title: Text(title, style: const TextStyle(color: Colors.black, fontSize: 16)),


      ),
    );
  }
}