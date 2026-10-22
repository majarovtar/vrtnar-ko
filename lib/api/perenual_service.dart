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
      scientificName: (json['scientific_name'] is List &&
              (json['scientific_name'] as List).isNotEmpty)
          ? (json['scientific_name'] as List).first as String
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
      poisonousToAnimals:
          json['poisonous_to_pets'] == true || json['poisonous_to_pets'] == 1,
      description: json['description'] as String?,
      pestSusceptibility: (json['pest_susceptibility'] is List)
          ? (json['pest_susceptibility'] as List).cast<String>()
          : [],
    );
  }
}

class PlantSearchResult {
  final int id;
  final String commonName;
  final String? watering;
  final bool? edible;
  final List<String> sunlight;
  final String? imageUrl;

  const PlantSearchResult({
    required this.id,
    required this.commonName,
    this.watering,
    this.edible,
    this.sunlight = const [],
    this.imageUrl,
  });

  factory PlantSearchResult.fromJson(Map<String, dynamic> json) {
    String? imageUrl;
    final defaultImage = json['default_image'] as Map<String, dynamic>?;
    if (defaultImage != null) {
      imageUrl = defaultImage['small_url'] as String? ?? 
                 defaultImage['thumbnail'] as String?;
    }

    return PlantSearchResult(
      id: json['id'] as int,
      commonName: json['common_name'] as String? ?? 'Unknown',
      watering: json['watering'] as String?,
      edible: json['edible'] as bool?,
      sunlight: (json['sunlight'] is List)
          ? (json['sunlight'] as List).cast<String>()
          : (json['sunlight'] is String && (json['sunlight'] as String).isNotEmpty)
              ? [json['sunlight'] as String]
              : [],
      imageUrl: imageUrl,
    );
  }
}

class PerenualService {
  static const _baseUrl = 'https://perenual.com/api/v2';

  static final PerenualService _instance = PerenualService._();
  factory PerenualService() => _instance;
  PerenualService._();

  static const _apiKey = 'sk-KmUd6ad9fb252549f16533';

  final Map<String, PlantDetails> _cache = {};

  Future<PlantDetails?> fetchPlantDetails(String plantName) async {
    if (_cache.containsKey(plantName)) return _cache[plantName];

    try {
      final searchUrl = Uri.parse(
        '$_baseUrl/species-list?key=$_apiKey&q=${Uri.encodeComponent(plantName)}',
      );
      final searchResponse = await http.get(searchUrl);

      if (searchResponse.statusCode != 200) {
        print('Perenual search body: ${searchResponse.body}');
        return null;
      }

      final searchData = jsonDecode(searchResponse.body) as Map<String, dynamic>;
      final results = searchData['data'] as List?;
      if (results == null || results.isEmpty) return null;

      final speciesId = results[0]['id'] as int;

      final detailsUrl = Uri.parse(
        '$_baseUrl/species/details/$speciesId?key=$_apiKey',
      );
      final detailsResponse = await http.get(detailsUrl);

      if (detailsResponse.statusCode != 200) {
        print('Perenual details body: ${detailsResponse.body}');
        return null;
      }

      final detailsData =
          jsonDecode(detailsResponse.body) as Map<String, dynamic>;
      final details = PlantDetails.fromJson(detailsData);
      _cache[plantName] = details;
      return details;
    } catch (e) {
      print('Perenual error: $e');
      return null;
    }
  }

  Future<List<PlantSearchResult>> searchPlants({
    String? query,
    String? sunlightFilter,
    bool? poisonous,
    bool edibleOnly = false,
    int page = 1,
  }) async {
    try {
      final queryParameters = <String, String>{
        'key': _apiKey,
        'page': '$page',
      };

      if (poisonous != null) {
        queryParameters['poisonous'] = poisonous ? '1' : '0';
      }

      if (edibleOnly) {
        queryParameters['edible'] = '1';
      }

      if (query != null && query.trim().isNotEmpty) {
        queryParameters['q'] = query.trim();
      }

      if (sunlightFilter != null && sunlightFilter.isNotEmpty) {
        queryParameters['sunlight'] = sunlightFilter;
      }

      final url = Uri.parse('$_baseUrl/species-list')
          .replace(queryParameters: queryParameters);

      final response = await http.get(url);

      if (response.statusCode != 200) {
        print('Plant search failed: ${response.statusCode}');
        print(response.body);
        return [];
      }

      final data = jsonDecode(response.body) as Map<String, dynamic>;
      final rawList = data['data'] as List? ?? [];

      return rawList
          .whereType<Map<String, dynamic>>()
          .take(3)
          .map(PlantSearchResult.fromJson)
          .toList();
    } catch (e) {
      print('Plant search error: $e');
      return [];
    }
  }
}