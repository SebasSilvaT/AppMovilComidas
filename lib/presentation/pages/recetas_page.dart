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
                "Recetas",
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 24,
                ),
              ),
              centerTitle: false,
              titlePadding: EdgeInsets.only(left: 20, bottom: 16),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Container(
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
                child: TextField(
                  controller: controller,
                  onChanged: filtrar,
                  decoration: InputDecoration(
                    hintText: "Buscar receta...",
                    hintStyle: TextStyle(color: Colors.grey.shade400),
                    border: InputBorder.none,
                    prefixIcon: Icon(Icons.search, color: Color(0xFFFF6B6B)),
                    contentPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                  ),
                ),
              ),
            ),
          ),
          recetasFiltradas.isEmpty
              ? SliverFillRemaining(
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        CircularProgressIndicator(
                          valueColor: AlwaysStoppedAnimation<Color>(Color(0xFFFF6B6B)),
                        ),
                        SizedBox(height: 16),
                        Text(
                          "Cargando recetas...",
                          style: TextStyle(
                            color: Colors.grey.shade600,
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                  ),
                )
              : SliverPadding(
                  padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  sliver: SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, index) {
                        final receta = recetasFiltradas[index];
                        return _buildRecetaCard(context, receta);
                      },
                      childCount: recetasFiltradas.length,
                    ),
                  ),
                ),
        ],
      ),
    );
  }

  Widget _buildRecetaCard(BuildContext context, Receta receta) {
    return Container(
      margin: EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 15,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(20),
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
          child: Padding(
            padding: EdgeInsets.all(16),
            child: Row(
              children: [
                // Icono decorativo
                Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Color(0xFFFF6B6B), Color(0xFFFF8E53)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: Icon(
                    Icons.restaurant,
                    color: Colors.white,
                    size: 30,
                  ),
                ),
                SizedBox(width: 16),
                // Nombre de la receta
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        receta.nombre,
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.grey.shade800,
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        "Toca para ver detalles",
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.grey.shade500,
                        ),
                      ),
                    ],
                  ),
                ),
                // Botón de favorito
                Container(
                  decoration: BoxDecoration(
                    color: receta.isFavorite 
                        ? Color(0xFFFF6B6B).withOpacity(0.1)
                        : Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: IconButton(
                    icon: Icon(
                      receta.isFavorite ? Icons.favorite : Icons.favorite_border,
                      color: receta.isFavorite ? Color(0xFFFF6B6B) : Colors.grey.shade400,
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
                          SnackBar(
                            content: Text('Error al actualizar favorito'),
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
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
