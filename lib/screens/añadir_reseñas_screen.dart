import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class AnadirResenasScreen extends StatelessWidget {
  const AnadirResenasScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    final accent = const Color(0xFFA50302);

    final isGuest = user == null;

    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        backgroundColor: accent,
        elevation: 0,
        leading: GestureDetector(
          onTap: () => Navigator.pop(context),
          child: const Center(
            child: Text(
              '<',
              style: TextStyle(
                color: Colors.white,
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
        title: const Text(
          "Añadir Reseñas",
          style: TextStyle(color: Colors.white),
        ),
      ),
      body: isGuest
          ? const Center(
              child: Text(
                "Debes iniciar sesión para ver tus pedidos y dejar reseñas.",
                style: TextStyle(fontSize: 16, color: Colors.grey),
                textAlign: TextAlign.center,
              ),
            )
          : StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('Usuarios')
                  .doc(user.uid)
                  .collection('Ordenes')
                  .where('status', isEqualTo: 'Entregado')
                  .snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData)
                  return const Center(child: CircularProgressIndicator());

                final pedidos = snapshot.data!.docs;
                final productos = <Map<String, dynamic>>[];

                for (var doc in pedidos) {
                  final data = doc.data() as Map<String, dynamic>;
                  final items = data['items'] as List<dynamic>? ?? [];

                  for (var item in items) {
                    productos.add({
                      'name': item['name'],
                      'image': item['image'],
                      'pedidoId': doc.id,
                      'productId': item['id'],
                    });
                  }
                }

                if (productos.isEmpty) {
                  return const Center(
                    child: Text("No hay productos entregados aún."),
                  );
                }

                return ListView.separated(
                  padding: const EdgeInsets.all(16),
                  separatorBuilder: (_, __) => const SizedBox(height: 14),
                  itemCount: productos.length,
                  itemBuilder: (context, index) {
                    final producto = productos[index];
                    return Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: accent.withOpacity(0.1)),
                      ),
                      child: ListTile(
                        contentPadding: const EdgeInsets.all(12),
                        leading: ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: producto['image'] != null
                              ? Image.network(
                                  producto['image'],
                                  width: 52,
                                  height: 52,
                                  fit: BoxFit.cover,
                                )
                              : const Icon(Icons.image, size: 40),
                        ),
                        title: Text(
                          producto['name'] ?? '',
                          style: const TextStyle(fontWeight: FontWeight.w600),
                        ),
                        trailing: ElevatedButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => DetalleResenaScreen(
                                  productId: producto['productId'],
                                  pedidoId: producto['pedidoId'],
                                  productName: producto['name'],
                                  imageUrl: producto['image'],
                                ),
                              ),
                            );
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: accent,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 8,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          child: const Text("Reseñar"),
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

class DetalleResenaScreen extends StatefulWidget {
  final String productId;
  final String pedidoId;
  final String productName;
  final String? imageUrl;

  const DetalleResenaScreen({
    super.key,
    required this.productId,
    required this.pedidoId,
    required this.productName,
    this.imageUrl,
  });

  @override
  State<DetalleResenaScreen> createState() => _DetalleResenaScreenState();
}

class _DetalleResenaScreenState extends State<DetalleResenaScreen> {
  final _controller = TextEditingController();
  int _rating = 0;
  bool _loading = false;

  void _guardarResena() async {
    final text = _controller.text.trim();
    if (_rating == 0 || text.length < 10) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            "Completa tu reseña con una calificación y al menos 10 caracteres.",
          ),
        ),
      );
      return;
    }

    setState(() => _loading = true);

    final user = FirebaseAuth.instance.currentUser;
    final doc = FirebaseFirestore.instance.collection('Resenas').doc();

    await doc.set({
      'userId': user?.uid,
      'pedidoId': widget.pedidoId,
      'productId': widget.productId,
      'productName': widget.productName,
      'image': widget.imageUrl,
      'text': text,
      'rating': _rating,
      'timestamp': FieldValue.serverTimestamp(),
    });

    setState(() => _loading = false);
    Navigator.pop(context);
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text("Reseña enviada")));
  }

  @override
  Widget build(BuildContext context) {
    final accent = const Color(0xFFe53935);

    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        backgroundColor: accent,
        title: const Text("Escribir reseña"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Row(
              children: [
                if (widget.imageUrl != null)
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.network(
                      widget.imageUrl!,
                      width: 48,
                      height: 48,
                      fit: BoxFit.cover,
                    ),
                  ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    widget.productName,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(5, (i) {
                final filled = i < _rating;
                return GestureDetector(
                  onTap: () => setState(() => _rating = i + 1),
                  child: Icon(
                    Icons.star,
                    color: filled ? Colors.amber : Colors.grey[300],
                    size: 36,
                  ),
                );
              }),
            ),
            const SizedBox(height: 20),
            TextField(
              controller: _controller,
              maxLines: 5,
              decoration: InputDecoration(
                hintText: "Escribe tu reseña...",
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton(
                onPressed: _loading ? null : _guardarResena,
                style: ElevatedButton.styleFrom(
                  backgroundColor: accent,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: _loading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text(
                        "Enviar reseña",
                        style: TextStyle(color: Colors.white),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
