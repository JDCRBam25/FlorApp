import 'package:florapp/widgets/popular_products_section.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:florapp/widgets/Ajustes.dart';
import 'package:florapp/widgets/Estado.dart';
import 'package:florapp/widgets/recommended_products_widget.dart';

class ProfileContentWidget extends StatelessWidget {
  final int notificationCount;
  final String countryFlagEmoji;

  const ProfileContentWidget({
    super.key,
    this.notificationCount = 0,
    this.countryFlagEmoji = '🇵🇪',
  });

  Future<String> _getUsername() async {
    final user = FirebaseAuth.instance.currentUser;
    return user?.displayName ?? user?.email ?? 'Usuario';
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<String>(
      future: _getUsername(),
      builder: (context, snapshot) {
        final username = snapshot.data ?? 'Usuario';
        String firstLetter = username.isNotEmpty ? username[0].toUpperCase() : 'U';

        return SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 25),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                child: Row(
                  children: [
                    CircleAvatar(
                      backgroundColor: Colors.green[700],
                      child: Text(firstLetter,
                          style: const TextStyle(color: Colors.white, fontSize: 20)),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        username,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 20,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ),
                    Text(countryFlagEmoji, style: const TextStyle(fontSize: 24)),
                    const SizedBox(width: 12),
                    InkWell(
                      onTap: () {
                        Navigator.push(context,
                            MaterialPageRoute(builder: (_) => SettingsScreen()));
                      },
                      child: const Icon(Icons.settings),
                    ),
                    const SizedBox(width: 12),
                    Stack(
                      children: [
                        const Icon(Icons.notifications),
                        if (notificationCount > 0)
                          Positioned(
                            right: 0,
                            top: 0,
                            child: Container(
                              padding: const EdgeInsets.all(4),
                              decoration: const BoxDecoration(
                                color: Colors.red,
                                shape: BoxShape.circle,
                              ),
                              constraints: const BoxConstraints(
                                  minWidth: 18, minHeight: 18),
                              child: Text(
                                notificationCount.toString(),
                                style: const TextStyle(
                                    color: Colors.white, fontSize: 12),
                                textAlign: TextAlign.center,
                              ),
                            ),
                          ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 8),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: const [
                    Text(
                      'Mis pedidos',
                      style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 15),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      _buildIconText(Icons.credit_card, "Entregado", context),
                      const SizedBox(width: 30),
                      _buildIconText(Icons.inbox, "Pendientes\nde envío", context),
                      const SizedBox(width: 30),
                      _buildIconText(Icons.local_shipping, "Enviado", context),
                      const SizedBox(width: 30),
                      _buildIconText(Icons.assignment_return, "Devoluciones", context),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 15),
              Container(height: 10, color: const Color(0xFFE9E9E9)),
              const SizedBox(height: 3),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      _buildIconText(Icons.chat_bubble_outline, "Añadir\nreseñas", context),
                      const SizedBox(width: 60),
                      _buildIconText(Icons.history, "Historial", context),
                      const SizedBox(width: 60),
                      _buildIconText(Icons.confirmation_num_outlined, "Cupones", context),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 3),
              Container(height: 10, color: const Color(0xFFE9E9E9)),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      _buildIconText(Icons.credit_card, "Tarjetas", context),
                      const SizedBox(width: 20),
                      _buildIconText(Icons.help_outline, "Centro de ayuda", context),
                      const SizedBox(width: 20),
                      _buildIconText(Icons.feedback_outlined, "Sugerencias", context),
                      const SizedBox(width: 15),
                      _buildIconText(Icons.question_answer_outlined, "Preguntas y respuestas", context),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 2),
              Container(height: 10, color: const Color(0xFFE9E9E9)),

              // 📦 Sección: Populares
              const SizedBox(height: 12),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 16),
                child: Text(
                  'Te podría gustar',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                ),
              ),
              const SizedBox(height: 8),
              const PopularProductsWidget(),
              const SizedBox(height: 24),

              // 🎯 Sección: Recomendados
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 16),
                child: Text(
                  'Basado en tus compras',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                ),
              ),
              const SizedBox(height: 8),
              const RecommendedProductsWidget(),
              const SizedBox(height: 24),
            ],
          ),
        );
      },
    );
  }

  static Widget _buildIconText(IconData icon, String label, BuildContext context) {
    return GestureDetector(
      onTap: () {
        if (label.contains("Pendientes\nde envío")) {
          Navigator.push(context,
              MaterialPageRoute(builder: (_) => const PedidosPorEstadoScreen(estado: "Pendiente de envío")));
        } else if (label.contains("Enviado")) {
          Navigator.push(context,
              MaterialPageRoute(builder: (_) => const PedidosPorEstadoScreen(estado: "Enviado")));
        } else if (label.contains("Entregado")) {
          Navigator.push(context,
              MaterialPageRoute(builder: (_) => const PedidosPorEstadoScreen(estado: "Entregado")));
        }
      },
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 28),
          const SizedBox(height: 6),
          Text(label,
              textAlign: TextAlign.center,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 10)),
        ],
      ),
    );
  }
}
