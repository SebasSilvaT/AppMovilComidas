import 'package:flutter/material.dart';
import '../../domain/entities/receta.dart';
import '../../core/config/dependency_injection.dart';
import 'receta_detalle_page.dart';

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
  late List<Receta> recetasFiltradas;
  TextEditingController controller = TextEditingController();

  final _getRecetasUseCase = DependencyInjection.getRecetasUseCase;
  final _manageFavoritosUseCase = DependencyInjection.manageFavoritosUseCase;

  Future<void> _cargarFavoritos() async {
    try {
      final favoritos = await _manageFavoritosUseCase.obtenerTodosFavoritos();
      setState(() {
        for (var receta in widget.recetas) {
          receta.isFavorite = favoritos.contains(receta.id);
        }
        recetasFiltradas = widget.recetas;
      });
    } catch (e) {
      print('Error al cargar favoritos: $e');
    }
  }

  @override
  void initState() {
    super.initState();
    recetasFiltradas = widget.recetas;
    _cargarFavoritos();
    if (widget.recetas.isEmpty) {
      cargarRecetas();
    }
  }

  void cargarRecetas() async {
    try {
      final data = await _getRecetasUseCase.execute();
      
      final favoritos = await _manageFavoritosUseCase.obtenerTodosFavoritos();
      for (var receta in data) {
        receta.isFavorite = favoritos.contains(receta.id);
      }
      
      widget.onRecetasLoaded(data);
      setState(() {
        recetasFiltradas = data;
      });
    } catch (e) {
      print('Error al cargar recetas: $e');
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
            child: recetasFiltradas.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        CircularProgressIndicator(),
                        SizedBox(height: 16),
                        Text("Cargando recetas..."),
                      ],
                    ),
                  )
                : ListView.builder(
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
                          onPressed: () async {
                            try {
                              if (receta.isFavorite) {
                                await _manageFavoritosUseCase.eliminarFavorito(receta.id);
                              } else {
                                await _manageFavoritosUseCase.agregarFavorito(receta.id);
                              }
                              widget.onToggleFavorite(receta);
                            } catch (e) {
                              print('Error al cambiar favorito: $e');
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text('Error al actualizar favorito')),
                              );
                            }
                          },
                        ),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => RecetaDetallePage(
                                receta: receta,
                                onToggleFavorite: widget.onToggleFavorite,
                              ),
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
