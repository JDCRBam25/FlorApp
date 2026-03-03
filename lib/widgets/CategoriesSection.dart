import 'package:florapp/screens/AllCategoriesScreen.dart';
import 'package:florapp/screens/CategoryProductsScreen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

final List<Map<String, dynamic>> categories = [
  {
    'name': 'Ramos',
    'svgPath': 'assets/ramos.svg',
    'color': Colors.yellow.shade700,
  },
  {
    'name': 'Artefactos',
    'svgPath': 'assets/artefactos.svg',
    'color': Colors.blue.shade700,
  },
  {
    'name': 'Eventos',
    'svgPath': 'assets/eventos.svg',
    'color': Colors.pink.shade400,
  },
  {
    'name': 'Arreglos',
    'svgPath': 'assets/arreglos.svg',
    'color': Colors.green.shade600,
  },
  {
    'name': 'Carteras',
    'svgPath': 'assets/carteras.svg',
    'color': Colors.orange.shade700,
  },
  {
    'name': 'Personalizados',
    'svgPath': 'assets/personalizados.svg',
    'color': Colors.purple.shade700,
  },
];

Widget categoryHeader(BuildContext context) {
  return Padding(
    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          'Categoría',
          style: TextStyle(
            color: Colors.red.shade900,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        TextButton(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => const AllCategoriesScreen(),
              ),
            );
          },
          child: Text(
            'Ver todo',
            style: TextStyle(color: Colors.red.shade900),
          ),
        ),
      ],
    ),
  );
}


Widget categoryList(BuildContext context) {
  return Padding(
    padding: const EdgeInsets.symmetric(horizontal: 16),
    child: SizedBox(
      height: 100,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: categories.length,
        separatorBuilder: (_, __) => const SizedBox(width: 16),
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
              children: [
                CircleAvatar(
                  radius: 30,
                  backgroundColor: cat['color'],
                  child: SvgPicture.asset(
                    cat['svgPath'],
                    width: 60,
                    height: 60,
                    fit: BoxFit.contain,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  cat['name'] ?? '',
                  style: TextStyle(color: Colors.red.shade900),
                ),
              ],
            ),
          );
        },
      ),
    ),
  );
}
