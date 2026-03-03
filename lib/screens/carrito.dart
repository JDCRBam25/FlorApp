import 'package:florapp/screens/deliveryMethodScreen.dart';
import 'package:florapp/widgets/Detalles.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../screensadmin/loginscreen.dart'; // Asegúrate de importar la pantalla de login

class CartContentWidget extends StatefulWidget {
  const CartContentWidget({Key? key}) : super(key: key);

  @override
  _CartContentWidgetState createState() => _CartContentWidgetState();
}

class _CartContentWidgetState extends State<CartContentWidget> {
  List<Map<String, dynamic>> cartItems = [];
  final mainColor = const Color(0xFFA50302);
  late String userId;
  bool isGuest = false;

  @override
  void initState() {
    super.initState();
    final user = FirebaseAuth.instance.currentUser;
    if (user == null || user.isAnonymous) {
      isGuest = true;
    } else {
      userId = user.uid;
      loadCartItems();
    }
  }

  Future<void> loadCartItems() async {
    final snapshot = await FirebaseFirestore.instance
        .collection('Usuarios')
        .doc(userId)
        .collection('carrito')
        .get();

    setState(() {
      cartItems = snapshot.docs
          .map(
            (doc) => {
              'id': doc.id,
              'name': doc['productName'],
              'price': doc['discountedPrice'],
              'quantity': doc['quantity'],
              'image': doc['productImage'],
              'selected': doc['selected'],
            },
          )
          .toList();
    });
  }

  bool get allSelected =>
      cartItems.isNotEmpty && cartItems.every((i) => i['selected'] == true);
  bool get anySelected => cartItems.any((i) => i['selected'] == true);

  double get totalPrice => cartItems.fold(0.0, (sum, item) {
        return sum + (item['selected'] ? item['price'] * item['quantity'] : 0);
      });

  Future<void> updateQuantity(int index, int newQuantity) async {
    final id = cartItems[index]['id'];
    setState(() => cartItems[index]['quantity'] = newQuantity);
    await FirebaseFirestore.instance
        .collection('Usuarios')
        .doc(userId)
        .collection('carrito')
        .doc(id)
        .update({'quantity': newQuantity});
  }

  Future<void> removeItem(int index) async {
    final id = cartItems[index]['id'];
    setState(() => cartItems.removeAt(index));
    await FirebaseFirestore.instance
        .collection('Usuarios')
        .doc(userId)
        .collection('carrito')
        .doc(id)
        .delete();
  }

  void toggleSelectAll(bool? v) {
    setState(() {
      for (var item in cartItems) item['selected'] = v ?? false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0.7,
        title: const Text(
          'Carrito de Compras',
          style: TextStyle(color: Colors.black),
        ),
        iconTheme: const IconThemeData(color: Colors.black),
        actions: [
          IconButton(
            onPressed: () => toggleSelectAll(!allSelected),
            icon: Row(
              children: [
                Icon(
                  allSelected ? Icons.check_box : Icons.check_box_outline_blank,
                  color: mainColor,
                ),
                const SizedBox(width: 4),
                Text('Todos', style: TextStyle(color: mainColor, fontSize: 12)),
              ],
            ),
          ),
        ],
      ),
      body: isGuest
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.lock_outline, size: 60, color: Colors.grey),
                  const SizedBox(height: 16),
                  const Text(
                    'Inicia sesión para usar el carrito',
                    style: TextStyle(fontSize: 18, color: Colors.black87),
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(builder: (_) => const LoginScreen()),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: mainColor,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 30, vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                    ),
                    child: const Text(
                      'Iniciar Sesión',
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ],
              ),
            )
          : cartItems.isEmpty
              ? const Center(
                  child: Text(
                    'Tu carrito está vacío',
                    style: TextStyle(fontSize: 20, color: Colors.grey),
                  ),
                )
              : ListView.builder(
                  itemCount: cartItems.length,
                  itemBuilder: (ctx, i) {
                    final item = cartItems[i];
                    final isSel = item['selected'] as bool;

                    return GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => ProductDetailScreen(
                              productName: item['name'],
                              productImage: item['image'],
                              originalPrice: item['price'],
                              discountedPrice: item['price'],
                              description: '',
                            ),
                          ),
                        );
                      },
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 250),
                        curve: Curves.easeInOut,
                        margin: const EdgeInsets.symmetric(
                          vertical: 6,
                          horizontal: 16,
                        ),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(15),
                          border: Border.all(
                            color: isSel ? mainColor : Colors.grey.shade300,
                            width: isSel ? 2 : 1,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: isSel
                                  ? mainColor.withOpacity(0.2)
                                  : Colors.black12,
                              blurRadius: isSel ? 8 : 2,
                            ),
                          ],
                          color: Colors.white,
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(12),
                          child: Row(
                            children: [
                              ClipRRect(
                                borderRadius: BorderRadius.circular(12),
                                child: item['image'].endsWith('.svg')
                                    ? SvgPicture.network(
                                        item['image'],
                                        width: 80,
                                        height: 80,
                                        fit: BoxFit.cover,
                                      )
                                    : Image.network(
                                        item['image'],
                                        width: 80,
                                        height: 80,
                                        fit: BoxFit.cover,
                                      ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      item['name'],
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                        color: isSel ? mainColor : Colors.black,
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      'S/ ${item['price']}',
                                      style: TextStyle(
                                        color: isSel
                                            ? mainColor
                                            : Colors.black87,
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    Row(
                                      children: [
                                        IconButton(
                                          icon: const Icon(Icons.remove,
                                              size: 20),
                                          onPressed: () {
                                            if (item['quantity'] > 1) {
                                              updateQuantity(
                                                i,
                                                item['quantity'] - 1,
                                              );
                                            }
                                          },
                                        ),
                                        Text(
                                          '${item['quantity']}',
                                          style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            color: isSel
                                                ? mainColor
                                                : Colors.black,
                                          ),
                                        ),
                                        IconButton(
                                          icon:
                                              const Icon(Icons.add, size: 20),
                                          onPressed: () => updateQuantity(
                                            i,
                                            item['quantity'] + 1,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                              Column(
                                children: [
                                  Checkbox(
                                    value: isSel,
                                    activeColor: mainColor,
                                    onChanged: (v) => setState(
                                      () => item['selected'] = v ?? false,
                                    ),
                                  ),
                                  IconButton(
                                    icon: const Icon(
                                      Icons.delete,
                                      color: Colors.red,
                                    ),
                                    onPressed: () => removeItem(i),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
      bottomNavigationBar: isGuest
          ? null
          : Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              decoration: BoxDecoration(
                color: Colors.white,
                border: Border(top: BorderSide(color: Colors.grey.shade300)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black12,
                    blurRadius: 10,
                    offset: Offset(0, -2),
                  ),
                ],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Total: S/ ${totalPrice.toStringAsFixed(2)}',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: mainColor,
                    ),
                  ),
                  ElevatedButton(
                    onPressed: anySelected
                        ? () {
                            final selectedItems = cartItems
                                .where((i) => i['selected'] == true)
                                .toList();

                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => DeliveryMethodScreen(
                                  items: selectedItems,
                                  total: totalPrice,
                                ),
                              ),
                            );
                          }
                        : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: anySelected ? mainColor : Colors.grey,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 30,
                        vertical: 12,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                    ),
                    child: Text(
                      'Continuar compra',
                      style: TextStyle(
                        color: anySelected ? Colors.white : Colors.grey[400],
                      ),
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}
