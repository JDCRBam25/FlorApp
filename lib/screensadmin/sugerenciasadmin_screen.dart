import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

class SugerenciasScreen extends StatelessWidget {
  const SugerenciasScreen({super.key});

  String _formatTimestamp(Timestamp ts) {
    final date = ts.toDate();
    return DateFormat.yMMMd().add_jm().format(date);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 235, 235, 235),
      appBar: AppBar(
        title: const Text('Sugerencias de Usuarios'),
        backgroundColor: const Color(0xFFAC0A0A),
        foregroundColor: Colors.white,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('sugerencias')
            .orderBy('timestamp', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting)
            return const Center(child: CircularProgressIndicator());
          if (snapshot.hasError)
            return const Center(child: Text('Error al cargar sugerencias'));
          final docs = snapshot.data!.docs;
          if (docs.isEmpty) {
            return const Center(child: Text('No hay sugerencias aún'));
          }

          return ListView.separated(
            padding: const EdgeInsets.all(16),
            separatorBuilder: (_, __) => const SizedBox(height: 12),
            itemCount: docs.length,
            itemBuilder: (context, i) {
              final data = docs[i].data() as Map<String, dynamic>;
              final texto = data['text'] ?? '';
              final email = data['email'] ?? 'Anónimo';
              final userId = data['userId'] ?? '—';
              final ts = data['timestamp'] as Timestamp;

              return Card(
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10)),
                elevation: 2,
                child: ListTile(
                  contentPadding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  title: Text(
                    texto,
                    style: const TextStyle(fontSize: 16),
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 8),
                      Text('Usuario: $email'),
                      Text('UID: $userId', style: const TextStyle(fontSize: 12)),
                      Text('Fecha: ${_formatTimestamp(ts)}',
                          style: const TextStyle(fontSize: 12)),
                    ],
                  ),
                  trailing: IconButton(
                    icon: const Icon(Icons.delete, color: Colors.red),
                    onPressed: () async {
                      final ok = await showDialog<bool>(
                        context: context,
                        builder: (_) => AlertDialog(
                          title: const Text('Eliminar sugerencia'),
                          content: const Text('¿Seguro que deseas eliminar esto?'),
                          actions: [
                            TextButton(
                                onPressed: () => Navigator.pop(context, false),
                                child: const Text('Cancelar')),
                            TextButton(
                                onPressed: () => Navigator.pop(context, true),
                                child: const Text('Eliminar',
                                    style: TextStyle(color: Colors.red))),
                          ],
                        ),
                      );
                      if (ok == true) {
                        await FirebaseFirestore.instance
                            .collection('sugerencias')
                            .doc(docs[i].id)
                            .delete();
                        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                            content: Text('Sugerencia eliminada ✅')));
                      }
                    },
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
