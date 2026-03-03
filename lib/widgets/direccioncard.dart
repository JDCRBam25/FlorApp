import 'package:flutter/material.dart';

class DireccionCard extends StatelessWidget {
  final Map<String, dynamic> data;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  final VoidCallback? onManage; // opcional

  const DireccionCard({
    super.key,
    required this.data,
    required this.onEdit,
    required this.onDelete,
    this.onManage,
  });

  @override
  Widget build(BuildContext context) {
    // Icono dinámico
    IconData icono = data['tipo'] == 'Laboral' ? Icons.work_outline : Icons.home_outlined;
    Color iconColor = data['tipo'] == 'Laboral' ? const Color(0xFFA50302) : Colors.blueGrey;

    return Card(
      color: Colors.white, // <-- FONDO BLANCO
      margin: const EdgeInsets.only(bottom: 20),
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(icono, color: iconColor, size: 32),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        data['direccion'] ?? '',
                        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                      ),
                      if ((data['referencias'] ?? '').isNotEmpty)
                        Text(
                          data['referencias'],
                          style: const TextStyle(fontSize: 15, color: Colors.black87),
                        ),
                      const SizedBox(height: 6),
                      Text(
                        "${data['departamento'] ?? ''} - ${data['provincia'] ?? ''} ${data['distrito'] != null && data['distrito'] != '' ? '- ${data['distrito']}' : ''}",
                        style: const TextStyle(fontSize: 14, color: Colors.grey),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        "${data['nombreCompleto'] ?? ''} - ${data['telefono'] ?? ''}",
                        style: const TextStyle(fontSize: 14, color: Colors.grey),
                      ),
                    ],
                  ),
                ),
                // Botón 3 puntos
                PopupMenuButton<String>(
                  color: Colors.white,
                  onSelected: (op) {
                    if (op == 'editar') onEdit();
                    if (op == 'eliminar') onDelete();
                    if (op == 'gestionar' && onManage != null) onManage!();
                  },
                  itemBuilder: (ctx) => [
                    const PopupMenuItem(value: 'editar', child: Text('Editar')),
                    const PopupMenuItem(value: 'eliminar', child: Text('Eliminar')),
                    if (onManage != null)
                      const PopupMenuItem(value: 'gestionar', child: Text('Gestionar mis domicilios')),
                  ],
                )
              ],
            ),
          ),
        ],
      ),
    );
  }
}
