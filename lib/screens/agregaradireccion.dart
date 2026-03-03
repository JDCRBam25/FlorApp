import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';

const Color rojoPrincipal = Color.fromARGB(255, 172, 10, 10);

class DireccionFormScreen extends StatefulWidget {
  final String userId;
  final String? direccionId;
  final Map<String, dynamic>? data;

  const DireccionFormScreen({
    super.key,
    required this.userId,
    this.direccionId,
    this.data,
  });

  @override
  State<DireccionFormScreen> createState() => _DireccionFormScreenState();
}

class _DireccionFormScreenState extends State<DireccionFormScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _direccionController;
  late TextEditingController _departamentoController;
  late TextEditingController _provinciaController;
  late TextEditingController _distritoController;
  late TextEditingController _apartamentoController;
  late TextEditingController _referenciasController;
  late TextEditingController _nombreController;
  late TextEditingController _telefonoController;

  bool _sinNumero = false;
  String _tipoDomicilio = "Residencial";

  final List<String> departamentos = [
    'Amazonas',
    'Áncash',
    'Apurímac',
    'Arequipa',
    'Ayacucho',
    'Cajamarca',
    'Callao',
    'Cusco',
    'Huancavelica',
    'Huánuco',
    'Ica',
    'Junín',
    'La Libertad',
    'Lambayeque',
    'Lima',
    'Loreto',
    'Madre de Dios',
    'Moquegua',
    'Pasco',
    'Piura',
    'Puno',
    'San Martín',
    'Tacna',
    'Tumbes',
    'Ucayali'
  ];

  final Map<String, List<String>> provinciasPorDepartamento = {
    'Lima': [
      'Lima',
      'Barranca',
      'Cajatambo',
      'Canta',
      'Cañete',
      'Huaral',
      'Huarochirí',
      'Huaura',
      'Oyon',
      'Yauyos'
    ],
    'Arequipa': [
      'Arequipa',
      'Camana',
      'Caraveli',
      'Castilla',
      'Caylloma',
      'Condesuyos',
      'Islay',
      'La Union'
    ],
    // Agrega provincias para otros departamentos si lo necesitas
  };

  String normalizarDepartamento(String valor) {
    for (final dpto in departamentos) {
      if (valor.toLowerCase().contains(dpto.toLowerCase())) {
        return dpto;
      }
    }
    return '';
  }

  String normalizarProvincia(String dpto, String valor) {
    if (!provinciasPorDepartamento.containsKey(dpto)) return '';
    for (final prov in provinciasPorDepartamento[dpto]!) {
      if (valor.toLowerCase().contains(prov.toLowerCase())) {
        return prov;
      }
    }
    return '';
  }

  @override
  void initState() {
    super.initState();
    _direccionController = TextEditingController(
      text: widget.data?['direccion'] ?? '',
    );
    _departamentoController = TextEditingController(
      text: widget.data?['departamento'] ?? '',
    );
    _provinciaController = TextEditingController(
      text: widget.data?['provincia'] ?? '',
    );
    _distritoController = TextEditingController(
      text: widget.data?['distrito'] ?? '',
    );
    _apartamentoController = TextEditingController(
      text: widget.data?['apartamento'] ?? '',
    );
    _referenciasController = TextEditingController(
      text: widget.data?['referencias'] ?? '',
    );
    _nombreController = TextEditingController(
      text: widget.data?['nombreCompleto'] ?? '',
    );
    _telefonoController = TextEditingController(
      text: widget.data?['telefono'] ?? '',
    );
    _sinNumero = widget.data?['sinNumero'] ?? false;
    _tipoDomicilio = widget.data?['tipo'] ?? "Residencial";
  }

  @override
  void dispose() {
    _direccionController.dispose();
    _departamentoController.dispose();
    _provinciaController.dispose();
    _distritoController.dispose();
    _apartamentoController.dispose();
    _referenciasController.dispose();
    _nombreController.dispose();
    _telefonoController.dispose();
    super.dispose();
  }

  InputDecoration buildDecoration(String label, {String? hint}) {
    return InputDecoration(
      labelText: label,
      hintText: hint,
      filled: true,
      fillColor: Colors.white,
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: Colors.grey, width: 1),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: rojoPrincipal, width: 2),
      ),
      labelStyle: const TextStyle(color: Colors.black),
      floatingLabelStyle: const TextStyle(color: rojoPrincipal),
      counterText: '',
    );
  }

  @override
  Widget build(BuildContext context) {
    final isEdit = widget.direccionId != null;
    final departamentoSeleccionado = _departamentoController.text.isNotEmpty;
    final List<String> provinciasDisponibles = provinciasPorDepartamento[_departamentoController.text] ?? [];

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: rojoPrincipal,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
        title: const Text(
          'Nuevo domicilio',
          style: TextStyle(color: Colors.white),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              Material(
                color: Colors.transparent,
                child: InkWell(
                  borderRadius: BorderRadius.circular(8),
                  onTap: () async {
                    LocationPermission permission = await Geolocator.requestPermission();
                    if (permission == LocationPermission.denied || permission == LocationPermission.deniedForever) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Debes otorgar permisos de ubicación')),
                      );
                      return;
                    }
                    Position position = await Geolocator.getCurrentPosition(
                      desiredAccuracy: LocationAccuracy.high,
                    );
                    List<Placemark> placemarks = await placemarkFromCoordinates(
                      position.latitude,
                      position.longitude,
                    );
                    if (placemarks.isNotEmpty) {
                      final place = placemarks.first;
                      String dpto = normalizarDepartamento(place.administrativeArea ?? '');
                      String prov = normalizarProvincia(dpto, place.subAdministrativeArea ?? '');
                      setState(() {
                        _direccionController.text = '${place.street ?? ''}';
                        _departamentoController.text = dpto;
                        _provinciaController.text = prov;
                        _distritoController.text = '${place.locality ?? ''}';
                      });
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('No se pudo obtener la dirección')),
                      );
                    }
                  },
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 15),
                    child: Row(
                      children: const [
                        Icon(Icons.my_location, color: Colors.blue),
                        SizedBox(width: 6),
                        Text(
                          'Usar mi ubicación',
                          style: TextStyle(
                            color: Colors.blue,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              const Text(
                'Ingresar direccion o lugar',
                style: TextStyle(fontWeight: FontWeight.w500),
              ),

              TextFormField(
                controller: _direccionController,
                decoration: buildDecoration(
                  '',
                  hint: 'Ej: Avenida los leones 4563',
                ),
                validator: (v) =>
                    v == null || v.isEmpty ? 'Campo obligatorio' : null,
              ),
              Row(
                children: [
                  Checkbox(
                    value: _sinNumero,
                    onChanged: (v) => setState(() => _sinNumero = v!),
                  ),
                  const Text('Mi calle no tiene número'),
                ],
              ),
              const SizedBox(height: 12),

              const Text(
                'Departamento',
                style: TextStyle(fontWeight: FontWeight.w500),
              ),
              DropdownButtonFormField<String>(
                value: departamentos.contains(_departamentoController.text)
                    ? _departamentoController.text
                    : null,
                items: departamentos
                    .map((dpto) => DropdownMenuItem(
                          value: dpto,
                          child: Text(dpto),
                        ))
                    .toList(),
                onChanged: (v) {
                  setState(() {
                    _departamentoController.text = v ?? '';
                    _provinciaController.clear();
                    _distritoController.clear();
                  });
                },
                decoration: buildDecoration(''),
                validator: (v) => v == null || v.isEmpty ? 'Campo obligatorio' : null,
              ),
              const SizedBox(height: 12),

              const Text(
                'Provincia',
                style: TextStyle(fontWeight: FontWeight.w500),
              ),
              DropdownButtonFormField<String>(
                value: provinciasDisponibles.contains(_provinciaController.text)
                    ? _provinciaController.text
                    : null,
                items: provinciasDisponibles
                    .map((prov) => DropdownMenuItem(
                          value: prov,
                          child: Text(prov),
                        ))
                    .toList(),
                onChanged: departamentoSeleccionado
                    ? (v) {
                        setState(() {
                          _provinciaController.text = v ?? '';
                          _distritoController.clear();
                        });
                      }
                    : null,
                decoration: buildDecoration(''),
                validator: (v) {
                  if (!departamentoSeleccionado) return null;
                  return v == null || v.isEmpty ? 'Campo obligatorio' : null;
                },
                disabledHint: const Text('Selecciona primero un departamento'),
              ),
              const SizedBox(height: 12),

              const Text(
                'Distrito',
                style: TextStyle(fontWeight: FontWeight.w500),
              ),
              TextFormField(
                controller: _distritoController,
                decoration: buildDecoration(''),
                enabled: departamentoSeleccionado,
                style: TextStyle(
                  color: departamentoSeleccionado ? Colors.black : Colors.grey,
                ),
                validator: (v) {
                  if (!departamentoSeleccionado) return null;
                  return v == null || v.isEmpty ? 'Campo obligatorio' : null;
                },
              ),
              const SizedBox(height: 12),

              const Text(
                'Apartamento',
                style: TextStyle(fontWeight: FontWeight.w500),
              ),
              TextFormField(
                controller: _apartamentoController,
                decoration: buildDecoration('', hint: 'Ej: 12D'),
              ),
              const SizedBox(height: 12),

              const Text(
                'Indicaciones para la entrega (opcional)',
                style: TextStyle(fontWeight: FontWeight.w500),
              ),
              TextFormField(
                controller: _referenciasController,
                decoration: buildDecoration(
                  '',
                  hint:
                      'Ej.: Entre calles, color del edificio, no tiene timbre.',
                ),
                maxLength: 128,
                maxLines: 2,
              ),
              const SizedBox(height: 12),

              const Text(
                'Tipo de domicilio',
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
              Column(
                children: [
                  RadioListTile<String>(
                    value: 'Residencial',
                    groupValue: _tipoDomicilio,
                    title: const Text('Residencial'),
                    secondary: const Icon(Icons.home_outlined),
                    activeColor: rojoPrincipal,
                    onChanged: (value) =>
                        setState(() => _tipoDomicilio = value!),
                  ),
                  RadioListTile<String>(
                    value: 'Laboral',
                    groupValue: _tipoDomicilio,
                    title: const Text('Laboral'),
                    secondary: const Icon(Icons.work_outline),
                    activeColor: rojoPrincipal,
                    onChanged: (value) =>
                        setState(() => _tipoDomicilio = value!),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              const Text(
                'Datos de contacto',
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
              const Text(
                'Te llamaremos si hay un problema con la entrega.',
                style: TextStyle(fontSize: 12, color: Colors.black54),
              ),
              const SizedBox(height: 8),
              const Text(
                'Nombre y Apellido',
                style: TextStyle(fontWeight: FontWeight.w500),
              ),

              TextFormField(
                controller: _nombreController,
                decoration: buildDecoration(''),
                validator: (v) =>
                    v == null || v.isEmpty ? 'Campo obligatorio' : null,
              ),
              const SizedBox(height: 12),
              const Text(
                'Teléfono',
                style: TextStyle(fontWeight: FontWeight.w500),
              ),

              TextFormField(
                controller: _telefonoController,
                decoration: buildDecoration(''),
                keyboardType: TextInputType.phone,
                validator: (v) =>
                    v == null || v.isEmpty ? 'Campo obligatorio' : null,
              ),
              const SizedBox(height: 24),

              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    backgroundColor: rojoPrincipal,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(6),
                    ),
                  ),
                  onPressed: () async {
                    if (_formKey.currentState!.validate()) {
                      final data = {
                        'direccion': _direccionController.text,
                        'sinNumero': _sinNumero,
                        'departamento': _departamentoController.text,
                        'provincia': _provinciaController.text,
                        'distrito': _distritoController.text,
                        'apartamento': _apartamentoController.text,
                        'referencias': _referenciasController.text,
                        'tipo': _tipoDomicilio,
                        'nombreCompleto': _nombreController.text,
                        'telefono': _telefonoController.text,
                      };
                      final ref = FirebaseFirestore.instance
                          .collection('Usuarios')
                          .doc(widget.userId)
                          .collection('Direcciones');
                      if (isEdit) {
                        await ref.doc(widget.direccionId).set(data);
                      } else {
                        await ref.add(data);
                      }
                      Navigator.of(context).pop();

                    }
                  },
                  child: const Text(
                    'Guardar',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
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
