import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'CategoryProductsScreen.dart';

final List<Map<String, dynamic>> categories = [
  {
    'name': 'Ramos',
    'svgPath': 'assets/ramos.svg',
  },
  {
    'name': 'Artefactos',
    'svgPath': 'assets/artefactos.svg',
  },
  {
    'name': 'Eventos',
    'svgPath': 'assets/eventos.svg',
  },
  {
    'name': 'Arreglos',
    'svgPath': 'assets/arreglos.svg',
  },
  {
    'name': 'Carteras',
    'svgPath': 'assets/carteras.svg',
  },
  {
    'name': 'Personalizados',
    'svgPath': 'assets/personalizados.svg',
  },
];

class AllCategoriesScreen extends StatelessWidget {
  const AllCategoriesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(55),
        child: AppBar(
          backgroundColor: const Color(0xFFA50302),
          elevation: 3,
          automaticallyImplyLeading: false,
          title: Row(
            children: [
              GestureDetector(
                onTap: () => Navigator.pop(context),
                child: const Text(
                  '<',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              const Text(
                'Todas las categorías',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: GridView.builder(
          itemCount: categories.length,
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 20,
            mainAxisSpacing: 20,
            childAspectRatio: 0.8,
          ),
          itemBuilder: (context, index) {
            final cat = categories[index];
            return GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) =>
                        CategoryProductsScreen(categoryName: cat['name']),
                  ),
                );
              },
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 150,
                    height: 150,
                    padding: const EdgeInsets.all(14),
                    child: SvgPicture.asset(
                      cat['svgPath'],
                      fit: BoxFit.contain,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    cat['name'],
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFFA50302),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
