import 'package:flutter/material.dart';
import 'package:get/get.dart';

class PassengerInfoController extends GetxController {
  final formKey = GlobalKey<FormState>();
  final nameController = TextEditingController(text:'yo yo');
  final phoneController = TextEditingController(text:'+251900000000');
  final emailController = TextEditingController(text:'yimeryonas27@gmail.com');
  final selectedInsurance = Rx<String?>(null);
  final additionalPassengers = <Map<String, String>>[].obs;
  void selectInsurance(String insurance) {
    selectedInsurance.value = insurance;
  }
  void addPassenger(Map<String, String> passenger) {
    additionalPassengers.add(passenger);
  }
  void updatePassenger(int index, Map<String, String> passenger) {
    additionalPassengers[index] = passenger;
  }
  void removePassenger(int index) {
    additionalPassengers.removeAt(index);
  }
  void updateMainPassengerName(String givenNames, String surname) {
    nameController.text = '$givenNames $surname';
  }
  int get passengerCount => 1 + additionalPassengers.length;
  double calculateTotalPrice(double? basePrice) {
    return (basePrice ?? 0) * passengerCount;
  }
  bool validateForm() {
    return formKey.currentState?.validate() ?? false;
  }
  @override
  void onClose() {
    nameController.dispose();
    phoneController.dispose();
    emailController.dispose();
    super.onClose();
  }
}
