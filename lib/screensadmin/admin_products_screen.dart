import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:florapp/screensadmin/add_product_screen.dart';
import 'package:florapp/screensadmin/edit_product_screen.dart';
import '../services/product_service.dart';

class AdminProductsScreen extends StatefulWidget {
  const AdminProductsScreen({Key? key}) : super(key: key);

  @override
  State<AdminProductsScreen> createState() => _AdminProductsScreenState();
}

class _AdminProductsScreenState extends State<AdminProductsScreen> {
  bool _useCards = true;
  String _searchTerm = '';
  String _selectedCategory = 'Todas';

  final List<String> _categories = [
    'Todas',
    'Artefactos',
    'Arreglos',
    'Eventos',
    'Ramos',
    'Carteras',
    'Personalizados',
  ];

  void _editProd(BuildContext context, String productId) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EditProductScreen(productId: productId),
      ),
    );
  }

  void _confirmDelete(BuildContext context, String productId) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirmar eliminación'),
        content: const Text('¿Seguro que quieres eliminar este producto?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () {
              deleteProduct(context, productId);
              Navigator.pop(context);
            },
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );
  }

  void _refreshProduct(BuildContext context, String productId) {
    refreshProduct(context, productId);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5), // fondo general gris claro
      appBar: AppBar(
        backgroundColor: const Color(0xFFAC0A0A),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Gestión de Productos',
          style: TextStyle(color: Colors.white),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // BARRA DE BÚSQUEDA
            TextField(
              decoration: const InputDecoration(
                hintText: 'Buscar por nombre...',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(),
                filled: true,
                fillColor: Colors.white,
              ),
              onChanged: (value) => setState(() => _searchTerm = value.trim().toLowerCase()),
            ),
            const SizedBox(height: 12),

            // FILTROS Y BOTONES
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: [
                DropdownButton<String>(
                  value: _selectedCategory,
                  items: _categories.map((c) {
                    return DropdownMenuItem<String>(
                      value: c,
                      child: Text(c),
                    );
                  }).toList(),
                  onChanged: (value) => setState(() => _selectedCategory = value!),
                ),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text('Vista:'),
                    Switch(
                      value: _useCards,
                      onChanged: (value) => setState(() => _useCards = value),
                      activeColor: const Color(0xFFAC0A0A),
                    ),
                    Text(_useCards ? 'Tarjetas' : 'Tabla'),
                  ],
                ),
                ElevatedButton.icon(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => AddProductScreen()),
                    );
                  },
                  icon: const Icon(Icons.add),
                  label: const Text('Agregar'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFAC0A0A),
                    foregroundColor: Colors.white,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Expanded(child: _buildProductsView(context)),
          ],
        ),
      ),
    );
  }

  Widget _buildProductsView(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance.collection('productos').snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting)
          return const Center(child: CircularProgressIndicator());
        if (snapshot.hasError)
          return const Center(child: Text('Error al cargar productos'));
        if (!snapshot.hasData || snapshot.data!.docs.isEmpty)
          return const Center(child: Text('No hay productos registrados'));

        final allProducts = snapshot.data!.docs;
        final filteredProducts = allProducts.where((doc) {
          final data = doc.data() as Map<String, dynamic>;
          final name = (data['nombre'] ?? '').toString().toLowerCase();
          final category = (data['categoria'] ?? '').toString();
          return name.contains(_searchTerm) &&
              (_selectedCategory == 'Todas' || category == _selectedCategory);
        }).toList();

        if (_useCards) {
          return ListView.separated(
            itemCount: filteredProducts.length,
            separatorBuilder: (_, __) => const SizedBox(height: 10),
            itemBuilder: (context, index) {
              final product = filteredProducts[index];
              final data = product.data() as Map<String, dynamic>;

              return Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  border: Border.all(color: const Color(0xFFAC0A0A), width: 1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    ClipRRect(
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(8),
                        bottomLeft: Radius.circular(8),
                      ),
                      child: Image.network(
                        data['imagenURL'] ?? '',
                        width: 100,
                        height: 100,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) =>
                            const Icon(Icons.broken_image, size: 100),
                      ),
                    ),
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.all(12),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              data['nombre'] ?? 'Sin nombre',
                              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                            ),
                            const SizedBox(height: 4),
                            Text('Categoría: ${data['categoria'] ?? 'Sin categoría'}'),
                            Text('Precio: S/${(data['precio'] as num?)?.toStringAsFixed(2) ?? '0.00'}'),
                          ],
                        ),
                      ),
                    ),
                    Column(
                      children: [
                        IconButton(
                          icon: const Icon(Icons.edit, color: Colors.blue),
                          onPressed: () => _editProd(context, product.id),
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete, color: Colors.red),
                          onPressed: () => _confirmDelete(context, product.id),
                        ),
                        IconButton(
                          icon: const Icon(Icons.refresh, color: Colors.green),
                          onPressed: () => _refreshProduct(context, product.id),
                        ),
                      ],
                    ),
                  ],
                ),
              );
            },
          );
        } else {
          return SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: DataTable(
              columns: const [
                DataColumn(label: Text('Nombre')),
                DataColumn(label: Text('Categoría')),
                DataColumn(label: Text('Precio')),
                DataColumn(label: Text('Acciones')),
              ],
              rows: filteredProducts.map((product) {
                final data = product.data() as Map<String, dynamic>;
                return DataRow(
                  cells: [
                    DataCell(Text(data['nombre'] ?? 'Sin nombre')),
                    DataCell(Text(data['categoria'] ?? 'Sin categoría')),
                    DataCell(Text('S/${(data['precio'] as num?)?.toStringAsFixed(2) ?? '0.00'}')),
                    DataCell(
                      Row(
                        children: [
                          IconButton(
                            icon: const Icon(Icons.edit, color: Colors.blue),
                            onPressed: () => _editProd(context, product.id),
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete, color: Colors.red),
                            onPressed: () => _confirmDelete(context, product.id),
                          ),
                          IconButton(
                            icon: const Icon(Icons.refresh, color: Colors.green),
                            onPressed: () => _refreshProduct(context, product.id),
                          ),
                        ],
                      ),
                    ),
                  ],
                );
              }).toList(),
            ),
          );
        }
      },
    );
  }
}
