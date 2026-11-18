import 'dart:convert';

import 'package:http/http.dart' as http;

import '../models/products.dart';

// All catalog HTTP requests are handled here.
class ApiService {
  static const String _baseUrl = 'https://dummyjson.com/products';

  static Future<List<Products>> getProducts({
    String? query,
    String? category,
  }) async {
    final searchTerm = query?.trim();
    final categorySlug = category?.trim();
    final Uri uri;
    if (categorySlug != null && categorySlug.isNotEmpty) {
      uri = Uri.parse(
        '$_baseUrl/category/${Uri.encodeComponent(categorySlug)}',
      );
    } else if (searchTerm != null && searchTerm.isNotEmpty) {
      uri = Uri.parse('$_baseUrl/search').replace(
        queryParameters: {'q': searchTerm},
      );
    } else {
      uri = Uri.parse(_baseUrl);
    }

    final response = await http.get(uri).timeout(const Duration(seconds: 15));

    if (response.statusCode != 200) {
      throw Exception('Server API mengembalikan kode ${response.statusCode}.');
    }

    final responseData = jsonDecode(response.body) as Map<String, dynamic>;
    final products = responseData['products'] as List<dynamic>;
    final result = products
        .map((item) => Products.fromJson(item as Map<String, dynamic>))
        .toList();

    if (categorySlug != null &&
        categorySlug.isNotEmpty &&
        searchTerm != null &&
        searchTerm.isNotEmpty) {
      return result
          .where(
            (product) =>
                product.title.toLowerCase().contains(searchTerm.toLowerCase()),
          )
          .toList();
    }
    return result;
  }

  static Future<List<String>> getCategories() async {
    final response = await http
        .get(Uri.parse('$_baseUrl/category-list'))
        .timeout(const Duration(seconds: 15));
    if (response.statusCode != 200) {
      throw Exception(
        'Daftar kategori tidak dapat dimuat (kode ${response.statusCode}).',
      );
    }
    final categories = jsonDecode(response.body) as List<dynamic>;
    return categories.map((category) => category as String).toList();
  }

  static Future<Products> getProduct(int id) async {
    final response = await http
        .get(Uri.parse('$_baseUrl/$id'))
        .timeout(const Duration(seconds: 15));
    if (response.statusCode != 200) {
      throw Exception('Detail produk tidak dapat dimuat.');
    }
    return Products.fromJson(jsonDecode(response.body) as Map<String, dynamic>);
  }
}
