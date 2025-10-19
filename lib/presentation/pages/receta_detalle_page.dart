import 'package:flutter/material.dart';
import '../../domain/entities/receta.dart';
import '../../core/config/dependency_injection.dart';

class RecetaDetallePage extends StatefulWidget {
  final Receta receta;
  final Function(Receta) onToggleFavorite;

  const RecetaDetallePage({
    Key? key, 
    required this.receta,
    required this.onToggleFavorite,
  }) : super(key: key);

  @override
  State<RecetaDetallePage> createState() => _RecetaDetallePageState();
}

class _RecetaDetallePageState extends State<RecetaDetallePage> {
  final Set<int> _ingredientesSeleccionados = {};
  bool _esFavorito = false;

  final _manageFavoritosUseCase = DependencyInjection.manageFavoritosUseCase;
  final _manageListaComprasUseCase = DependencyInjection.manageListaComprasUseCase;

  @override
  void initState() {
    super.initState();
    _esFavorito = widget.receta.isFavorite;
    _cargarEsFavorito();
  }

  Future<void> _cargarEsFavorito() async {
    try {
      final esFav = await _manageFavoritosUseCase.esFavorito(widget.receta.id);
      if (mounted) {
        setState(() {
          _esFavorito = esFav;
          widget.receta.isFavorite = esFav;
        });
      }
    } catch (e) {
      print('Error al cargar favorito: $e');
    }
  }

  Future<void> _toggleFavorito() async {
    try {
      setState(() {
        _esFavorito = !_esFavorito;
      });

      if (_esFavorito) {
        await _manageFavoritosUseCase.agregarFavorito(widget.receta.id);
      } else {
        await _manageFavoritosUseCase.eliminarFavorito(widget.receta.id);
      }

      widget.receta.isFavorite = _esFavorito;
      widget.onToggleFavorite(widget.receta);
    } catch (e) {
      print('Error al cambiar favorito: $e');
      setState(() {
        _esFavorito = !_esFavorito;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al actualizar favorito')),
      );
    }
  }

  void _mostrarListaCompras(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Lista de Compras'),
          content: FutureBuilder<List<Map<String, dynamic>>>(
            future: _manageListaComprasUseCase.obtenerListaCompras(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return Center(child: CircularProgressIndicator());
              }
              
              if (snapshot.hasError) {
                return Text('Error al cargar la lista: ${snapshot.error}');
              }
              
              if (!snapshot.hasData || snapshot.data!.isEmpty) {
                return Text('No hay ingredientes en la lista de compras');
              }
              
              final listaCompras = snapshot.data!;
              return SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: listaCompras.map((item) => Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4.0),
                    child: Text(
                      '• ${item['ingrediente_nombre']} - ${item['ingrediente_cantidad']}',
                      style: TextStyle(fontSize: 16),
                    ),
                  )).toList(),
                ),
              );
            },
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text('Cerrar'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.receta.nombre),
        actions: [
          IconButton(
            icon: Icon(
              _esFavorito ? Icons.favorite : Icons.favorite_border,
              color: _esFavorito ? Colors.red : null,
            ),
            onPressed: _toggleFavorito,
          ),
          IconButton(
            icon: Icon(Icons.shopping_cart),
            onPressed: () {
              _mostrarListaCompras(context);
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("Ingredientes",
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              ...widget.receta.ingredientes.asMap().entries.map((entry) {
                final index = entry.key;
                final ingrediente = entry.value;
                return CheckboxListTile(
                  title: Text(ingrediente.nombre),
                  subtitle: Text(ingrediente.cantidad),
                  value: _ingredientesSeleccionados.contains(index),
                  onChanged: (bool? value) async {
                    try {
                      setState(() {
                        if (value == true) {
                          _ingredientesSeleccionados.add(index);
                          _manageListaComprasUseCase.agregarAListaCompras(
                            widget.receta.id,
                            [ingrediente],
                          );
                        } else {
                          _ingredientesSeleccionados.remove(index);
                          _manageListaComprasUseCase.eliminarDeListaCompras(
                            ingrediente.nombre,
                          );
                        }
                      });
                    } catch (e) {
                      print('Error al marcar ingrediente: $e');
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Error al actualizar el ingrediente')),
                      );
                    }
                  },
                );
              }),
              SizedBox(height: 20),
              Text("Instrucciones",
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              Text(widget.receta.instrucciones, style: TextStyle(fontSize: 16)),
            ],
          ),
        ),
      ),
    );
  }
}
