import 'dart:convert';

import 'package:http/http.dart' as http;

class PlantDetails {
  final String commonName;
  final String scientificName;
  final String cycle;
  final String watering;
  final List<String> sunlight;
  final String growthRate;
  final String soil;
  final String floweringSeason;
  final bool poisonousToAnimals;
  final String? description;
  final List<String> pestSusceptibility;

  const PlantDetails({
    required this.commonName,
    required this.scientificName,
    required this.cycle,
    required this.watering,
    required this.sunlight,
    required this.growthRate,
    required this.soil,
    required this.floweringSeason,
    required this.poisonousToAnimals,
    this.description,
    required this.pestSusceptibility,
  });

  factory PlantDetails.fromJson(Map<String, dynamic> json) {
    return PlantDetails(
      commonName: json['common_name'] as String? ?? 'Unknown',
      scientificName: (json['scientific_name'] is List)
          ? (json['scientific_name'] as List).firstOrNull as String? ?? 'Unknown'
          : json['scientific_name'] as String? ?? 'Unknown',
      cycle: json['cycle'] as String? ?? 'Unknown',
      watering: json['watering'] as String? ?? 'Unknown',
      sunlight: (json['sunlight'] is List)
          ? (json['sunlight'] as List).cast<String>()
          : [json['sunlight'] as String? ?? 'Unknown'],
      growthRate: json['growth_rate'] as String? ?? 'Unknown',
      soil: (json['soil'] is List)
          ? (json['soil'] as List).cast<String>().join(', ')
          : json['soil'] as String? ?? 'Unknown',
      floweringSeason: json['flowering_season'] as String? ?? 'Unknown',
      poisonousToAnimals: json['poisonous_to_pets'] == true ||
          json['poisonous_to_pets'] == 1,
      description: json['description'] as String?,
      pestSusceptibility: (json['pest_susceptibility'] is List)
          ? (json['pest_susceptibility'] as List).cast<String>()
          : [],
    );
  }
}

class PerenualService {
  static const _baseUrl = 'https://perenual.com/api/v2';

  static final PerenualService _instance = PerenualService._();
  factory PerenualService() => _instance;
  PerenualService._();

  static const _apiKey = 'sk-Orrl69e3b9ac158ed16533';

  final Map<String, PlantDetails> _cache = {};

  /// Search for a plant species by name and return details for the first match.
  Future<PlantDetails?> fetchPlantDetails(String plantName) async {
    if (_cache.containsKey(plantName)) return _cache[plantName];

    try {
      // Step 1: Search for the species
      final searchUrl = Uri.parse(
        '$_baseUrl/species-list?key=$_apiKey&q=${Uri.encodeComponent(plantName)}',
      );
      print('Perenual search: $searchUrl');
      final searchResponse = await http.get(searchUrl);
      print('Perenual search status: ${searchResponse.statusCode}');
      if (searchResponse.statusCode != 200) {
        print('Perenual search body: ${searchResponse.body}');
        return null;
      }

      final searchData = jsonDecode(searchResponse.body) as Map<String, dynamic>;
      final results = searchData['data'] as List?;
      print('Perenual search results: ${results?.length ?? 0}');
      if (results == null || results.isEmpty) return null;

      final speciesId = results[0]['id'] as int;
      print('Perenual species ID: $speciesId');

      // Step 2: Fetch full details
      final detailsUrl = Uri.parse(
        '$_baseUrl/species/details/$speciesId?key=$_apiKey',
      );
      final detailsResponse = await http.get(detailsUrl);
      print('Perenual details status: ${detailsResponse.statusCode}');
      if (detailsResponse.statusCode != 200) {
        print('Perenual details body: ${detailsResponse.body}');
        return null;
      }

      final detailsData = jsonDecode(detailsResponse.body) as Map<String, dynamic>;
      final details = PlantDetails.fromJson(detailsData);
      _cache[plantName] = details;
      print('Perenual loaded: ${details.commonName}');
      return details;
    } catch (e) {
      print('Perenual error: $e');
      return null;
    }
  }
}
