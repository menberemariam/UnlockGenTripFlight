import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/flight_booking_controller.dart';
import '../controllers/flight_search_controller.dart';

class PassengerInfoController extends GetxController {

  final formKey = GlobalKey<FormState>();

  // All fields start empty — user must fill them
  final firstNameController = TextEditingController();
  final lastNameController = TextEditingController();
  final phoneController = TextEditingController();
  final emailController = TextEditingController();
  final passportController = TextEditingController();
  final birthDateController = TextEditingController();
  final countryController = TextEditingController();
  final selectedGender = 'MALE'.obs;
  final selectedTitle = 'Mr'.obs;

  // Selected country map — drives countryCode, dialCode, nationality display
  final selectedCountry = Rxn<Map<String, String>>();

  String get countryCode => selectedCountry.value?['code'] ?? '';
  String get dialCode => selectedCountry.value?['dial'] ?? '';

  void selectCountry(Map<String, String> country) {
    selectedCountry.value = country;
    countryController.text = country['code'] ?? '';
    // Prepopulate phone with dial code if phone is empty
    if (phoneController.text.isEmpty) {
      phoneController.text = country['dial'] ?? '';
    }
  }

  // Keep nameController as alias for display
  TextEditingController get nameController => firstNameController;

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
    firstNameController.text = givenNames;
    lastNameController.text = surname;
  }

  int get passengerCount => 1 + additionalPassengers.length;

  bool validateForm() {
    return formKey.currentState?.validate() ?? false;
  }

  // Normalize date to yyyy-MM-dd with zero-padded month and day
  // Handles: "2000-2-23" → "2000-02-23", "23/02/2000" → "2000-02-23"
  String _normalizeBirthDate(String raw) {
    if (raw.isEmpty) return raw;
    try {
      // Format: dd/MM/yyyy (from date picker in AddPassengerScreen)
      if (raw.contains('/')) {
        final parts = raw.split('/');
        if (parts.length == 3) {
          final day = parts[0].padLeft(2, '0');
          final month = parts[1].padLeft(2, '0');
          final year = parts[2];
          return '$year-$month-$day';
        }
      }
      // Format: yyyy-M-d or yyyy-MM-dd
      if (raw.contains('-')) {
        final parts = raw.split('-');
        if (parts.length == 3) {
          final year = parts[0];
          final month = parts[1].padLeft(2, '0');
          final day = parts[2].padLeft(2, '0');
          return '$year-$month-$day';
        }
      }
    } catch (_) {}
    return raw;
  }

  // Valid API title values: MR | MRS | MS
  // Maps user-facing titles to API-accepted enum values
  String _mapTitle(String title) {
    switch (title.toUpperCase()) {
      case 'MR':   return 'MR';
      case 'MRS':  return 'MRS';
      case 'MS':   return 'MS';
      case 'DR':   return 'MR';   // DR not in ClientPassengerTitle enum
      case 'PROF': return 'MR';
      default:     return 'MR';
    }
  }

  // Build customerInfos list for hold API
  List<Map<String, dynamic>> buildCustomerInfos() {
    final firstName = firstNameController.text.trim();
    final lastName = lastNameController.text.trim();
    final phone = phoneController.text.replaceAll('+', '').replaceAll(' ', '');
    final email = emailController.text.trim();
    final passport = passportController.text.trim();
    final birthDate = birthDateController.text.trim();
    final country = countryController.text.trim();

    final main = _mainPassengerData;
    final finalFirst = firstName.isNotEmpty ? firstName : (main?['givenNames'] ?? '');
    final finalLast = lastName.isNotEmpty ? lastName : (main?['surname'] ?? '');
    final finalPassport = passport.isNotEmpty ? passport : (main?['passport'] ?? '');
    final rawBirth = birthDate.isNotEmpty ? birthDate : (main?['dob'] ?? '');
    final finalBirth = _normalizeBirthDate(rawBirth); // always yyyy-MM-dd
    final finalCountry = country.isNotEmpty ? country : (main?['nationality'] ?? 'ET');
    final finalGender = selectedGender.value.isNotEmpty ? selectedGender.value : (main?['gender'] ?? 'MALE');

    return [
      {
        'gender': finalGender,
        'birthDate': finalBirth,
        'phoneNo': phone,
        'firstName': finalFirst,
        'lastName': finalLast,
        'middleName': '',
        'country': finalCountry,
        'passPort': finalPassport,
        'title': _mapTitle(selectedTitle.value),
        'email': email,
        'notify': true,
        'paxType': 'ADT',
        'paxId': 'PAX1',
        'accountNumber': '',
        'depBarcodeImage': '',
        'retBarcodeImage': '',
        'depBarcodeCid': '',
        'retBarcodeCid': '',
      }
    ];
  }

  // Store main passenger data from AddPassengerScreen
  Map<String, String>? _mainPassengerData;

  void setMainPassengerData(Map<String, String> data) {
    _mainPassengerData = data;
    firstNameController.text = data['givenNames'] ?? '';
    lastNameController.text = data['surname'] ?? '';
  }

  FlightBookingController get flightController => Get.find<FlightBookingController>();

  double get baseFlightPrice {
    final searchCtrl = Get.find<FlightSearchController>();
    if (searchCtrl.selectedOffer.value == null &&
        searchCtrl.selectedOutboundOffer.value == null) {
      return flightController.finalPrice;
    }
    return searchCtrl.totalDisplayPrice;
  }

  String get priceCurrency => Get.find<FlightSearchController>().displayCurrency;

  double get insurancePrice {
    switch (selectedInsurance.value) {
      case "Basic": return 20;
      case "Standard": return 40;
      case "Premium": return 60;
      default: return 0;
    }
  }

  double get totalPrice {
    final flightTotal = baseFlightPrice * passengerCount;
    final insuranceTotal = insurancePrice * passengerCount;
    return flightTotal + insuranceTotal;
  }

  bool get isRoundTrip => flightController.isRoundTrip;
  bool get isOneWay => flightController.isOneWay;

  String get tripTypeLabel => isRoundTrip ? "Round Trip" : "One Way";

  @override
  void onClose() {
    firstNameController.dispose();
    lastNameController.dispose();
    phoneController.dispose();
    emailController.dispose();
    passportController.dispose();
    birthDateController.dispose();
    countryController.dispose();
    super.onClose();
  }
}
