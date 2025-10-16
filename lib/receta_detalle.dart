import 'package:flutter/material.dart';
import 'receta.dart';
import 'database_helper.dart';

class RecetaDetalle extends StatefulWidget {
  final Receta receta;

  const RecetaDetalle({Key? key, required this.receta}) : super(key: key);

  @override
  State<RecetaDetalle> createState() => _RecetaDetalleState();
}

class _RecetaDetalleState extends State<RecetaDetalle> {
  final Set<int> _ingredientesSeleccionados = {};
  final DatabaseHelper _dbHelper = DatabaseHelper();
  bool _esFavorito = false;

  @override
  void initState() {
    super.initState();
    _cargarEsFavorito();
  }

  Future<void> _cargarEsFavorito() async {
    final esFav = await _dbHelper.esFavorito(widget.receta.id);
    setState(() {
      _esFavorito = esFav;
    });
  }

  Future<void> _toggleFavorito() async {
    setState(() {
      _esFavorito = !_esFavorito;
    });

    if (_esFavorito) {
      await _dbHelper.agregarFavorito(widget.receta.id);
    } else {
      await _dbHelper.eliminarFavorito(widget.receta.id);
    }
  }

  Future<void> _guardarIngredientesSeleccionados() async {
    try {
      // Primero limpiamos los ingredientes anteriores de esta receta
      await Future.forEach(_ingredientesSeleccionados, (int index) async {
        final ingrediente = widget.receta.ingredientes[index];
        await _dbHelper.agregarIngredienteALista(
          widget.receta.id,
          ingrediente.nombre,
          ingrediente.cantidad,
        );
      });
    } catch (e) {
      print('Error al guardar ingredientes: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al guardar la lista de compras')),
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
            future: _dbHelper.obtenerListaCompras(),
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
          if (_ingredientesSeleccionados.isNotEmpty)
            IconButton(
              icon: Icon(Icons.list),
              onPressed: () async {
                await _guardarIngredientesSeleccionados();
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
                        } else {
                          _ingredientesSeleccionados.remove(index);
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
