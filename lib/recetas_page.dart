import 'package:flutter/material.dart';
import 'api_service.dart';
import 'receta.dart';
import 'receta_detalle.dart';

class RecetasPage extends StatefulWidget {
  final Function(Receta) onToggleFavorite;
  final Function(List<Receta>) onRecetasLoaded;
  final List<Receta> recetas;

  const RecetasPage({
    Key? key,
    required this.onToggleFavorite,
    required this.onRecetasLoaded,
    required this.recetas,
  }) : super(key: key);

  @override
  _RecetasPageState createState() => _RecetasPageState();
}

class _RecetasPageState extends State<RecetasPage> {
  final ApiService api = ApiService();
  late List<Receta> recetasFiltradas;
  TextEditingController controller = TextEditingController();

  @override
  void initState() {
    super.initState();
    recetasFiltradas = widget.recetas;
    if (widget.recetas.isEmpty) {
      cargarRecetas();
    }
  }

  void cargarRecetas() async {
    try {
      final data = await api.getRecetas();
      widget.onRecetasLoaded(data);
      setState(() {
        recetasFiltradas = data;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error al cargar recetas: $e")),
      );
    }
  }

  void filtrar(String query) {
    final filtradas = widget.recetas
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
                  trailing: IconButton(
                    icon: Icon(
                      receta.isFavorite ? Icons.favorite : Icons.favorite_border,
                      color: receta.isFavorite ? Colors.red : null,
                    ),
                    onPressed: () => widget.onToggleFavorite(receta),
                  ),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => RecetaDetalle(receta: receta),  // Make sure this matches the actual class name
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
