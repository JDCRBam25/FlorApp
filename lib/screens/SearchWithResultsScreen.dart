// lib/screens/search_with_results_screen.dart

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:florapp/widgets/product_card.dart';

class SearchWithResultsScreen extends StatefulWidget {
  final String initialQuery;

  const SearchWithResultsScreen({
    Key? key,
    this.initialQuery = '',
  }) : super(key: key);

  @override
  State<SearchWithResultsScreen> createState() =>
      _SearchWithResultsScreenState();
}

class _SearchWithResultsScreenState extends State<SearchWithResultsScreen> {
  late TextEditingController _searchController;
  String _searchText = '';
  List<DocumentSnapshot> _results = [];
  List<String> _categories = ['Todos'];
  String _selectedCategory = 'Todos';
  String _priceOrder = 'Ninguno';
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController(text: widget.initialQuery);
    _searchText = widget.initialQuery;
    if (_searchText.isNotEmpty) {
      // Ejecutar búsqueda al montar la pantalla
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _performSearch(_searchText);
      });
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _performSearch(String query) async {
    setState(() {
      _isLoading = true;
      _searchText = query;
    });

    // Cargamos todos los productos habilitados
    final snapshot = await FirebaseFirestore.instance
        .collection('productos')
        .where('activo', isEqualTo: true)
        .get();

    final allDocs = snapshot.docs;
    final foundCategories = <String>{'Todos'};

    // Filtramos en memoria (puedes optimizar con queries compuestos e índices)
    final lowerQuery = query.toLowerCase();
    final filtered = allDocs.where((doc) {
      final data = doc.data() as Map<String, dynamic>;
      final name = (data['nombre'] ?? '').toString().toLowerCase();
      final category = (data['categoria'] ?? '').toString().toLowerCase();
      final price = (data['precio']?.toString() ?? '');

      // Construimos set de categorías dinámicas
      foundCategories.add(data['categoria'] ?? 'Sin categoría');

      // match bidireccional en nombre y categoría
      final matchesName = name.contains(lowerQuery) || lowerQuery.contains(name);
      final matchesCategory =
          category.contains(lowerQuery) || lowerQuery.contains(category);
      final matchesPrice = price.contains(lowerQuery);

      return matchesName || matchesCategory || matchesPrice;
    }).toList();

    // Filtrar por categoría si no es "Todos"
    var finalResults = filtered;
    if (_selectedCategory != 'Todos') {
      finalResults = finalResults.where((doc) {
        final data = doc.data() as Map<String, dynamic>;
        return (data['categoria'] ?? '') == _selectedCategory;
      }).toList();
    }

    // Ordenar por precio
    if (_priceOrder == 'Menor a mayor') {
      finalResults.sort((a, b) {
        final da = (a['precio'] ?? 0) as num;
        final db = (b['precio'] ?? 0) as num;
        return da.compareTo(db);
      });
    } else if (_priceOrder == 'Mayor a menor') {
      finalResults.sort((a, b) {
        final da = (a['precio'] ?? 0) as num;
        final db = (b['precio'] ?? 0) as num;
        return db.compareTo(da);
      });
    }

    setState(() {
      _categories = foundCategories.toList();
      _results = finalResults;
      _isLoading = false;
    });
  }

  void _onSearchSubmitted(String text) {
    if (text.trim().isEmpty) return;
    _performSearch(text.trim());
  }

  void _onCategoryChanged(String? newCat) {
    if (newCat == null) return;
    setState(() => _selectedCategory = newCat);
    _performSearch(_searchText);
  }

  void _onOrderChanged(String? newOrder) {
    if (newOrder == null) return;
    setState(() => _priceOrder = newOrder);
    _performSearch(_searchText);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white, // fondo blanco
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 1,
        title: SizedBox(
          height: 40,
          child: TextField(
            controller: _searchController,
            textInputAction: TextInputAction.search,
            onSubmitted: _onSearchSubmitted,
            decoration: InputDecoration(
              hintText: 'Buscar productos...',
              fillColor: Colors.grey[100],
              filled: true,
              prefixIcon: const Icon(Icons.search, color: Color(0xFFA50302)),
              suffixIcon: _searchController.text.isNotEmpty
                  ? IconButton(
                      icon: const Icon(Icons.clear, color: Color(0xFFA50302)),
                      onPressed: () {
                        _searchController.clear();
                        setState(() {
                          _searchText = '';
                          _results.clear();
                        });
                      },
                    )
                  : null,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(30),
                borderSide: BorderSide.none,
              ),
            ),
          ),
        ),
      ),
      body: Column(
        children: [
          // --- FILTROS ---
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              children: [
                Expanded(
                  child: DropdownButtonFormField<String>(
                    value: _selectedCategory,
                    items: _categories
                        .map((c) => DropdownMenuItem(
                              value: c,
                              child: Text(c),
                            ))
                        .toList(),
                    onChanged: _onCategoryChanged,
                    decoration: InputDecoration(
                      labelText: 'Categoría',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: DropdownButtonFormField<String>(
                    value: _priceOrder,
                    items: const [
                      'Ninguno',
                      'Menor a mayor',
                      'Mayor a menor',
                    ]
                        .map((o) => DropdownMenuItem(
                              value: o,
                              child: Text(o),
                            ))
                        .toList(),
                    onChanged: _onOrderChanged,
                    decoration: InputDecoration(
                      labelText: 'Orden precio',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          // --- RESULTADOS ---
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _results.isEmpty
                    ? const Center(
                        child: Text(
                          'No se encontraron productos',
                          style: TextStyle(fontSize: 16, color: Colors.grey),
                        ),
                      )
                    : GridView.builder(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 8),
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          mainAxisSpacing: 16,
                          crossAxisSpacing: 16,
                          childAspectRatio: 0.68,
                        ),
                        itemCount: _results.length,
                        itemBuilder: (ctx, i) {
                          final data =
                              _results[i].data()! as Map<String, dynamic>;
                          return ProductCard(
                            productName: data['nombre'] ?? '',
                            productImage: data['imagenURL'] ?? '',
                            originalPrice:
                                (data['precio'] ?? 0).toDouble(),
                            discountedPrice:
                                (data['precio'] ?? 0).toDouble(),
                            description: data['descripcion'] ?? '',
                          );
                        },
                      ),
          ),
        ],
      ),
    );
  }
}
