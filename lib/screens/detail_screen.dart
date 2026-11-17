import 'package:flutter/material.dart';

import '../models/products.dart';
import '../services/api_service.dart';
import '../services/wishlist_service.dart';

// DetailScreen mengambil data lengkap karakter dan menyediakan tombol favorit.
class DetailScreen extends StatefulWidget {
  const DetailScreen({required this.productId, super.key});

  final int productId;

  @override
  State<DetailScreen> createState() => _DetailScreenState();
}

class _DetailScreenState extends State<DetailScreen> {
  Products? _products;
  bool _isWishlist = false;
  bool _isLoading = true;
  String? _errorMessage;

  String? get image => null;

  @override
  void initState() {
    super.initState();
    _loadCharacter();
  }

  // Mengambil informasi terbaru karakter dan status favorit lokalnya.
  Future<void> _loadCharacter() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });
    try {
      final Products = await ApiService.getCharacter(widget.productId);
      final isWishlist = await WishlistService.isWishlist(Products.id);
      if (!mounted) return;
      setState(() {
        _products = Products;
        _isWishlist = isWishlist;
        _isLoading = false;
      });
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _errorMessage = 'Detail tidak dapat dimuat: $error';
        _isLoading = false;
      });
    }
  }

  // Mengubah favorit dan memberi umpan balik melalui Snackbar.
  Future<void> _toggleFavorite() async {
    final Products = _products;
    if (Products == null) return;
    final isAdded = await WishlistService.toggleFavorite(Products);
    if (!mounted) return;
    setState(() => _isWishlist = isAdded);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          isAdded
              ? '${Products.title} ditambahkan ke favorit'
              : '${Products.title} dihapus dari favorit',
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_products?.title ?? 'Detail product'),
        actions: [
          if (_products != null)
            IconButton(
              tooltip: _isWishlist ? 'Hapus favorit' : 'Tambah favorit',
              onPressed: _toggleFavorite,
              icon: Icon(
                _isWishlist ? Icons.favorite : Icons.favorite_border,
                color: _isWishlist ? Colors.red : null,
              ),
            ),
        ],
      ),
      body: _buildBody(),
    );
  }

  // Menampilkan indikator, pesan error, atau informasi karakter lengkap.
  Widget _buildBody() {
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
              onPressed: _loadCharacter,
              child: const Text('Coba Lagi'),
            ),
          ],
        ),
      );
    }

    // ignore: unused_local_variable
    final products = _products;

    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(24),
          child: Image.network(
            image!,
            height: 300,
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) {
              return const SizedBox(
                height: 300,
                child: Center(child: Icon(Icons.person, size: 80)),
              );
            },
          ),
        ),
        const SizedBox(height: 20),
        Text(
          Products.title,
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.headlineSmall
              ?.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        _detailRow('title', Products.title),
        _detailRow('category', Products.category),
        _detailRow('brand', Products.brand),
        _detailRow('price', Products.price),
        _detailRow('rating', Products.rating),
      ],
    );
  }

  // Baris label dan nilai agar informasi detail mudah dibaca.
  Widget _detailRow(String label, String value, [Color? valueColor]) {
    return Card(
      child: ListTile(
        title: Text(label, style: const TextStyle(color: Colors.grey)),
        subtitle: Text(
          value,
          style: TextStyle(
            color: valueColor ?? Theme.of(context).colorScheme.onSurface,
            fontSize: 16,
          ),
        ),
      ),
    );
  }
}
