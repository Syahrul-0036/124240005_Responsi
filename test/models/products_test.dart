import 'package:flutter_test/flutter_test.dart';
import 'package:shoppinghub/models/products.dart';

void main() {
  test('parses DummyJSON product fields and thumbnail', () {
    final product = Products.fromJson({
      'id': 1,
      'title': 'Mascara',
      'description': 'A product',
      'category': 'beauty',
      'price': 9.99,
      'discountPercentage': 10.48,
      'rating': 2.56,
      'stock': 99,
      'brand': 'Essence',
      'thumbnail': 'https://example.com/thumbnail.webp',
      'images': ['https://example.com/product.webp'],
    });

    expect(product.price, 9.99);
    expect(product.discountPercentage, 10.48);
    expect(product.rating, 2.56);
    expect(product.stock, 99);
    expect(product.image, 'https://example.com/thumbnail.webp');
  });

  test('reads the image key used by previously saved wishlist products', () {
    final product = Products.fromJson({
      'id': 2,
      'title': 'Saved product',
      'price': 1,
      'image': 'https://example.com/saved.webp',
    });

    expect(product.image, 'https://example.com/saved.webp');
  });
}
