import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class AyudaEntregaScreen extends StatelessWidget {
  const AyudaEntregaScreen({super.key});

  void _abrirWhatsApp(BuildContext context) async {
    const telefono = '51977334757'; // Tu número real
    const mensaje = 'Hola, tengo una consulta sobre el estado de mi entrega.';
    final url = Uri.parse(
      'https://wa.me/$telefono?text=${Uri.encodeFull(mensaje)}',
    );

    try {
      await launchUrl(url, mode: LaunchMode.externalApplication);
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('No se pudo abrir WhatsApp: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    final accent = const Color(0xFFe53935);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: accent,
        elevation: 0,
        leading: GestureDetector(
          onTap: () => Navigator.pop(context),
          child: const Center(
            child: Text(
              '<',
              style: TextStyle(
                color: Colors.white, // flecha blanca
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
        title: const Text(
          "Ayuda - Entrega a domicilio",
          style: TextStyle(color: Colors.white), // texto blanco
        ),
      ),

      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Información útil",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            const Text(
              "• Tiempo promedio de entrega: 2 a 5 días hábiles.\n"
              "• Entregamos con couriers confiables como Olva y Shalom.\n"
              "• Puedes hacer seguimiento desde 'Enviado'.\n"
              "• Si tu pedido no ha llegado, contáctanos.",
              style: TextStyle(fontSize: 14),
            ),
            const Spacer(),
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton.icon(
                onPressed: () => _abrirWhatsApp(context),
                icon: const Icon(Icons.chat_bubble_outline),
                label: const Text("Contactar por WhatsApp"),
                style: ElevatedButton.styleFrom(
                  backgroundColor: accent,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
