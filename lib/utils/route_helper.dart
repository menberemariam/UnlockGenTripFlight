import 'package:get/get.dart';

class RouteHelper {
  static const String home = '/';
  static const String search = '/search';
  static const String results = '/results';
  static const String fareSelection = '/fare-selection';
  static const String passengerInfo = '/passenger-info';
  static const String addons = '/addons';

  // Navigate to search with city parameters
  static void goToSearch({String? from, String? to}) {
    Get.toNamed(search, arguments: {
      'from': from,
      'to': to,
    });
  }

  // Navigate to results
  static void goToResults() {
    Get.toNamed(results);
  }

  // Navigate to fare selection
  static void goToFareSelection() {
    Get.toNamed(fareSelection);
  }

  // Navigate to passenger info
  static void goToPassengerInfo() {
    Get.toNamed(passengerInfo);
  }

  // Navigate to add-ons
  static void goToAddons() {
    Get.toNamed(addons);
  }

  // Go back to home
  static void goToHome() {
    Get.offAllNamed(home);
  }
}
