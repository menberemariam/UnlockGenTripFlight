import 'package:flutter/material.dart';
import '../model/booking.dart';
import '../model/flight.dart';

class BookingProvider extends ChangeNotifier {
  final BookingData _bookingData = BookingData();
  BookingData get bookingData => _bookingData;

  void setSearchParams(SearchParams params) {
    _bookingData.searchParams = params;
    notifyListeners();
  }

  void selectFlight(Flight flight) {
    _bookingData.selectedFlight = flight;
    notifyListeners();
  }

  void selectFare(FareType fare) {
    _bookingData.selectedFare = fare;
    notifyListeners();
  }

  void setPassengers(List<Passenger> passengers) {
    _bookingData.passengers = passengers;
    notifyListeners();
  }

  void setContactInfo(String name, String phone, String email) {
    _bookingData.contactName = name;
    _bookingData.phoneNumber = phone;
    _bookingData.email = email;
    notifyListeners();
  }

  void setInsurance(String? insurance) {
    _bookingData.selectedInsurance = insurance;
    notifyListeners();
  }

  void setSeat(String? seat) {
    _bookingData.selectedSeat = seat;
    notifyListeners();
  }

  void addAddOn(String addOn) {
    _bookingData.addOns.add(addOn);
    notifyListeners();
  }

  void removeAddOn(String addOn) {
    _bookingData.addOns.remove(addOn);
    notifyListeners();
  }

  void reset() {
    _bookingData.searchParams = null;
    _bookingData.selectedFlight = null;
    _bookingData.selectedFare = null;
    _bookingData.passengers.clear();
    _bookingData.contactName = null;
    _bookingData.phoneNumber = null;
    _bookingData.email = null;
    _bookingData.selectedInsurance = null;
    _bookingData.selectedSeat = null;
    _bookingData.addOns.clear();
    notifyListeners();
  }
}
