import 'package:get/get.dart';

class MiddleController extends GetxController {
  final isExpanded = false.obs;
  final isLoading = true.obs;

  // Observable lists for the three horizontal sections
  final cheapFlights = <Map<String, String>>[].obs;
  final bestDeals = <Map<String, String>>[].obs;
  final trending = <Map<String, String>>[].obs;

  @override
  void onInit() {
    super.onInit();
    fetchHomeData();
  }

  void toggleExpanded() => isExpanded.value = !isExpanded.value;

  Future<void> fetchHomeData({bool isRefresh = false}) async {
    if (!isRefresh) isLoading.value = true;

    try {
      // Simulate network delay – replace with real API call later
      await Future.delayed(const Duration(seconds: 2));

      // --- Hardcoded data from images (ready for API replacement) ---

      // trip11.jpg – Cheap flights
      final mockCheap = [
        {
          'name': 'Sapporo',
          'date': 'Thu, Feb 26',
          'price': '\$34.10',
          'image': '', // Replace with actual image URL later
        },
        {
          'name': 'Osaka',
          'date': 'Thu, Mar 12',
          'price': '\$36.60',
          'image': '',
        },
        {
          'name': 'Fukuoka',
          'date': 'Sun, Mar 1',
          'price': '\$43.10',
          'image': '',
        },
        {
          'name': 'Okinawa',
          'date': 'Thu, Mar 12',
          'price': '\$48.30',
          'image': '',
        },
      ];

      // trip12.jpg – Best deals
      final mockBestDeals = [
        {
          'name': 'Boston',
          'date': 'Thu, Mar 5',
          'price': '\$372.10',
          'image': '',
        },
        {
          'name': 'Beijing',
          'date': 'Thu, Mar 12',
          'price': '\$99.80',
          'image': '',
        },
        {
          'name': 'Malé',
          'date': 'Sat, Feb 28',
          'price': '\$274.50',
          'image': '',
        },
        {
          'name': 'Dubai',
          'date': 'Fri, Mar 13',
          'price': '\$203.80',
          'image': '',
        },
      ];

      // trip13.jpg – Trending destinations
      final mockTrending = [
        {
          'name': 'Los Angeles',
          'date': 'Fri, Mar 6',
          'price': '\$248.20',
          'image': '',
        },
        {
          'name': 'Manila',
          'date': 'Fri, Mar 13',
          'price': '\$97.60',
          'image': '',
        },
        {
          'name': 'Bangkok',
          'date': 'Fri, Mar 6',
          'price': '\$115.40',
          'image': '',
        },
        {
          'name': 'Seoul',
          'date': 'Thu, Feb 12',
          'price': '\$121.70',
          'image': '',
        },
      ];

      // Assign to observables
      cheapFlights.assignAll(mockCheap);
      bestDeals.assignAll(mockBestDeals);
      trending.assignAll(mockTrending);
    } catch (e) {
      Get.snackbar('Error', 'Failed to load flights: $e',
          snackPosition: SnackPosition.BOTTOM);
    } finally {
      isLoading.value = false;
    }
  }

  // Pull‑to‑refresh support
  Future<void> onRefresh() => fetchHomeData(isRefresh: true);
}