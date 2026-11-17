import 'package:flutter/material.dart';
import 'package:shoppinghub/widgets/products_title.dart';

import '../models/products.dart';
import '../services/api_service.dart';
import '../services/wishlist_service.dart';
// ignore: unused_import
import '../widgets/products_tile.dart';
import 'detail_screen.dart';

// Home menampilkan karakter API dengan filter, pencarian, dan kontrol favorit.
class HomeScreen extends StatefulWidget {
  const HomeScreen({required this.refreshKey, super.key});

  final int refreshKey;

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _searchController = TextEditingController();
  List<Products> _products = [];
  Set<int> _wishlistIds = {};
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadProducts();
    _loadWishlist();
  }

  @override
  void didUpdateWidget(covariant HomeScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.refreshKey != widget.refreshKey) {
      // Membaca ulang favorit saat tab berubah agar perubahan layar lain langsung tampak.
      _loadWishlist();
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  // Meminta data karakter sesuai status dan teks pencarian yang sedang dipilih.
  Future<void> _loadProducts() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });
    try {
      final Products = await ApiService.getCharacters(
        title: _searchController.text,
      );
      if (!mounted) return;
      setState(() {
        _products = Products;
        _isLoading = false;
      });
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _errorMessage = 'Tidak dapat memuat karakter: $error';
        _isLoading = false;
      });
    }
  }

  // Memuat id favorit lokal agar ikon semua kartu bisa diperbarui.
  Future<void> _loadWishlist() async {
    final wishlist = await WishlistService.getWishlist();
    if (!mounted) return;
    setState(() {
      _wishlistIds = wishlist.map((Products) => Products.id).toSet();
    });
  }

  // Menyimpan perubahan favorit lalu memperbarui ikon kartu.
  Future<void> _toggleWishlist(Products products) async {
    final isAdded = await WishlistService.toggleWishlist(products);
    if (!mounted) return;
    setState(() {
      if (isAdded != null) {
        _wishlistIds.add(products.id);
      } else {
        _wishlistIds.remove(products.id);
      }
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          isAdded != null
              ? '${products.title} ditambahkan ke favorit'
              : '${products.title} dihapus dari favorit',
        ),
      ),
    );
  }

  // Menunggu detail ditutup, lalu memuat ulang favorit dari SharedPreferences.
  Future<void> _openDetail(Products products) async {
    await Navigator.push(
      context,
      MaterialPageRoute<void>(
        builder: (_) => DetailScreen(productId: products.id),
      ),
    );
    await _loadWishlist();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
          child: TextField(
            controller: _searchController,
            textInputAction: TextInputAction.search,
            onSubmitted: (_) => _loadProducts(),
            decoration: InputDecoration(
              hintText: 'Cari nama product',
              prefixIcon: const Icon(Icons.search),
              suffixIcon: IconButton(
                tooltip: 'Cari',
                onPressed: _loadProducts,
                icon: const Icon(Icons.arrow_forward),
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
          ),
        ),
        SizedBox(
          height: 46,
          child: ListView(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            scrollDirection: Axis.horizontal,
          ),
        ),
        const SizedBox(height: 8),
        Expanded(child: _buildCharacterList()),
      ],
    );
  }

  // Menangani status memuat, error, hasil kosong, dan daftar karakter.
  Widget _buildCharacterList() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (_errorMessage != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(_errorMessage!, textAlign: TextAlign.center),
              const SizedBox(height: 12),
              FilledButton(
                onPressed: _loadProducts,
                child: const Text('Coba Lagi'),
              ),
            ],
          ),
        ),
      );
    }
    if (_products.isEmpty) {
      return const Center(child: Text('Product tidak ditemukan'));
    }

    return ListView.builder(
      itemCount: _products.length,
      itemBuilder: (context, index) {
        final Products = _products[index];
        return ProductsTitle(
          products: Products,
          isWishlist: _wishlistIds.contains(Products.id),
          onWishlistPressed: () => _toggleWishlist(Products),
          onTap: () => _openDetail(Products),
        );
      },
    );
  }
}
