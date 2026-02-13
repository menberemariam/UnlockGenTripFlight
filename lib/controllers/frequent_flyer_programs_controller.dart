import 'package:get/get_core/src/get_main.dart';
import 'package:get/get_navigation/src/extension_navigation.dart';
import 'package:get/get_rx/src/rx_types/rx_types.dart';
import 'package:get/get_state_manager/src/simple/get_controllers.dart';
import 'package:get_storage/get_storage.dart';

class FrequentFlyerController extends GetxController {
  final box = GetStorage();

  // store list of added programs
  final RxList<Map<String, String>> programs = <Map<String, String>>[].obs;

  @override
  void onInit() {
    super.onInit();
    // Load previously saved programs
    final saved = box.read('frequent_flyer_programs');
    if (saved != null) {
      programs.assignAll(List<Map<String, String>>.from(saved));
    }
  }

  void addProgram(Map<String, String> program) {
    programs.add(program);
    box.write('frequent_flyer_programs', programs);
    Get.snackbar('Success', 'Program added');
  }
}
