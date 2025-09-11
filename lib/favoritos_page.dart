import 'package:flutter/material.dart';
import 'receta.dart';
import 'receta_detalle.dart';

class FavoritosPage extends StatelessWidget {
  final List<Receta> recetas;
  final Function(Receta) onToggleFavorite;

  const FavoritosPage({
    Key? key,
    required this.recetas,
    required this.onToggleFavorite,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final recetasFavoritas = recetas.where((r) => r.isFavorite).toList();

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
                    onPressed: () => onToggleFavorite(receta),
                  ),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => RecetaDetalle(receta: receta),
                      ),
                    );
                  },
                );
              },
            ),
    );
  }
}
