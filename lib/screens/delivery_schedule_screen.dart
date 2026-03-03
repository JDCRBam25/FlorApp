import 'package:florapp/screens/agregaradireccion.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:florapp/screens/payment_method_screen.dart';

const Color rojoPrincipal = Color.fromARGB(255, 172, 10, 10);

class DeliveryTypeScreen extends StatelessWidget {
  final List<Map<String, dynamic>> items;
  final double total;
  final dynamic method;

  const DeliveryTypeScreen({
    Key? key,
    required this.items,
    required this.total,
    required this.method,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final userId = FirebaseAuth.instance.currentUser!.uid;
    final direccionesRef = FirebaseFirestore.instance
        .collection('Usuarios')
        .doc(userId)
        .collection('Direcciones');

    return Scaffold(
      backgroundColor: const Color(0xFFF3F3F3),
      appBar: AppBar(
        backgroundColor: rojoPrincipal,
        iconTheme: const IconThemeData(color: Colors.white),
        elevation: 0,
        title: const Text(
          'Elige tu dirección',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.fromLTRB(18, 20, 18, 8),
            child: Text(
              'Mis direcciones',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
            ),
          ),
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: direccionesRef.snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return const Center(
                    child: Text('No tienes direcciones registradas.'),
                  );
                }

                final direcciones = snapshot.data!.docs;

                return ListView.builder(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                  itemCount: direcciones.length,
                  itemBuilder: (ctx, index) {
                    final direccion =
                        direcciones[index].data() as Map<String, dynamic>;

                    IconData icono = direccion['tipo'] == 'Laboral'
                        ? Icons.work_outline
                        : Icons.home_outlined;

                    Color iconColor = direccion['tipo'] == 'Laboral'
                        ? rojoPrincipal
                        : Colors.blueGrey;

                    return Card(
                      color: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 1.0,
                      margin: const EdgeInsets.only(bottom: 12),
                      child: InkWell(
                        borderRadius: BorderRadius.circular(12),
                        onTap: () {
                          final direccionCompleta =
                              direccion['direccion'] ?? '';
                          final referencias = direccion['referencias'] ?? '';
                          final distrito = direccion['distrito'] ?? '';
                          final provincia = direccion['provincia'] ?? '';
                          final departamento = direccion['departamento'] ?? '';

                          final direccionFinal =
                              "$direccionCompleta, $referencias, $distrito, $provincia, $departamento";

                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => PaymentMethodScreen(
                                items: items,
                                total: total,
                                method: method,
                                schedule: '12:00',
                                address: direccionFinal,
                              ),
                            ),
                          );
                        },
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 18,
                            vertical: 16,
                          ),
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
                                      direccion['direccion'] ?? '',
                                      style: const TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                    if ((direccion['referencias'] ?? '')
                                        .isNotEmpty)
                                      Text(
                                        direccion['referencias'],
                                        style: const TextStyle(
                                          fontSize: 15,
                                          color: Colors.black87,
                                        ),
                                      ),
                                    const SizedBox(height: 6),
                                    Text(
                                      "${direccion['departamento'] ?? ''} - ${direccion['provincia'] ?? ''}${direccion['distrito'] != null ? ' - ${direccion['distrito']}' : ''}",
                                      style: const TextStyle(
                                        fontSize: 14,
                                        color: Colors.grey,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      "${direccion['nombreCompleto'] ?? ''} - ${direccion['telefono'] ?? ''}",
                                      style: const TextStyle(
                                        fontSize: 14,
                                        color: Colors.grey,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const Icon(
                                Icons.chevron_right,
                                color: rojoPrincipal,
                                size: 28,
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
          ),
          Container(
            width: double.infinity,
            color: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 6),
            child: OutlinedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => DireccionFormScreen(userId: userId),
                  ),
                );
              },
              style: OutlinedButton.styleFrom(
                foregroundColor: const Color(0xFFA50302),
                side: const BorderSide(color: Colors.transparent),
                padding: const EdgeInsets.symmetric(vertical: 18),
                textStyle: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: const [
                  Text("Agregar domicilio"),
                  Icon(Icons.chevron_right, color: Color(0xFFA50302)),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
