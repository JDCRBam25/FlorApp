import 'dart:io';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';

class EditProductScreen extends StatefulWidget {
  final String productId;
  const EditProductScreen({required this.productId});

  @override
  _EditProductScreenState createState() => _EditProductScreenState();
}

class _EditProductScreenState extends State<EditProductScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _priceController = TextEditingController();
  final _descriptionController = TextEditingController();

  final List<String> categories = [
    'Artefactos',
    'Arreglos',
    'Eventos',
    'Ramos',
    'Carteras',
    'Personalizados',
  ];

  String? selectedCategory;
  File? _selectedImage;
  String imageUrl = '';

  @override
  void initState() {
    super.initState();
    _loadProductData();
  }

  Future<void> _loadProductData() async {
    final doc = await FirebaseFirestore.instance
        .collection('productos')
        .doc(widget.productId)
        .get();
    final data = doc.data()!;
    _nameController.text = data['nombre'];
    _priceController.text = data['precio'].toString();
    _descriptionController.text = data['descripcion'];
    selectedCategory = data['categoria'];
    imageUrl = data['imagenURL'];
    setState(() {});
  }

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

  Future<void> _updateProduct() async {
    if (!_formKey.currentState!.validate()) return;

    String finalUrl = imageUrl;
    if (_selectedImage != null) {
      finalUrl = await _uploadImage(_selectedImage!);
    }

    try {
      await FirebaseFirestore.instance
          .collection('productos')
          .doc(widget.productId)
          .update({
        'nombre': _nameController.text.trim(),
        'precio': double.tryParse(_priceController.text) ?? 0.0,
        'descripcion': _descriptionController.text.trim(),
        'categoria': selectedCategory,
        'imagenURL': finalUrl,
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Producto actualizado ✅')),
      );
      Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al actualizar: $e')),
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
        backgroundColor: const Color(0xFFAC0A0A),
        title: const Text('Editar Producto'),
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
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
                          value: cat,
                          child: Text(cat),
                        ))
                    .toList(),
                onChanged: (value) => setState(() => selectedCategory = value),
                validator: (value) =>
                    value == null ? 'Selecciona una categoría' : null,
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
                    child: Image.file(
                      _selectedImage!,
                      height: 180,
                      fit: BoxFit.cover,
                    ),
                  ),
                )
              else if (imageUrl.isNotEmpty)
                Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey.shade400),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.network(
                      imageUrl,
                      height: 180,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) =>
                          const Icon(Icons.broken_image, size: 100),
                    ),
                  ),
                ),
              ElevatedButton.icon(
                onPressed: _pickImage,
                icon: const Icon(Icons.image),
                label: Text(_selectedImage == null
                    ? 'Cambiar Imagen'
                    : 'Seleccionar Nueva'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFAC0A0A),
                  foregroundColor: Colors.white,
                ),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: _updateProduct,
                  icon: const Icon(Icons.save),
                  label: const Text('Actualizar Producto'),
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
    );
  }
}
