import 'package:flutter/material.dart';
import 'package:shoppinghub/widgets/products_title.dart';

import '../models/products.dart';
import '../services/wishlist_service.dart';
// ignore: unused_import
import '../widgets/products_tile.dart';
import 'detail_screen.dart';

// Daftar ini membaca favorit persisten dan menyegarkannya saat tab dipilih.
class WishlistScreen extends StatefulWidget {
  const WishlistScreen({required this.refreshKey, super.key});

  final int refreshKey;

  @override
  State<WishlistScreen> createState() => _WishlistScreenState();
}

class _WishlistScreenState extends State<WishlistScreen> {
  List<Products> _Wishlist = [];
  bool _isLoading = true;

  List<Products>? get wislist => null;

  @override
  void initState() {
    super.initState();
    _loadWishlist();
  }

  @override
  void didUpdateWidget(covariant WishlistScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.refreshKey != widget.refreshKey) {
      // Pemuatan ulang saat tab berpindah menyinkronkan perubahan dari layar lain.
      _loadWishlist();
    }
  }

  // Membaca daftar favorit terbaru dari SharedPreferences.
  Future<void> _loadFavorites() async {
    setState(() => _isLoading = true);
    final wishlist = await WishlistService.getWishlist();
    if (!mounted) return;
    setState(() {
      _Wishlist = wishlist;
      _isLoading = false;
    });
  }

  // Menghapus kartu yang digeser dan menyimpan perubahan secara permanen.
  Future<void> _removeWishlist(Products products) async {
    await WishlistService.removeWishlist(products.id);
    if (!mounted) return;
    setState(() {
      _Wishlist.removeWhere((wishlist) => wishlist.id == products.id);
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('${products.title} dihapus dari favorit')),
    );
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
    if (_Wishlist.isEmpty) {
      return const Center(child: Text('Belum ada product favorit'));
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(vertical: 8),
      itemCount: _Wishlist.length,
      itemBuilder: (context, index) {
        final Products = _Wishlist[index];
        return Dismissible(
          key: ValueKey(Products.id),
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
          onDismissed: (_) => _removeWishlist(Products),
          child: ProductsTitle(
            products: Products,
            isWishlist: true,
            onWishlistPressed: () => _removeWishlist(Products),
            onTap: () => _openDetail(Products),
          ),
        );
      },
    );
  }
}

extension on _WishlistScreenState {
  void _loadWishlist() {}
}
