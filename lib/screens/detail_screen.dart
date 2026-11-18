import 'package:flutter/material.dart';

import '../models/products.dart';
import '../services/api_service.dart';
import '../services/wishlist_service.dart';

// Loads product details and provides a favorite toggle.
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

  @override
  void initState() {
    super.initState();
    _loadProduct();
  }

  Future<void> _loadProduct() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });
    try {
      final product = await ApiService.getProduct(widget.productId);
      final isWishlist = await WishlistService.isWishlist(product.id);
      if (!mounted) return;
      setState(() {
        _products = product;
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

  Future<void> _toggleFavorite() async {
    final product = _products;
    if (product == null) return;
    final bool isAdded;
    try {
      isAdded = await WishlistService.toggleFavorite(product);
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
    setState(() => _isWishlist = isAdded);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: isAdded ? Colors.green.shade700 : Colors.red.shade700,
        content: Text(
          isAdded
              ? '${product.title} ditambahkan ke favorit'
              : '${product.title} dihapus dari favorit',
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
                color: _isWishlist ? Colors.green : null,
              ),
            ),
        ],
      ),
      body: _buildBody(),
    );
  }

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
              onPressed: _loadProduct,
              child: const Text('Coba Lagi'),
            ),
          ],
        ),
      );
    }

    final product = _products;
    if (product == null) {
      return const Center(child: Text('Detail produk tidak tersedia.'));
    }

    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(24),
          child: Image.network(
            product.image,
            height: 300,
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) {
              return const SizedBox(
                height: 300,
                child: Center(
                  child: Icon(Icons.shopping_bag_outlined, size: 80),
                ),
              );
            },
          ),
        ),
        const SizedBox(height: 20),
        Text(
          product.title,
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.headlineSmall
              ?.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        _detailRow('Category', product.category),
        if (product.brand.isNotEmpty && product.brand != 'Unknown')
          _detailRow('Brand', product.brand),
        _detailRow('Price', '\$${product.price.toStringAsFixed(2)}'),
        _detailRow('Rating', product.rating.toStringAsFixed(1)),
        _detailRow('Description', product.description),
        _detailRow(
          'Discount',
          '${product.discountPercentage.toStringAsFixed(2)}%',
        ),
        _detailRow('Stock', '${product.stock} items'),
      ],
    );
  }

  Widget _detailRow(String label, String value) {
    return Card(
      child: ListTile(
        title: Text(label, style: const TextStyle(color: Colors.grey)),
        subtitle: Text(
          value,
          style: TextStyle(
            color: Theme.of(context).colorScheme.onSurface,
            fontSize: 16,
          ),
        ),
      ),
    );
  }
}
