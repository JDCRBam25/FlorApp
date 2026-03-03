// centro_ayuda_screen.dart
import 'package:florapp/screens/AyudaEntregaScreen.dart';
import 'package:florapp/screens/AyudaRecojoScreen.dart';
import 'package:flutter/material.dart';

class CentroAyudaScreen extends StatelessWidget {
  const CentroAyudaScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final primary = const Color(0xFFA50302);
    final accent = const Color(0xFFe53935);

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        backgroundColor: primary,
        elevation: 0,
        leading: GestureDetector(
          onTap: () => Navigator.pop(context),
          child: const Center(
            child: Text(
              '<',
              style: TextStyle(
                color: Colors.white,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
        title: const Text(
          "Centro de Ayuda",
          style: TextStyle(color: Colors.white),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          _buildHelpOption(
            context,
            title: "Entrega a domicilio",
            subtitle: "Consultas sobre envíos, estado del pedido, problemas de entrega.",
            icon: Icons.local_shipping,
            color: primary,
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const AyudaEntregaScreen()),
              );
            },
          ),
          const SizedBox(height: 20),
          _buildHelpOption(
            context,
            title: "Recojo en tienda",
            subtitle: "Preguntas sobre ubicaciones, horarios o confirmaciones de recojo.",
            icon: Icons.storefront_rounded,
            color: accent,
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const AyudaRecojoScreen()),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildHelpOption(
    BuildContext context, {
    required String title,
    required String subtitle,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: color.withOpacity(0.2)),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: color.withOpacity(0.1),
              ),
              child: Icon(icon, color: color, size: 28),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: color,
                      )),
                  const SizedBox(height: 6),
                  Text(
                    subtitle,
                    style: const TextStyle(fontSize: 13, color: Colors.black87),
                  ),
                ],
              ),
            ),
            const Icon(Icons.chevron_right, color: Colors.grey),
          ],
        ),
      ),
    );
  }
}
