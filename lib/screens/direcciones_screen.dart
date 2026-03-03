import 'package:florapp/screens/agregaradireccion.dart';
import 'package:florapp/widgets/direccioncard.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class DireccionesScreen extends StatelessWidget {
  final String userId;
  const DireccionesScreen({super.key, required this.userId});

  @override
  Widget build(BuildContext context) {
    final ref = FirebaseFirestore.instance
        .collection('Usuarios')
        .doc(userId)
        .collection('Direcciones');

    return Scaffold(
      backgroundColor: const Color(0xFFF3F3F3),
      appBar: AppBar(
        backgroundColor: const Color(0xFFA50302),
        iconTheme: const IconThemeData(color: Color.fromARGB(255, 255, 255, 255)),
        elevation: 0,
        title: const Text('Mis datos', style: TextStyle(color: Color.fromARGB(255, 255, 255, 255))),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.fromLTRB(18, 20, 18, 8),
            child: Text('Direcciones', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20)),
          ),
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: ref.snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return const Center(child: Text('No hay direcciones registradas.'));
                }
                final direcciones = snapshot.data!.docs;
                return ListView.builder(
                  itemCount: direcciones.length,
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  itemBuilder: (context, i) {
                    final data = direcciones[i].data() as Map<String, dynamic>;
                    return DireccionCard(
                      data: data,
                      onEdit: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => DireccionFormScreen(
                              userId: userId,
                              direccionId: direcciones[i].id,
                              data: data,
                            ),
                          ),
                        );
                      },
                      onDelete: () async {
                        final confirmar = await showDialog<bool>(
                          context: context,
                          builder: (c) => AlertDialog(
                            title: const Text('Eliminar domicilio'),
                            content: const Text('¿Estás seguro de eliminar este domicilio?'),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.pop(c, false),
                                child: const Text('Cancelar'),
                              ),
                              TextButton(
                                onPressed: () => Navigator.pop(c, true),
                                child: const Text('Eliminar', style: TextStyle(color: Colors.red)),
                              ),
                            ],
                          ),
                        );
                        if (confirmar == true) {
                          await ref.doc(direcciones[i].id).delete();
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Domicilio eliminado')),
                          );
                        }
                      },
                      onManage: null,
                    );
                  },
                );
              },
            ),
          ),
          // Botón "Agregar domicilio" fuera del listado
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
                textStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
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
