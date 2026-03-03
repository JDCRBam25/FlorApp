import 'package:flutter/material.dart';
import 'package:florapp/screens/delivery_schedule_screen.dart';
import 'package:florapp/screens/payment_method_screen.dart';

const Color rojoPrincipal = Color.fromARGB(255, 172, 10, 10);

enum DeliveryMethod { domicilio, tienda }

class DeliveryMethodScreen extends StatelessWidget {
  final List<Map<String, dynamic>> items;
  final double total;

  const DeliveryMethodScreen({
    Key? key,
    required this.items,
    required this.total,
  }) : super(key: key);

  void _navigateNext(BuildContext context, DeliveryMethod method) {
    if (method == DeliveryMethod.tienda) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => PaymentMethodScreen(
            items: items,
            total: total,
            method: method,
            schedule: 'Recojo en tienda',
          ),
        ),
      );
    } else {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => DeliveryTypeScreen(
            items: items,
            total: total,
            method: method,
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF3F3F3),
      appBar: AppBar(
        backgroundColor: rojoPrincipal,
        title: const Text(
          'Revisa cuándo llega tu compra',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        elevation: 1,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Column(
        children: [
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey.shade300),
            ),
            child: Column(
              children: [
                ListTile(
                  title: const Text('Envío a domicilio',
                      style: TextStyle(fontWeight: FontWeight.w600)),
                  subtitle: const Text('Recibe tus productos en tu dirección',
                      style: TextStyle(fontSize: 13)),
                  trailing: GestureDetector(
                    onTap: () => _navigateNext(context, DeliveryMethod.domicilio),
                    child: Icon(Icons.chevron_right, color: rojoPrincipal, size: 30),
                  ),
                ),
                const Divider(height: 1),
                ListTile(
                  title: const Text('Recojo en tienda',
                      style: TextStyle(fontWeight: FontWeight.w600)),
                  subtitle: const Text('Retira tu pedido en el local',
                      style: TextStyle(fontSize: 13)),
                  trailing: GestureDetector(
                    onTap: () => _navigateNext(context, DeliveryMethod.tienda),
                    child: Icon(Icons.chevron_right, color: rojoPrincipal, size: 30),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView.separated(
              padding: const EdgeInsets.all(12),
              itemCount: items.length,
              separatorBuilder: (_, __) => const SizedBox(height: 10),
              itemBuilder: (ctx, idx) {
                final item = items[idx];
                final imageUrl = item['image'] as String? ?? 'https://via.placeholder.com/44';
                final deliveryText = item['deliveryText'] as String? ?? 'Fecha no disponible';
                final name = item['name'] as String? ?? 'Producto';

                return Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: const [
                      BoxShadow(color: Colors.black12, blurRadius: 2, offset: Offset(0, 1)),
                    ],
                  ),
                  child: ListTile(
                    contentPadding: const EdgeInsets.all(10),
                    leading: ClipRRect(
                      borderRadius: BorderRadius.circular(30),
                      child: Image.network(imageUrl, width: 48, height: 48, fit: BoxFit.cover),
                    ),
                    title: Text(name, style: const TextStyle(fontWeight: FontWeight.bold)),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 2),
                        Row(
                          children: [
                            const Icon(Icons.calendar_today, size: 16, color: rojoPrincipal),
                            const SizedBox(width: 6),
                            Text(deliveryText,
                                style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
                          ],
                        ),
                        const SizedBox(height: 4),
                        const Text('Única opción disponible',
                            style: TextStyle(color: Colors.grey, fontSize: 12)),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
