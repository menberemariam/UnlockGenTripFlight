import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/passengers_class_controller.dart';
import '../../controllers/flight_booking_controller.dart';
import '../../widgets/flight_form_widgets/multi_city_form.dart';
import '../../widgets/flight_form_widgets/round_trip_form.dart';
import '../../widgets/flight_form_widgets/one_way_form.dart';

class FlightBookingScreen extends StatefulWidget {
  const FlightBookingScreen({super.key});
  @override
  State<FlightBookingScreen> createState() => _FlightBookingScreenState();
}
class _FlightBookingScreenState extends State<FlightBookingScreen>
    with TickerProviderStateMixin {
  final passengersController = Get.put(PassengersClassController());
  final FlightBookingController controller = Get.put(FlightBookingController());
  final PageController _pageController = PageController();
  int _currentPage = 0;
  Timer? _timer;

  late AnimationController _animationController;
  late Animation<double> _heightAnimation;

  final double _minHeight = 150;
  final double _maxHeight = 220;
  bool _isExpanded = false;

  final List<Map<String, String>> _advertisements = [
    {
      'title': 'Explore the world with Air Europa',
      'subtitle': 'Find exclusive prices today!',
      'image': 'https://images.unsplash.com/photo-1499856871958-5b9627545d1a?w=800',
    },
    {
      'title': 'HW_travels.com',
      'subtitle': 'Explore the world with Air Europa',
      'image': 'https://images.unsplash.com/photo-1436491865332-7a61a109cc05?w=800',
    },
    {
      'title': 'Travel in Style and Comfort',
      'subtitle': 'Premium flights at great prices!',
      'image': 'https://images.unsplash.com/photo-1488646953014-85cb44e25828?w=800',
    },
  ];

  @override
  void initState() {
    super.initState();
    _startAutoSlide();

    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _heightAnimation = Tween<double>(
      begin: _minHeight,
      end: _maxHeight,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));
  }

  void _startAutoSlide() {
    _timer = Timer.periodic(const Duration(seconds: 3), (timer) {
      if (_currentPage < _advertisements.length - 1) {
        _currentPage++;
      } else {
        _currentPage = 0;
      }

      if (_pageController.hasClients) {
        _pageController.animateToPage(
          _currentPage,
          duration: const Duration(milliseconds: 500),
          curve: Curves.easeInOut,
        );
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _pageController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  int _selectedTab = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[300],
      body: SafeArea(
        child: Column(
          children: [
            AnimatedBuilder(
              animation: _heightAnimation,
              builder: (context, child) {
                return GestureDetector(
                  onTap: () {
                    setState(() {
                      _isExpanded = !_isExpanded;
                      if (_isExpanded) {
                        _animationController.forward();
                      } else {
                        _animationController.reverse();
                      }
                    });
                  },
                  child: SizedBox(
                    height: _heightAnimation.value,
                    child: Stack(
                      children: [
                        PageView.builder(
                          controller: _pageController,
                          onPageChanged: (index) {
                            setState(() {
                              _currentPage = index;
                            });
                          },
                          itemCount: _advertisements.length,
                          itemBuilder: (context, index) {
                            return _buildAdBanner(_advertisements[index]);
                          },
                        ),
                        // Back Button
                        Positioned(
                          top: 16,
                          left: 16,
                          child: GestureDetector(
                            onTap: () => Get.back(),
                            child: Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: Colors.black.withOpacity(0.3),
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.arrow_back,
                                color: Colors.white,
                                size: 24,
                              ),
                            ),
                          ),
                        ),
                        // Profile Icon
                        Positioned(
                          top: 16,
                          right: 16,
                          child: Container(
                            padding: const EdgeInsets.all(8),
                            decoration: const BoxDecoration(
                              color: Color(0xFFFFC107),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.person,
                              color: Colors.white,
                              size: 24,
                            ),
                          ),
                        ),
                        Positioned(
                          bottom: 16,
                          right: 16,
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(
                              color: Colors.black.withOpacity(0.5),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              '${_currentPage + 1}/${_advertisements.length}',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),

                      ],
                    ),
                  ),
                );
              },
            ),
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    Container(
                      margin: const EdgeInsets.all(16),
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.05),
                            blurRadius: 10,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              _buildTabButton('One-way', 0),
                              _buildTabButton('Round-trip', 1),
                              _buildTabButton('Multi-city', 2),
                            ],
                          ),
                          const SizedBox(height: 24),
                          if (_selectedTab == 0) OneWayForm(),
                          if (_selectedTab == 1) RoundTripForm(),
                          if (_selectedTab == 2) MultiCityForm(),
                          const SizedBox(height: 20),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
  Widget _buildAdBanner(Map<String, String> ad) {
    return Container(
      decoration: BoxDecoration(
        image: DecorationImage(
          image: NetworkImage(ad['image']!),
          fit: BoxFit.cover,
        ),
      ),
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
            colors: [
              const Color(0xFFD4AF37).withOpacity(0.9),
              Colors.transparent,
            ],
          ),
        ),
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Row(
              children: [
                const Text(
                  'HW_travels.com',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(width: 8),
                const Text(
                  '| ✈ AirEuropa',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              ad['title']!,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              ad['subtitle']!,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 12),

          ],
        ),
      ),
    );
  }
  Widget _buildTabButton(String label, int index) {
    final isSelected = _selectedTab == index;
    return Expanded(
      child: GestureDetector(
        onTap: () {
          setState(() {
            _selectedTab = index;
          });
        },
        child: Column(
          children: [
            Text(
              label,
              style: TextStyle(
                fontSize: 16,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                color: isSelected ? const Color(0xFFFFC107) : Colors.grey[600],
              ),
            ),
            const SizedBox(height: 8),
            Container(
              height: 3,
              decoration: BoxDecoration(
                color: isSelected ? const Color(0xFFFFC107) : Colors.transparent,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

