import 'package:flutter/material.dart';
import 'package:shoppinghub/widgets/products_title.dart';

import '../models/products.dart';
import '../services/wishlist_service.dart';
import 'detail_screen.dart';

// Daftar ini membaca favorit persisten dan menyegarkannya saat tab dipilih.
class WishlistScreen extends StatefulWidget {
  const WishlistScreen({required this.refreshKey, super.key});

  final int refreshKey;

  @override
  State<WishlistScreen> createState() => _WishlistScreenState();
}

class _WishlistScreenState extends State<WishlistScreen> {
  List<Products> _wishlist = [];
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadFavorites();
  }

  @override
  void didUpdateWidget(covariant WishlistScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.refreshKey != widget.refreshKey) {
      // Pemuatan ulang saat tab berpindah menyinkronkan perubahan dari layar lain.
      _loadFavorites();
    }
  }

  Future<void> _loadFavorites() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });
    try {
      final wishlist = await WishlistService.getWishlist();
      if (!mounted) return;
      setState(() {
        _wishlist = wishlist;
        _isLoading = false;
      });
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _errorMessage = 'Wishlist tidak dapat dimuat: $error';
        _isLoading = false;
      });
    }
  }

  // Menghapus kartu yang digeser dan menyimpan perubahan secara permanen.
  Future<void> _removeWishlist(Products products) async {
    try {
      await WishlistService.removeWishlist(products.id);
      if (!mounted) return;
      setState(() {
        _wishlist.removeWhere((wishlist) => wishlist.id == products.id);
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${products.title} dihapus dari favorit'),
          backgroundColor: Colors.red.shade700,
        ),
      );
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Produk tidak dapat dihapus: $error'),
          backgroundColor: Colors.red.shade700,
        ),
      );
      await _loadFavorites();
    }
  }

  // Membuka detail dan menyegarkan isi tab setelah layar detail ditutup.
  Future<void> _openDetail(Products products) async {
    await Navigator.push(
      context,
      MaterialPageRoute<void>(
        builder: (_) => DetailScreen(productId: products.id),
      ),
    );
    await _loadFavorites();
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (_errorMessage != null) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.all(20),
              child: Text(_errorMessage!, textAlign: TextAlign.center),
            ),
            FilledButton(
              onPressed: _loadFavorites,
              child: const Text('Coba Lagi'),
            ),
          ],
        ),
      );
    }
    if (_wishlist.isEmpty) {
      return const Center(child: Text('Belum ada product favorit'));
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(vertical: 8),
      itemCount: _wishlist.length,
      itemBuilder: (context, index) {
        final product = _wishlist[index];
        return Dismissible(
          key: ValueKey(product.id),
          direction: DismissDirection.endToStart,
          background: Container(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
            padding: const EdgeInsets.only(right: 24),
            alignment: Alignment.centerRight,
            decoration: BoxDecoration(
              color: Colors.red.shade400,
              borderRadius: BorderRadius.circular(18),
            ),
            child: const Icon(Icons.delete_outline, color: Colors.white),
          ),
          onDismissed: (_) => _removeWishlist(product),
          child: ProductsTitle(
            products: product,
            isWishlist: true,
            onWishlistPressed: () => _removeWishlist(product),
            onTap: () => _openDetail(product),
          ),
        );
      },
    );
  }
}
