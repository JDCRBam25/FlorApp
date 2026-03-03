import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:florapp/widgets/product_card.dart';
import 'package:florapp/models/product.dart';

class RecommendedProductsWidget extends StatelessWidget {
  const RecommendedProductsWidget({Key? key}) : super(key: key);

  Product _productFromDoc(Map<String, dynamic> data) {
    return Product(
      productName: data['nombre'] ?? '',
      productImage: data['imagenURL'] ?? '',
      originalPrice: (data['precio'] ?? 0).toDouble(),
      discountedPrice: (data['precio'] ?? 0).toDouble(),
      description: data['descripcion'] ?? '',
    );
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('productos')
          .limit(10)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        }

        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return const Center(child: Text('No se encontraron productos'));
        }

        final products = snapshot.data!.docs
            .map((doc) => _productFromDoc(doc.data()! as Map<String, dynamic>))
            .toList()
          ..shuffle(); // aleatorizar

        return GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          padding: const EdgeInsets.all(12),
          itemCount: products.length,
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            childAspectRatio: 0.7,
          ),
          itemBuilder: (context, index) {
            final product = products[index];
            return ProductCard(
              productName: product.productName,
              productImage: product.productImage,
              originalPrice: product.originalPrice,
              discountedPrice: product.discountedPrice,
              description: product.description,
              initiallyFavorite: false,
              width: double.infinity,
              margin: EdgeInsets.zero,
            );
          },
        );
      },
    );
  }
}
