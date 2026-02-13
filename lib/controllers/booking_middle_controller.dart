import 'package:get/get.dart';
class HomeController extends GetxController {

  final isExpanded = false.obs;

  void toggleExpanded() => isExpanded.value = !isExpanded.value;

  final List<Map<String, String>> cheapFlights = [
    {'name': 'Sapporo', 'date': 'Thu, Feb 26', 'price': '\$34.10', 'image': 'https://placeholder.com/image_sapporo.jpg'},
    {'name': 'Osaka',     'date': 'Thu, Mar 12', 'price': '\$36.60', 'image': 'https://placeholder.com/image_osaka.jpg'},
    {'name': 'Fukuoka',   'date': 'Sun, Mar 1',  'price': '\$43.10', 'image': 'https://placeholder.com/image_fukuoka.jpg'},
    {'name': 'Okinawa',   'date': 'Thu, Mar 12', 'price': '\$48.30', 'image': 'https://placeholder.com/image_okinawa.jpg'},
  ];

  final List<Map<String, String>> bestDeals = [ {'name': 'Sapporo', 'date': 'Thu, Feb 26', 'price': '\$34.10', 'image': 'https://placeholder.com/image_sapporo.jpg'},
    {'name': 'Osaka',     'date': 'Thu, Mar 12', 'price': '\$36.60', 'image': 'https://placeholder.com/image_osaka.jpg'},
    {'name': 'Fukuoka',   'date': 'Sun, Mar 1',  'price': '\$43.10', 'image': 'https://placeholder.com/image_fukuoka.jpg'},
    {'name': 'Okinawa',   'date': 'Thu, Mar 12', 'price': '\$48.30', 'image': 'https://placeholder.com/image_okinawa.jpg'},
  ];

  final List<Map<String, String>> trending = [ {'name': 'Sapporo', 'date': 'Thu, Feb 26', 'price': '\$34.10', 'image': 'https://placeholder.com/image_sapporo.jpg'},
    {'name': 'Osaka',     'date': 'Thu, Mar 12', 'price': '\$36.60', 'image': 'https://placeholder.com/image_osaka.jpg'},
    {'name': 'Fukuoka',   'date': 'Sun, Mar 1',  'price': '\$43.10', 'image': 'https://placeholder.com/image_fukuoka.jpg'},
    {'name': 'Okinawa',   'date': 'Thu, Mar 12', 'price': '\$48.30', 'image': 'https://placeholder.com/image_okinawa.jpg'},
  ];
}