/// Modelo que representa a una Persona en el sistema
class Persona {
  final int? id;
  final String nombre;
  final String foto; // Ruta local del archivo de imagen
  final String fecha; // Fecha en formato ISO 8601 o legible

  Persona({
    this.id,
    required this.nombre,
    required this.foto,
    required this.fecha,
  });

  /// Convierte la instancia de Persona en un Map para insertar o actualizar en SQLite
  Map<String, dynamic> toMap() {
    final map = <String, dynamic>{
      'nombre': nombre,
      'foto': foto,
      'fecha': fecha,
    };
    if (id != null) {
      map['id'] = id;
    }
    return map;
  }

  /// Crea una instancia de Persona a partir de un Map obtenido de la consulta SQLite
  factory Persona.fromMap(Map<String, dynamic> map) {
    return Persona(
      id: map['id'] as int?,
      nombre: map['nombre'] as String,
      foto: map['foto'] as String,
      fecha: map['fecha'] as String,
    );
  }

  /// Crea una copia de la persona con campos opcionales modificados
  Persona copyWith({
    int? id,
    String? nombre,
    String? foto,
    String? fecha,
  }) {
    return Persona(
      id: id ?? this.id,
      nombre: nombre ?? this.nombre,
      foto: foto ?? this.foto,
      fecha: fecha ?? this.fecha,
    );
  }
}
