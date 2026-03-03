import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:florapp/screensadmin/PedidosEstadoScreen.dart';
import 'package:flutter/material.dart';

class AdminPedidosScreen extends StatelessWidget {
  const AdminPedidosScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final List<_PedidoEstadoCard> cards = [
      _PedidoEstadoCard(
        icon: Icons.schedule,
        label: 'Pendiente de envío',
        color: Colors.orangeAccent.shade100,
        estado: 'Pendiente de envío',
      ),
      _PedidoEstadoCard(
        icon: Icons.local_shipping,
        label: 'Enviado',
        color: Colors.lightBlueAccent.shade100,
        estado: 'Enviado',
      ),
      _PedidoEstadoCard(
        icon: Icons.inventory_2,
        label: 'Entregado',
        color: Colors.greenAccent.shade100,
        estado: 'Entregado',
      ),
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Gestión de Pedidos'),
        backgroundColor: const Color(0xFFAC0A0A),
        iconTheme: const IconThemeData(color: Colors.white),
        titleTextStyle: const TextStyle(color: Colors.white, fontSize: 20),
      ),
      backgroundColor: Colors.white,
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: GridView.count(
          crossAxisCount: 2,
          mainAxisSpacing: 20,
          crossAxisSpacing: 20,
          childAspectRatio: 1,
          children: cards.map((card) {
            return StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('Ordenes')
                  .where('status', isEqualTo: card.estado)
                  .snapshots(),
              builder: (context, snapshot) {
                final count = snapshot.hasData ? snapshot.data!.docs.length : 0;

                return GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => PedidosPorEstadoScreen(estado: card.estado), // CORREGIDO AQUÍ
                      ),
                    );
                  },
                  child: Container(
                    decoration: BoxDecoration(
                      color: card.color,
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(25),
                        bottomRight: Radius.circular(25),
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black12,
                          blurRadius: 6,
                          offset: const Offset(2, 3),
                        ),
                      ],
                    ),
                    child: Stack(
                      children: [
                        Center(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(card.icon, size: 45, color: Colors.white),
                              const SizedBox(height: 12),
                              Text(
                                card.label,
                                textAlign: TextAlign.center,
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.white,
                                ),
                              ),
                            ],
                          ),
                        ),
                        if (count > 0)
                          Positioned(
                            top: 8,
                            right: 8,
                            child: Container(
                              padding: const EdgeInsets.all(6),
                              decoration: const BoxDecoration(
                                color: Colors.redAccent,
                                shape: BoxShape.circle,
                              ),
                              child: Text(
                                '$count',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                );
              },
            );
          }).toList(),
        ),
      ),
    );
  }
}

class _PedidoEstadoCard {
  final IconData icon;
  final String label;
  final Color color;
  final String estado;

  _PedidoEstadoCard({
    required this.icon,
    required this.label,
    required this.color,
    required this.estado,
  });
}
