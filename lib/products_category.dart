import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'widgets/product_card.dart'; // Asegúrate de tener este widget para mostrar los productos

class CategoriesCenterText extends StatefulWidget {
  const CategoriesCenterText({super.key});

  @override
  State<CategoriesCenterText> createState() => _CategoriesCenterTextState();
}

class _CategoriesCenterTextState extends State<CategoriesCenterText> {
  int selectedIndex = 0;

  // Obtener los productos de Firebase
  Future<List<Widget>> _loadProducts(String category) async {
    try {
      // Consulta a Firebase Firestore para obtener los productos de la categoría seleccionada
      QuerySnapshot querySnapshot = await FirebaseFirestore.instance
          .collection('productos')
          .where('categoria', isEqualTo: category) // Filtra por la categoría
          .get();

      // Mapeamos los productos obtenidos y los mostramos como ProductCards
      List<Widget> products = querySnapshot.docs.map((doc) {
        var data = doc.data() as Map<String, dynamic>;
        return ProductCard(
          productName: data['nombre'], // Nombre del producto
          productImage: data['imagenURL'], // Imagen URL del producto
          originalPrice: data['precio'], // Precio original del producto
          discountedPrice: data['precio'], // Aquí puedes aplicar algún descuento si lo deseas
          description: data['descripcion'], // Descripción del producto
        );
      }).toList();

      return products;
    } catch (e) {
      print('Error al cargar productos: $e');
      return []; // En caso de error, devuelve una lista vacía
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 55),
      child: Column(
        children: [
          // Barra de categorías con íconos y texto
          SizedBox(
            height: 150,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 10),
              itemCount: 7, // Número de categorías (ajustar si es necesario)
              separatorBuilder: (_, __) => const SizedBox(width: 10),
              itemBuilder: (context, index) {
                return GestureDetector(
                  onTap: () {
                    setState(() {
                      selectedIndex = index;
                    });
                  },
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    transform: Matrix4.identity()..scale(selectedIndex == index ? 1.001 : 0.95),
                    width: 120,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: selectedIndex == index ? const Color(0xFFA50302) : Colors.black,
                        width: selectedIndex == index ? 2 : 1,
                      ),
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.local_offer, // Cambia el icono según la categoría
                          size: 36,
                          color: selectedIndex == index ? const Color(0xFFA50302) : Colors.black,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Arreglos', // Cambia el texto por la categoría correspondiente
                          style: TextStyle(
                            color: selectedIndex == index ? const Color(0xFFA50302) : Colors.black,
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
          const SizedBox(height: 20),

          // Mostrar los productos de la categoría seleccionada
          Expanded(
            child: FutureBuilder<List<Widget>>(
              future: _loadProducts('Arreglos'), // Pasamos la categoría "Arreglos"
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator()); // Mostramos el indicador de carga
                } else if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}')); // Muestra el error en caso de fallo
                } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return const Center(child: Text('No products available.')); // Si no hay productos, muestra este mensaje
                } else {
                  // Si los productos se cargan correctamente, mostramos el GridView
                  return GridView.count(
                    padding: const EdgeInsets.all(12),
                    crossAxisCount: 2,
                    mainAxisSpacing: 12,
                    crossAxisSpacing: 12,
                    childAspectRatio: 0.7,
                    children: snapshot.data!, // Aquí van los productos que obtuvimos de Firebase
                  );
                }
              },
            ),
          ),
        ],
      ),
    );
  }
}
