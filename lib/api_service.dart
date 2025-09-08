import 'dart:convert';
import 'package:http/http.dart' as http;
import 'receta.dart';

class ApiService {
  static const String baseUrl = "http://10.0.2.2:3000";

  Future<List<Receta>> getRecetas() async {
    final response = await http.get(Uri.parse("$baseUrl/recetas"));
    print("Respuesta: ${response.body}");

    if (response.statusCode == 200) {
      List<dynamic> body = jsonDecode(response.body);
      return body.map((json) => Receta.fromJson(json)).toList();
    } else {
      throw Exception("Error al cargar recetas");
    }
  }

  Future<Receta> getRecetaById(int id) async {
    final response = await http.get(Uri.parse("$baseUrl/recetas/$id"));

    if (response.statusCode == 200) {
      return Receta.fromJson(jsonDecode(response.body));
    } else {
      throw Exception("Error al cargar receta");
    }
  }
}
