import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';
import 'providers/booking_provider.dart';
import 'routes/app_routes.dart';

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
      title: 'H_W travels app',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primaryColor: const Color(0xFFFFD700),
        scaffoldBackgroundColor: Colors.white,
        fontFamily: 'Roboto',
      ),

      initialRoute: AppRoutes.splash,
      getPages: AppRoutes.getPages,
    );
  }
}


