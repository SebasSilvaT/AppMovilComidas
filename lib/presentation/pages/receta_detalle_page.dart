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
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          child: Container(
            padding: EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
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
                        Icons.shopping_cart,
                        color: Color(0xFFFF6B6B),
                        size: 24,
                      ),
                    ),
                    SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Lista de Compras',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.grey.shade800,
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 20),
                FutureBuilder<List<Map<String, dynamic>>>(
                  future: _manageListaComprasUseCase.obtenerListaCompras(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return Padding(
                        padding: EdgeInsets.all(20),
                        child: CircularProgressIndicator(
                          valueColor: AlwaysStoppedAnimation<Color>(Color(0xFFFF6B6B)),
                        ),
                      );
                    }
                    
                    if (snapshot.hasError) {
                      return Padding(
                        padding: EdgeInsets.all(20),
                        child: Text(
                          'Error al cargar la lista',
                          style: TextStyle(color: Colors.red),
                        ),
                      );
                    }
                    
                    if (!snapshot.hasData || snapshot.data!.isEmpty) {
                      return Padding(
                        padding: EdgeInsets.all(20),
                        child: Text(
                          'No hay ingredientes en la lista',
                          style: TextStyle(color: Colors.grey.shade600),
                        ),
                      );
                    }
                    
                    final listaCompras = snapshot.data!;
                    return Container(
                      constraints: BoxConstraints(maxHeight: 300),
                      child: SingleChildScrollView(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: listaCompras.map((item) => Container(
                            margin: EdgeInsets.only(bottom: 8),
                            padding: EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Colors.grey.shade50,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Row(
                              children: [
                                Icon(
                                  Icons.check_circle,
                                  color: Color(0xFFFF6B6B),
                                  size: 20,
                                ),
                                SizedBox(width: 12),
                                Expanded(
                                  child: Text(
                                    '${item['ingrediente_nombre']} - ${item['ingrediente_cantidad']}',
                                    style: TextStyle(fontSize: 15),
                                  ),
                                ),
                              ],
                            ),
                          )).toList(),
                        ),
                      ),
                    );
                  },
                ),
                SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () => Navigator.of(context).pop(),
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
                      'Cerrar',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                    ),
                  ),
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
            expandedHeight: 200,
            floating: false,
            pinned: true,
            backgroundColor: Color(0xFFFF6B6B),
            elevation: 0,
            leading: IconButton(
              icon: Icon(Icons.arrow_back, color: Colors.white),
              onPressed: () => Navigator.of(context).pop(),
            ),
            flexibleSpace: FlexibleSpaceBar(
              title: Text(
                widget.receta.nombre,
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 20,
                ),
              ),
              centerTitle: false,
              titlePadding: EdgeInsets.only(left: 60, bottom: 16),
              background: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Color(0xFFFF6B6B), Color(0xFFFF8E53)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                child: Center(
                  child: Icon(
                    Icons.restaurant,
                    size: 80,
                    color: Colors.white.withOpacity(0.3),
                  ),
                ),
              ),
            ),
            actions: [
              Container(
                margin: EdgeInsets.only(right: 8),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: IconButton(
                  icon: Icon(
                    _esFavorito ? Icons.favorite : Icons.favorite_border,
                    color: Colors.white,
                  ),
                  onPressed: _toggleFavorito,
                ),
              ),
              Container(
                margin: EdgeInsets.only(right: 12),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: IconButton(
                  icon: Icon(Icons.shopping_cart, color: Colors.white),
                  onPressed: () {
                    _mostrarListaCompras(context);
                  },
                ),
              ),
            ],
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Sección de Ingredientes
                  Container(
                    padding: EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 10,
                          offset: Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                color: Color(0xFFFF6B6B).withOpacity(0.1),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Icon(
                                Icons.shopping_basket,
                                color: Color(0xFFFF6B6B),
                                size: 24,
                              ),
                            ),
                            SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                "Ingredientes",
                                style: TextStyle(
                                  fontSize: 22,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.grey.shade800,
                                ),
                              ),
                            ),
                            // Botón para marcar/desmarcar todos
                            Container(
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: _ingredientesSeleccionados.length == widget.receta.ingredientes.length
                                      ? [Color(0xFFFF6B6B), Color(0xFFFF8E53)]
                                      : [Colors.grey.shade300, Colors.grey.shade400],
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                ),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Material(
                                color: Colors.transparent,
                                child: InkWell(
                                  borderRadius: BorderRadius.circular(10),
                                  onTap: () async {
                                    try {
                                      final todosSeleccionados = _ingredientesSeleccionados.length == widget.receta.ingredientes.length;
                                      
                                      setState(() {
                                        if (todosSeleccionados) {
                                          // Desmarcar todos
                                          _ingredientesSeleccionados.clear();
                                        } else {
                                          // Marcar todos
                                          _ingredientesSeleccionados.clear();
                                          for (int i = 0; i < widget.receta.ingredientes.length; i++) {
                                            _ingredientesSeleccionados.add(i);
                                          }
                                        }
                                      });
                                      
                                      if (todosSeleccionados) {
                                        // Eliminar todos de la lista de compras
                                        for (var ingrediente in widget.receta.ingredientes) {
                                          await _manageListaComprasUseCase.eliminarDeListaCompras(
                                            ingrediente.nombre,
                                          );
                                        }
                                      } else {
                                        // Agregar todos a la lista de compras
                                        await _manageListaComprasUseCase.agregarAListaCompras(
                                          widget.receta.id,
                                          widget.receta.ingredientes,
                                        );
                                      }
                                    } catch (e) {
                                      print('Error al marcar/desmarcar todos: $e');
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        SnackBar(
                                          content: Text('Error al actualizar ingredientes'),
                                          backgroundColor: Color(0xFFFF6B6B),
                                          behavior: SnackBarBehavior.floating,
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(10),
                                          ),
                                        ),
                                      );
                                    }
                                  },
                                  child: Padding(
                                    padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Icon(
                                          _ingredientesSeleccionados.length == widget.receta.ingredientes.length
                                              ? Icons.check_box
                                              : Icons.check_box_outline_blank,
                                          color: Colors.white,
                                          size: 18,
                                        ),
                                        SizedBox(width: 6),
                                        Text(
                                          _ingredientesSeleccionados.length == widget.receta.ingredientes.length
                                              ? 'Desmarcar todo'
                                              : 'Marcar todo',
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontSize: 13,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 16),
                        ...widget.receta.ingredientes.asMap().entries.map((entry) {
                          final index = entry.key;
                          final ingrediente = entry.value;
                          final isSelected = _ingredientesSeleccionados.contains(index);
                          
                          return Container(
                            margin: EdgeInsets.only(bottom: 8),
                            decoration: BoxDecoration(
                              color: isSelected 
                                  ? Color(0xFFFF6B6B).withOpacity(0.05)
                                  : Colors.grey.shade50,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: isSelected 
                                    ? Color(0xFFFF6B6B).withOpacity(0.3)
                                    : Colors.transparent,
                                width: 1.5,
                              ),
                            ),
                            child: CheckboxListTile(
                              title: Text(
                                ingrediente.nombre,
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w500,
                                  color: Colors.grey.shade800,
                                ),
                              ),
                              subtitle: Text(
                                ingrediente.cantidad,
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.grey.shade600,
                                ),
                              ),
                              value: isSelected,
                              activeColor: Color(0xFFFF6B6B),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
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
                                    SnackBar(
                                      content: Text('Error al actualizar el ingrediente'),
                                      backgroundColor: Color(0xFFFF6B6B),
                                      behavior: SnackBarBehavior.floating,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                    ),
                                  );
                                }
                              },
                            ),
                          );
                        }),
                      ],
                    ),
                  ),
                  
                  SizedBox(height: 20),
                  
                  // Sección de Instrucciones
                  Container(
                    padding: EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 10,
                          offset: Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                color: Color(0xFFFF6B6B).withOpacity(0.1),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Icon(
                                Icons.menu_book,
                                color: Color(0xFFFF6B6B),
                                size: 24,
                              ),
                            ),
                            SizedBox(width: 12),
                            Text(
                              "Instrucciones",
                              style: TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                                color: Colors.grey.shade800,
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 16),
                        Text(
                          widget.receta.instrucciones,
                          style: TextStyle(
                            fontSize: 16,
                            height: 1.6,
                            color: Colors.grey.shade700,
                          ),
                        ),
                      ],
                    ),
                  ),
                  
                  SizedBox(height: 20),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
