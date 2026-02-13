import 'package:get/get_rx/src/rx_types/rx_types.dart';
import 'package:get/get_state_manager/src/simple/get_controllers.dart';
import 'package:get_storage/get_storage.dart';

class PriceAlertController extends GetxController {
  final box = GetStorage();

  final RxBool isRoundTrip = false.obs;
  final RxBool nonstop = false.obs;
  final RxBool emailAlerts = true.obs;

  final String email = "menbereremariam123@gmail.com";

  final double currentPrice = 718.20;
  final double recommendedPrice = 758.10;
  final double alertPrice = 773.26;

  @override
  void onInit() {
    super.onInit();
    emailAlerts.value = box.read('emailAlerts') ?? true;
  }

  void toggleRoundTrip(bool value) => isRoundTrip.value = value;
  void toggleNonstop(bool value) => nonstop.value = value;
  void toggleEmail(bool value) {
    emailAlerts.value = value;
    box.write('emailAlerts', value);
  }
}
