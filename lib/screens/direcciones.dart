import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'agregaradireccion.dart'; // Asegúrate de tener el path correcto

// Modelo Direccion (puedes importarlo si lo tienes aparte)
class Direccion {
  String id;
  String direccion;
  bool sinNumero;
  String departamento;
  String provincia;
  String distrito;
  String apartamento;
  String referencias;
  String tipo; // "Residencial" o "Laboral"
  String nombreCompleto;
  String telefono;

  Direccion({
    required this.id,
    required this.direccion,
    required this.sinNumero,
    required this.departamento,
    required this.provincia,
    required this.distrito,
    required this.apartamento,
    required this.referencias,
    required this.tipo,
    required this.nombreCompleto,
    required this.telefono,
  });

  factory Direccion.fromMap(Map<String, dynamic> data, String id) {
    return Direccion(
      id: id,
      direccion: data['direccion'] ?? '',
      sinNumero: data['sinNumero'] ?? false,
      departamento: data['departamento'] ?? '',
      provincia: data['provincia'] ?? '',
      distrito: data['distrito'] ?? '',
      apartamento: data['apartamento'] ?? '',
      referencias: data['referencias'] ?? '',
      tipo: data['tipo'] ?? '',
      nombreCompleto: data['nombreCompleto'] ?? '',
      telefono: data['telefono'] ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'direccion': direccion,
      'sinNumero': sinNumero,
      'departamento': departamento,
      'provincia': provincia,
      'distrito': distrito,
      'apartamento': apartamento,
      'referencias': referencias,
      'tipo': tipo,
      'nombreCompleto': nombreCompleto,
      'telefono': telefono,
    };
  }
}

class DireccionesScreen extends StatelessWidget {
  final String userId;

  const DireccionesScreen({super.key, required this.userId});

  @override
  Widget build(BuildContext context) {
    final direccionRef = FirebaseFirestore.instance
        .collection('Usuarios')
        .doc(userId)
        .collection('Direcciones');

    return Scaffold(
      appBar: AppBar(
        title: const Text('Direcciones de entrega'),
        backgroundColor: const Color.fromARGB(255, 172, 10, 10),
        foregroundColor: Colors.white,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: direccionRef.snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text('No hay direcciones registradas.'));
          }

          final direcciones = snapshot.data!.docs
              .map((doc) => Direccion.fromMap(doc.data() as Map<String, dynamic>, doc.id))
              .toList();

          return ListView.builder(
            itemCount: direcciones.length,
            itemBuilder: (context, i) {
              final d = direcciones[i];
              return Card(
                margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                child: ListTile(
                  title: Text(
                    d.nombreCompleto,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Padding(
                    padding: const EdgeInsets.only(top: 6.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '${d.direccion}${d.sinNumero ? " S/N" : ""}${d.apartamento.isNotEmpty ? ", Apt. ${d.apartamento}" : ""}',
                        ),
                        Text(
                          '${d.distrito}, ${d.provincia}, ${d.departamento}',
                          style: const TextStyle(color: Colors.black87),
                        ),
                        if (d.referencias.isNotEmpty)
                          Text('Ref: ${d.referencias}',
                              style: const TextStyle(fontSize: 12, color: Colors.black54)),
                        Text('Tipo: ${d.tipo}', style: const TextStyle(fontSize: 12)),
                        Text('Teléfono: ${d.telefono}', style: const TextStyle(fontSize: 12)),
                      ],
                    ),
                  ),
                  trailing: PopupMenuButton<String>(
                    onSelected: (value) async {
                      if (value == 'editar') {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => DireccionFormScreen(
                              userId: userId,
                              direccionId: d.id,
                              data: d.toMap(),
                            ),
                          ),
                        );
                      } else if (value == 'eliminar') {
                        await direccionRef.doc(d.id).delete();
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Dirección eliminada')),
                        );
                      }
                    },
                    itemBuilder: (_) => [
                      const PopupMenuItem(
                        value: 'editar',
                        child: Text('Editar'),
                      ),
                      const PopupMenuItem(
                        value: 'eliminar',
                        child: Text('Eliminar'),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: const Color.fromARGB(255, 172, 10, 10),
        child: const Icon(Icons.add, color: Colors.white),
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => DireccionFormScreen(userId: userId),
            ),
          );
        },
      ),
    );
  }
}
