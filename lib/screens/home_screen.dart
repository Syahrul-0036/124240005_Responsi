import 'package:flutter/material.dart';
import 'package:shoppinghub/widgets/products_title.dart';

import '../models/products.dart';
import '../services/api_service.dart';
import '../services/wishlist_service.dart';
import 'detail_screen.dart';

// Home displays searchable products and their favorite controls.
class HomeScreen extends StatefulWidget {
  const HomeScreen({required this.refreshKey, super.key});

  final int refreshKey;

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _searchController = TextEditingController();
  List<Products> _products = [];
  List<String> _categories = [];
  Set<int> _wishlistIds = {};
  String? _selectedCategory;
  bool _isLoading = true;
  bool _isLoadingCategories = true;
  String? _errorMessage;
  String? _categoryError;

  @override
  void initState() {
    super.initState();
    _loadProducts();
    _loadCategories();
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

  Future<void> _loadProducts() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });
    try {
      final products = await ApiService.getProducts(
        query: _searchController.text,
        category: _selectedCategory,
      );
      if (!mounted) return;
      setState(() {
        _products = products;
        _isLoading = false;
      });
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _errorMessage = 'Tidak dapat memuat produk: $error';
        _isLoading = false;
      });
    }
  }

  Future<void> _loadCategories() async {
    setState(() {
      _isLoadingCategories = true;
      _categoryError = null;
    });
    try {
      final categories = await ApiService.getCategories();
      if (!mounted) return;
      setState(() {
        _categories = categories;
        _isLoadingCategories = false;
      });
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _categoryError = 'Kategori tidak dapat dimuat: $error';
        _isLoadingCategories = false;
      });
    }
  }

  Future<void> _loadWishlist() async {
    try {
      final wishlist = await WishlistService.getWishlist();
      if (!mounted) return;
      setState(() {
        _wishlistIds = wishlist.map((product) => product.id).toSet();
      });
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Wishlist tidak dapat dimuat: $error'),
          backgroundColor: Colors.red.shade700,
        ),
      );
    }
  }

  Future<void> _toggleWishlist(Products products) async {
    final bool isAdded;
    try {
      isAdded = await WishlistService.toggleWishlist(products);
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Wishlist tidak dapat diperbarui: $error'),
          backgroundColor: Colors.red.shade700,
        ),
      );
      return;
    }
    if (!mounted) return;
    setState(() {
      if (isAdded) {
        _wishlistIds.add(products.id);
      } else {
        _wishlistIds.remove(products.id);
      }
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          isAdded
              ? '${products.title} ditambahkan ke favorit'
              : '${products.title} dihapus dari favorit',
        ),
        backgroundColor: isAdded ? Colors.green.shade700 : Colors.red.shade700,
      ),
    );
  }

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
        _buildCategoryFilter(),
        const SizedBox(height: 8),
        Expanded(child: _buildCharacterList()),
      ],
    );
  }

  Widget _buildCategoryFilter() {
    if (_isLoadingCategories) {
      return const SizedBox(
        height: 46,
        child: Center(child: CircularProgressIndicator(strokeWidth: 2)),
      );
    }
    if (_categoryError != null) {
      return SizedBox(
        height: 46,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Flexible(
              child: Text(
                _categoryError!,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            TextButton(
              onPressed: _loadCategories,
              child: const Text('Coba lagi'),
            ),
          ],
        ),
      );
    }

    return SizedBox(
      height: 46,
      child: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 12),
        scrollDirection: Axis.horizontal,
        children: [
          _categoryChip(null, 'Semua'),
          for (final category in _categories)
            _categoryChip(category, category.replaceAll('-', ' ')),
        ],
      ),
    );
  }

  Widget _categoryChip(String? category, String label) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: ChoiceChip(
        label: Text(label),
        selected: _selectedCategory == category,
        onSelected: (_) {
          setState(() => _selectedCategory = category);
          _loadProducts();
        },
      ),
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
        final product = _products[index];
        return ProductsTitle(
          products: product,
          isWishlist: _wishlistIds.contains(product.id),
          onWishlistPressed: () => _toggleWishlist(product),
          onTap: () => _openDetail(product),
        );
      },
    );
  }
}
