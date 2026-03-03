import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class AyudaRecojoScreen extends StatelessWidget {
  const AyudaRecojoScreen({super.key});

  void _contactarSoporte(BuildContext context) async {
    const telefono = '51977334757'; // cambia por tu número real
    const mensaje = 'Hola, tengo una consulta sobre recojo en tienda.';
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
    final primary = const Color(0xFFA50302);

    return Scaffold(
      backgroundColor: Colors.white,
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
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
        title: const Text(
          "Ayuda - Recojo en tienda",
          style: TextStyle(color: Colors.white),
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
              "• Puedes recoger tu pedido en nuestra tienda principal.\n"
              "• Horario: Lunes a sábado de 10am a 6pm.\n"
              "• Lleva tu DNI y el número de pedido.\n"
              "• Te notificaremos por email o SMS cuando esté listo.",
              style: TextStyle(fontSize: 14),
            ),
            const Spacer(),
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton.icon(
                onPressed: () => _contactarSoporte(context),
                icon: const Icon(Icons.chat_bubble_outline),
                label: const Text("Contactar por WhatsApp"),
                style: ElevatedButton.styleFrom(
                  backgroundColor: primary,
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
