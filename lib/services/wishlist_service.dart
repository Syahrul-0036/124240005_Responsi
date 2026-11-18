import 'dart:convert';

import '../models/products.dart';
import 'db_helper.dart';

// Store complete favorite product data in the local SQLite database.
class WishlistService {
  static Future<List<Products>> getWishlist() async {
    final database = await DbHelper.instance.database;
    final rows = await database.query(
      'wishlist_products',
      orderBy: 'product_id',
    );
    return rows
        .map(
          (row) => Products.fromJson(
            jsonDecode(row['product_json'] as String) as Map<String, dynamic>,
          ),
        )
        .toList();
  }

  static Future<void> saveFavorites(List<Products> products) async {
    final database = await DbHelper.instance.database;
    await database.transaction((transaction) async {
      await transaction.delete('wishlist_products');
      for (final product in products) {
        await transaction.insert('wishlist_products', {
          'product_id': product.id,
          'product_json': jsonEncode(product.toJson()),
        });
      }
    });
  }

  static Future<bool> isWishlist(int productId) async {
    final database = await DbHelper.instance.database;
    final rows = await database.query(
      'wishlist_products',
      columns: ['product_id'],
      where: 'product_id = ?',
      whereArgs: [productId],
      limit: 1,
    );
    return rows.isNotEmpty;
  }

  static Future<bool> toggleFavorite(Products products) async {
    final database = await DbHelper.instance.database;
    return database.transaction((transaction) async {
      final rows = await transaction.query(
        'wishlist_products',
        columns: ['product_id'],
        where: 'product_id = ?',
        whereArgs: [products.id],
        limit: 1,
      );
      if (rows.isNotEmpty) {
        await transaction.delete(
          'wishlist_products',
          where: 'product_id = ?',
          whereArgs: [products.id],
        );
        return false;
      }
      await transaction.insert('wishlist_products', {
        'product_id': products.id,
        'product_json': jsonEncode(products.toJson()),
      });
      return true;
    });
  }

  static Future<void> removeFavorite(int productsId) async {
    final database = await DbHelper.instance.database;
    await database.delete(
      'wishlist_products',
      where: 'product_id = ?',
      whereArgs: [productsId],
    );
  }

  static Future<bool> toggleWishlist(Products products) {
    return toggleFavorite(products);
  }

  static Future<void> removeWishlist(int id) {
    return removeFavorite(id);
  }
}
