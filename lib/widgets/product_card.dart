import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:florapp/widgets/Detalles.dart';
import 'package:florapp/models/product.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ProductCard extends StatefulWidget {
  final String productName;
  final String productImage;
  final double originalPrice;
  final double discountedPrice;
  final String description;
  final bool initiallyFavorite;
  final double width;
  final EdgeInsetsGeometry margin;

  const ProductCard({
    Key? key,
    required this.productName,
    required this.productImage,
    required this.originalPrice,
    required this.discountedPrice,
    required this.description,
    this.initiallyFavorite = false,
    this.width = 200,
    this.margin = const EdgeInsets.all(8),
  }) : super(key: key);

  @override
  _ProductCardState createState() => _ProductCardState();
}

class _ProductCardState extends State<ProductCard> {
  late bool isFavorite;
  late final Product product;

  @override
  void initState() {
    super.initState();
    product = Product(
      productName: widget.productName,
      productImage: widget.productImage,
      originalPrice: widget.originalPrice,
      discountedPrice: widget.discountedPrice,
      description: widget.description,
    );
    isFavorite = widget.initiallyFavorite;
  }

  Future<void> toggleFavorite() async {
    setState(() => isFavorite = !isFavorite);
    try {
      final userId = FirebaseAuth.instance.currentUser!.uid;
      final favoriteCollection = FirebaseFirestore.instance
          .collection('Usuarios')
          .doc(userId)
          .collection('favorites');

      if (isFavorite) {
        final exists = await favoriteCollection
            .where('productName', isEqualTo: product.productName)
            .limit(1)
            .get();
        if (exists.docs.isEmpty) {
          await favoriteCollection.add({
            'productName': product.productName,
            'productImage': product.productImage,
            'originalPrice': product.originalPrice,
            'discountedPrice': product.discountedPrice,
            'description': product.description,
            'timestamp': FieldValue.serverTimestamp(),
          });
        }
      } else {
        final snapshot = await favoriteCollection
            .where('productName', isEqualTo: product.productName)
            .get();
        for (var doc in snapshot.docs) {
          await doc.reference.delete();
        }
      }
    } catch (e) {
      setState(() => isFavorite = !isFavorite);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Error al actualizar favoritos')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ProductDetailScreen(
              productName: product.productName,
              productImage: product.productImage,
              originalPrice: product.originalPrice,
              discountedPrice: product.discountedPrice,
              description: product.description,
            ),
          ),
        );
      },
      child: Container(
        width: widget.width,
        margin: widget.margin,
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 6,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Stack(
              clipBehavior: Clip.none,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Align(
                      alignment: Alignment.center,
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: widget.productImage.endsWith('.svg')
                            ? SvgPicture.network(
                                widget.productImage,
                                width: 140,
                                height: 120,
                                fit: BoxFit.cover,
                              )
                            : Image.network(
                                widget.productImage,
                                width: 140,
                                height: 120,
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) =>
                                    const Icon(Icons.broken_image),
                              ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      product.productName,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      'Rosas',
                      style: TextStyle(color: Colors.grey, fontSize: 12),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Text(
                          '\$${product.originalPrice}',
                          style: TextStyle(
                            decoration: TextDecoration.lineThrough,
                            color: Colors.grey[600],
                            fontSize: 12,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          '\$${product.discountedPrice}',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                Positioned(
                  top: 0,
                  left: 0,
                  right: 0,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.yellow[700],
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Text(
                          '20% OFF',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                        ),
                      ),
                      GestureDetector(
                        onTap: toggleFavorite,
                        child: Container(
                          padding: const EdgeInsets.all(6),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: const [
                              BoxShadow(
                                color: Colors.black12,
                                blurRadius: 4,
                                offset: Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Icon(
                            isFavorite
                                ? Icons.favorite
                                : Icons.favorite_border,
                            size: 20,
                            color: isFavorite ? Colors.red : Colors.black54,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Positioned(
                  bottom: -8,
                  right: -8,
                  child: Container(
                    margin: const EdgeInsets.only(right: 4, bottom: 4),
                    decoration: const BoxDecoration(
                      color: Colors.black,
                      shape: BoxShape.circle,
                    ),
                    child: IconButton(
                      padding: const EdgeInsets.all(8),
                      iconSize: 20,
                      icon: const Icon(Icons.add, color: Colors.white),
                      onPressed: () async {
                        final userId =
                            FirebaseAuth.instance.currentUser!.uid;

                        await FirebaseFirestore.instance
                            .collection('Usuarios')
                            .doc(userId)
                            .collection('carrito')
                            .add({
                              'productName': product.productName,
                              'productImage': product.productImage,
                              'originalPrice': product.originalPrice,
                              'discountedPrice': product.discountedPrice,
                              'description': product.description,
                              'quantity': 1,
                              'selected': true,
                              'timestamp': FieldValue.serverTimestamp(),
                            });

                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              '${product.productName} añadido al carrito',
                            ),
                          ),
                        );
                      },
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
