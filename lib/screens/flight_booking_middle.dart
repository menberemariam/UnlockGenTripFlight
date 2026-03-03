import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../widgets/business_class_promo.dart';
import '../../widgets/expandable_top_section.dart';
import '../../widgets/explore_world_section.dart';
import '../../widgets/travel_inspiration_section.dart';

import '../controllers/booking_controllers/booking_middle_controller.dart';

class FlightBookingMiddle extends StatelessWidget {
  const FlightBookingMiddle({super.key});

  @override
  Widget build(BuildContext context) {
    final MiddleController controller = Get.put(MiddleController());

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ExpandableTopBar(controller: controller),
        const BusinessClassPromo(),
        const TravelInspirationHeader(),
        const SizedBox(height: 8),
        const ExploreWorldSection(),
        const SizedBox(height: 40), // breathing room — adjust as needed

        SafeArea(
          top: false,
          bottom: true,
          child: SizedBox(
            height: MediaQuery.of(context).padding.bottom,
          ),
        ),
      ],
    );
  }
}