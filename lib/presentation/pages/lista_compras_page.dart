import 'package:flutter/material.dart';
import '../../core/config/dependency_injection.dart';

class ListaComprasPage extends StatefulWidget {
  @override
  _ListaComprasPageState createState() => _ListaComprasPageState();
}

class _ListaComprasPageState extends State<ListaComprasPage> {
  final _manageListaComprasUseCase = DependencyInjection.manageListaComprasUseCase;
  Map<String, double> _cantidades = {};

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Lista de Compras'),
        actions: [
          IconButton(
            icon: Icon(Icons.delete),
            onPressed: () async {
              await _manageListaComprasUseCase.limpiarListaCompras();
              setState(() {
                _cantidades.clear();
              });
            },
          ),
        ],
      ),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: _manageListaComprasUseCase.obtenerListaCompras(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(child: Text('No hay ingredientes en la lista'));
          }

          Map<String, Map<String, dynamic>> ingredientesCombinados = {};
          
          for (var item in snapshot.data!) {
            String nombre = item['ingrediente_nombre'];
            String cantidadStr = item['ingrediente_cantidad'];
            
            RegExp regExp = RegExp(r'(\d+\.?\d*)\s*(.*)');
            var match = regExp.firstMatch(cantidadStr);
            
            if (match != null) {
              double cantidad = double.tryParse(match.group(1) ?? '0') ?? 0;
              String unidad = match.group(2) ?? '';
              
              if (!_cantidades.containsKey(nombre)) {
                _cantidades[nombre] = cantidad;
              }

              if (ingredientesCombinados.containsKey(nombre)) {
                ingredientesCombinados[nombre]!['cantidad'] = _cantidades[nombre];
              } else {
                ingredientesCombinados[nombre] = {
                  'nombre': nombre,
                  'cantidad': _cantidades[nombre],
                  'unidad': unidad,
                };
              }
            }
          }

          return ListView.builder(
            itemCount: ingredientesCombinados.length,
            itemBuilder: (context, index) {
              String nombre = ingredientesCombinados.keys.elementAt(index);
              var ingrediente = ingredientesCombinados[nombre]!;
              
              return Card(
                margin: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                child: ListTile(
                  title: Text(ingrediente['nombre']),
                  subtitle: Text('${ingrediente['cantidad']} ${ingrediente['unidad']}'),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: Icon(Icons.remove),
                        onPressed: () {
                          setState(() {
                            if ((_cantidades[nombre] ?? 0) > 0) {
                              _cantidades[nombre] = (_cantidades[nombre] ?? 0) - 1;
                              // Persistir el cambio en la base de datos
                              _manageListaComprasUseCase.actualizarCantidadIngrediente(
                                nombre, 
                                _cantidades[nombre]!
                              );
                            }
                          });
                        },
                      ),
                      Text('${_cantidades[nombre] ?? 0}'),
                      IconButton(
                        icon: Icon(Icons.add),
                        onPressed: () {
                          setState(() {
                            _cantidades[nombre] = (_cantidades[nombre] ?? 0) + 1;
                            // Persistir el cambio en la base de datos
                            _manageListaComprasUseCase.actualizarCantidadIngrediente(
                              nombre, 
                              _cantidades[nombre]!
                            );
                          });
                        },
                      ),
                      IconButton(
                        icon: Icon(Icons.delete, color: Colors.red),
                        onPressed: () async {
                          await _manageListaComprasUseCase.eliminarDeListaCompras(nombre);
                          setState(() {
                            _cantidades.remove(nombre);
                          });
                        },
                      ),
                    ],
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
