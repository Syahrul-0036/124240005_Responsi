import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../models/products.dart';

// Menyimpan daftar karakter favorit sebagai satu nilai JSON di SharedPreferences.
class WishlistService {
  static const String _favoritesKey = 'Wishlis_Products';

  static String? get _wishlistesKey => null;

  static Future<List<Products>> getWishlist() async {
    final preferences = await SharedPreferences.getInstance();
    final savedWishlistes = preferences.getString(_wishlistesKey!);
    if (savedWishlistes == null || savedWishlistes.isEmpty) {
      return [];
    }

    final decodedFavorites = jsonDecode(savedWishlistes) as List<dynamic>;
    return decodedFavorites
        .map((item) => Products.fromJson(item as Map<String, dynamic>))
        .toList();
  }

  static Future<void> saveFavorites(List<Products> characters) async {
    final preferences = await SharedPreferences.getInstance();
    final jsonProducts = Products.map((Products) => Products.toJson()).toList();
    await preferences.setString(_favoritesKey, jsonEncode(jsonProducts));
  }

  static Future<bool> isWishlist(int productId) async {
    final favorites = await getWishlist();
    return favorites.any((Products) => Products.id == productId);
  }

  // Menambah atau menghapus karakter lalu menyimpan daftar yang baru.
  static Future<bool> toggleFavorite(Products products) async {
    final favorites = await getWishlist();
    final alreadyFavorite = favorites.any(
      (favorite) => favorite.id == products.id,
    );
    if (alreadyFavorite) {
      favorites.removeWhere((favorite) => favorite.id == products.id);
    } else {
      favorites.add(products);
    }
    await saveFavorites(favorites);
    return !alreadyFavorite;
  }

  static Future<void> removeFavorite(int productsId) async {
    final wishlist = await getWishlist();
    wishlist.removeWhere((Products) => Products.id == productsId);
    await saveFavorites(wishlist);
  }

  static Future<Object?> toggleWishlist(Products products) async {
    return null;
  }

  static Future<void> removeWishlist(int id) async {}
}
