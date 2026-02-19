import 'package:get/get.dart';

class MiddleController extends GetxController {
  // ── Observable states ───────
  final isExpanded = false.obs;
  final isLoading = true.obs;           // ← NEW: controls shimmer/overlay

  // Make lists observable so UI rebuilds automatically when data changes
  final cheapFlights = <Map<String, String>>[].obs;
  final bestDeals    = <Map<String, String>>[].obs;
  final trending     = <Map<String, String>>[].obs;

  @override
  void onInit() {
    super.onInit();
    fetchHomeData();   // ← auto-fetch when controller is initialized
  }

  void toggleExpanded() => isExpanded.value = !isExpanded.value;

  Future<void> fetchHomeData({bool isRefresh = false}) async {
    if (!isRefresh) {
      isLoading.value = true;
      // LoadingService.to.show();   // ← Uncomment if using global overlay shimmer
    }

    try {
      // Simulate API delay (replace with your real API call)
      await Future.delayed(const Duration(seconds: 2));

      // Example: real data assignment (replace with your API response parsing)
      final mockCheap = [
        {'name': 'Sapporo',   'date': 'Thu, Feb 26', 'price': '\$34.10', 'image': 'https://images.unsplash.com/photo-1506905925346-21bda4d32df4'},
        {'name': 'Osaka',     'date': 'Thu, Mar 12', 'price': '\$36.60', 'image': 'https://images.unsplash.com/photo-1590551023317-5a0b4a4e2e'},
        {'name': 'Fukuoka',   'date': 'Sun, Mar 1',  'price': '\$43.10', 'image': 'https://images.unsplash.com/photo-1549524936-9e299e01a8b2'},
        {'name': 'Okinawa',   'date': 'Thu, Mar 12', 'price': '\$48.30', 'image': 'https://images.unsplash.com/photo-1587132137056-bfbf78ed6241'},
      ];

      // You can use different data per list or same — up to you
      cheapFlights.assignAll(mockCheap);
      bestDeals.assignAll(mockCheap);     // or fetch different endpoint
      trending.assignAll(mockCheap);

      // If you have real API:
      // final response = await ApiService.getHomeFlights();
      // cheapFlights.assignAll(response.cheap.map((e) => e.toMap()).toList());
      // ...
    } catch (e) {
      Get.snackbar('Error', 'Failed to load flights: $e',
          snackPosition: SnackPosition.BOTTOM);
      // Optionally clear lists or show retry button
    } finally {
      isLoading.value = false;
      // LoadingService.to.hide();   // ← Uncomment if using global overlay
    }
  }

  // Optional: Pull-to-refresh support
  Future<void> onRefresh() => fetchHomeData(isRefresh: true);
}