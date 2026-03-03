// lib/services/product_service.dart
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

Future<void> deleteProduct(BuildContext context, String productId) async {
  try {
    await FirebaseFirestore.instance.collection('productos').doc(productId).delete();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Producto eliminado ✅')),
    );
  } catch (e) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Error al eliminar: $e')),
    );
  }
}

Future<void> refreshProduct(BuildContext context, String productId) async {
  try {
    await FirebaseFirestore.instance.collection('productos').doc(productId).update({
      'ultimaActualizacion': FieldValue.serverTimestamp(),
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Producto actualizado 🔄')),
    );
  } catch (e) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Error al actualizar: $e')),
    );
  }
}
