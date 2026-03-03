import 'package:florapp/screens/SearchWithResultsScreen.dart';
import 'package:florapp/widgets/popular_products_section.dart';
import 'package:florapp/widgets/search_filter_bar.dart';
import 'package:flutter/material.dart';
import '../widgets/OfferCarousel.dart'; // Carrusel de ofertas
import '../widgets/CategoriesSection.dart'; // Sección de categorías
import 'package:flutter_svg/flutter_svg.dart'; // Asegúrate de tener este import para usar SVG

class HomeContentWidget extends StatefulWidget {
  const HomeContentWidget({super.key});

  @override
  State<HomeContentWidget> createState() => _HomeContentWidgetState();
}

class _HomeContentWidgetState extends State<HomeContentWidget> {
  String _searchText = '';
  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        children: [
          // SECCIÓN 0: AppBar
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment
                  .spaceBetween, // Coloca el logo a la izquierda y el ícono a la derecha
              children: [
                // Espaciado antes del logo
                const SizedBox(width: 16),

                // Logo centrado
                Expanded(
                  child: Center(
                    child: SvgPicture.asset(
                      'assets/logo2.svg',
                      width: 210,
                      height: 150,
                    ),
                  ),
                ),

                // Ícono de notificación al final (derecha)
                IconButton(
                  icon: const Icon(Icons.notifications, color: Colors.red),
                  onPressed: () {},
                ),
              ],
            ),
          ),

          // SECCIÓN 1: Barra de búsqueda inline con overlay
          SearchWithHistoryInline(
            onSearchSelected: (term) {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => SearchWithResultsScreen(initialQuery: term),
                ),
              );
            },
          ),

          // SECCIÓN 2: Carrusel de ofertas
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 0, vertical: 0),
            child: SizedBox(
              width: MediaQuery.of(context).size.width * 1,
              child: OfferCarousel(),
            ),
          ),

          // SECCIÓN 3: Categorías y productos populares
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 0, vertical: 0),
            child: Column(
              children: [
                categoryHeader(context),
                categoryList(context), // <-- pasa el context aquí
              ],
            ),
          ),

          // SECCIÓN 4: Los más pedidos
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 0, vertical: 0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [PopularProductsWidget()],
            ),
          ),
        ],
      ),
    );
  }
}
