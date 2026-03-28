import 'package:get/get.dart';

import '../screens/splash_screen.dart';
import '../screens/home/home_screen.dart';

// ONE WAY
import '../screens/one_way_screen/results_screen.dart';
import '../screens/one_way_screen/fare_selection_screen.dart';
import '../screens/one_way_screen/passenger_info_screen.dart';
import '../screens/one_way_screen/addons_screen.dart';
import '../screens/one_way_screen/payment_screen.dart';

// ROUND TRIP
import '../screens/round_trip_screen/departure_results_screen.dart';
import '../screens/round_trip_screen/return_results_screen.dart';
import '../screens/round_trip_screen/select_fare_screen.dart';
class AppRoutes {

  // Base
  static const String splash = '/';
  static const String home = '/home';

  // ONE WAY FLOW
  static const String results = '/results';
  static const String fareSelection = '/fare-selection';
  static const String passengerInfo = '/passenger-info';
  static const String addons = '/addons';
  static const String payment = '/payment';

  // ROUND TRIP FLOW
  static const String departureResults = '/departure-results';
  static const String returnResults = '/return-results';
  static const bookingSummary = '/booking-summary';
  static const selectFare = '/select-fare';
  static List<GetPage> getPages = [

    /// Base Pages
    GetPage(
      name: splash,
      page: () => const SplashScreen(),
    ),

    GetPage(
      name: home,
      page: () => const HomeScreen(),
    ),

    /// ONE WAY FLOW
    GetPage(
      name: results,
      page: () => const ResultsScreen(),
    ),

    GetPage(
      name: fareSelection,
      page: () => const FareSelectionScreen(),
    ),

    GetPage(
      name: passengerInfo,
      page: () => const PassengerInfoScreen(),
    ),

    GetPage(
      name: addons,
      page: () => const AddonsScreen(),
    ),

    GetPage(
      name: payment,
      page: () => const PaymentScreen(),
    ),

    /// ROUND TRIP FLOW
    GetPage(
      name: departureResults,
      page: () => DepartureResultsScreen(),
    ),

    GetPage(
      name: returnResults,
      page: () => ReturnResultsScreen(),
    ),
    GetPage(
      name: AppRoutes.selectFare,
      page: () => const SelectFareScreen(),
    ),
  ];
}