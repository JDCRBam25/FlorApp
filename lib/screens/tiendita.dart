import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../widgets/product_card.dart';

class Category {
  final IconData icon;
  final String label;

  const Category({required this.icon, required this.label});
}

class CategoriesCenterText extends StatefulWidget {
  const CategoriesCenterText({super.key});

  @override
  State<CategoriesCenterText> createState() => _CategoriesCenterTextState();
}

class _CategoriesCenterTextState extends State<CategoriesCenterText> {
  int selectedIndex = 0;

  final categories = const [
    Category(icon: Icons.local_offer, label: 'Todas las ofertas'),
    Category(icon: Icons.local_fire_department, label: 'Ofertas del día'),
    Category(icon: Icons.local_grocery_store, label: 'Ramos'),
    Category(icon: Icons.electrical_services, label: 'Artefactos'),
    Category(icon: Icons.event, label: 'Eventos'),
    Category(icon: Icons.account_box, label: 'Arreglos'),
    Category(icon: Icons.wallet_giftcard, label: 'Carteras'),
    Category(icon: Icons.design_services, label: 'Personalizados'),
  ];

  Stream<QuerySnapshot> _getProductsStream(String category) {
    final productos = FirebaseFirestore.instance.collection('productos');

    if (category == 'Todas las ofertas') {
      return productos.snapshots();
    } else if (category == 'Ofertas del día') {
      return productos.where('descuento', isGreaterThan: 0).snapshots();
    } else {
      return productos.where('categoria', isEqualTo: category).snapshots();
    }
  }

  @override
  Widget build(BuildContext context) {
    final currentCategory = categories[selectedIndex].label;

    return Scaffold(
      backgroundColor: const Color(0xFFF4F4F4), // Gris claro de fondo
      body: Padding(
        padding: const EdgeInsets.only(top: 55),
        child: Column(
          children: [
            // Categorías horizontales
            SizedBox(
              height: 150,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 10),
                itemCount: categories.length,
                separatorBuilder: (_, __) => const SizedBox(width: 10),
                itemBuilder: (context, index) {
                  final isSelected = index == selectedIndex;
                  final category = categories[index];

                  return GestureDetector(
                    onTap: () {
                      setState(() {
                        selectedIndex = index;
                      });
                    },
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      transform: Matrix4.identity()..scale(isSelected ? 1.001 : 0.95),
                      width: 120,
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: isSelected ? const Color(0xFFA50302) : Colors.black,
                          width: isSelected ? 2 : 1,
                        ),
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            category.icon,
                            size: 36,
                            color: isSelected ? const Color(0xFFA50302) : Colors.black,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            category.label,
                            style: TextStyle(
                              color: isSelected ? const Color(0xFFA50302) : Colors.black,
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),

            const SizedBox(height: 5),

            // Stream de productos con diseño tipo segundo ejemplo
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream: _getProductsStream(currentCategory),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (snapshot.hasError) {
                    return Center(child: Text('Error: ${snapshot.error}'));
                  }

                  if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                    return const Center(child: Text('No hay productos'));
                  }

                  final products = snapshot.data!.docs;

                  return GridView.builder(
                    padding: const EdgeInsets.all(12),
                    itemCount: products.length,
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      crossAxisSpacing: 12,
                      mainAxisSpacing: 12,
                      childAspectRatio: 0.7, // Más alto
                    ),
                    itemBuilder: (context, index) {
                      final data = products[index].data() as Map<String, dynamic>;
                      return ProductCard(
                        productName: data['nombre'],
                        productImage: data['imagenURL'],
                        originalPrice: (data['precio'] ?? 0).toDouble(),
                        discountedPrice: (data['precio'] ?? 0).toDouble(),
                        description: data['descripcion'],
                        initiallyFavorite: false,
                        width: double.infinity,
                        margin: EdgeInsets.zero,
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
