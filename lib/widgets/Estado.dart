import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:florapp/widgets/DetallePedidoScreen.dart';
import 'package:flutter/material.dart';

const Color rojoPrincipal = Color.fromARGB(255, 172, 10, 10);

class PedidosPorEstadoScreen extends StatelessWidget {
  final String estado; // Ejemplo: "Pendiente de envío", "Enviado", "Entregado"

  const PedidosPorEstadoScreen({super.key, required this.estado});

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      return const Scaffold(
        body: Center(child: Text('Debes iniciar sesión para ver tus pedidos')),
      );
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF7F7F7),
      appBar: AppBar(
        backgroundColor: rojoPrincipal,
        elevation: 1,
        iconTheme: const IconThemeData(color: Colors.white),
        title: Text(
          'Pedidos: $estado',
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('Usuarios')
            .doc(user.uid)
            .collection('Ordenes')
            .where('status', isEqualTo: estado)
            .orderBy('timestamp', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(
              child: Text(
                'No hay pedidos en este estado.',
                style: TextStyle(
                  color: Colors.black54,
                  fontWeight: FontWeight.w600,
                  fontSize: 17,
                ),
              ),
            );
          }

          final pedidos = snapshot.data!.docs;

          return ListView.separated(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            itemCount: pedidos.length,
            separatorBuilder: (_, __) => const SizedBox(height: 14),
            itemBuilder: (context, index) {
              final pedido = pedidos[index].data() as Map<String, dynamic>;
              final items = pedido['items'] as List<dynamic>? ?? [];
              final primerProducto = items.isNotEmpty ? items.first : null;

              return GestureDetector(
  onTap: () {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => DetallePedidoScreen(pedido: pedido),
      ),
    );
  },
  child: Card(
    color: Colors.white,
    elevation: 0.8,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(14),
    ),
    child: Padding(
      padding: const EdgeInsets.all(14),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: primerProducto != null && primerProducto['image'] != null
                ? Image.network(
                    primerProducto['image'],
                    width: 52,
                    height: 52,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => const Icon(
                      Icons.image_not_supported,
                      size: 38,
                      color: Colors.grey,
                    ),
                  )
                : Container(
                    width: 52,
                    height: 52,
                    color: Colors.grey[200],
                    child: const Icon(
                      Icons.shopping_bag,
                      size: 32,
                      color: Colors.grey,
                    ),
                  ),
          ),
          const SizedBox(width: 18),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  pedido['metodoEntrega'] ?? '',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 4),
                if (primerProducto != null)
                  Text(
                    primerProducto['name'] ?? '',
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: Colors.black54,
                    ),
                  ),
                if (items.length > 1)
                  Text(
                    '+ ${items.length - 1} productos',
                    style: const TextStyle(
                      fontSize: 13,
                      color: Colors.black38,
                    ),
                  ),
                const SizedBox(height: 3),
                Text(
                  'Total: S/ ${(pedido['total'] ?? 0).toStringAsFixed(2)}',
                  style: const TextStyle(
                    color: rojoPrincipal,
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                  ),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: _getEstadoColor(pedido['status'] ?? ''),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  pedido['status'] ?? '',
                  style: const TextStyle(
                    fontSize: 12,
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              const SizedBox(height: 6),
              if (pedido['timestamp'] != null)
                Text(
                  (pedido['timestamp'] as Timestamp)
                      .toDate()
                      .toLocal()
                      .toString()
                      .substring(0, 16),
                  style: const TextStyle(
                    fontSize: 11,
                    color: Colors.black54,
                  ),
                ),
            ],
          ),
        ],
      ),
    ),
  ),
);

            },
          );
        },
      ),
    );
  }

  Color _getEstadoColor(String estado) {
    switch (estado.toLowerCase()) {
      case 'pendiente de envío':
        return Colors.orange;
      case 'enviado':
        return Colors.blue;
      case 'entregado':
        return Colors.green;
      default:
        return rojoPrincipal;
    }
  }
}
