import 'package:flutter/material.dart';
import 'api_service.dart';
import 'receta.dart';
import 'receta_detalle.dart';

class RecetasPage extends StatefulWidget {
  @override
  _RecetasPageState createState() => _RecetasPageState();
}

class _RecetasPageState extends State<RecetasPage> {
  final ApiService api = ApiService();
  List<Receta> recetas = [];
  List<Receta> recetasFiltradas = [];
  TextEditingController controller = TextEditingController();

  @override
  void initState() {
    super.initState();
    cargarRecetas();
  }

  void cargarRecetas() async {
    try {
      final data = await api.getRecetas();
      setState(() {
        recetas = data;
        recetasFiltradas = data;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error al cargar recetas: $e")),
      );
    }
  }

  void filtrar(String query) {
    final filtradas = recetas
        .where((r) => r.nombre.toLowerCase().contains(query.toLowerCase()))
        .toList();

    setState(() {
      recetasFiltradas = filtradas;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Recetas")),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: controller,
              onChanged: filtrar,
              decoration: InputDecoration(
                labelText: "Buscar receta",
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.search),
              ),
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: recetasFiltradas.length,
              itemBuilder: (context, index) {
                final receta = recetasFiltradas[index];
                return ListTile(
                  title: Text(receta.nombre),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => RecetaDetallePage(receta: receta),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
