import 'package:get/get_core/src/get_main.dart';
import 'package:get/get_navigation/src/extension_navigation.dart';
import 'package:get/get_rx/src/rx_types/rx_types.dart';
import 'package:get/get_state_manager/src/simple/get_controllers.dart';
import 'package:get_storage/get_storage.dart';

class BookingController extends GetxController {
  final box = GetStorage();

  final RxInt activeFilterCount = 1.obs;
  final RxBool showRefundedOnly = false.obs;

  void clearAllFilters() {
    activeFilterCount.value = 0;
    showRefundedOnly.value = false;
    Get.snackbar('Filters', 'All filters cleared');
  }
}
