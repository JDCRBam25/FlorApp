// preguntas_respuestas_screen.dart
import 'package:flutter/material.dart';

class PreguntasRespuestasScreen extends StatefulWidget {
  const PreguntasRespuestasScreen({super.key});

  @override
  State<PreguntasRespuestasScreen> createState() =>
      _PreguntasRespuestasScreenState();
}

class _PreguntasRespuestasScreenState
    extends State<PreguntasRespuestasScreen> with TickerProviderStateMixin {
  final primary = const Color(0xFFA50302);
  final accent = const Color(0xFFe53935);

  final List<Map<String, String>> faqList = [
    {
      'question': '¿Cómo puedo rastrear mi pedido?',
      'answer':
          'Desde tu perfil, accede a "Mis pedidos" y selecciona el estado correspondiente.',
    },
    {
      'question': '¿Cómo uso un cupón de descuento?',
      'answer':
          'Introduce el código en el campo correspondiente al momento de pagar.',
    },
    {
      'question': '¿Puedo devolver un producto?',
      'answer':
          'Sí, desde "Mis pedidos", en productos entregados puedes gestionar devoluciones.',
    },
    {
      'question': '¿Qué métodos de pago aceptan?',
      'answer':
          'Tarjetas de crédito, débito y billeteras electrónicas compatibles.',
    },
    {
      'question': '¿Cómo contacto con soporte?',
      'answer':
          'Ve al "Centro de ayuda" desde tu perfil para contactarnos directamente.',
    },
  ];

  int? _expandedIndex;

  @override
  Widget build(BuildContext context) {
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
          "Preguntas y Respuestas",
          style: TextStyle(color: Colors.white),
        ),
      ),
      body: ListView.separated(
        padding: const EdgeInsets.all(20),
        itemCount: faqList.length,
        separatorBuilder: (_, __) => const SizedBox(height: 14),
        itemBuilder: (context, index) {
          final item = faqList[index];
          final isExpanded = _expandedIndex == index;

          return ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Container(
              color: Colors.white,
              child: ExpansionTile(
                tilePadding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                onExpansionChanged: (expanded) {
                  setState(() {
                    _expandedIndex = expanded ? index : null;
                  });
                },
                initiallyExpanded: isExpanded,
                title: AnimatedDefaultTextStyle(
                  duration: const Duration(milliseconds: 200),
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: isExpanded ? accent : primary,
                  ),
                  child: Text(item['question']!),
                ),
                children: [
                  AnimatedSize(
                    duration: const Duration(milliseconds: 300),
                    curve: Curves.easeOut,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 8),
                      child: AnimatedOpacity(
                        duration: const Duration(milliseconds: 300),
                        opacity: isExpanded ? 1.0 : 0.0,
                        child: Text(
                          item['answer']!,
                          style: const TextStyle(
                              fontSize: 14, color: Colors.black87),
                        ),
                      ),
                    ),
                  ),
                ],
                iconColor: accent,
                collapsedIconColor: Colors.grey,
              ),
            ),
          );
        },
      ),
    );
  }
}
