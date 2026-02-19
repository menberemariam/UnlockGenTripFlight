import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../providers/booking_provider.dart';

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
    final flight = bookingData.selectedFlight;
    final fare = bookingData.selectedFare;
    final searchParams = bookingData.searchParams;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Payment'),
        actions: [
          _buildStepIndicator(),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildBookingSummary(flight, fare, searchParams, bookingData),
                  _buildPaymentMethods(),
                  if (selectedPaymentMethod == 'card') _buildCardPaymentForm(),
                  if (selectedPaymentMethod == 'paypal') _buildPayPalForm(),
                  if (selectedPaymentMethod == 'bank') _buildBankTransferForm(),
                  _buildPriceBreakdown(bookingData),
                ],
              ),
            ),
          ),
          _buildBottomBar(context, bookingData),
        ],
      ),
    );
  }

  Widget _buildStepIndicator() {
    return Padding(
      padding: const EdgeInsets.only(right: 16),
      child: Row(
        children: [
          _buildStep(1, true),
          _buildStep(2, true),
          _buildStep(3, true),
          _buildStep(4, true),
        ],
      ),
    );
  }

  Widget _buildStep(int number, bool active) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 4),
      width: 24,
      height: 24,
      decoration: BoxDecoration(
        color: active ? Color(0xFFEAA21B) : Colors.grey.shade300,
        shape: BoxShape.circle,
      ),
      child: Center(
        child: Text(
          '$number',
          style: TextStyle(
            color: active ? Colors.white : Colors.grey.shade600,
            fontSize: 12,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  Widget _buildBookingSummary(flight, fare, searchParams, bookingData) {
    return Container(
      padding: const EdgeInsets.all(16),
      color: Color(0xFFFFF8E6),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.flight_takeoff, color: Color(0xFFEAA21B)),
              const SizedBox(width: 8),
              const Text(
                'Booking Summary',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '${searchParams?.from ?? ''} → ${searchParams?.to ?? ''}',
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              Text(
                DateFormat('EEE, MMM dd').format(searchParams?.date ?? DateTime.now()),
                style: TextStyle(color: Colors.grey.shade700),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            '${flight?.airline ?? ''} • ${flight?.departureTime ?? ''}-${flight?.arrivalTime ?? ''}',
            style: TextStyle(color: Colors.grey.shade700),
          ),
          const SizedBox(height: 8),
          Text(
            'Fare: ${fare?.name ?? ''} • Passengers: ${searchParams?.adults ?? 1}',
            style: TextStyle(color: Colors.grey.shade700),
          ),
          if (bookingData.selectedSeat != null) ...[
            const SizedBox(height: 8),
            Text(
              'Seat: ${bookingData.selectedSeat}',
              style: TextStyle(color: Colors.grey.shade700),
            ),
          ],
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
          const Text(
            'Payment Method',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          _buildPaymentMethodOption(
            'card',
            'Credit/Debit Card',
            Icons.credit_card,
            'Visa, Mastercard, Amex',
          ),
          _buildPaymentMethodOption(
            'paypal',
            'PayPal',
            Icons.account_balance_wallet,
            'Pay with your PayPal account',
          ),
          _buildPaymentMethodOption(
            'bank',
            'Bank Transfer',
            Icons.account_balance,
            'Direct bank transfer',
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentMethodOption(
    String value,
    String title,
    IconData icon,
    String subtitle,
  ) {
    final isSelected = selectedPaymentMethod == value;
    return GestureDetector(
      onTap: () => setState(() => selectedPaymentMethod = value),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          border: Border.all(
            color: isSelected ? Color(0xFFEAA21B): Colors.grey.shade300,
            width: isSelected ? 2 : 1,
          ),
          borderRadius: BorderRadius.circular(12),
          color: isSelected ? Color(0xFFFFF8E6) : Colors.white,
        ),
        child: Row(
          children: [
            Icon(
              icon,
              color: isSelected ? Color(0xFFEAA21B) : Colors.grey.shade600,
              size: 32,
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: isSelected ? Color(0xFFEAA21B): Colors.black,
                    ),
                  ),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey.shade600,
                    ),
                  ),
                ],
              ),
            ),
            Radio<String>(
              value: value,
              groupValue: selectedPaymentMethod,
              onChanged: (val) => setState(() => selectedPaymentMethod = val!),
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
          const Text(
            'Card Details',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _cardNumberController,
            decoration: const InputDecoration(
              labelText: 'Card Number',
              hintText: '1234 5678 9012 3456',
              border: OutlineInputBorder(),
              prefixIcon: Icon(Icons.credit_card),
            ),
            keyboardType: TextInputType.number,
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _cardHolderController,
            decoration: const InputDecoration(
              labelText: 'Card Holder Name',
              hintText: 'John Doe',
              border: OutlineInputBorder(),
              prefixIcon: Icon(Icons.person),
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: TextFormField(
                  controller: _expiryController,
                  decoration: const InputDecoration(
                    labelText: 'Expiry Date',
                    hintText: 'MM/YY',
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
                    labelText: 'CVV',
                    hintText: '123',
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
          const Text(
            'You will be redirected to PayPal to complete your payment',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 14),
          ),
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
          const Text(
            'Bank Transfer Details',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          _buildInfoRow('Bank Name:', 'Trip.com International Bank'),
          _buildInfoRow('Account Name:', 'Trip.com Payments Ltd'),
          _buildInfoRow('Account Number:', '1234567890'),
          _buildInfoRow('Sort Code:', '12-34-56'),
          _buildInfoRow('Reference:', 'TRIP${DateTime.now().millisecondsSinceEpoch}'),
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
                  child: Text(
                    'Please include the reference number in your transfer',
                    style: TextStyle(fontSize: 12),
                  ),
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
          Text(
            label,
            style: TextStyle(color: Colors.grey.shade600),
          ),
          Text(
            value,
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  Widget _buildPriceBreakdown(bookingData) {
    final basePrice = bookingData.selectedFare?.price ?? 0;
    final insurancePrice = bookingData.selectedInsurance == 'travel'
        ? 35.03
        : bookingData.selectedInsurance == 'cancellation'
            ? 25.70
            : 0.0;
    final total = basePrice + insurancePrice;

    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Price Breakdown',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          _buildPriceRow('Flight Fare', '£${basePrice.toStringAsFixed(2)}'),
          if (insurancePrice > 0)
            _buildPriceRow('Travel Insurance', '£${insurancePrice.toStringAsFixed(2)}'),
          _buildPriceRow('Taxes & Fees', 'Included'),
          const Divider(height: 32),
          _buildPriceRow(
            'Total',
            '£${total.toStringAsFixed(2)}',
            isTotal: true,
          ),
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
          Text(
            label,
            style: TextStyle(
              fontSize: isTotal ? 18 : 14,
              fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: isTotal ? 18 : 14,
              fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
              color: isTotal ? Color(0xFF9B8E35) : Colors.black,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomBar(BuildContext context, bookingData) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.grey.shade300,
            blurRadius: 4,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Total Amount',
                style: TextStyle(fontSize: 12, color: Colors.grey),
              ),
              Text(
                '£${bookingData.totalPrice.toStringAsFixed(2)}',
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF9B8E35),
                ),
              ),
            ],
          ),
          ElevatedButton(
            onPressed: () => _processPayment(context),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green,
              padding: const EdgeInsets.symmetric(horizontal: 48, vertical: 16),
            ),
            child: const Text(
              'Pay Now',
              style: TextStyle(fontSize: 16, color: Colors.white, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }

  void _processPayment(BuildContext context) {
    // Show loading
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(
        child: CircularProgressIndicator(),
      ),
    );

    // Simulate payment processing
    Future.delayed(const Duration(seconds: 2), () {
      Navigator.pop(context); // Close loading
      _showSuccessDialog(context);
    });
  }

  void _showSuccessDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: const BoxDecoration(
                color: Colors.green,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.check,
                color: Colors.white,
                size: 48,
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'Payment Successful!',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'Your booking has been confirmed.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 8),
            Text(
              'Booking Reference: TRIP${DateTime.now().millisecondsSinceEpoch}',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey.shade600,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              context.read<BookingProvider>().reset();
              Get.offAllNamed('/home');
            },
            child: const Text('Back to Home'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: const Text('View Booking'),
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
