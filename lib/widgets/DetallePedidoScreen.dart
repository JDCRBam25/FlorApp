import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

const Color rojoPrincipal = Color.fromARGB(255, 172, 10, 10);

class DetallePedidoScreen extends StatelessWidget {
  final Map<String, dynamic> pedido;
  
  const DetallePedidoScreen({super.key, required this.pedido});

  @override
  Widget build(BuildContext context) {
    final List items = pedido['items'] ?? [];
    final DateTime? fecha = pedido['timestamp'] is Timestamp
        ? (pedido['timestamp'] as Timestamp).toDate()
        : null;

    final metodoEntrega = (pedido['metodoEntrega'] ?? '').toLowerCase();
final esTienda = metodoEntrega.contains('tienda');
final esEnvio = metodoEntrega.contains('envío') || metodoEntrega.contains('envio');


    return Scaffold(
      backgroundColor: const Color(0xFFF7F7F7),
      appBar: AppBar(
        backgroundColor: rojoPrincipal,
        title: const Text(
          'Detalle del pedido',
          style: TextStyle(color: Colors.white),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: ListView(
        padding: const EdgeInsets.all(18),
        children: [
          // Estado y Fecha
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _BadgeEstado(pedido['status'] ?? ''),
              if (fecha != null)
                Text(
                  '${fecha.toLocal()}'.substring(0, 16),
                  style: const TextStyle(fontSize: 13, color: Colors.black54),
                ),
            ],
          ),
          const SizedBox(height: 18),

          // Productos
          Card(
            color: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
            ),
            elevation: 0.8,
            child: Padding(
              padding: const EdgeInsets.all(14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Productos',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  const Divider(),
                  ...items.map<Widget>(
                    (i) => ListTile(
                      contentPadding: EdgeInsets.zero,
                      leading: ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: i['image'] != null
                            ? Image.network(
                                i['image'],
                                width: 44,
                                height: 44,
                                fit: BoxFit.cover,
                                errorBuilder: (_, __, ___) =>
                                    const Icon(Icons.image_not_supported),
                              )
                            : const Icon(
                                Icons.shopping_bag,
                                size: 32,
                                color: Colors.grey,
                              ),
                      ),
                      title: Text(
                        i['name'] ?? '',
                        style: const TextStyle(fontWeight: FontWeight.w600),
                      ),
                      subtitle: Text('Cantidad: ${i['quantity']}'),
                      trailing: Text(
                        'S/ ${(i['price'] * i['quantity']).toStringAsFixed(2)}',
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Datos del pedido
          Card(
  color: Colors.white,
  shape: RoundedRectangleBorder(
    borderRadius: BorderRadius.circular(14),
  ),
  elevation: 0.7,
  child: Padding(
    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
    child: Column(
      children: [
        _InfoRow(
          'Total',
          'S/ ${(pedido['total'] ?? 0).toStringAsFixed(2)}',
        ),
        const Divider(),
        _InfoRow('Método de entrega', pedido['metodoEntrega'] ?? ''),
        // Cambios aquí:
        if ((pedido['metodoEntrega'] ?? '').toLowerCase().contains('tienda')) ...[
          _InfoRow('Dirección', 'Av. Principal 123 – San Isidro'),
          _InfoRow('Horario', '10:00 a.m. a 7:00 p.m.'),
        ],
        if ((pedido['metodoEntrega'] ?? '').toLowerCase().contains('envío') ||
            (pedido['metodoEntrega'] ?? '').toLowerCase().contains('envio')) ...[
          _InfoRow('Dirección', pedido['direccionEntrega'] ?? 'No especificado'),
          if ((pedido['horarioEntrega'] ?? '').toString().trim().isNotEmpty)
            _InfoRow('Horario', pedido['horarioEntrega']),
        ],
        _InfoRow('Método de pago', pedido['metodoPago'] ?? ''),
      ],
    ),
  ),
)

        ],
      ),
    );
  }
}

class _BadgeEstado extends StatelessWidget {
  final String estado;
  const _BadgeEstado(this.estado);

  @override
  Widget build(BuildContext context) {
    Color color;
    switch (estado.toLowerCase()) {
      case 'pendiente de envío':
        color = Colors.orange;
        break;
      case 'enviado':
        color = Colors.blue;
        break;
      case 'entregado':
        color = Colors.green;
        break;
      default:
        color = rojoPrincipal;
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        estado,
        style: const TextStyle(
          fontSize: 12,
          color: Colors.white,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final String label;
  final String value;
  const _InfoRow(this.label, this.value);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(color: Colors.black54)),
          Flexible(
            child: Text(
              value,
              textAlign: TextAlign.end,
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }
}
