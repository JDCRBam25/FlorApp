import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:florapp/models/product.dart';

class FavoriteProductsProvider extends ChangeNotifier {
  List<Product> favoriteItems = [];

  Future<void> loadFavorites(String userId) async {
    final favoriteCollection = FirebaseFirestore.instance
        .collection('Usuarios')
        .doc(userId)
        .collection('favorites');

    final snapshot = await favoriteCollection.get();
    favoriteItems = snapshot.docs.map((doc) {
      final data = doc.data();
      return Product(
        id: doc.id, // asignar id aquí
        productName: data['productName'],
        productImage: data['productImage'],
        originalPrice: (data['originalPrice'] as num).toDouble(),
        discountedPrice: (data['discountedPrice'] as num).toDouble(),
        description: data['description'],
      );
    }).toList();

    notifyListeners();
  }

  Future<void> toggleFavorite(Product product, String userId) async {
    final favoriteCollection = FirebaseFirestore.instance
        .collection('Usuarios')
        .doc(userId)
        .collection('favorites');

    final index = favoriteItems.indexWhere((fav) => fav.id == product.id);

    if (index != -1) {
      final docId = favoriteItems[index].id;
      favoriteItems.removeAt(index);
      if (docId != null) {
        await favoriteCollection.doc(docId).delete();
      }
    } else {
      final docRef = await favoriteCollection.add({
        'productName': product.productName,
        'productImage': product.productImage,
        'originalPrice': product.originalPrice,
        'discountedPrice': product.discountedPrice,
        'description': product.description,
        'timestamp': FieldValue.serverTimestamp(),
      });

      final newProduct = product.copyWith(id: docRef.id);
      favoriteItems.add(newProduct);
    }

    notifyListeners();
  }

  bool isFavorite(Product product) {
    return favoriteItems.any((fav) => fav.id == product.id);
  }
}
