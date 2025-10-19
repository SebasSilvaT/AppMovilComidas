import 'ingrediente.dart';

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

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nombre': nombre,
      'ingredientes': ingredientes.map((i) => i.toJson()).toList(),
      'instrucciones': instrucciones,
    };
  }
}
