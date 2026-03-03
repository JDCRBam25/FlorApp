import 'package:florapp/screens/a%C3%B1adir_rese%C3%B1as_screen.dart';
import 'package:florapp/screens/centro_ayuda_screen.dart';
import 'package:florapp/screens/cupones_screen.dart';
import 'package:florapp/screens/preguntas_respuestas_screen.dart';
import 'package:florapp/screens/sugerencias_screen.dart';
import 'package:florapp/screensadmin/tarjetas_screen.dart';
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
    return Scaffold(
      backgroundColor: Colors.grey[100],
      body: SafeArea(
        child: FutureBuilder<String>(
          future: _getUsername(),
          builder: (context, snapshot) {
            final username = snapshot.data ?? 'Usuario';
            final firstLetter = username.isNotEmpty
                ? username[0].toUpperCase()
                : 'U';

            return SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 🔹 ENCABEZADO VISUAL
                  Container(
                    height: 180,
                    width: double.infinity,
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        colors: [Color(0xFFA50302), Color(0xFFe53935)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        CircleAvatar(
                          radius: 30,
                          backgroundColor: Colors.white,
                          child: Text(
                            firstLetter,
                            style: const TextStyle(
                              color: Colors.red,
                              fontSize: 24,
                            ),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          username,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          countryFlagEmoji,
                          style: const TextStyle(fontSize: 24),
                        ),
                      ],
                    ),
                  ),

                  // 🔹 BOTONES SUPERIORES (AJUSTES Y NOTIFICACIONES)
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.end,

                      children: [
                        Text(
                          "Mis pedidos",
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                            
                          ),
                        ),const SizedBox(width: 179),
                        InkWell(
                          onTap: () => Navigator.push(
                            context,
                            MaterialPageRoute(builder: (_) => SettingsScreen()),
                          ),
                          child: const Icon(
                            Icons.settings,
                            color: Colors.black87,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Stack(
                          children: [
                            const Icon(
                              Icons.notifications_none_rounded,
                              size: 28,
                            ),
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
                                    minWidth: 18,
                                    minHeight: 18,
                                  ),
                                  child: Text(
                                    notificationCount.toString(),
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 12,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  _cardSection([
                    _buildIconText(Icons.credit_card, "Entregado", context),
                    _buildIconText(
                      Icons.inbox,
                      "Pendientes\nde envío",
                      context,
                    ),
                    _buildIconText(Icons.local_shipping, "Enviado", context),
                    _buildIconText(
                      Icons.assignment_return,
                      "Devoluciones",
                      context,
                    ),
                  ]),

                  // 🔹 ACCESOS RÁPIDOS
                  _sectionTitle("Accesos rápidos"),
                  _cardSection([
                    _buildIconText(
                      Icons.chat_bubble_outline,
                      "Añadir\nreseñas",
                      context,
                    ),
                    _buildIconText(Icons.credit_card, "Tarjetas", context),
                    _buildIconText(
                      Icons.confirmation_num_outlined,
                      "Cupones",
                      context,
                    ),
                  ]),

                  // 🔹 SOPORTE Y MÁS
                  _sectionTitle("Soporte y cuenta"),
                  _cardSection([
                    _buildIconText(
                      Icons.help_outline,
                      "Centro de ayuda",
                      context,
                    ),
                    _buildIconText(
                      Icons.feedback_outlined,
                      "Sugerencias",
                      context,
                    ),
                    _buildIconText(
                      Icons.question_answer_outlined,
                      "Preguntas y respuestas",
                      context,
                    ),
                  ]),

                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
                    child: Text(
                      'Basado en tus compras',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),
                  ),
                  const SizedBox(height: 4), // mínimo espacio
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 12),
                    child: RecommendedProductsWidget(),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _sectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: Text(
        title,
        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
      ),
    );
  }

  Widget _cardSection(List<Widget> items) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 5,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: List.generate(items.length * 2 - 1, (i) {
              if (i.isEven) return items[i ~/ 2];
              return const SizedBox(width: 30);
            }),
          ),
        ),
      ),
    );
  }

  Widget _buildIconText(IconData icon, String label, BuildContext context) {
    return GestureDetector(
      onTap: () {
        if (label.contains("Pendientes\nde envío")) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) =>
                  const PedidosPorEstadoScreen(estado: "Pendiente de envío"),
            ),
          );
        } else if (label.contains("Enviado")) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) =>
                  const PedidosPorEstadoScreen(estado: "Enviado"),
            ),
          );
        } else if (label.contains("Entregado")) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) =>
                  const PedidosPorEstadoScreen(estado: "Entregado"),
            ),
          );
        } else if (label == "Tarjetas") {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const TarjetasScreen()),
          );
        } else if (label.contains("reseñas")) {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const AnadirResenasScreen()),
          );
        } else if (label.contains("Cupones")) {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const CuponesScreen()),
          );
        } else if (label.contains("Centro de ayuda")) {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const CentroAyudaScreen()),
          );
        } else if (label.contains("Sugerencias")) {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const SugerenciasScreen()),
          );
        } else if (label.contains("Preguntas y respuestas")) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => const PreguntasRespuestasScreen(),
            ),
          );
        }
      },
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.grey[200],
            ),
            child: Icon(icon, size: 28, color: Colors.black87),
          ),
          const SizedBox(height: 6),
          Text(
            label,
            textAlign: TextAlign.center,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 10),
          ),
        ],
      ),
    );
  }
}
