import 'package:flutter/material.dart';

import 'tiendita.dart';
import 'usuario.dart';
import 'carrito.dart';
import 'casita.dart';
import 'corazoncito.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;

  final List<Widget> _screens = const [
    HomeContentWidget(),
    CategoriesCenterText(),
    FavoritosScreen(),
    CartContentWidget(),
    ProfileContentWidget(),
  ];

  // Cambiar de pantalla al tocar un item en el BottomNavigationBar
  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white, // Fondo blanco
      body: _buildBody(), // Usar la función para el body
      bottomNavigationBar: _buildBottomNavigationBar(), // Usar la función para el BottomNavigationBar
    );
  }

  // Función que construye el AppBar

  // Función que construye el body de la pantalla
  Widget _buildBody() {
    return Container(
      color: Colors.white, // Fondo blanco para el body
      child: _screens[_selectedIndex], // Mostrar el contenido según la pantalla seleccionada
    );
  }

  // Función que construye el BottomNavigationBar
  BottomNavigationBar _buildBottomNavigationBar() {
    return BottomNavigationBar(
      currentIndex: _selectedIndex,
      onTap: _onItemTapped,
      backgroundColor: Colors.red.shade900,
      showSelectedLabels: false,
      showUnselectedLabels: false,
      selectedItemColor: Colors.white,
      unselectedItemColor: Colors.white70,
      type: BottomNavigationBarType.fixed,
      items: const [
        BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Inicio'),
        BottomNavigationBarItem(icon: Icon(Icons.store), label: 'Tienda'),
        BottomNavigationBarItem(
          icon: Icon(Icons.favorite),
          label: 'Favoritos',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.shopping_cart),
          label: 'Carrito',
        ),
        BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Perfil'),
      ],
    );
  }
}
