import 'dart:io';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';

class AddProductScreen extends StatefulWidget {
  @override
  _AddProductScreenState createState() => _AddProductScreenState();
}

class _AddProductScreenState extends State<AddProductScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _priceController = TextEditingController();
  final _descriptionController = TextEditingController();

  final List<String> categories = [
    'Seleccione',
    'Artefactos',
    'Arreglos',
    'Eventos',
    'Ramos',
    'Carteras',
    'Personalizados',
  ];

  String selectedCategory = 'Seleccione';
  File? _selectedImage;

  Future<void> _pickImage() async {
    final picked = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (picked != null) {
      setState(() => _selectedImage = File(picked.path));
    }
  }

  Future<String> _uploadImage(File file) async {
    final ref = FirebaseStorage.instance
        .ref()
        .child('productos/${DateTime.now().millisecondsSinceEpoch}.jpg');
    await ref.putFile(file);
    return ref.getDownloadURL();
  }

  Future<void> _addProduct() async {
    if (!_formKey.currentState!.validate()) return;

    if (_selectedImage == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Selecciona una imagen')),
      );
      return;
    }

    try {
      final imageUrl = await _uploadImage(_selectedImage!);
      await FirebaseFirestore.instance.collection('productos').add({
        'nombre': _nameController.text.trim(),
        'precio': double.tryParse(_priceController.text) ?? 0.0,
        'descripcion': _descriptionController.text.trim(),
        'categoria': selectedCategory,
        'imagenURL': imageUrl,
        'activo': true,
        'fechaCreacion': FieldValue.serverTimestamp(),
      });

      Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al agregar: $e')),
      );
    }
  }

  Widget _buildTextInput(TextEditingController controller, String label,
      {TextInputType keyboardType = TextInputType.text, int maxLines = 1}) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      maxLines: maxLines,
      decoration: InputDecoration(
        labelText: label,
        border: const OutlineInputBorder(),
        filled: true,
        fillColor: Colors.white,
      ),
      validator: (value) =>
          value == null || value.trim().isEmpty ? 'Campo requerido' : null,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        title: const Text('Nuevo Producto'),
        backgroundColor: const Color(0xFFAC0A0A),
        foregroundColor: Colors.white,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                _buildTextInput(_nameController, 'Nombre*'),
                const SizedBox(height: 12),
                _buildTextInput(_priceController, 'Precio*',
                    keyboardType: TextInputType.number),
                const SizedBox(height: 12),
                _buildTextInput(_descriptionController, 'Descripción',
                    maxLines: 3),
                const SizedBox(height: 12),
                DropdownButtonFormField<String>(
                  value: selectedCategory,
                  decoration: const InputDecoration(
                    labelText: 'Categoría*',
                    border: OutlineInputBorder(),
                    filled: true,
                    fillColor: Colors.white,
                  ),
                  items: categories
                      .map((cat) => DropdownMenuItem(
                          value: cat, child: Text(cat)))
                      .toList(),
                  onChanged: (value) => setState(() => selectedCategory = value!),
                  validator: (value) => value == 'Seleccione'
                      ? 'Selecciona una categoría'
                      : null,
                ),
                const SizedBox(height: 16),
                if (_selectedImage != null)
                  Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey.shade400),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.file(_selectedImage!, height: 180, fit: BoxFit.cover),
                    ),
                  ),
                ElevatedButton.icon(
                  onPressed: _pickImage,
                  icon: const Icon(Icons.image),
                  label: Text(
                      _selectedImage == null ? 'Seleccionar Imagen' : 'Cambiar Imagen'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFAC0A0A),
                    foregroundColor: Colors.white,
                  ),
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: _addProduct,
                    icon: const Icon(Icons.save),
                    label: const Text('Guardar Producto'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFAC0A0A),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
