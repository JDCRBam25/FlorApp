import 'package:florapp/screens/add_card_form.dart';
import 'package:florapp/screens/confirm_order_screen.dart';
import 'package:florapp/screens/deliveryMethodScreen.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

const Color rojoPrincipal = Color.fromARGB(255, 172, 10, 10);

class PaymentMethodScreen extends StatefulWidget {
  final List<Map<String, dynamic>> items;
  final double total;
  final dynamic method;
  final String schedule;
  final String? address;

  const PaymentMethodScreen({
    Key? key,
    required this.items,
    required this.total,
    required this.method,
    required this.schedule,
    this.address,
  }) : super(key: key);

  @override
  State<PaymentMethodScreen> createState() => _PaymentMethodScreenState();
}

class _PaymentMethodScreenState extends State<PaymentMethodScreen> {
  late final String userId;
  late String userName = '';

  @override
  void initState() {
    super.initState();
    userId = FirebaseAuth.instance.currentUser!.uid;
    _loadUserName();
  }

  Future<void> _loadUserName() async {
    final doc = await FirebaseFirestore.instance.collection('Usuarios').doc(userId).get();
    if (doc.exists) {
      setState(() {
        userName = doc['Nombre'] ?? '';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF3F3F3),
      appBar: AppBar(
        backgroundColor: rojoPrincipal,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
        title: const Text(
          'Elige cómo pagar',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('Tarjetas')
            .where('userId', isEqualTo: userId)
            .snapshots(),
        builder: (ctx, snap) {
          if (!snap.hasData) return const Center(child: CircularProgressIndicator());
          final cards = snap.data!.docs;

          return Column(
            children: [
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                  children: [
                    paymentCard(
                      image: 'assets/yape.png',
                      title: 'Yape',
                      promo: '20% OFF · Tope S/ 30',
                      onTap: () => navigateToConfirm(context, 'Yape'),
                    ),
                    ...cards.map((c) {
                      final data = c.data() as Map<String, dynamic>;
                      final cardType = data['type'] ?? "Débito";
                      final cardNumber = data['cardNumber'] ?? '';
                      final last4 = cardNumber.length >= 4
                          ? cardNumber.substring(cardNumber.length - 4)
                          : '----';
                      final bank = data['banco'] ?? 'VISA';

                      return paymentCard(
                        image: 'assets/visa.png',
                        title: '$bank ${cardType == "Débito" ? "Débito" : "Crédito"}',
                        subtitle: '**** $last4',
                        onTap: () => navigateToConfirm(context, '**** $last4'),

                      );
                    }),
                    genericCard(Icons.credit_card_outlined, 'Nueva tarjeta de débito', context),
                    genericCard(Icons.credit_card, 'Nueva tarjeta de crédito', context),
                  ],
                ),
              ),
              Divider(height: 1, color: Colors.grey.shade300),
              Container(
                color: Colors.white,
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    GestureDetector(
                      onTap: () {},
                      child: const Text(
                        'Ingresar código de cupón',
                        style: TextStyle(color: rojoPrincipal, fontWeight: FontWeight.bold, fontSize: 16),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        const Text('Pagas', style: TextStyle(fontSize: 18)),
                        const Spacer(),
                        Text(
                          'S/ ${widget.total.toStringAsFixed(0)}',
                          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  void navigateToConfirm(BuildContext context, String payment) {
  final bool esTienda = widget.method == DeliveryMethod.tienda;
  final bool direccionValida = widget.address != null && widget.address!.trim().isNotEmpty;
  final bool horarioValido = widget.schedule.trim().isNotEmpty;

  if (!esTienda && (!direccionValida || !horarioValido)) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Completa dirección y horario de entrega antes de continuar.')),
    );
    return;
  }

  Navigator.push(
    context,
    MaterialPageRoute(
      builder: (_) => ConfirmOrderScreen(
        items: widget.items,
        total: widget.total,
        method: esTienda ? 'tienda' : 'delivery',
        address: esTienda ? null : widget.address!.trim(),
        schedule: esTienda ? '' : widget.schedule.trim(),
        payment: payment,
      ),
    ),
  );
}


  Widget paymentCard({
    required String image,
    required String title,
    String? subtitle,
    String? promo,
    required VoidCallback onTap,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 4, offset: const Offset(0, 2))],
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(vertical: 8, horizontal: 14),
        leading: CircleAvatar(backgroundColor: Colors.white, backgroundImage: AssetImage(image), radius: 22),
        title: Row(
          children: [
            Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            if (promo != null) ...[
              const SizedBox(width: 6),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(color: rojoPrincipal, borderRadius: BorderRadius.circular(8)),
                child: const Text("NUEVO", style: TextStyle(color: Colors.white, fontSize: 12)),
              ),
            ]
          ],
        ),
        subtitle: subtitle != null
            ? Padding(padding: const EdgeInsets.only(top: 4), child: Text(subtitle, style: const TextStyle(fontSize: 14, color: Colors.grey)))
            : promo != null
                ? Padding(padding: const EdgeInsets.only(top: 4), child: Text(promo, style: TextStyle(fontSize: 13, color: rojoPrincipal, fontWeight: FontWeight.bold)))
                : null,
        trailing: const Icon(Icons.chevron_right, color: rojoPrincipal, size: 30),
        onTap: onTap,
      ),
    );
  }

  Widget genericCard(IconData icon, String title, BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 4, offset: const Offset(0, 2))],
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(vertical: 8, horizontal: 14),
        leading: Icon(icon, color: Colors.black87),
        title: Text(title),
        trailing: const Icon(Icons.chevron_right, color: rojoPrincipal, size: 30),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => AddCardForm(userId: userId, userName: userName),
            ),
          );
        },
      ),
    );
  }
}
