import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:get/get.dart';
import '../../providers/booking_provider.dart';
import '../../controllers/flight_booking_controller.dart';
import '../../controllers/flight_search_controller.dart';
import '../../controllers/passenger_info_controller.dart';

class PaymentScreen extends StatefulWidget {
  const PaymentScreen({super.key});

  @override
  State<PaymentScreen> createState() => _PaymentScreenState();
}

class _PaymentScreenState extends State<PaymentScreen> {
  String selectedPaymentMethod = 'card';
  final _cardNumberController = TextEditingController();
  final _cardHolderController = TextEditingController();
  final _expiryController = TextEditingController();
  final _cvvController = TextEditingController();
  bool saveCard = false;

  @override
  Widget build(BuildContext context) {
    final bookingProvider = context.watch<BookingProvider>();
    final bookingData = bookingProvider.bookingData;
    final searchParams = bookingData.searchParams;
    final flightController = Get.find<FlightBookingController>();
    final searchCtrl = Get.find<FlightSearchController>();
    final offer = searchCtrl.selectedOffer.value;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Payment'),
        actions: [_buildStepIndicator()],
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildBookingSummary(flightController, searchCtrl, searchParams),
                  _buildPaymentMethods(),
                  if (selectedPaymentMethod == 'card') _buildCardPaymentForm(),
                  if (selectedPaymentMethod == 'paypal') _buildPayPalForm(),
                  if (selectedPaymentMethod == 'bank') _buildBankTransferForm(),
                  _buildPriceBreakdown(offer, bookingData),
                ],
              ),
            ),
          ),
          _buildBottomBar(context, offer, bookingData),
        ],
      ),
    );
  }

  Widget _buildStepIndicator() {
    return Padding(
      padding: const EdgeInsets.only(right: 16),
      child: Row(children: [
        _buildStep(1, true), _buildStep(2, true),
        _buildStep(3, true), _buildStep(4, true),
      ]),
    );
  }

  Widget _buildStep(int number, bool active) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 4),
      width: 24, height: 24,
      decoration: BoxDecoration(
        color: active ? const Color(0xFFEAA21B) : Colors.grey.shade300,
        shape: BoxShape.circle,
      ),
      child: Center(
        child: Text('$number',
            style: TextStyle(
                color: active ? Colors.white : Colors.grey.shade600,
                fontSize: 12, fontWeight: FontWeight.bold)),
      ),
    );
  }

  Widget _buildBookingSummary(FlightBookingController flightController,
      FlightSearchController searchCtrl, searchParams) {
    final isRoundTrip = flightController.isRoundTrip;
    final offer = searchCtrl.selectedOffer.value;

    return Container(
      padding: const EdgeInsets.all(16),
      color: const Color(0xFFFFF8E6),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [
            const Icon(Icons.flight_takeoff, color: Color(0xFFEAA21B)),
            const SizedBox(width: 8),
            Text(
              isRoundTrip ? 'Round Trip - Booking Summary' : 'One Way - Booking Summary',
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ]),
          const SizedBox(height: 12),
          if (offer != null) ...[
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('${offer.originCode} → ${offer.destinationCode}',
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                Text(offer.departureTime,
                    style: TextStyle(color: Colors.grey.shade700)),
              ],
            ),
            const SizedBox(height: 4),
            Text('${offer.airlineName} • ${offer.departureTime}–${offer.arrivalTime} • ${offer.duration}',
                style: TextStyle(color: Colors.grey.shade700)),
            if (isRoundTrip && offer.returnFlight != null) ...[
              const Divider(height: 20, thickness: 1),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('${offer.destinationCode} → ${offer.originCode}',
                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                ],
              ),
              const SizedBox(height: 4),
              Text(
                '${offer.returnFlight!.segments.isNotEmpty ? offer.returnFlight!.segments.first.airlineName : offer.airlineName} • ${offer.returnFlight!.formattedDuration}',
                style: TextStyle(color: Colors.grey.shade700),
              ),
            ],
          ] else ...[
            Text(
              '${flightController.departureCity.value} → ${flightController.destinationCity.value}',
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ],
          const Divider(height: 20, thickness: 1),
          Text('Passengers: ${searchParams?.adults ?? 1}',
              style: TextStyle(color: Colors.grey.shade700)),
        ],
      ),
    );
  }

  Widget _buildPaymentMethods() {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Payment Method',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),
          _buildPaymentMethodOption('card', 'Credit/Debit Card', Icons.credit_card, 'Visa, Mastercard, Amex'),
          _buildPaymentMethodOption('paypal', 'PayPal', Icons.account_balance_wallet, 'Pay with your PayPal account'),
          _buildPaymentMethodOption('bank', 'Bank Transfer', Icons.account_balance, 'Direct bank transfer'),
        ],
      ),
    );
  }

  Widget _buildPaymentMethodOption(String value, String title, IconData icon, String subtitle) {
    final isSelected = selectedPaymentMethod == value;
    return GestureDetector(
      onTap: () => setState(() => selectedPaymentMethod = value),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          border: Border.all(
            color: isSelected ? const Color(0xFFEAA21B) : Colors.grey.shade300,
            width: isSelected ? 2 : 1,
          ),
          borderRadius: BorderRadius.circular(12),
          color: isSelected ? const Color(0xFFFFF8E6) : Colors.white,
        ),
        child: Row(
          children: [
            Icon(icon, color: isSelected ? const Color(0xFFEAA21B) : Colors.grey.shade600, size: 32),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title,
                      style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: isSelected ? const Color(0xFFEAA21B) : Colors.black)),
                  Text(subtitle,
                      style: TextStyle(fontSize: 12, color: Colors.grey.shade600)),
                ],
              ),
            ),
            Icon(
              isSelected ? Icons.radio_button_checked : Icons.radio_button_unchecked,
              color: isSelected ? const Color(0xFFEAA21B) : Colors.grey,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCardPaymentForm() {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Card Details', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),
          TextFormField(
            controller: _cardNumberController,
            decoration: const InputDecoration(
              labelText: 'Card Number', hintText: '1234 5678 9012 3456',
              border: OutlineInputBorder(), prefixIcon: Icon(Icons.credit_card),
            ),
            keyboardType: TextInputType.number,
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _cardHolderController,
            decoration: const InputDecoration(
              labelText: 'Card Holder Name', hintText: 'John Doe',
              border: OutlineInputBorder(), prefixIcon: Icon(Icons.person),
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: TextFormField(
                  controller: _expiryController,
                  decoration: const InputDecoration(
                    labelText: 'Expiry Date', hintText: 'MM/YY',
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.datetime,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: TextFormField(
                  controller: _cvvController,
                  decoration: const InputDecoration(
                    labelText: 'CVV', hintText: '123',
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.number,
                  obscureText: true,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Checkbox(
                value: saveCard,
                onChanged: (val) => setState(() => saveCard = val ?? false),
              ),
              const Text('Save card for future payments'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPayPalForm() {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          const Icon(Icons.account_balance_wallet, size: 64, color: Color(0xFFEAA21B)),
          const SizedBox(height: 16),
          const Text('You will be redirected to PayPal to complete your payment',
              textAlign: TextAlign.center, style: TextStyle(fontSize: 14)),
          const SizedBox(height: 16),
          ElevatedButton.icon(
            onPressed: () {},
            icon: const Icon(Icons.open_in_new, color: Colors.white),
            label: const Text('Continue with PayPal', style: TextStyle(color: Colors.white)),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFEAA21B),
              minimumSize: const Size(double.infinity, 50),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBankTransferForm() {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Bank Transfer Details',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),
          _buildInfoRow('Bank Name:', 'Habesha Wings Travel'),
          _buildInfoRow('Account Name:', 'HW Travels Ltd'),
          _buildInfoRow('Account Number:', '1234567890'),
          _buildInfoRow('Sort Code:', '12-34-56'),
          _buildInfoRow('Reference:', 'HW${DateTime.now().millisecondsSinceEpoch}'),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.orange.shade50,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.orange.shade200),
            ),
            child: Row(
              children: [
                Icon(Icons.info_outline, color: Colors.orange.shade700),
                const SizedBox(width: 8),
                const Expanded(
                  child: Text('Please include the reference number in your transfer',
                      style: TextStyle(fontSize: 12)),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(color: Colors.grey.shade600)),
          Text(value, style: const TextStyle(fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Widget _buildPriceBreakdown(offer, bookingData) {
    final searchCtrl = Get.find<FlightSearchController>();
    final currency = searchCtrl.displayCurrency;
    final total = offer != null
        ? searchCtrl.totalDisplayPrice
        : (bookingData.selectedFare?.price ?? 0.0);

    final insurancePrice = bookingData.selectedInsurance == 'travel'
        ? 35.03
        : bookingData.selectedInsurance == 'cancellation'
            ? 25.70
            : 0.0;
    final grandTotal = total + insurancePrice;

    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Price Breakdown',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),
          _buildPriceRow('Flight Total', '$currency ${total.toStringAsFixed(2)}'),
          if (insurancePrice > 0)
            _buildPriceRow('Travel Insurance', '£${insurancePrice.toStringAsFixed(2)}'),
          const Divider(height: 32),
          _buildPriceRow('Total', '$currency ${grandTotal.toStringAsFixed(2)}', isTotal: true),
        ],
      ),
    );
  }

  Widget _buildPriceRow(String label, String value, {bool isTotal = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label,
              style: TextStyle(
                  fontSize: isTotal ? 18 : 14,
                  fontWeight: isTotal ? FontWeight.bold : FontWeight.normal)),
          Text(value,
              style: TextStyle(
                  fontSize: isTotal ? 18 : 14,
                  fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
                  color: isTotal ? const Color(0xFF9B8E35) : Colors.black)),
        ],
      ),
    );
  }

  Widget _buildBottomBar(BuildContext context, offer, bookingData) {
    final searchCtrl = Get.find<FlightSearchController>();
    final currency = searchCtrl.displayCurrency;
    final total = offer != null
        ? searchCtrl.totalDisplayPrice
        : (bookingData.totalPrice ?? 0.0);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(color: Colors.grey.shade300, blurRadius: 4, offset: const Offset(0, -2)),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('Total Amount', style: TextStyle(fontSize: 12, color: Colors.grey)),
              Text(
                '$currency ${total.toStringAsFixed(2)}',
                style: const TextStyle(
                    fontSize: 24, fontWeight: FontWeight.bold, color: Color(0xFF9B8E35)),
              ),
            ],
          ),
          ElevatedButton(
            onPressed: () => _processPayment(context),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green,
              padding: const EdgeInsets.symmetric(horizontal: 48, vertical: 16),
            ),
            child: const Text('Pay Now',
                style: TextStyle(fontSize: 16, color: Colors.white, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  void _processPayment(BuildContext context) async {
    if (selectedPaymentMethod == 'card') {
      if (_cardNumberController.text.trim().isEmpty) {
        Get.snackbar('Required', 'Please enter your card number',
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: const Color(0xFFFFEBEE),
            colorText: const Color(0xFFD32F2F));
        return;
      }
      if (_cardHolderController.text.trim().isEmpty) {
        Get.snackbar('Required', 'Please enter the card holder name',
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: const Color(0xFFFFEBEE),
            colorText: const Color(0xFFD32F2F));
        return;
      }
      if (!_expiryController.text.contains('/')) {
        Get.snackbar('Required', 'Please enter expiry date as MM/YY',
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: const Color(0xFFFFEBEE),
            colorText: const Color(0xFFD32F2F));
        return;
      }
      if (_cvvController.text.trim().isEmpty) {
        Get.snackbar('Required', 'Please enter your CVV',
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: const Color(0xFFFFEBEE),
            colorText: const Color(0xFFD32F2F));
        return;
      }
    }

    final searchCtrl = Get.find<FlightSearchController>();

    // Find PassengerInfoController — it must already exist from PassengerInfoScreen
    PassengerInfoController? passengerCtrl;
    try {
      passengerCtrl = Get.find<PassengerInfoController>();
    } catch (_) {}

    final customerInfos = passengerCtrl?.buildCustomerInfos() ?? [];

    // Only block if we truly have no passenger controller at all
    if (passengerCtrl == null) {
      Get.snackbar('Error', 'Passenger information is missing. Please go back and fill in passenger details.',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: const Color(0xFFFFEBEE),
          colorText: const Color(0xFFD32F2F),
          duration: const Duration(seconds: 4));
      return;
    }

    if (!mounted) return;

    // Show loading spinner
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => const Center(child: CircularProgressIndicator()),
    );

    if (searchCtrl.selectedOffer.value != null) {
      // Step 1: Hold the booking
      final held = await searchCtrl.holdFlight(customerInfos: customerInfos);

      if (!mounted) return;
      Navigator.of(context, rootNavigator: true).pop(); // close spinner

      if (!held) {
        final msg = searchCtrl.errorMessage.value.isNotEmpty
            ? searchCtrl.errorMessage.value
            : 'Could not hold booking. Please try again.';
        Get.snackbar(
          'Hold Failed',
          msg,
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red.shade100,
          colorText: Colors.red.shade900,
          duration: const Duration(seconds: 6),
          mainButton: TextButton(
            onPressed: () {
              Get.back(); // close snackbar
              Get.back(); // go back to flight results
            },
            child: const Text('Select flight',
                style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
          ),
        );
        return;
      }

      // Show loading spinner again for confirm
      if (!mounted) return;
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (ctx) => const Center(child: CircularProgressIndicator()),
      );

      // Step 2: Confirm payment
      final parts = _expiryController.text.split('/');
      final confirmResult = await searchCtrl.confirmBooking(
        cardHolder: _cardHolderController.text.trim(),
        cardNumber: _cardNumberController.text.replaceAll(' ', ''),
        expireMonth: parts.first.trim(),
        expireYear: parts.length > 1 ? parts.last.trim() : '',
        cvv: _cvvController.text.trim(),
      );

      if (!mounted) return;
      Navigator.of(context, rootNavigator: true).pop(); // close spinner

      if (!mounted) return;

      // Check if 3DS challenge is required
      if (searchCtrl.needs3DS) {
        _show3DSDialog(context, searchCtrl);
        return;
      }

      _showSuccessDialog(context, searchCtrl, confirmResult ?? {});
    }
  }

  void _show3DSDialog(BuildContext context, FlightSearchController searchCtrl) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: const BoxDecoration(
                color: Color(0xFFEAA21B),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.security, color: Colors.white, size: 48),
            ),
            const SizedBox(height: 20),
            const Text('3D Secure Verification',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center),
            const SizedBox(height: 12),
            Text(
              'Your bank requires additional verification.\n\nTrace No: ${searchCtrl.pending3DSTraceNumber ?? ''}',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey.shade600, fontSize: 13),
            ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.orange.shade50,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.orange.shade200),
              ),
              child: const Text(
                'Complete the verification with your bank, then tap "Confirm" below.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 12),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          Obx(() => ElevatedButton(
            onPressed: searchCtrl.isLoading.value
                ? null
                : () async {
                    Navigator.pop(ctx);
                    if (!mounted) return;
                    showDialog(
                      context: context,
                      barrierDismissible: false,
                      builder: (_) => const Center(child: CircularProgressIndicator()),
                    );
                    final result = await searchCtrl.complete3DS();
                    if (!mounted) return;
                    Navigator.of(context, rootNavigator: true).pop();
                    if (!mounted) return;
                    _showSuccessDialog(context, searchCtrl, result ?? {});
                  },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFEAA21B),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            child: searchCtrl.isLoading.value
                ? const SizedBox(width: 20, height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                : const Text('Confirm 3DS', style: TextStyle(color: Colors.white)),
          )),
        ],
      ),
    );
  }

  void _showSuccessDialog(BuildContext context, FlightSearchController searchCtrl,
      Map<String, dynamic> confirmResult) {

    final data = confirmResult['data'] as Map<String, dynamic>?;
    final order = data?['order'] as Map<String, dynamic>?;
    final holdBooking = data?['holdFlightBooking'] as Map<String, dynamic>?;
    final holdResponse = holdBooking?['holdBookingResponse'] as Map<String, dynamic>?;
    final bookingRetrieve = holdBooking?['bookingRetrieveResponse'] as Map<String, dynamic>?;
    final flightInfo = holdBooking?['flightInfo'] as Map<String, dynamic>?;

    // ── Order fields ──────────────────────────────────────────────────────
    final statusDesc    = (order?['statusDesc']    ?? '') as String;
    final approveCode   = order?['approveCode']    as String?;
    final traceNumber   = order?['traceNumber']    as String?;
    final amount        = (order?['amount'] as num?)?.toDouble();
    final currencyName  = (order?['currencyName']  ?? '') as String;
    final paymentChannel = order?['paymentChannel'] as String?;

    // ── Payer info ────────────────────────────────────────────────────────
    final payer = order?['payer'] as Map<String, dynamic>?;
    final payerEmail  = payer?['email']  as String?;
    final payerMobile = payer?['mobile'] as String?;

    // ── PNR ───────────────────────────────────────────────────────────────
    final pnr = searchCtrl.pnr
        ?? holdBooking?['pnr'] as String?
        ?? flightInfo?['pnr'] as String?
        ?? holdResponse?['order']?['bookingReference'] as String?
        ?? bookingRetrieve?['order']?['bookingReference'] as String?;

    // ── Booking status ────────────────────────────────────────────────────
    final bookingStatus = holdBooking?['bookingStatus'] as String?
        ?? holdResponse?['order']?['status'] as String?;

    // ── Order ID ──────────────────────────────────────────────────────────
    final ndcOrderId = holdResponse?['order']?['orderId'] as String?
        ?? flightInfo?['orderIdOfNDC'] as String?;

    final displayAmount   = amount ?? searchCtrl.totalDisplayPrice;
    final displayCurrency = currencyName.isNotEmpty ? currencyName : searchCtrl.displayCurrency;

    // ── Passenger — fallback to PassengerInfoController ───────────────────
    final passengers = (holdResponse?['passengers'] as List?)
        ?? (bookingRetrieve?['passengers'] as List?);
    final firstPax = passengers?.isNotEmpty == true
        ? passengers!.first as Map<String, dynamic>? : null;
    // Fallback: read directly from PassengerInfoController
    PassengerInfoController? paxCtrl;
    try { paxCtrl = Get.find<PassengerInfoController>(); } catch (_) {}
    final passengerName = (firstPax != null
        ? '${firstPax['firstName'] ?? ''} ${firstPax['lastName'] ?? ''}'.trim()
        : null)
        ?? (paxCtrl != null
            ? '${paxCtrl.firstNameController.text} ${paxCtrl.lastNameController.text}'.trim()
            : null);

    // ── Journeys — fallback to selectedOffer ──────────────────────────────
    final journeys  = (holdResponse?['journeys']  as List?)
        ?? (bookingRetrieve?['journeys'] as List?);
    final segments  = (holdResponse?['segments']  as List?)
        ?? (bookingRetrieve?['segments'] as List?);

    // ── Baggage ───────────────────────────────────────────────────────────
    final baggageList = holdBooking?['holdBookingResponse']?['baggageAllowances'] as List?;
    final baggageInfo = baggageList?.isNotEmpty == true
        ? '${(baggageList!.first as Map)['totalQuantity']} PC'
        : (flightInfo?['baggageInfo'] as List?)?.isNotEmpty == true
            ? '${(flightInfo!['baggageInfo'] as List).first} PC'
            : searchCtrl.selectedOffer.value?.baggageInfo;

    // ── Payment time limit ────────────────────────────────────────────────
    final paymentLimit = bookingRetrieve?['paymentTimeLimit'] as String?
        ?? holdBooking?['bookingRetrieveResponse']?['paymentTimeLimit'] as String?
        ?? searchCtrl.paymentTimeLimit;

    // ── Pricing — fallback to offer pricing ───────────────────────────────
    final pricing        = holdResponse?['pricing'] as Map<String, dynamic>?
        ?? bookingRetrieve?['pricing'] as Map<String, dynamic>?;
    final pricingCurrency = pricing?['currency'] as String?
        ?? searchCtrl.selectedOffer.value?.pricing.currency
        ?? displayCurrency;
    final totalAmount    = (pricing?['totalAmount'] as num?)?.toDouble()
        ?? displayAmount;
    final baseAmount     = (pricing?['baseAmount'] as num?)?.toDouble()
        ?? searchCtrl.selectedOffer.value?.pricing.baseFare;
    final totalTaxes     = (pricing?['totalTaxes'] as num?)?.toDouble()
        ?? searchCtrl.selectedOffer.value?.pricing.taxes;

    // ── Build fallback journeys from selectedOffer if API didn't return them
    List<Map<String, dynamic>> fallbackJourneys = [];
    if (journeys == null || journeys.isEmpty) {
      final offer = searchCtrl.selectedOffer.value;
      if (offer != null) {
        final outbound = offer.outboundFlight;
        if (outbound != null) {
          fallbackJourneys.add({
            'originCode':        outbound.originCode,
            'destinationCode':   outbound.destinationCode,
            'originName':        outbound.segments.isNotEmpty
                ? outbound.segments.first.departureAirportName : outbound.originCode,
            'destinationName':   outbound.segments.isNotEmpty
                ? outbound.segments.last.arrivalAirportName : outbound.destinationCode,
            'departureDateTime': outbound.segments.isNotEmpty
                ? outbound.segments.first.departureDateTime?.toIso8601String() ?? '' : '',
            'arrivalDateTime':   outbound.segments.isNotEmpty
                ? outbound.segments.last.arrivalDateTime?.toIso8601String() ?? '' : '',
            'segmentIds': [],
            '_flightNo': outbound.segments.isNotEmpty
                ? '${outbound.segments.first.airlineCode} ${outbound.segments.first.flightNumber}' : '',
          });
        }
        final ret = offer.returnFlight;
        if (ret != null) {
          fallbackJourneys.add({
            'originCode':        ret.originCode,
            'destinationCode':   ret.destinationCode,
            'originName':        ret.segments.isNotEmpty
                ? ret.segments.first.departureAirportName : ret.originCode,
            'destinationName':   ret.segments.isNotEmpty
                ? ret.segments.last.arrivalAirportName : ret.destinationCode,
            'departureDateTime': ret.segments.isNotEmpty
                ? ret.segments.first.departureDateTime?.toIso8601String() ?? '' : '',
            'arrivalDateTime':   ret.segments.isNotEmpty
                ? ret.segments.last.arrivalDateTime?.toIso8601String() ?? '' : '',
            'segmentIds': [],
            '_flightNo': ret.segments.isNotEmpty
                ? '${ret.segments.first.airlineCode} ${ret.segments.first.flightNumber}' : '',
          });
        }
      }
    }
    final allJourneys = (journeys?.cast<Map<String, dynamic>>() ?? []).isNotEmpty
        ? journeys!.cast<Map<String, dynamic>>()
        : fallbackJourneys;

    final isAuthorized = (pnr != null && pnr.isNotEmpty) ||
        statusDesc.toLowerCase().contains('authorized') ||
        statusDesc.toLowerCase().contains('approved') ||
        approveCode != null ||
        confirmResult['success'] == true;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) {
        final scrollCtrl = ScrollController();
        // Auto-scroll to bottom after frame renders
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (scrollCtrl.hasClients) {
            scrollCtrl.animateTo(
              scrollCtrl.position.maxScrollExtent,
              duration: const Duration(milliseconds: 800),
              curve: Curves.easeInOut,
            );
          }
        });
        return Dialog(
        insetPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: ConstrainedBox(
          constraints: BoxConstraints(
            maxHeight: MediaQuery.of(ctx).size.height * 0.95,
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: Scaffold(
              backgroundColor: const Color(0xFFFAF8F2),
              body: SingleChildScrollView(
                controller: scrollCtrl,
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                // ── Status icon ───────────────────────────────────────
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: isAuthorized ? Colors.green : const Color(0xFFEAA21B),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    isAuthorized ? Icons.check_circle : Icons.hourglass_top,
                    color: Colors.white, size: 40,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  isAuthorized ? 'Booking Confirmed!' : 'Booking On Hold',
                  style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 4),
                Text(
                  isAuthorized
                      ? 'Your ticket has been issued successfully.'
                      : 'Your booking is pending payment.',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.grey.shade600, fontSize: 13),
                ),

                const SizedBox(height: 16),
                const Divider(),

                // ── PNR ───────────────────────────────────────────────
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFF8E6),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: const Color(0xFFD4AF37)),
                  ),
                  child: Column(children: [
                    const Text('PNR / Booking Reference',
                        style: TextStyle(fontSize: 12, color: Color(0xFF9E9E9E))),
                    const SizedBox(height: 4),
                    Text(
                      pnr ?? 'Processing...',
                      style: const TextStyle(
                          fontSize: 28, fontWeight: FontWeight.bold,
                          color: Color(0xFFD4AF37), letterSpacing: 4),
                    ),
                    if (ndcOrderId != null) ...[
                      const SizedBox(height: 4),
                      Text(ndcOrderId,
                          style: const TextStyle(fontSize: 11, color: Color(0xFF9E9E9E))),
                    ],
                  ]),
                ),

                const SizedBox(height: 16),

                // ── Flight details ────────────────────────────────────
                if (allJourneys.isNotEmpty) ...[
                  const Align(alignment: Alignment.centerLeft,
                      child: Text('Flight Details',
                          style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold))),
                  const SizedBox(height: 8),
                  ...allJourneys.asMap().entries.map((entry) {
                    final j = entry.value;
                    final origin     = j['originCode']      ?? '';
                    final dest       = j['destinationCode'] ?? '';
                    final originName = j['originName']      ?? '';
                    final destName   = j['destinationName'] ?? '';
                    final dep = (j['departureDateTime'] as String? ?? '');
                    final arr = (j['arrivalDateTime']   as String? ?? '');
                    final depFmt = dep.length >= 16 ? dep.substring(0, 16).replaceAll('T', ' ') : dep;
                    final arrFmt = arr.length >= 16 ? arr.substring(0, 16).replaceAll('T', ' ') : arr;

                    // Flight number — from segments or fallback key
                    final segIds = j['segmentIds'] as List?;
                    final matchSeg = segments?.firstWhere(
                      (s) => segIds?.contains((s as Map)['segmentId']) == true,
                      orElse: () => null,
                    ) as Map<String, dynamic>?;
                    final carrier = matchSeg?['marketingCarrier'] as Map<String, dynamic>?;
                    final flightNo = carrier != null
                        ? '${carrier['carrierCode']} ${carrier['flightNumber']}'
                        : (j['_flightNo'] as String? ?? '');
                    final aircraft = matchSeg?['aircraftType'] as String?;

                    return Container(
                      margin: const EdgeInsets.only(bottom: 6),
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade50,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: Colors.grey.shade200),
                      ),
                      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                        Row(children: [
                          Text('$origin → $dest',
                              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                          const Spacer(),
                          const Icon(Icons.flight_takeoff, size: 16, color: Color(0xFFD4AF37)),
                        ]),
                        const SizedBox(height: 2),
                        Text('$originName → $destName',
                            style: const TextStyle(fontSize: 11, color: Color(0xFF9E9E9E))),
                        const SizedBox(height: 6),
                        Row(children: [
                          const Icon(Icons.access_time, size: 13, color: Color(0xFF9E9E9E)),
                          const SizedBox(width: 4),
                          Text('Dep: $depFmt', style: const TextStyle(fontSize: 12)),
                          const SizedBox(width: 10),
                          Text('Arr: $arrFmt', style: const TextStyle(fontSize: 12)),
                        ]),
                        if (flightNo.isNotEmpty || aircraft != null) ...[
                          const SizedBox(height: 4),
                          Row(children: [
                            if (flightNo.isNotEmpty) ...[
                              const Icon(Icons.flight, size: 13, color: Color(0xFFD4AF37)),
                              const SizedBox(width: 4),
                              Text(flightNo, style: const TextStyle(fontSize: 12, color: Color(0xFFD4AF37))),
                            ],
                            if (aircraft != null) ...[
                              const SizedBox(width: 12),
                              const Icon(Icons.airplanemode_active, size: 13, color: Color(0xFF9E9E9E)),
                              const SizedBox(width: 4),
                              Text(aircraft, style: const TextStyle(fontSize: 12, color: Color(0xFF9E9E9E))),
                            ],
                          ]),
                        ],
                      ]),
                    );
                  }),
                  const SizedBox(height: 4),
                ],

                // ── Passenger + baggage ───────────────────────────────
                if (passengerName != null && passengerName.isNotEmpty)
                  _ticketRow('Passenger', passengerName),
                if (baggageInfo != null)
                  _ticketRow('Baggage', baggageInfo),
                if (bookingStatus != null)
                  _ticketRow('Booking Status', bookingStatus),

                // ── Payment details ───────────────────────────────────
                const Divider(height: 20),
                const Align(alignment: Alignment.centerLeft,
                    child: Text('Payment Details',
                        style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold))),
                const SizedBox(height: 8),
                if (baseAmount != null)
                  _ticketRow('Base Fare', '$pricingCurrency ${baseAmount.toStringAsFixed(2)}'),
                if (totalTaxes != null)
                  _ticketRow('Taxes', '$pricingCurrency ${totalTaxes.toStringAsFixed(2)}'),
                _ticketRow('Total Paid',
                    '$displayCurrency ${totalAmount.toStringAsFixed(2)}', bold: true),
                if (paymentChannel != null)
                  _ticketRow('Payment Method', paymentChannel),
                if (statusDesc.isNotEmpty)
                  _ticketRow('Payment Status', statusDesc),
                if (approveCode != null)
                  _ticketRow('Approval Code', approveCode),
                if (traceNumber != null)
                  _ticketRow('Trace No.', traceNumber),
                if (paymentLimit != null)
                  _ticketRow('Pay By', paymentLimit.replaceAll('T', ' ')),
                if (payerEmail != null)
                  _ticketRow('Email', payerEmail),
                if (payerMobile != null)
                  _ticketRow('Mobile', payerMobile),

                const SizedBox(height: 16),

                // ── Actions ───────────────────────────────────────────
                Row(children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () {
                        Navigator.pop(ctx);
                        context.read<BookingProvider>().reset();
                        Get.offAllNamed('/home');
                      },
                      child: const Text('Home'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.pop(ctx);
                        context.read<BookingProvider>().reset();
                        Get.offAllNamed('/home');
                      },
                      style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFEAA21B)),
                      child: const Text('Done',
                          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                    ),
                  ),
                ]),
              ],
                  ),
                ),
              ),
            ),
          ),
        ),
      );
      },
    );
  }

  Widget _ticketRow(String label, String value, {bool bold = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(color: Colors.grey.shade600, fontSize: 13)),
          Flexible(
            child: Text(value,
                textAlign: TextAlign.end,
                style: TextStyle(
                    fontWeight: bold ? FontWeight.bold : FontWeight.w600,
                    fontSize: bold ? 15 : 13,
                    color: bold ? const Color(0xFFD4AF37) : Colors.black87)),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _cardNumberController.dispose();
    _cardHolderController.dispose();
    _expiryController.dispose();
    _cvvController.dispose();
    super.dispose();
  }
}
