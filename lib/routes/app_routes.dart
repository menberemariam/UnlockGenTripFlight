import 'package:get/get.dart';

import '../screens/home/home_screen.dart';
import '../screens/splash_screen.dart';
import '../screens/search_screen.dart';
import '../screens/results_screen.dart';
import '../screens/fare_selection_screen.dart';
import '../screens/passenger_info_screen.dart';
import '../screens/addons_screen.dart';

class AppRoutes {
  // Route name constants
  static const String splash        = '/splash';
  static const String home          = '/';
  static const String search        = '/search';
  static const String results       = '/results';
  static const String fareSelection = '/fare-selection';
  static const String passengerInfo = '/passenger-info';
  static const String addons        = '/addons';

  // Optional: you had these before – keeping them is fine (no conflict)
  static const String HOME  = '/';
  static const String ALERT = '/price_alert_screen';   // seems unused for now

  // This is the MOST IMPORTANT PART that was missing
  static final List<GetPage> getPages = [
    GetPage(
      name: splash,
      page: () => const SplashScreen(),
      transition: Transition.fadeIn,
    ),
    GetPage(
      name: home,
      page: () => const HomeScreen(),
      transition: Transition.fade,
    ),
    GetPage(
      name: search,
      page: () => const SearchScreen(),
      transition: Transition.rightToLeft,
    ),
    GetPage(
      name: results,
      page: () => const ResultsScreen(),
      transition: Transition.rightToLeft,
    ),
    GetPage(
      name: fareSelection,
      page: () => const FareSelectionScreen(),
      transition: Transition.rightToLeft,
    ),
    GetPage(
      name: passengerInfo,
      page: () => const PassengerInfoScreen(),
      transition: Transition.rightToLeft,
    ),
    GetPage(
      name: addons,
      page: () => const AddonsScreen(),
      transition: Transition.rightToLeft,
    ),
  ];

  // Navigation helper methods (unchanged)
  static void goToSearch({String? from, String? to}) {
    Get.toNamed(
      search,
      arguments: {
        'from': from,
        'to': to,
      },
    );
  }

  static void goToResults() {
    Get.toNamed(results);
  }

  static void goToFareSelection() {
    Get.toNamed(fareSelection);
  }

  static void goToPassengerInfo() {
    Get.toNamed(passengerInfo);
  }

  static void goToAddons() {
    Get.toNamed(addons);
  }

  static void goToHome() {
    Get.offAllNamed(home);
  }

  // Optional: helper to go to splash (if needed)
  static void goToSplash() {
    Get.offAllNamed(splash);
  }
}