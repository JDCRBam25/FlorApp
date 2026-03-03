import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../screens/add_card_form.dart';
import '../screens/edit_card_form.dart';
import '../screensadmin/loginscreen.dart'; // Asegúrate de importar la pantalla de login

const Color rojoPrincipal = Color(0xFFD32F2F);

class TarjetasScreen extends StatefulWidget {
  const TarjetasScreen({super.key});

  @override
  State<TarjetasScreen> createState() => _TarjetasScreenState();
}

class _TarjetasScreenState extends State<TarjetasScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  late String _userId;
  late String _userName = '';

  @override
  void initState() {
    super.initState();
    final user = _auth.currentUser;
    _userId = user?.uid ?? '';
    if (_userId.isNotEmpty) {
      _loadUserData();
    }
  }

  Future<void> _loadUserData() async {
    final doc = await _firestore.collection('Usuarios').doc(_userId).get();
    if (doc.exists && mounted) {
      setState(() {
        _userName = doc['Nombre'] ?? '';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = _auth.currentUser;
    final bool isGuest = user == null || user.isAnonymous;

    return Scaffold(
      backgroundColor: const Color(0xFFF3F3F3),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        title: const Text(
          'Mis tarjetas',
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: isGuest
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.lock_outline, size: 80, color: Colors.grey),
                  const SizedBox(height: 20),
                  const Text(
                    'Debes iniciar sesión para ver tus tarjetas',
                    style: TextStyle(fontSize: 16, color: Colors.grey),
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton.icon(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const LoginScreen()),
                      );
                    },
                    icon: const Icon(Icons.login),
                    label: const Text('Iniciar sesión'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: rojoPrincipal,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                    ),
                  ),
                ],
              ),
            )
          : Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8),
              child: StreamBuilder<QuerySnapshot>(
                stream: _firestore
                    .collection('Tarjetas')
                    .where('userId', isEqualTo: _userId)
                    .snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(
                            Icons.credit_card_off,
                            size: 80,
                            color: Colors.grey,
                          ),
                          const SizedBox(height: 20),
                          const Text(
                            'Aún no has guardado ninguna tarjeta.',
                            textAlign: TextAlign.center,
                            style: TextStyle(fontSize: 16, color: Colors.grey),
                          ),
                        ],
                      ),
                    );
                  }

                  return ListView.builder(
                    itemCount: snapshot.data!.docs.length,
                    itemBuilder: (context, index) {
                      final card = snapshot.data!.docs[index];
                      return _buildCardItem(card);
                    },
                  );
                },
              ),
            ),
      floatingActionButton: isGuest
          ? null
          : FloatingActionButton.extended(
              onPressed: () {
                Navigator.of(context).push(_crearRutaAnimada());
              },
              backgroundColor: rojoPrincipal,
              foregroundColor: Colors.white,
              icon: const Icon(Icons.add),
              label: const Text(
                'Añadir tarjeta',
                style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
              ),
            ),
    );
  }

  Widget _buildCardItem(DocumentSnapshot card) {
    final cardNumber = card['cardNumber'] as String;
    final cardName = card['cardName'] as String;
    final expiryDate = card['expiryDate'] as String;
    final cardType = _determineCardType(cardNumber);

    return Card(
      color: const Color(0xFF1E1E1E),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 6,
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Icon(Icons.credit_card, size: 30, color: Colors.white),
                Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.edit, color: Colors.white70),
                      onPressed: () => _editCard(card),
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete, color: Colors.redAccent),
                      onPressed: () => _confirmDelete(card.id),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 20),
            Text(
              '•••• •••• •••• ${cardNumber.substring(cardNumber.length - 4)}',
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w600,
                color: Colors.white,
                letterSpacing: 2,
              ),
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildInfoColumn('Titular', cardName),
                _buildInfoColumn('Expira', expiryDate),
                _buildInfoColumn('Tipo', cardType),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoColumn(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(color: Colors.grey, fontSize: 12)),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 14,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Future<void> _confirmDelete(String cardId) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Confirmar eliminación'),
        content: const Text(
          '¿Estás seguro de que deseas eliminar esta tarjeta?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );
    if (confirm == true) {
      _deleteCard(cardId);
    }
  }

  Future<void> _deleteCard(String cardId) async {
    try {
      await _firestore.collection('Tarjetas').doc(cardId).delete();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Tarjeta eliminada correctamente')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al eliminar tarjeta: $e')),
        );
      }
    }
  }

  Future<void> _editCard(DocumentSnapshot card) async {
    final result = await Navigator.of(context).push(
      PageRouteBuilder(
        pageBuilder: (_, animation, __) => EditCardForm(
          cardId: card.id,
          currentCardNumber: card['cardNumber'],
          currentCardName: card['cardName'],
          currentExpiryDate: card['expiryDate'],
          currentCvv: card['cvv'],
          userId: _userId,
          userName: _userName,
        ),
        transitionsBuilder: (_, animation, __, child) {
          return FadeTransition(
            opacity: animation.drive(
              Tween(begin: 0.0, end: 1.0).chain(CurveTween(curve: Curves.easeInOut)),
            ),
            child: child,
          );
        },
        transitionDuration: const Duration(milliseconds: 400),
      ),
    );

    if (result == true && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Tarjeta actualizada correctamente')),
      );
    }
  }

  String _determineCardType(String cardNumber) {
    if (cardNumber.startsWith('4')) return 'Visa';
    if (cardNumber.startsWith('5')) return 'Mastercard';
    if (cardNumber.startsWith('34') || cardNumber.startsWith('37')) return 'Amex';
    return 'Crédito';
  }

  Route _crearRutaAnimada() {
    return PageRouteBuilder(
      pageBuilder: (context, animation, secondaryAnimation) =>
          AddCardForm(userId: _userId, userName: _userName),
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        final fade = animation.drive(
          Tween(begin: 0.0, end: 1.0).chain(CurveTween(curve: Curves.easeInOut)),
        );
        return FadeTransition(opacity: fade, child: child);
      },
      transitionDuration: const Duration(milliseconds: 400),
    );
  }
}
