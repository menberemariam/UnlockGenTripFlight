import 'package:get/get.dart';
import '../screens/home_screen.dart';
import 'app_routes.dart';

class AppPages {
  static final routes = [
    GetPage(
      name: AppRoutes.HOME,
      page: () => HomeScreen(),
    ),
    // Add other routes here as you create the pages
  ];
}