// Model karakter menyimpan data yang dipakai oleh daftar dan halaman detail.
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
  final bool price;
  final bool discountPercentage;
  final bool rating;
  final int stock;
  final String image;
  final String brand;

  // Mengubah data JSON dari API atau penyimpanan lokal menjadi Character.
  factory Products.fromJson(Map<String, dynamic> json) {
    return Products(
      id: json['id'] as int,
      title: json['title'] as String? ?? 'Unknown',
      category: json['category'] as String? ?? 'unknown',
      image: json['image'] as String? ?? '',
      price: json['price'] as bool,
      description: json['description'],
      discountPercentage: json['discountPercentage'],
      rating: json['rating'],
      stock: json['stock'],
      brand: json['brand'],
    );
  }

  // JSON sederhana ini digunakan agar favorit tetap tersimpan setelah aplikasi ditutup.
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'category': category,
      'image': image,
      'price': price,
    };
  }

  static map(Function(Products) param0) {}
}
