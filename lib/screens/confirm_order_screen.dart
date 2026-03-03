import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

const Color rojoPrincipal = Color.fromARGB(255, 172, 10, 10);

class ConfirmOrderScreen extends StatefulWidget {
  final List<Map<String, dynamic>> items;
  final double total;
  final dynamic method;
  final String schedule;
  final String payment;
  final String? address;

  const ConfirmOrderScreen({
    Key? key,
    required this.items,
    required this.total,
    required this.method,
    required this.schedule,
    required this.payment,
    this.address,
  }) : super(key: key);

  @override
  State<ConfirmOrderScreen> createState() => _ConfirmOrderScreenState();
}

class _ConfirmOrderScreenState extends State<ConfirmOrderScreen> {
  bool _isLoading = false;

  Future<void> confirmOrder(BuildContext context) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Debes iniciar sesión para confirmar el pedido.')),
      );
      return;
    }
    final userId = user.uid;

    final bool esTienda = widget.method == 'tienda';
    final bool direccionValida = widget.address != null && widget.address!.trim().isNotEmpty;

    final String metodoEntrega = esTienda ? 'Recojo en tienda' : 'Envío a domicilio';

    final String direccionEntrega = esTienda || !direccionValida
        ? 'Av. Principal 123 – San Isidro'
        : widget.address!;

    final String horarioEntrega = esTienda || !direccionValida
        ? '10:00 a.m. a 7:00 p.m.'
        : widget.schedule;

    String metodoPago;
    if (widget.payment.toLowerCase() == 'yape') {
      metodoPago = 'Yape';
    } else if (widget.payment.length >= 4) {
      metodoPago = 'Tarjeta ${widget.payment.substring(widget.payment.length - 4)}';
    } else {
      metodoPago = widget.payment;
    }

    final orderData = {
      'userId': userId,
      'items': widget.items,
      'total': widget.total,
      'metodoEntrega': metodoEntrega,
      'direccionEntrega': direccionEntrega,
      'horarioEntrega': horarioEntrega,
      'metodoPago': metodoPago,
      'status': 'Pendiente de envío',
      'timestamp': FieldValue.serverTimestamp(),
    };

    setState(() => _isLoading = true);

    try {
      await FirebaseFirestore.instance
          .collection('Usuarios')
          .doc(userId)
          .collection('Ordenes')
          .add(orderData);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('¡Pedido confirmado con éxito!')),
      );
      if (mounted) {
        Navigator.of(context).popUntil((route) => route.isFirst);
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al confirmar pedido: $e')),
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool esTienda = widget.method == 'tienda';
    final bool direccionValida = widget.address != null && widget.address!.trim().isNotEmpty;

    final String direccionEntrega = esTienda || !direccionValida
        ? 'Sucursal: Av. Principal 123 – San Isidro'
        : widget.address!;

    final String horarioEntrega = esTienda || !direccionValida
        ? 'Horario: 10:00 a.m. a 7:00 p.m.'
        : 'Horario: ${widget.schedule}';

    return Scaffold(
      backgroundColor: const Color(0xFFF7F7F7),
      appBar: AppBar(
        backgroundColor: rojoPrincipal,
        title: const Text(
          'Revisa y confirma',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        elevation: 1,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        children: [
          _ProductosSection(items: widget.items),
          const SizedBox(height: 16),
          _SectionCard(
            icon: esTienda ? Icons.store_mall_directory : Icons.local_shipping_outlined,
            title: 'Método de entrega',
            subtitle: '$direccionEntrega\n$horarioEntrega',
            trailing: esTienda
                ? const Padding(
                    padding: EdgeInsets.only(top: 4),
                    child: Text(
                      'GRATIS',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.green,
                        fontSize: 14,
                      ),
                    ),
                  )
                : null,
          ),
          const SizedBox(height: 8),
          _SectionCard(
            icon: Icons.credit_card_outlined,
            title: 'Método de pago',
            subtitle: widget.payment.toLowerCase() == 'yape'
                ? 'Yape'
                : (widget.payment.length >= 4
                    ? 'Tarjeta ${widget.payment.substring(widget.payment.length - 4)}'
                    : widget.payment),
          ),
        ],
      ),
      bottomNavigationBar: Container(
        color: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Total',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                ),
                Text(
                  'S/ ${widget.total.toStringAsFixed(2)}',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: _isLoading ? null : () => confirmOrder(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: rojoPrincipal,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: _isLoading
                    ? const CircularProgressIndicator(
                        color: Colors.white,
                        strokeWidth: 2,
                      )
                    : const Text(
                        'Confirmar compra',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ProductosSection extends StatelessWidget {
  final List<Map<String, dynamic>> items;

  const _ProductosSection({required this.items});

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 0.7,
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Productos (${items.length})',
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            const Divider(),
            ...items.map(
              (i) => ListTile(
                contentPadding: EdgeInsets.zero,
                leading: ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.network(
                    i['image'],
                    width: 44,
                    height: 44,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => const Icon(Icons.image_not_supported),
                  ),
                ),
                title: Text(
                  i['name'],
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
    );
  }
}

class _SectionCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final Widget? trailing;

  const _SectionCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Colors.white,
      elevation: 0.7,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        leading: CircleAvatar(
          backgroundColor: Colors.grey.shade200,
          child: Icon(icon, color: rojoPrincipal),
        ),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text(subtitle, overflow: TextOverflow.ellipsis, maxLines: 3),
        trailing: trailing,
      ),
    );
  }
}
