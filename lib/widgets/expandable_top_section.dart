// lib/screens/home/widgets/expandable_top_bar.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:trip3/widgets/flight_status.dart';
import 'package:trip3/widgets/search_anywhere.dart';

import '../screen/home/home_controller.dart';

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
                  onTap: () => Get.to(FlightSearchResultsScreen())
                ),
                _ActionButton(
                  icon: Icons.notification_add,
                  label: 'Price alerts',
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
                  icon: Icons.show_chart,
                  title: 'Flight Status',
                  route: '/flight_status',
                ),
                const Divider(height: 1, color: Colors.grey),
                _ExpandableItem(
                  icon: Icons.calendar_today,
                  title: 'My bookings',
                  route: '/my_bookings',
                ),
                const Divider(height: 1, color: Colors.grey),
                _ExpandableItem(
                  icon: Icons.credit_card,
                  title: 'Frequent flyer programs',
                  route: '/frequent_flyer',
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
  final String route;

  const _ExpandableItem({
    required this.icon,
    required this.title,
    required this.route,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => Get.toNamed(route),
      child: ListTile(
        leading: Icon(icon, color: Colors.blue, size: 16,),
        title: Text(title, style: const TextStyle(color: Colors.black, fontSize: 16)),


      ),
    );
  }
}