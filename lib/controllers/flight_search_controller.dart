
import 'package:get/get_rx/src/rx_types/rx_types.dart';
import 'package:get/get_state_manager/src/simple/get_controllers.dart';

class FlightSearchController extends GetxController {
  var isLoading = true.obs;
  var hasResults = false.obs;

  @override
  void onInit() {
    super.onInit();
    Future.delayed(const Duration(seconds: 2), () {
      isLoading.value = false;
      hasResults.value = false;
    });
  }
}
