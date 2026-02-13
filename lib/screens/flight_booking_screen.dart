import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'flight_booking_middle.dart';

class FlightBookingScreen extends StatefulWidget {
  const FlightBookingScreen({super.key});

  @override
  State<FlightBookingScreen> createState() => _FlightBookingScreenState();
}

class _FlightBookingScreenState extends State<FlightBookingScreen>
    with TickerProviderStateMixin {
  final PageController _pageController = PageController();
  int _currentPage = 0;
  Timer? _timer;

  late AnimationController _animationController;
  late Animation<double> _heightAnimation;

  final double _minHeight = 150;
  final double _maxHeight = 220;
  bool _isExpanded = false;
  String _selectedClass = 'First';
  bool _isClassDropdownOpen = false;

  // Moved here – real state for checkbox
  bool _flightPlusHotelChecked = false;

  final List<String> _flightClasses = [
    'Economy',
    'Economy/premium economy',
    'Premium Economy',
    'Business/First',
    'Business',
    'First',
  ];
  final List<Map<String, String>> _advertisements = [
    {
      'title': 'Explore the world with Air Europa',
      'subtitle': 'Find exclusive prices today!',
      'image': 'https://images.unsplash.com/photo-1499856871958-5b9627545d1a?w=800',
    },
    {
      'title': 'Trip.com',
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
    _timer = Timer.periodic(const Duration(seconds: 5), (timer) {
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

  int _selectedTab = 2;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true, // ← helps with keyboard
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
                physics: const AlwaysScrollableScrollPhysics(), // ← force scroll
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
                          if (_selectedTab == 0) ..._buildOneWayContent(),
                          if (_selectedTab == 1) ..._buildRoundTripContent(),
                          if (_selectedTab == 2) ..._buildMultiCityContent(),
                          const SizedBox(height: 20),
                        ],
                      ),
                    ),

                    // Middle section – added constraints to prevent it taking infinite height
                    Container(
                      margin: const EdgeInsets.symmetric(horizontal: 0, vertical: 0),
                      padding: const EdgeInsets.all(0),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(0),
                      ),
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(minHeight: 100, maxHeight: 1150),
                        child: FlightBookingMiddle(),
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
              const Color(0xFF1E3A8A).withOpacity(0.9),
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
                  'Trip.com',
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
                color: isSelected ? const Color(0xFF1E5EFF) : Colors.grey[600],
              ),
            ),
            const SizedBox(height: 8),
            Container(
              height: 3,
              decoration: BoxDecoration(
                color: isSelected ? const Color(0xFF1E5EFF) : Colors.transparent,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLocationField({
    required IconData icon,
    required String label,
    bool isPlaceholder = false,
  }) {
    return Row(
      children: [
        Icon(icon, color: Colors.grey[700]),
        const SizedBox(width: 12),
        Text(
          label,
          style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w500,
            color: isPlaceholder ? Colors.grey[400] : Colors.black,
          ),
        ),
      ],
    );
  }

  Widget _buildLineReversField() {
    return Row(
      children: [
        Expanded(
          child: Container(
            height: 1,
            color: Colors.grey[300],
          ),
        ),
        const SizedBox(width: 8),
        Container(
          height: 40,
          padding: const EdgeInsets.all(4),
          decoration: BoxDecoration(
            color: Colors.white,
            border: Border.all(color: Colors.grey[300]!),
            borderRadius: BorderRadius.circular(8),
          ),
          child: const Icon(
            Icons.swap_vert,
            color: Colors.black,
          ),
        ),
      ],
    );
  }

  Widget _buildDividerField() {
    return const Divider(
      color: Colors.grey,
      thickness: 0.3,
    );
  }

  List<Widget> _buildOneWayContent() {
    return [
      _buildLocationField(
        icon: Icons.flight_takeoff,
        label: 'London',
      ),
      _buildLineReversField(),
      _buildLocationField(
        icon: Icons.flight_land,
        label: 'Bangkok',
      ),
      _buildDividerField(),
      const SizedBox(height: 10),
      Row(
        children: const [
          Icon(Icons.calendar_today, color: Colors.grey),
          SizedBox(width: 12),
          Text(
            'Wed, Feb 11',
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
      _buildDividerField(),
      const SizedBox(height: 10),
      _buildPassengersAndClass(),
      _buildDividerField(),
      const SizedBox(height: 10),
      ..._buildFlightHotelSection(),
      _buildSearchButton(),
      const SizedBox(height: 10),
      _buildRecentSearch(),
    ];
  }

  List<Widget> _buildRoundTripContent() {
    return [
      _buildLocationField(
        icon: Icons.flight_takeoff,
        label: 'London',
      ),
      _buildLineReversField(),
      _buildLocationField(
        icon: Icons.flight_land,
        label: 'Bangkok',
      ),
      _buildDividerField(),
      const SizedBox(height: 10),
      Row(
        children: const [
          Icon(Icons.calendar_today, color: Colors.grey),
          SizedBox(width: 10),
          Text(
            'Wed, Feb 11 - Wed, Feb 11',
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
      _buildDividerField(),
      const SizedBox(height: 10),
      _buildPassengersAndClass(),
      _buildDividerField(),
      ..._buildFlightHotelSection(),
      const SizedBox(height: 10),
      _buildSearchButton(),
      const SizedBox(height: 10),
      _buildRecentSearch(),
    ];
  }

  List<Widget> _buildMultiCityContent() {
    return [
      Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Flight 1',
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 16),
          _buildLocationField(
            icon: Icons.flight_takeoff,
            label: 'Bangkok',
          ),
          _buildLineReversField(),
          _buildLocationField(
            icon: Icons.flight_land,
            label: 'Bangkok',
          ),
          _buildDividerField(),
          const SizedBox(height: 10),
          Row(
            children: const [
              Icon(Icons.calendar_today, color: Colors.grey),
              SizedBox(width: 12),
              Text(
                'Wed, Feb 11',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ],
      ),
      _buildDividerField(),
      const SizedBox(height: 10),
      Container(
        decoration: BoxDecoration(
          color: Colors.grey[50],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Flight 2',
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 10),
            _buildLocationField(
              icon: Icons.flight_takeoff,
              label: 'Bangkok',
            ),
            _buildLineReversField(),
            _buildLocationField(
              icon: Icons.flight_land,
              label: 'Where to?',
              isPlaceholder: true,
            ),
            _buildDividerField(),
            const SizedBox(height: 16),
            Row(
              children: const [
                Icon(Icons.calendar_today, color: Colors.grey),
                SizedBox(width: 12),
                Text(
                  'Sat, Feb 14',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
      _buildDividerField(),
      SizedBox(
        width: double.infinity,
        child: Center(
          child: TextButton.icon(
            onPressed: () {},
            icon: const Icon(
              Icons.add_circle_outline,
              color: Color(0xFF1E5EFF),
              size: 20,
            ),
            label: const Text(
              'Add another flight',
              style: TextStyle(
                color: Color(0xFF1E5EFF),
                fontSize: 15,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ),
      ),
      _buildDividerField(),
      const SizedBox(height: 10),
      _buildPassengersAndClass(),
      const Divider(
        color: Colors.grey,
        thickness: 0.3,
      ),
      const SizedBox(height: 10),
      _buildSearchButton(),
    ];
  }

  Widget _buildPassengersAndClass() {
    return Column(
      children: [
        Row(
          children: [
            const Icon(Icons.person, color: Colors.grey),
            const SizedBox(width: 8),
            const Text('1', style: TextStyle(fontSize: 16)),
            const SizedBox(width: 16),
            const Icon(Icons.work_outline, color: Colors.grey),
            const SizedBox(width: 8),
            const Text('0', style: TextStyle(fontSize: 16)),
            const SizedBox(width: 16),
            const Icon(Icons.child_care, color: Colors.grey),
            const SizedBox(width: 8),
            const Text('0', style: TextStyle(fontSize: 16)),
            const SizedBox(width: 16),
            const Text('|', style: TextStyle(color: Colors.grey)),
            const SizedBox(width: 16),
            Expanded(
              child: GestureDetector(
                onTap: () {
                  setState(() {
                    _isClassDropdownOpen = !_isClassDropdownOpen;
                  });
                },
                child: Text(
                  _selectedClass,
                  style: const TextStyle(fontSize: 14),
                ),
              ),
            ),
            GestureDetector(
              onTap: () {
                setState(() {
                  _isClassDropdownOpen = !_isClassDropdownOpen;
                });
              },
              child: Icon(
                _isClassDropdownOpen
                    ? Icons.keyboard_arrow_up
                    : Icons.keyboard_arrow_down,
                color: Colors.grey,
              ),
            ),
          ],
        ),

        if (_isClassDropdownOpen)
          Container(
            margin: const EdgeInsets.only(top: 8),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.grey[300]!),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    border: Border(
                      bottom: BorderSide(color: Colors.grey[200]!),
                    ),
                  ),
                  child: const Center(
                    child: Text(
                      'Class',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),

                ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: _flightClasses.length,
                  separatorBuilder: (context, index) => Divider(
                    height: 1,
                    color: Colors.grey[200],
                  ),
                  itemBuilder: (context, index) {
                    final className = _flightClasses[index];
                    final isSelected = className == _selectedClass;

                    return ListTile(
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      title: Text(
                        className,
                        style: TextStyle(
                          fontSize: 16,
                          color: isSelected ? const Color(0xFF1E5EFF) : Colors.black87,
                          fontWeight: isSelected ? FontWeight.w500 : FontWeight.normal,
                        ),
                      ),
                      trailing: isSelected
                          ? const Icon(
                        Icons.check,
                        color: Color(0xFF1E5EFF),
                        size: 20,
                      )
                          : null,
                      onTap: () {
                        setState(() {
                          _selectedClass = className;
                          _isClassDropdownOpen = false;
                        });
                      },
                    );
                  },
                ),
              ],
            ),
          ),
      ],
    );
  }

  List<Widget> _buildFlightHotelSection() {
    bool isChecked = false;
    return [
      Row(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            decoration: BoxDecoration(
              color: Colors.pink,
              borderRadius: BorderRadius.circular(4),
            ),
            child: const Text(
              'Save 6% on avg.',
              style: TextStyle(
                color: Colors.white,
                fontSize: 10,
                fontWeight: FontWeight.normal,
              ),
            ),
          ),
        ],
      ),

      Row(
        children: [
          Checkbox(
            value: isChecked,
            onChanged: (value) {
              setState(() {
                isChecked = value!;
              });
            },
            activeColor: const Color(0xFF1E5EFF),
          ),
          const Text(
            'Flight + Hotel',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    ];
  }

  Widget _buildSearchButton() {
    return SizedBox(
      width: double.infinity,
      height: 50,
      child: ElevatedButton(
        onPressed: () {},
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF1E5EFF),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: const Text(
          'Search',
          style: TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  Widget _buildRecentSearch() {
    return Row(
      children: [
        Text(
          'London → Bangkok',
          style: TextStyle(
            color: Colors.grey[600],
            fontSize: 14,
          ),
        ),
        const SizedBox(width: 8),
        Text(
          'Feb 11',
          style: TextStyle(
            color: Colors.grey[600],
            fontSize: 14,
          ),
        ),
        const SizedBox(width: 8),
        Icon(Icons.delete_outline, color: Colors.grey[400], size: 20),
      ],
    );
  }
}