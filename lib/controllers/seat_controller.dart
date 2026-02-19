import 'dart:ui';

import 'package:get/get.dart';

class SeatController extends GetxController {
  final selectedSeats = <String>{}.obs;

  final occupiedSeats = {
    "1A",
    "1C",
    "1D",
    "1F",
    "2A",
    "2B",
    "2C",
    "2D",
    "2E",
    "2F",
    "3E",
    "3F",
    "4A",
    "4F",
    "6A",
    "6B",
    "6E",
    "6F",
    "7A",
    "7B",
    "7C",
    "14E",
    "14F",
    "16A",
    "16B",
    "16C",
    "16D",
    "22F",
    "25A",
    "25B",
    "25F",
    "28F",
    "30A",
    "30B",
    "30C",
    "30D",
    "30E",
    "30F",
  }.obs;

  final brandColor = const Color(0xFFEAA21B);
  final double basePrice = 44.30;

  bool isOccupied(String seat) => occupiedSeats.contains(seat);
  bool isSelected(String seat) => selectedSeats.contains(seat);

  void toggleSeat(String seat) {
    if (isOccupied(seat)) return;
    if (isSelected(seat)) {
      selectedSeats.remove(seat);
    } else {
      selectedSeats.add(seat);
    }
  }

  String get selectedCountText => selectedSeats.isEmpty
      ? "No seat selected"
      : "${selectedSeats.length} seat${selectedSeats.length > 1 ? 's' : ''}";

  String get totalPriceText => "\$${basePrice.toStringAsFixed(2)}";
}