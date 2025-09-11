class Ingrediente {
  final String nombre;
  final String cantidad;

  Ingrediente({required this.nombre, required this.cantidad});

  factory Ingrediente.fromJson(Map<String, dynamic> json) {
    return Ingrediente(
      nombre: json['nombre'],
      cantidad: json['cantidad'],
    );
  }
}

class Receta {
  final int id;
  final String nombre;
  final List<Ingrediente> ingredientes;
  final String instrucciones;
  bool isFavorite;

  Receta({
    required this.id,
    required this.nombre,
    required this.ingredientes,
    required this.instrucciones,
    this.isFavorite = false,
  });

  factory Receta.fromJson(Map<String, dynamic> json) {
    var ingredientesJson = json['ingredientes'] as List;
    List<Ingrediente> ingredientesList =
        ingredientesJson.map((i) => Ingrediente.fromJson(i)).toList();

    return Receta(
      id: json['id'],
      nombre: json['nombre'],
      ingredientes: ingredientesList,
      instrucciones: json['instrucciones'],
    );
  }
}
