import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:florapp/widgets/product_card.dart';
import 'package:florapp/models/product.dart';

enum SortOrder { priceAsc, priceDesc }

class CategoryProductsScreen extends StatefulWidget {
  final String categoryName;

  const CategoryProductsScreen({Key? key, required this.categoryName})
    : super(key: key);

  @override
  State<CategoryProductsScreen> createState() => _CategoryProductsScreenState();
}

class _CategoryProductsScreenState extends State<CategoryProductsScreen> {
  SortOrder _sortOrder = SortOrder.priceAsc;
  double? _minPrice;
  double? _maxPrice;
  String _searchText = '';

  Product _productFromFirestore(Map<String, dynamic> data) {
    return Product(
      productName: data['nombre'] ?? '',
      productImage: data['imagenURL'] ?? '',
      originalPrice: (data['precio'] ?? 0).toDouble(),
      discountedPrice: (data['precio'] ?? 0).toDouble(),
      description: data['descripcion'] ?? '',
    );
  }

  Query _buildQuery() {
    Query query = FirebaseFirestore.instance
        .collection('productos')
        .where('categoria', isEqualTo: widget.categoryName);

    if (_minPrice != null) {
      query = query.where('precio', isGreaterThanOrEqualTo: _minPrice);
    }
    if (_maxPrice != null) {
      query = query.where('precio', isLessThanOrEqualTo: _maxPrice);
    }

    query = query.orderBy(
      'precio',
      descending: _sortOrder == SortOrder.priceDesc,
    );

    return query;
  }

  @override
  Widget build(BuildContext context) {
    final query = _buildQuery();

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: Text(
          widget.categoryName,
          style: const TextStyle(color: Color.fromARGB(255, 0, 0, 0)),
        ),
        iconTheme: const IconThemeData(color: Color.fromARGB(255, 0, 0, 0)),
        actions: [
          PopupMenuButton<SortOrder>(
            icon: const Icon(Icons.sort, color: Color.fromARGB(255, 0, 0, 0)),
            onSelected: (SortOrder selected) {
              setState(() {
                _sortOrder = selected;
              });
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: SortOrder.priceAsc,
                child: Text('Precio: menor a mayor'),
              ),
              const PopupMenuItem(
                value: SortOrder.priceDesc,
                child: Text('Precio: mayor a menor'),
              ),
            ],
          ),
          IconButton(
            icon: const Icon(Icons.filter_alt, color: Color.fromARGB(255, 0, 0, 0)),
            onPressed: () async {
              final result = await showDialog<Map<String, double?>>(
                context: context,
                builder: (context) =>
                    PriceFilterDialog(minPrice: _minPrice, maxPrice: _maxPrice),
              );
              if (result != null) {
                setState(() {
                  _minPrice = result['min'];
                  _maxPrice = result['max'];
                });
              }
            },
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(56),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            child: TextField(
              
              decoration: InputDecoration(
                hintText: 'Buscar productos...',
                hintStyle: const TextStyle(color: Color(0xFFB71C1C)),
                prefixIcon: const Icon(Icons.search, color: Color(0xFFB71C1C)),
                filled: true,
                fillColor: const Color(0xFFFFFFFF),
                border: const UnderlineInputBorder(
                  borderSide: BorderSide(color: Color(0xFFB71C1C)),
                ),
                enabledBorder: const UnderlineInputBorder(
                  borderSide: BorderSide(color: Color(0xFFB71C1C)),
                ),
                focusedBorder: const UnderlineInputBorder(
                  borderSide: BorderSide(color: Color(0xFFB71C1C), width: 2),
                ),
                contentPadding: const EdgeInsets.symmetric(
                  vertical: 10,
                  horizontal: 12,
                ),
              ),
              onChanged: (value) {
                setState(() {
                  _searchText = value.trim().toLowerCase();
                });
              },
            ),
          ),
        ),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: query.snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text('No hay productos'));
          }

          final docs = snapshot.data!.docs;
          List<Map<String, dynamic>> filteredDocs = docs
              .map((doc) => doc.data()! as Map<String, dynamic>)
              .toList();

          if (_searchText.isNotEmpty) {
            filteredDocs = filteredDocs.where((prod) {
              return (prod['nombre'] ?? '').toString().toLowerCase().contains(
                _searchText,
              );
            }).toList();
          }

          return GridView.builder(
            padding: const EdgeInsets.all(12),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              mainAxisSpacing: 12,
              crossAxisSpacing: 12,
              childAspectRatio: 0.68,
            ),
            itemCount: filteredDocs.length,
            itemBuilder: (context, index) {
              final product = _productFromFirestore(filteredDocs[index]);

              return ProductCard(
                productName: product.productName,
                productImage: product.productImage,
                originalPrice: product.originalPrice,
                discountedPrice: product.discountedPrice,
                description: product.description,
                initiallyFavorite: false,
              );
            },
          );
        },
      ),
    );
  }
}

class PriceFilterDialog extends StatefulWidget {
  final double? minPrice;
  final double? maxPrice;

  const PriceFilterDialog({this.minPrice, this.maxPrice, Key? key})
    : super(key: key);

  @override
  State<PriceFilterDialog> createState() => _PriceFilterDialogState();
}

class _PriceFilterDialogState extends State<PriceFilterDialog> {
  late TextEditingController minController;
  late TextEditingController maxController;

  @override
  void initState() {
    super.initState();
    minController = TextEditingController(
      text: widget.minPrice?.toString() ?? '',
    );
    maxController = TextEditingController(
      text: widget.maxPrice?.toString() ?? '',
    );
  }

  @override
  void dispose() {
    minController.dispose();
    maxController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Filtrar por precio'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: minController,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(labelText: 'Precio mínimo'),
          ),
          TextField(
            controller: maxController,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(labelText: 'Precio máximo'),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancelar'),
        ),
        ElevatedButton(
          onPressed: () {
            final min = double.tryParse(minController.text);
            final max = double.tryParse(maxController.text);
            Navigator.pop(context, {'min': min, 'max': max});
          },
          child: const Text('Aplicar'),
        ),
      ],
    );
  }
}
