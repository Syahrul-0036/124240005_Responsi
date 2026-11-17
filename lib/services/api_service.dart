import 'dart:convert';

import 'package:http/http.dart' as http;

import '../models/products.dart';

// Semua komunikasi HTTP ke Rick and Morty API disimpan di satu tempat.
class ApiService {
  static const String _baseUrl = ' https://dummyjson.com/products';

  // Mengambil karakter dan mengembalikan daftar kosong jika API memberi 404.
  static Future<List<Products>> getCharacters({String? title}) async {
    final queryParameters = <String, String>{};
    if (title != null && title.isNotEmpty) {
      queryParameters['title'] = title.toLowerCase();
    }

    final uri = Uri.parse('$_baseUrl/products').replace(
      queryParameters: queryParameters.isEmpty ? null : queryParameters,
    );
    final response = await http.get(uri).timeout(const Duration(seconds: 15));

    if (response.statusCode == 404) {
      return [];
    }
    if (response.statusCode != 200) {
      throw Exception('Server API mengembalikan kode ${response.statusCode}.');
    }

    final responseData = jsonDecode(response.body) as Map<String, dynamic>;
    final results = responseData['results'] as List<dynamic>;
    return results
        .map((item) => Products.fromJson(item as Map<String, dynamic>))
        .toList();
  }

  // Mengambil satu karakter untuk memastikan detail berasal dari API terbaru.
  static Future<Products> getCharacter(int id) async {
    final response = await http
        .get(Uri.parse('$_baseUrl/character/$id'))
        .timeout(const Duration(seconds: 15));
    if (response.statusCode != 200) {
      throw Exception('Detail karakter tidak dapat dimuat.');
    }
    return Products.fromJson(jsonDecode(response.body) as Map<String, dynamic>);
  }
}
