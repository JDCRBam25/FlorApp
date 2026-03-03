import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:florapp/admin/Edit.dart';

class AdminUsersScreen extends StatefulWidget {
  const AdminUsersScreen({Key? key}) : super(key: key);

  @override
  State<AdminUsersScreen> createState() => _AdminUsersScreenState();
}

class _AdminUsersScreenState extends State<AdminUsersScreen> {
  String _searchText = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        backgroundColor: const Color(0xFFAC0A0A),
        foregroundColor: Colors.white,
        title: const Text('Gestión de Usuarios'),
        actions: [
          IconButton(
            icon: const Icon(Icons.person_add_alt_1),
            tooltip: 'Agregar administrador',
            onPressed: () => _showAddAdminDialog(context),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              decoration: const InputDecoration(
                labelText: 'Buscar por nombre',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(),
                filled: true,
                fillColor: Colors.white,
              ),
              onChanged: (val) {
                setState(() {
                  _searchText = val.toLowerCase().trim();
                });
              },
            ),
            const SizedBox(height: 20),
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream:
                    FirebaseFirestore.instance.collection('Usuarios').snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting)
                    return const Center(child: CircularProgressIndicator());
                  if (snapshot.hasError) return const SizedBox.shrink();
                  if (!snapshot.hasData || snapshot.data!.docs.isEmpty)
                    return const Center(child: Text('No hay usuarios registrados'));

                  final docs = snapshot.data!.docs;

                  final admins = docs.where((doc) {
                    final data = doc.data() as Map<String, dynamic>?;
                    final role = data?['role']?.toString().toLowerCase() ?? '';
                    final nombre = data?['Nombre']?.toString().toLowerCase() ?? '';
                    return role == 'admin' && nombre.contains(_searchText);
                  }).toList();

                  final users = docs.where((doc) {
                    final data = doc.data() as Map<String, dynamic>?;
                    final role = data?['role']?.toString().toLowerCase() ?? '';
                    final nombre = data?['Nombre']?.toString().toLowerCase() ?? '';
                    return role == 'user' && nombre.contains(_searchText);
                  }).toList();

                  return SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (admins.isNotEmpty) ...[
                          const Text(
                            'Administradores',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFFAC0A0A),
                            ),
                          ),
                          const SizedBox(height: 8),
                          _buildUserTable(admins),
                          const SizedBox(height: 30),
                        ],
                        if (users.isNotEmpty) ...[
                          const Text(
                            'Usuarios',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.black87,
                            ),
                          ),
                          const SizedBox(height: 8),
                          _buildUserTable(users),
                        ],
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildUserTable(List<QueryDocumentSnapshot> users) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: DataTable(
        headingRowColor: MaterialStateProperty.all(Colors.grey.shade200),
        columnSpacing: 16,
        columns: const [
          DataColumn(label: Text('Nombre')),
          DataColumn(label: Text('Apellidos')),
          DataColumn(label: Text('Email')),
          DataColumn(label: Text('Rol')),
          DataColumn(label: Text('Acciones')),
        ],
        rows: users.map((doc) {
          final data = doc.data() as Map<String, dynamic>?;
          return DataRow(
            cells: [
              DataCell(Text(data?['Nombre'] ?? '')),
              DataCell(Text(data?['Apellidos'] ?? '')),
              DataCell(Text(data?['Email'] ?? '')),
              DataCell(Text(data?['role'] ?? '')),
              DataCell(Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.edit, color: Colors.blue),
                    tooltip: 'Editar usuario',
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => EditUserScreen(userId: doc.id),
                        ),
                      );
                    },
                  ),
                  IconButton(
                    icon: const Icon(Icons.delete, color: Colors.red),
                    tooltip: 'Eliminar usuario',
                    onPressed: () async {
                      final confirm = await showDialog<bool>(
                        context: context,
                        builder: (context) => AlertDialog(
                          title: const Text('Confirmar eliminación'),
                          content: const Text(
                              '¿Seguro que quieres eliminar este usuario?'),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.pop(context, false),
                              child: const Text('Cancelar'),
                            ),
                            TextButton(
                              onPressed: () => Navigator.pop(context, true),
                              child: const Text('Eliminar',
                                  style: TextStyle(color: Colors.red)),
                            ),
                          ],
                        ),
                      );
                      if (confirm == true) {
                        await FirebaseFirestore.instance
                            .collection('Usuarios')
                            .doc(doc.id)
                            .delete();
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Usuario eliminado')),
                        );
                      }
                    },
                  ),
                ],
              )),
            ],
          );
        }).toList(),
      ),
    );
  }

  void _showAddAdminDialog(BuildContext context) {
    final _formKey = GlobalKey<FormState>();
    final _nameController = TextEditingController();
    final _lastNameController = TextEditingController();
    final _emailController = TextEditingController();
    final _passwordController = TextEditingController();

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: Colors.white,
        title: const Text('Agregar Administrador'),
        content: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: _nameController,
                  decoration: const InputDecoration(labelText: 'Nombre'),
                  validator: (value) => value!.isEmpty ? 'Campo requerido' : null,
                ),
                TextFormField(
                  controller: _lastNameController,
                  decoration: const InputDecoration(labelText: 'Apellidos'),
                  validator: (value) => value!.isEmpty ? 'Campo requerido' : null,
                ),
                TextFormField(
                  controller: _emailController,
                  decoration: const InputDecoration(labelText: 'Email'),
                  validator: (value) =>
                      !value!.contains('@') ? 'Email inválido' : null,
                ),
                TextFormField(
                  controller: _passwordController,
                  decoration: const InputDecoration(labelText: 'Contraseña'),
                  obscureText: true,
                  validator: (value) =>
                      value!.length < 6 ? 'Mínimo 6 caracteres' : null,
                ),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            child: const Text('Cancelar', style: TextStyle(color: Colors.black)),
            onPressed: () => Navigator.pop(context),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFAC0A0A),
              foregroundColor: Colors.white,
            ),
            child: const Text('Guardar'),
            onPressed: () async {
              if (_formKey.currentState!.validate()) {
                try {
                  final credential = await FirebaseAuth.instance
                      .createUserWithEmailAndPassword(
                    email: _emailController.text.trim(),
                    password: _passwordController.text.trim(),
                  );

                  await FirebaseFirestore.instance
                      .collection('Usuarios')
                      .doc(credential.user!.uid)
                      .set({
                    'Nombre': _nameController.text.trim(),
                    'Apellidos': _lastNameController.text.trim(),
                    'Email': _emailController.text.trim(),
                    'role': 'admin',
                    'fechaCreacion': FieldValue.serverTimestamp(),
                  });

                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Administrador registrado ✅')),
                  );
                } catch (e) {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Error: $e')),
                  );
                }
              }
            },
          ),
        ],
      ),
    );
  }
}
