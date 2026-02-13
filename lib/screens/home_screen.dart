import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'flight_booking_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 15),
              decoration: const BoxDecoration(
                color: Color(0xFF1E5EFF),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Trip.com',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: const BoxDecoration(
                      color: Color(0xFFFFC107),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.person,
                      color: Colors.white,
                      size: 20,
                    ),
                  ),
                ],
              ),
            ),
            

            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    Container(
                      margin: const EdgeInsets.all(0),
                      padding: const EdgeInsets.all(10),
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
                        children: [

                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: [
                              _buildCategoryItem(
                                'assets/icons/icons8-hotel-48.png',
                                'Hotels',
                                const Color(0xFF1E5EFF),
                              ),
                              GestureDetector(
                                onTap: () {
                                  Get.to(() => const FlightBookingScreen());
                                },
                                child: _buildCategoryItem(
                                  'assets/icons/icons8-airplane-take-off-48.png',
                                  'Flights',
                                  const Color(0xFF1E5EFF),
                                ),
                              ),


                                _buildCategoryItem(
                                  'assets/icons/flight+hotell.webp',
                                  'Flight + Hotel',
                                  const Color(0xFF1E5EFF),
                                ),
                              _buildCategoryItem(
                                'assets/icons/icons8-subway-48.png',

                                'Trains',
                                const Color(0xFF1E5EFF),
                              ),
                            ],
                          ),
                          const SizedBox(height: 24),
                          // Second Row - Additional Categories
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: [
                              _buildCategoryItem(
                                'assets/icons/Home and apartment.webp',
                                'Homes &\nApartments',
                                const Color(0xFF1E5EFF),
                              ),
                              _buildCategoryItem(
                                'assets/icons/attraction_and_tour.webp',

                                'Attractions\n& Tours',
                                const Color(0xFF1E5EFF),
                              ),
                              _buildCategoryItem(
                                'assets/icons/icons8-station-wagon-48.png',

                                'Car Rentals',
                                const Color(0xFF1E5EFF),
                              ),
                              _buildCategoryItem(
                                'assets/icons/private toure.webp',

                                'Private\nTours',
                                const Color(0xFF1E5EFF),
                              ),
                              _buildCategoryItem(
                                'assets/icons/icons8-below-48.png',
                                '+6 more',
                                const Color(0xFF1E5EFF),
                              ),
                            ],

                          ),

                        ],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(30),
                          border: Border.all(color: Color(0xFF1E5EFF)),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.public, color: Color(0xFF1E5EFF)),
                            const SizedBox(width: 12),
                            const Text(
                              'Where to?',
                              style: TextStyle(
                                color: Colors.blueGrey,
                                fontSize: 16,
                              ),
                            ),
                            const Spacer(),
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: const BoxDecoration(
                                color: Color(0xFF1E5EFF),
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.search,
                                color: Colors.white,
                                size: 20,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    
                    const SizedBox(height: 16),
                    
                    // Quick Links (Cities)
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          _buildCityLink('London'),
                          _buildCityLink('Paris'),
                          _buildCityLink('New York'),
                          _buildCityLink('Tokyo'),
                          Row(
                            children: const [
                              Icon(Icons.map, color: Color(0xFF1E5EFF), size: 18),
                              SizedBox(width: 4),
                              Text(
                                'Map',
                                style: TextStyle(
                                  color: Color(0xFF1E5EFF),
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    
                    const SizedBox(height: 20),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          _buildFeatureIcon(
                            'assets/icons/icons8-sale-price-tag-32 (1).png',
                            'Deals',
                          ),
                          _buildFeatureIcon(
                            'assets/icons/icons8-calendar-48.png',
                            'Events',
                          ),
                          _buildFeatureIcon(
                            'assets/icons/icons8-schedule-48.png',
                            'Trip.Planner',
                          ),
                          _buildFeatureIcon(
                            'assets/icons/icons8-increase-48.png',
                            'Trending',
                          ),
                          _buildFeatureIcon(
                            'assets/icons/icons8-trophy-48.png',
                            'Trip.Best',
                          ),
                        ],
                      ),
                    ),
                    
                    const SizedBox(height: 20),
                    
                    // Discount Banner
                    Container(
                      margin: const EdgeInsets.symmetric(horizontal: 16),
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            Colors.purple[50]!,
                            Colors.blue[50]!,
                          ],
                        ),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Text(
                              '🎁',
                              style: TextStyle(fontSize: 24),
                            ),
                          ),
                          const SizedBox(width: 12),
                          const Expanded(
                            child: Text(
                              'New User Discounts Available',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          ElevatedButton(
                            onPressed: () {},
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF1E5EFF),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                            child: const Text(
                              'Claim All',
                              style: TextStyle(color: Colors.white),
                            ),
                          ),
                        ],
                      ),
                    ),
                    
                    const SizedBox(height: 16),
                    
                    // Promo Cards
                    SizedBox(
                      height: 120,
                      child: ListView(
                        scrollDirection: Axis.horizontal,
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        children: [
                          _buildPromoCard(
                            'Hotels',
                            '10% off',
                            Colors.pink[50]!,
                            Colors.pink,
                          ),
                          const SizedBox(width: 12),
                          _buildPromoCard(
                            'Tours & tickets',
                            '5% off',
                            Colors.purple[50]!,
                            Colors.purple,
                          ),
                          const SizedBox(width: 12),
                          _buildPromoCard(
                            'Flights',
                            '15% off',
                            Colors.blue[50]!,
                            Colors.blue,
                          ),
                        ],
                      ),
                    ),
                    
                    const SizedBox(height: 20),

                    Row(
                      children: [
                        Expanded(
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: Container(
                              height: 250,
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                  colors: [
                                    const Color(0xFF0D6EFD),
                                    const Color(0xFF0A58CA),
                                  ],
                                ),
                              ),
                              child: Stack(
                                children: [
                                  Positioned(
                                    top: 16,
                                    left: 16,
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        const Text(
                                          'Trip.com',
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontSize: 18,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        const SizedBox(height: 8),
                                        const Text(
                                          'EXPLORE\nCULTURAL\nTOURISM\nIN HENGQIN',
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontSize: 24,
                                            fontWeight: FontWeight.bold,
                                            height: 1.2,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Positioned(
                                    bottom: 16,
                                    left: 16,
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 20,
                                        vertical: 10,
                                      ),
                                      decoration: BoxDecoration(
                                        color: Colors.amber,
                                        borderRadius: BorderRadius.circular(20),
                                      ),
                                      child: const Text(
                                        'Book Now',
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: Container(
                              height: 250,
                              color: Colors.grey[300],
                              child: Stack(
                                children: [
                                  Container(
                                    decoration: BoxDecoration(
                                      gradient: LinearGradient(
                                        begin: Alignment.topCenter,
                                        end: Alignment.bottomCenter,
                                        colors: [
                                          Colors.grey[400]!,
                                          Colors.grey[300]!,
                                        ],
                                      ),
                                    ),
                                  ),
                                  Positioned(
                                    bottom: 16,
                                    right: 16,
                                    child: Container(
                                      padding: const EdgeInsets.all(12),
                                      decoration: BoxDecoration(
                                        color: const Color(0xFF0D6EFD),
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: Column(
                                        children: const [
                                          Icon(
                                            Icons.smart_toy,
                                            color: Colors.white,
                                            size: 24,
                                          ),
                                          SizedBox(height: 4),
                                          Text(
                                            'GENIE',
                                            style: TextStyle(
                                              color: Colors.white,
                                              fontSize: 10,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),

                    
                    const SizedBox(height: 80),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: _buildBottomNavBar(),
    );
  }

  Widget _buildCategoryItem(String assetPath,  String label, Color color) {
    return Column(
      children: [
        Container(
          width: 60,
          height: 60,
          decoration: BoxDecoration(
            color: Color(0xCFEFEFFB),
            borderRadius: BorderRadius.circular(100),
          ),
          child: Center(
            child: Image.asset(
              assetPath,
              width: 32,
              height: 32,
            ),
          ),
        ),
        const SizedBox(height: 8),
        SizedBox(
          width: 70,
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: Color(0xFF1E5EFF),
              height: 1.2,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildCityLink(String city) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        city,
        style: TextStyle(
          fontSize: 12,
          color: Colors.grey[700],
        ),
      ),
    );
  }


  Widget _buildFeatureIcon(String assetPath, String label) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.grey[100],
            borderRadius: BorderRadius.circular(12),
          ),
          child: Image.asset(
            assetPath,
            width: 28,
            height: 28,


          ),
        ),
        const SizedBox(height: 8),
        Text(
          label,
          style: TextStyle(
            fontSize: 11,
            color: Colors.grey[700],
          ),
        ),
      ],
    );
  }

  Widget _buildPromoCard(String title, String discount, Color bgColor, Color? iconColor) {
    return Container(
      width: 180,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(
            Icons.card_giftcard,
            color: iconColor,
            size: 32,
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[700],
                ),
              ),
              const SizedBox(height: 4),
              Text(
                discount,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: iconColor,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildBottomNavBar() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        selectedItemColor: const Color(0xFF1E5EFF),
        unselectedItemColor: Colors.grey,
        currentIndex: 0,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.message),
            label: 'Messages',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.add_circle, size: 40),
            label: 'Post',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.card_travel),
            label: 'My Trips',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_outline),
            label: 'Sign In',
          ),
        ],
      ),
    );
  }
}
