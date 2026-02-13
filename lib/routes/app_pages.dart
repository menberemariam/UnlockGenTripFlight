import 'package:get/get.dart';
import '../screens/price_alert_screen.dart';
import '../screens/home_screen.dart';
import 'app_routes.dart';

class AppPages {
  static final routes = [
    GetPage(
      name: AppRoutes.HOME,
      page: () => HomeScreen(),
    ),
    GetPage(
      name: AppRoutes.ALERT,
      page: () => PriceAlertScreen(),
    ),
  ];
}