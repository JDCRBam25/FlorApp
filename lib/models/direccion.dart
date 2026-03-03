class Direccion {
  String id;
  String direccion;
  bool sinNumero;
  String departamento;
  String provincia;
  String distrito;
  String apartamento;
  String referencias;
  String tipo; // "Residencial" o "Laboral"
  String nombreCompleto;
  String telefono;

  Direccion({
    required this.id,
    required this.direccion,
    required this.sinNumero,
    required this.departamento,
    required this.provincia,
    required this.distrito,
    required this.apartamento,
    required this.referencias,
    required this.tipo,
    required this.nombreCompleto,
    required this.telefono,
  });

  factory Direccion.fromMap(Map<String, dynamic> data, String id) {
    return Direccion(
      id: id,
      direccion: data['direccion'] ?? '',
      sinNumero: data['sinNumero'] ?? false,
      departamento: data['departamento'] ?? '',
      provincia: data['provincia'] ?? '',
      distrito: data['distrito'] ?? '',
      apartamento: data['apartamento'] ?? '',
      referencias: data['referencias'] ?? '',
      tipo: data['tipo'] ?? '',
      nombreCompleto: data['nombreCompleto'] ?? '',
      telefono: data['telefono'] ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'direccion': direccion,
      'sinNumero': sinNumero,
      'departamento': departamento,
      'provincia': provincia,
      'distrito': distrito,
      'apartamento': apartamento,
      'referencias': referencias,
      'tipo': tipo,
      'nombreCompleto': nombreCompleto,
      'telefono': telefono,
    };
  }
}
