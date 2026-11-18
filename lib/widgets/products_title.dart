import 'package:flutter/material.dart';

import '../models/products.dart';

// Product card reused by the catalog and wishlist.
class ProductsTitle extends StatelessWidget {
  const ProductsTitle({
    required this.products,
    required this.isWishlist,
    required this.onWishlistPressed,
    required this.onTap,
    super.key,
  });

  final Products products;
  final bool isWishlist;
  final VoidCallback onWishlistPressed;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        leading: ClipRRect(
          borderRadius: BorderRadius.circular(28),
          child: Image.network(
            products.image,
            width: 56,
            height: 56,
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) {
              return const SizedBox(
                width: 56,
                height: 56,
                child: CircleAvatar(child: Icon(Icons.shopping_bag_outlined)),
              );
            },
          ),
        ),
        title: Text(
          products.title,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
        subtitle: Text(
          '${products.category.replaceAll('-', ' ')} · '
          '\$${products.price.toStringAsFixed(2)}',
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        trailing: IconButton(
          tooltip: isWishlist ? 'Hapus Wishlist' : 'Tambah Wishlist',
          onPressed: onWishlistPressed,
          icon: Icon(
            isWishlist ? Icons.favorite : Icons.favorite_border,
            color: isWishlist ? Colors.green : null,
          ),
        ),
        onTap: onTap,
      ),
    );
  }
}
