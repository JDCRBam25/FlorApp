import 'package:florapp/screens/popular_products_screen.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:florapp/widgets/product_card.dart';
import 'package:florapp/models/product.dart';

class PopularProductsWidget extends StatelessWidget {
  const PopularProductsWidget({Key? key}) : super(key: key);

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
    return Padding(
      padding: const EdgeInsets.only(left: 18, right: 6),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Título y botón "Ver más"
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Los más pedidos',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFFA50302),
                ),
              ),
              TextButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const PopularProductsScreen(),
                    ),
                  );
                },

                child: const Text(
                  'Ver más',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFFA50302),
                  ),
                ),
              ),
            ],
          ),

          // 👇 Este es el truco
          Transform.translate(
            offset: const Offset(0, -10), // sube visualmente todo el scroll
            child: SizedBox(
              height: 260,
              child: StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance
                    .collection('productos')
                    .snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (snapshot.hasError) {
                    return Center(child: Text('Error: ${snapshot.error}'));
                  }
                  if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                    return const Center(
                      child: Text('No hay productos populares'),
                    );
                  }

                  final products = snapshot.data!.docs
                      .map(
                        (doc) => _productFromDoc(
                          doc.data()! as Map<String, dynamic>,
                        ),
                      )
                      .toList();

                  final popularProducts = products.take(6).toList();

                  return SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: popularProducts.map((product) {
                        return ProductCard(
                          productName: product.productName,
                          productImage: product.productImage,
                          originalPrice: product.originalPrice,
                          discountedPrice: product.discountedPrice,
                          description: product.description,
                          initiallyFavorite: false,
                          width: 180,
                          margin: const EdgeInsets.only(right: 6),
                        );
                      }).toList(),
                    ),
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}
