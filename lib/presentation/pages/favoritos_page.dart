import 'package:flutter/material.dart';
import '../../domain/entities/receta.dart';
import '../../core/config/dependency_injection.dart';
import 'receta_detalle_page.dart';

class FavoritosPage extends StatefulWidget {
  final List<Receta> recetas;
  final Function(Receta) onToggleFavorite;

  const FavoritosPage({
    Key? key,
    required this.recetas,
    required this.onToggleFavorite,
  }) : super(key: key);

  @override
  State<FavoritosPage> createState() => _FavoritosPageState();
}

class _FavoritosPageState extends State<FavoritosPage> {
  final _manageFavoritosUseCase = DependencyInjection.manageFavoritosUseCase;

  @override
  Widget build(BuildContext context) {
    final recetasFavoritas = widget.recetas.where((r) => r.isFavorite).toList();

    return Scaffold(
      appBar: AppBar(
        title: Text("Favoritos"),
      ),
      body: recetasFavoritas.isEmpty
          ? Center(
              child: Text(
                "No tienes recetas favoritas",
                style: Theme.of(context).textTheme.titleLarge,
              ),
            )
          : ListView.builder(
              itemCount: recetasFavoritas.length,
              itemBuilder: (context, index) {
                final receta = recetasFavoritas[index];
                return ListTile(
                  title: Text(receta.nombre),
                  trailing: IconButton(
                    icon: Icon(
                      Icons.favorite,
                      color: Colors.red,
                    ),
                    onPressed: () async {
                      try {
                        await _manageFavoritosUseCase.eliminarFavorito(receta.id);
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
    );
  }
}
