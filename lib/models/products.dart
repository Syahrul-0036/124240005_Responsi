// Product data shared by the catalog, detail, and wishlist screens.
class Products {
  const Products({
    required this.id,
    required this.title,
    required this.description,
    required this.category,
    required this.price,
    required this.discountPercentage,
    required this.rating,
    required this.stock,
    required this.image,
    required this.brand,
  });

  final int id;
  final String title;
  final String description;
  final String category;
  final double price;
  final double discountPercentage;
  final double rating;
  final int stock;
  final String image;
  final String brand;

  // Convert API and locally stored JSON into a product.
  factory Products.fromJson(Map<String, dynamic> json) {
    return Products(
      id: (json['id'] as num).toInt(),
      title: json['title'] as String? ?? 'Unknown',
      description: json['description'] as String? ?? '',
      category: json['category'] as String? ?? 'unknown',
      image: _imageFromJson(json),
      price: (json['price'] as num?)?.toDouble() ?? 0,
      discountPercentage:
          (json['discountPercentage'] as num?)?.toDouble() ?? 0,
      rating: (json['rating'] as num?)?.toDouble() ?? 0,
      stock: (json['stock'] as num?)?.toInt() ?? 0,
      brand: json['brand'] as String? ?? 'Unknown',
    );
  }

  static String _imageFromJson(Map<String, dynamic> json) {
    final thumbnail = json['thumbnail'];
    if (thumbnail is String) return thumbnail;

    final image = json['image'];
    if (image is String) return image;

    final images = json['images'];
    if (images is List) {
      for (final image in images) {
        if (image is String) return image;
      }
    }
    return '';
  }

  // Keep the complete product when persisting favorites locally.
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'category': category,
      'image': image,
      'price': price,
      'discountPercentage': discountPercentage,
      'rating': rating,
      'stock': stock,
      'brand': brand,
    };
  }
}
