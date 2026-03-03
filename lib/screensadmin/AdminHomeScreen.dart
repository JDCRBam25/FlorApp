import 'package:florapp/admin/admin_users.dart';
import 'package:florapp/screensadmin/sugerenciasadmin_screen.dart';
import 'package:florapp/screensadmin/AdminPedidosScreen.dart';
import 'package:florapp/screensadmin/AdminSettingsScreen.dart';
import 'package:florapp/screensadmin/resenasscreen.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'loginscreen.dart';
import 'admin_products_screen.dart';

class AdminHomeScreen extends StatelessWidget {
  const AdminHomeScreen({Key? key}) : super(key: key);

  Future<void> _signOut(BuildContext context) async {
    await FirebaseAuth.instance.signOut();
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const LoginScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    final List<_AdminCardItem> items = [
      _AdminCardItem(
        icon: Icons.local_florist,
        label: 'Productos',
        color: const Color(0xFFE79090),
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const AdminProductsScreen()),
        ),
      ),
      _AdminCardItem(
        icon: Icons.people,
        label: 'Usuarios',
        color: const Color(0xFFE79090),
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const AdminUsersScreen()),
        ),
      ),
      _AdminCardItem(
        icon: Icons.offline_pin_rounded,
        label: 'Pedidos',
        color: const Color(0xFFE79090),
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const AdminPedidosScreen()),
        ),
      ),
      _AdminCardItem(
        icon: Icons.real_estate_agent_outlined,
        label: 'Reseñas',
        color: const Color(0xFFE79090),
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const ResenasScreen()),
        ),
      ),
      _AdminCardItem(
        icon: Icons.bus_alert,
        label: 'Sugerencias',
        color: const Color(0xFFE79090),
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const SugerenciasScreen()),
        ),
      ),
      _AdminCardItem(
        icon: Icons.settings,
        label: 'Configuración',
        color: const Color(0xFFE79090),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const AdminSettingsScreen()),
          );
        },
      ),
    ];

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: const Color(0xFFAC0A0A),
        iconTheme: const IconThemeData(color: Colors.white),
        title: const Text(
          'Panel de Administrador',
          style: TextStyle(color: Colors.white),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () => _signOut(context),
            tooltip: 'Cerrar sesión',
          ),
        ],
      ),

      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: GridView.count(
          crossAxisCount: 2,
          mainAxisSpacing: 20,
          crossAxisSpacing: 20,
          childAspectRatio: 1,
          children: items.map((item) => _buildAdminTile(item)).toList(),
        ),
      ),
    );
  }

  Widget _buildAdminTile(_AdminCardItem item) {
    return GestureDetector(
      onTap: item.onTap,
      child: Container(
        decoration: BoxDecoration(
          color: item.color,
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(30),
            bottomRight: Radius.circular(30),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 8,
              offset: const Offset(2, 4),
            ),
          ],
        ),
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(item.icon, size: 50, color: Colors.white),
              const SizedBox(height: 10),
              Text(
                item.label,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _AdminCardItem {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  _AdminCardItem({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });
}
