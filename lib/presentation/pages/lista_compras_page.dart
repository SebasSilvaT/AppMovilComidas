import 'package:flutter/material.dart';
import '../../core/config/dependency_injection.dart';
import '../../domain/entities/ingrediente.dart';

class ListaComprasPage extends StatefulWidget {
  @override
  _ListaComprasPageState createState() => _ListaComprasPageState();
}

class _ListaComprasPageState extends State<ListaComprasPage> {
  final _manageListaComprasUseCase = DependencyInjection.manageListaComprasUseCase;
  Map<String, double> _cantidades = {};

  void _mostrarDialogoAgregarIngrediente() {
    final TextEditingController nombreController = TextEditingController();
    final TextEditingController cantidadController = TextEditingController();
    final TextEditingController unidadController = TextEditingController();

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          child: Container(
            padding: EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Color(0xFFFF6B6B).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        Icons.add_shopping_cart,
                        color: Color(0xFFFF6B6B),
                        size: 24,
                      ),
                    ),
                    SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Agregar Ingrediente',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.grey.shade800,
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 24),
                TextField(
                  controller: nombreController,
                  decoration: InputDecoration(
                    labelText: 'Nombre del ingrediente',
                    hintText: 'Ej: Tomates',
                    prefixIcon: Icon(Icons.shopping_basket, color: Color(0xFFFF6B6B)),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: Color(0xFFFF6B6B), width: 2),
                    ),
                  ),
                  textCapitalization: TextCapitalization.sentences,
                ),
                SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      flex: 2,
                      child: TextField(
                        controller: cantidadController,
                        keyboardType: TextInputType.numberWithOptions(decimal: true),
                        decoration: InputDecoration(
                          labelText: 'Cantidad',
                          hintText: 'Ej: 2',
                          prefixIcon: Icon(Icons.numbers, color: Color(0xFFFF6B6B)),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(color: Color(0xFFFF6B6B), width: 2),
                          ),
                        ),
                      ),
                    ),
                    SizedBox(width: 12),
                    Expanded(
                      flex: 3,
                      child: TextField(
                        controller: unidadController,
                        decoration: InputDecoration(
                          labelText: 'Unidad',
                          hintText: 'Ej: kg, unidades',
                          prefixIcon: Icon(Icons.straighten, color: Color(0xFFFF6B6B)),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(color: Color(0xFFFF6B6B), width: 2),
                          ),
                        ),
                        textCapitalization: TextCapitalization.words,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 24),
                Row(
                  children: [
                    Expanded(
                      child: TextButton(
                        onPressed: () => Navigator.pop(context),
                        style: TextButton.styleFrom(
                          padding: EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: Text(
                          'Cancelar',
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.grey.shade600,
                          ),
                        ),
                      ),
                    ),
                    SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () async {
                          if (nombreController.text.trim().isEmpty) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('Por favor ingresa el nombre del ingrediente'),
                                backgroundColor: Colors.orange,
                                behavior: SnackBarBehavior.floating,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                              ),
                            );
                            return;
                          }

                          final nombre = nombreController.text.trim();
                          final cantidad = cantidadController.text.trim().isEmpty 
                              ? '1' 
                              : cantidadController.text.trim();
                          final unidad = unidadController.text.trim();
                          final cantidadCompleta = '$cantidad ${unidad}'.trim();

                          try {
                            // Crear un ingrediente para agregar manualmente
                            final ingrediente = Ingrediente(
                              nombre: nombre,
                              cantidad: cantidadCompleta,
                            );

                            // Agregar a la base de datos usando una receta temporal (ID negativo para items manuales)
                            await _manageListaComprasUseCase.agregarAListaCompras(
                              -1, // ID especial para ingredientes manuales
                              [ingrediente],
                            );

                            // Actualizar el estado local
                            setState(() {
                              _cantidades[nombre] = double.tryParse(cantidad) ?? 1.0;
                            });

                            Navigator.pop(context);

                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('Ingrediente agregado a la lista'),
                                backgroundColor: Color(0xFFFF6B6B),
                                behavior: SnackBarBehavior.floating,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                              ),
                            );
                          } catch (e) {
                            print('Error al agregar ingrediente: $e');
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('Error al agregar el ingrediente'),
                                backgroundColor: Colors.red,
                                behavior: SnackBarBehavior.floating,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                              ),
                            );
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Color(0xFFFF6B6B),
                          foregroundColor: Colors.white,
                          padding: EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          elevation: 0,
                        ),
                        child: Text(
                          'Agregar',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 120,
            floating: false,
            pinned: true,
            backgroundColor: Color(0xFFFF6B6B),
            elevation: 0,
            flexibleSpace: FlexibleSpaceBar(
              title: Text(
                "Lista de Compras",
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 24,
                ),
              ),
              centerTitle: false,
              titlePadding: EdgeInsets.only(left: 20, bottom: 16),
            ),
            actions: [
              Container(
                margin: EdgeInsets.only(right: 12),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: IconButton(
                  icon: Icon(Icons.delete_sweep, color: Colors.white),
                  onPressed: () async {
                    final shouldClear = await showDialog<bool>(
                      context: context,
                      builder: (context) => AlertDialog(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                        title: Text('Limpiar Lista'),
                        content: Text('¿Deseas eliminar todos los ingredientes?'),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(context, false),
                            child: Text('Cancelar'),
                          ),
                          ElevatedButton(
                            onPressed: () => Navigator.pop(context, true),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Color(0xFFFF6B6B),
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                            child: Text('Limpiar'),
                          ),
                        ],
                      ),
                    );
                    
                    if (shouldClear == true) {
                      await _manageListaComprasUseCase.limpiarListaCompras();
                      setState(() {
                        _cantidades.clear();
                      });
                    }
                  },
                ),
              ),
            ],
          ),
          SliverToBoxAdapter(
            child: FutureBuilder<List<Map<String, dynamic>>>(
              future: _manageListaComprasUseCase.obtenerListaCompras(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Container(
                    height: 400,
                    child: Center(
                      child: CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(Color(0xFFFF6B6B)),
                      ),
                    ),
                  );
                }

                if (snapshot.hasError) {
                  return Container(
                    height: 400,
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.error_outline, size: 60, color: Colors.red.shade300),
                          SizedBox(height: 16),
                          Text(
                            'Error al cargar la lista',
                            style: TextStyle(color: Colors.red.shade700, fontSize: 16),
                          ),
                        ],
                      ),
                    ),
                  );
                }

                if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return Container(
                    height: 400,
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            padding: EdgeInsets.all(30),
                            decoration: BoxDecoration(
                              color: Colors.grey.shade200,
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              Icons.shopping_cart_outlined,
                              size: 80,
                              color: Colors.grey.shade400,
                            ),
                          ),
                          SizedBox(height: 24),
                          Text(
                            "Lista vacía",
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Colors.grey.shade700,
                            ),
                          ),
                          SizedBox(height: 8),
                          Text(
                            "Agrega ingredientes desde\nlas recetas",
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 15,
                              color: Colors.grey.shade500,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
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

                return Padding(
                  padding: EdgeInsets.all(16),
                  child: Column(
                    children: ingredientesCombinados.entries.map((entry) {
                      String nombre = entry.key;
                      var ingrediente = entry.value;
                      
                      return Container(
                        margin: EdgeInsets.only(bottom: 12),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.05),
                              blurRadius: 10,
                              offset: Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Padding(
                          padding: EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Container(
                                    padding: EdgeInsets.all(8),
                                    decoration: BoxDecoration(
                                      color: Color(0xFFFF6B6B).withOpacity(0.1),
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    child: Icon(
                                      Icons.shopping_bag,
                                      color: Color(0xFFFF6B6B),
                                      size: 20,
                                    ),
                                  ),
                                  SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          ingrediente['nombre'],
                                          style: TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.grey.shade800,
                                          ),
                                        ),
                                        SizedBox(height: 4),
                                        Text(
                                          '${ingrediente['cantidad']} ${ingrediente['unidad']}',
                                          style: TextStyle(
                                            fontSize: 14,
                                            color: Colors.grey.shade600,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  IconButton(
                                    icon: Icon(Icons.delete, color: Colors.red.shade300),
                                    onPressed: () async {
                                      await _manageListaComprasUseCase.eliminarDeListaCompras(nombre);
                                      setState(() {
                                        _cantidades.remove(nombre);
                                      });
                                    },
                                  ),
                                ],
                              ),
                              SizedBox(height: 12),
                              Container(
                                decoration: BoxDecoration(
                                  color: Colors.grey.shade50,
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    IconButton(
                                      icon: Icon(Icons.remove_circle_outline),
                                      color: Color(0xFFFF6B6B),
                                      onPressed: () {
                                        setState(() {
                                          if ((_cantidades[nombre] ?? 0) > 0) {
                                            _cantidades[nombre] = (_cantidades[nombre] ?? 0) - 1;
                                            _manageListaComprasUseCase.actualizarCantidadIngrediente(
                                              nombre, 
                                              _cantidades[nombre]!
                                            );
                                          }
                                        });
                                      },
                                    ),
                                    Container(
                                      padding: EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                                      decoration: BoxDecoration(
                                        color: Colors.white,
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                      child: Text(
                                        '${_cantidades[nombre] ?? 0}',
                                        style: TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold,
                                          color: Color(0xFFFF6B6B),
                                        ),
                                      ),
                                    ),
                                    IconButton(
                                      icon: Icon(Icons.add_circle_outline),
                                      color: Color(0xFFFF6B6B),
                                      onPressed: () {
                                        setState(() {
                                          _cantidades[nombre] = (_cantidades[nombre] ?? 0) + 1;
                                          _manageListaComprasUseCase.actualizarCantidadIngrediente(
                                            nombre, 
                                            _cantidades[nombre]!
                                          );
                                        });
                                      },
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _mostrarDialogoAgregarIngrediente,
        backgroundColor: Color(0xFFFF6B6B),
        icon: Icon(Icons.add, color: Colors.white),
        label: Text(
          'Agregar',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w600,
          ),
        ),
        elevation: 4,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
      ),
    );
  }
}
