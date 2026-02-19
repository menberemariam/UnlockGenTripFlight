import 'package:get/get.dart';
import '../screens/splash_screen.dart';
import '../screens/home/home_screen.dart';
import '../screens/search_screen.dart';
import '../screens/results_screen.dart';
import '../screens/fare_selection_screen.dart';
import '../screens/passenger_info_screen.dart';
import '../screens/addons_screen.dart';
import '../screens/payment_screen.dart';

class AppRoutes {
  static const String splash = '/';
  static const String home = '/home';
  static const String search = '/search';
  static const String results = '/results';
  static const String fareSelection = '/fare-selection';
  static const String passengerInfo = '/passenger-info';
  static const String addons = '/addons';
  static const String payment = '/payment';
  static List<GetPage> getPages = [
    GetPage(
      name: splash,
      page: () => const SplashScreen(),
    ),
    GetPage(
      name: home,
      page: () => const HomeScreen(),
    ),
    GetPage(
      name: search,
      page: () => const SearchScreen(),
    ),
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
  ];
}
