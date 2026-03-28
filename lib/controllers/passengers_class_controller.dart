import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../widgets/passenger_Widgets/passenger_selection_sheet.dart';
class PassengersClassController extends GetxController {
  var adults = 1.obs;
  var children = 0.obs;
  var infants = 0.obs;
  var selectedClass = 'Economy'.obs;
  var isClassDropdownOpen = false.obs;
  final List<String> flightClasses = [
    'Economy',
    'Economy/premium economy',
    'Premium Economy',
    'Business/First',
    'Business',
    'First',
  ];
  void toggleDropdown() => isClassDropdownOpen.value = !isClassDropdownOpen.value;
  void selectClass(String className) {
    selectedClass.value = className;
    Get.back();
  }
  void updateCount(String type, int delta) {
    int totalPassengers = adults.value + children.value + infants.value;
    if (delta > 0 && totalPassengers >= 9) {
      Get.snackbar(
        "Limit Reached",
        "A maximum of 9 passengers is allowed per booking.",
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.black87,
        colorText: Colors.white,
        margin: const EdgeInsets.all(15),
      );
      return;
    }
    if (type == 'adults') {
      if (adults.value + delta >= 1) {
        adults.value += delta;
        if (infants.value > adults.value) {
          infants.value = adults.value;
        }
      }
    } else if (type == 'children') {
      if (children.value + delta >= 0) {
        children.value += delta;
      }
    } else if (type == 'infants') {
      if (infants.value + delta >= 0) {
        if (infants.value + delta <= adults.value) {
          infants.value += delta;
        } else {
          Get.snackbar(
            "Infant Policy",
            "Each infant must be accompanied by an adult.",
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: Colors.orangeAccent,
            colorText: Colors.white,
          );
        }
      }
    }
  }
  void showPassengersSheet() {
    Get.bottomSheet(
      const PassengerSelectionSheet(),
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
    );
  }
}