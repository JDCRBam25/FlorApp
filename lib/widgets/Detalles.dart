import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:share_plus/share_plus.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ProductDetailScreen extends StatefulWidget {
  final String productName;
  final String productImage;
  final double originalPrice;
  final double discountedPrice;
  final String description;
  final double rating;
  final int reviewsCount;

  const ProductDetailScreen({
    super.key,
    required this.productName,
    required this.productImage,
    required this.originalPrice,
    required this.discountedPrice,
    required this.description,
    this.rating = 4.5,
    this.reviewsCount = 24,
  });

  @override
  State<ProductDetailScreen> createState() => _ProductDetailScreenState();
}

class _ProductDetailScreenState extends State<ProductDetailScreen> {
  int quantity = 1;
  bool isFavorite = false;
  static const Color primaryRed = Color(0xFFa50302);

  @override
  void initState() {
    super.initState();
    _checkIfFavorite();
  }

  Future<void> _checkIfFavorite() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;
    final snapshot = await FirebaseFirestore.instance
        .collection('Usuarios')
        .doc(user.uid)
        .collection('favorites')
        .where('productName', isEqualTo: widget.productName)
        .limit(1)
        .get();
    if (snapshot.docs.isNotEmpty) {
      setState(() => isFavorite = true);
    }
  }

  Future<void> _toggleFavorite() async {
    setState(() => isFavorite = !isFavorite);
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;
    final ref = FirebaseFirestore.instance
        .collection('Usuarios')
        .doc(user.uid)
        .collection('favorites');

    if (isFavorite) {
      final exists = await ref
          .where('productName', isEqualTo: widget.productName)
          .limit(1)
          .get();
      if (exists.docs.isEmpty) {
        await ref.add({
          'productName': widget.productName,
          'productImage': widget.productImage,
          'originalPrice': widget.originalPrice,
          'discountedPrice': widget.discountedPrice,
          'description': widget.description,
          'timestamp': FieldValue.serverTimestamp(),
        });
      }
    } else {
      final docs = await ref
          .where('productName', isEqualTo: widget.productName)
          .get();
      for (var doc in docs.docs) {
        await doc.reference.delete();
      }
    }
  }

  Future<void> _addToCart() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;
    await FirebaseFirestore.instance
        .collection('Usuarios')
        .doc(user.uid)
        .collection('carrito')
        .add({
          'productName': widget.productName,
          'productImage': widget.productImage,
          'originalPrice': widget.originalPrice,
          'discountedPrice': widget.discountedPrice,
          'description': widget.description,
          'quantity': quantity,
          'selected': true,
          'timestamp': FieldValue.serverTimestamp(),
        });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${widget.productName} (x$quantity) añadido al carrito'),
      ),
    );
  }

  void _buyNow() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Función "Comprar ahora" aún no implementada'),
        duration: Duration(seconds: 2),
      ),
    );
  }

  Widget _buildProductImage(String url) {
    final size = MediaQuery.of(context).size.width * 0.8;
    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: url.endsWith('.svg')
          ? SvgPicture.network(url, width: size, height: 250, fit: BoxFit.cover)
          : Image.network(url, width: size, height: 250, fit: BoxFit.cover),
    );
  }

  @override
  Widget build(BuildContext context) {
    final discount = ((widget.originalPrice - widget.discountedPrice) /
            widget.originalPrice *
            100)
        .round();

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        titleSpacing: 0,
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.black),
          onPressed: () => Navigator.of(context).pop(),
        ),
        actions: [
          IconButton(
            icon: Icon(
              isFavorite ? Icons.favorite : Icons.favorite_border,
              color: primaryRed,
            ),
            onPressed: _toggleFavorite,
          ),
          IconButton(
            icon: const Icon(Icons.share, color: primaryRed),
            onPressed: () {
              Share.share(
                'Mira este producto: ${widget.productName} por \$${widget.discountedPrice}',
              );
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        physics: const BouncingScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (widget.discountedPrice < widget.originalPrice)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: primaryRed,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  '$discount% OFF',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                    fontSize: 12,
                  ),
                ),
              ),
            const SizedBox(height: 16),
            Center(
              child: Hero(
                tag: widget.productName,
                child: _buildProductImage(widget.productImage),
              ),
            ),
            const SizedBox(height: 24),
            Text(
              widget.productName,
              style: const TextStyle(fontSize: 26, fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 6),
            Row(
              children: [
                const Icon(Icons.star, color: Colors.amber, size: 20),
                const SizedBox(width: 4),
                Text('${widget.rating}', style: const TextStyle(fontWeight: FontWeight.w600)),
                Text(' (${widget.reviewsCount})', style: const TextStyle(color: Colors.grey)),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                if (widget.discountedPrice < widget.originalPrice)
                  Text(
                    '\$${widget.originalPrice.toStringAsFixed(2)}',
                    style: const TextStyle(
                      decoration: TextDecoration.lineThrough,
                      color: Colors.grey,
                      fontSize: 16,
                    ),
                  ),
                const SizedBox(width: 8),
                Text(
                  '\$${widget.discountedPrice.toStringAsFixed(2)}',
                  style: const TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            const Text('Descripción',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Colors.black87)),
            const SizedBox(height: 8),
            Text(
              widget.description,
              style: const TextStyle(fontSize: 16, height: 1.5, color: Colors.grey),
            ),
            const SizedBox(height: 28),
            const Text('Cantidad',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Colors.black87)),
            const SizedBox(height: 10),
            Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.remove),
                  onPressed: () => setState(() {
                    if (quantity > 1) quantity--;
                  }),
                ),
                Text('$quantity', style: const TextStyle(fontSize: 16)),
                IconButton(
                  icon: const Icon(Icons.add),
                  onPressed: () => setState(() => quantity++),
                ),
              ],
            ),
            const SizedBox(height: 32),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: _buyNow,
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      side: const BorderSide(color: primaryRed),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: const Text(
                      'Comprar ahora',
                      style: TextStyle(color: primaryRed),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: ElevatedButton(
                    onPressed: _addToCart,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: primaryRed,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: const Text(
                      'Añadir al carrito',
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
