import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';
import 'providers/booking_provider.dart';
import 'routes/app_routes.dart';
import 'controllers/flight_search_controller.dart';
import 'controllers/flight_booking_controller.dart';
import 'controllers/passengers_class_controller.dart';
import 'controllers/passenger_info_controller.dart';

void main() {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => BookingProvider(),
        ),
      ],
      child: const TripBookingApp(),
    ),
  );
}

class TripBookingApp extends StatelessWidget {
  const TripBookingApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'Habesha Wings',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primaryColor: const Color(0xFFFFD700),
        scaffoldBackgroundColor: Colors.white,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFFFFD700),
          primary: const Color(0xFFFFD700),
          secondary: const Color(0xFFFFC107),
        ),
        appBarTheme: const AppBarTheme(
          elevation: 0,
          centerTitle: true,
          backgroundColor: Color(0xFFFFD700),
          foregroundColor: Colors.white,
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFFFFD700),
            foregroundColor: Colors.white,
            elevation: 4,
            shadowColor: const Color(0xFFFFD700).withValues(alpha: 0.4),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          ),
        ),
        cardTheme: CardThemeData(
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          shadowColor: Colors.black.withValues(alpha: 0.1),
        ),
      ),
      defaultTransition: Transition.cupertino,
      transitionDuration: const Duration(milliseconds: 300),
      initialRoute: AppRoutes.splash,
      getPages: AppRoutes.getPages,
      initialBinding: BindingsBuilder(() {
        Get.put(FlightBookingController(), permanent: true);
        Get.put(FlightSearchController(), permanent: true);
        Get.put(PassengersClassController(), permanent: true);
        Get.put(PassengerInfoController(), permanent: true);
      }),
    );
  }
}


