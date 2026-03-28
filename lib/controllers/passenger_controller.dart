import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

class PassengerController extends GetxController {
  final formKey = GlobalKey<FormState>();
  final givenNamesController = TextEditingController();
  final surnameController = TextEditingController();
  final nationalityController = TextEditingController();
  final dobController = TextEditingController();
  final passportController = TextEditingController();

  final selectedGender = Rx<String?>(null);
  final showFrequentFlyer = false.obs;

  final nationality = ''.obs;
  final dob = ''.obs;

  @override
  void onInit() {
    super.onInit();
    nationalityController.addListener(() {
      nationality.value = nationalityController.text;
    });
    dobController.addListener(() {
      dob.value = dobController.text;
    });
  }

  void loadPassengerData(Map<String, String>? existingPassenger) {
    if (existingPassenger != null) {
      givenNamesController.text = existingPassenger['givenNames'] ?? '';
      surnameController.text = existingPassenger['surname'] ?? '';
      selectedGender.value = existingPassenger['gender'];
      nationalityController.text = existingPassenger['nationality'] ?? '';
      dobController.text = existingPassenger['dob'] ?? '';
      passportController.text = existingPassenger['passport'] ?? '';
    }
  }

  void selectGender(String gender) {
    selectedGender.value = gender;
  }

  void toggleFrequentFlyer() {
    showFrequentFlyer.value = !showFrequentFlyer.value;
  }

  void selectNationality(String nationality) {
    nationalityController.text = nationality;
  }


  Future<void> pickDateOfBirth(BuildContext context) async {
    final date = await showDatePicker(
      context: context,
      initialDate: DateTime(1990, 1, 1),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );
    if (date != null) {
      dobController.text = DateFormat('dd/MM/yyyy').format(date);
    }
  }

  Map<String, String>? savePassenger(BuildContext context, int? passengerIndex) {
    if (!formKey.currentState!.validate()) {
      return null;
    }
    if (selectedGender.value == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select gender')),
      );
      return null;
    }
    if (nationalityController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select nationality')),
      );
      return null;
    }

    if (dobController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select date of birth')),
      );
      return null;
    }

    return {
      'givenNames': givenNamesController.text,
      'surname': surnameController.text,
      'gender': selectedGender.value!,
      'nationality': nationalityController.text,
      'dob': dobController.text,
      'passport': passportController.text,
      'index': passengerIndex?.toString() ?? '',
    };
  }

  @override
  void onClose() {
    givenNamesController.dispose();
    surnameController.dispose();
    nationalityController.dispose();
    dobController.dispose();
    passportController.dispose();
    super.onClose();
  }
}
