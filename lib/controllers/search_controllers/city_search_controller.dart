import 'package:get/get.dart';

class CitySearchController extends GetxController {
  final searchText = ''.obs;
  final selectedRegion = 'Asia'.obs;
  final isMultipleDeparture = false.obs;
  final recentSearches = <String>[].obs;
  static const int maxRecent = 10;
  final expandedCountries = <String, bool>{}.obs;

  final List<String> regions = [
    'Asia',
    'Europe',
    'Oceania',
    'North America',
    'South America',
    'Africa',
  ];

  final Map<String, Map<String, List<String>>> hierarchicalData = {
    'Asia': {
      'India': [
        'New Delhi',
        'Mumbai',
        'Kochi',
        'Bengaluru',
        'Chennai',
        'Hyderabad'
      ],
      'Thailand': [
        'Bangkok',
        'Phuket',
        'Koh Samui',
        'Krabi',
        'Chiang Mai',
        'Pattaya'
      ],
      'Japan': ['Tokyo', 'Osaka', 'Kyoto', 'Nagoya'],
    },
    'Europe': {
      'UK': ['London', 'Manchester', 'Birmingham', 'Glasgow'],
      'France': ['Paris', 'Marseille', 'Lyon', 'Nice'],
      'Germany': ['Berlin', 'Munich', 'Frankfurt', 'Hamburg'],
    },
    'Oceania': {
      'Australia': ['Sydney', 'Melbourne', 'Brisbane', 'Perth'],
      'New Zealand': ['Auckland', 'Wellington', 'Christchurch'],
    },
    'North America': {
      'USA': ['New York', 'Los Angeles', 'Chicago', 'Miami'],
      'Canada': ['Toronto', 'Vancouver', 'Montreal'],
    },
    'South America': {
      'Brazil': ['Sao Paulo', 'Rio de Janeiro'],
      'Argentina': ['Buenos Aires'],
    },
    'Africa': {
      'Egypt': ['Cairo', 'Alexandria'],
      'South Africa': ['Johannesburg', 'Cape Town'],
    }
  };

  final List<String> popularCities = [
    'London',
    'Bangkok',
    'Istanbul',
    'Manchester',
    'Manila'
  ];

  Map<String, List<String>> get currentRegionData =>
      hierarchicalData[selectedRegion.value] ?? {};

  List<String> get allLocations {
    final List<String> list = [];
    hierarchicalData.forEach((_, countries) {
      countries.forEach((country, cities) {
        list.add(country);
        list.addAll(cities);
      });
    });
    return list;
  }
  List<String> get filteredResults {
    if (searchText.value.trim().isEmpty) return [];
    final query = searchText.value.toLowerCase();
    return allLocations
        .where((e) => e.toLowerCase().contains(query))
        .toList();
  }
  bool get isSearching => searchText.value.trim().isNotEmpty;

  void updateSearch(String value) {
    searchText.value = value;
  }

  void changeRegion(String region) {
    selectedRegion.value = region;
  }
  void toggleMultipleDeparture(bool value) {
    isMultipleDeparture.value = value;
  }

  void clearAllRecent() {
    recentSearches.clear();
  }

  void selectCity(String city) {
    recentSearches.remove(city);
    recentSearches.insert(0, city);

    if (recentSearches.length > maxRecent) {
      recentSearches.removeLast();
    }

    Get.back(result: city);
  }

  bool isExpanded(String country) {
    return expandedCountries[country] ?? false;
  }

  void toggleExpanded(String country) {
    expandedCountries[country] =
    !(expandedCountries[country] ?? false);
  }
}
