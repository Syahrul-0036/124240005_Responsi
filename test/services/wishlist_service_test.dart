import 'package:flutter_test/flutter_test.dart';
import 'package:shoppinghub/models/products.dart';
import 'package:shoppinghub/services/db_helper.dart';
import 'package:shoppinghub/services/wishlist_service.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

void main() {
  const product = Products(
    id: 1,
    title: 'Test product',
    description: 'A test product',
    category: 'test',
    price: 12.5,
    discountPercentage: 5,
    rating: 4.5,
    stock: 10,
    image: 'https://example.com/product.png',
    brand: 'Test brand',
  );

  setUpAll(() {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  });

  setUp(() async {
    final database = await DbHelper.instance.database;
    await database.delete('wishlist_products');
  });

  test('toggleWishlist adds and removes a product in SQLite', () async {
    expect(await WishlistService.toggleWishlist(product), isTrue);
    expect(await WishlistService.isWishlist(product.id), isTrue);

    expect(await WishlistService.toggleWishlist(product), isFalse);
    expect(await WishlistService.isWishlist(product.id), isFalse);
  });

  test('SQLite retains all saved product fields', () async {
    await WishlistService.saveFavorites([product]);

    final favorites = await WishlistService.getWishlist();

    expect(favorites, hasLength(1));
    expect(favorites.single.toJson(), product.toJson());
  });
}
