// lib/screens/home/flight_booking_middle.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../widgets/business_class_promo.dart';
import '../../widgets/expandable_top_section.dart';
import '../../widgets/explore_world_section.dart';
import '../../widgets/flight_status.dart';
import '../../widgets/travel_inspiration_section.dart';
import 'booking_middle_controller.dart';

class FlightBookingMiddle extends StatelessWidget {
  FlightBookingMiddle({super.key});

  final HomeController controller = Get.put(HomeController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ExpandableTopBar(controller: controller),
            const BusinessClassPromo(),
            const TravelInspirationHeader(),
            const SizedBox(height: 8),
            const ExploreWorldSection(),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}
