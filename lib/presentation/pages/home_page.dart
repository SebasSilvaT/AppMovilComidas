import 'package:flutter/material.dart';
import '../../domain/entities/receta.dart';
import '../../core/config/dependency_injection.dart';
import 'recetas_page.dart';
import 'favoritos_page.dart';
import 'lista_compras_page.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _selectedIndex = 0;
  List<Receta> recetas = [];
  
  final _manageFavoritosUseCase = DependencyInjection.manageFavoritosUseCase;

  @override
  void initState() {
    super.initState();
    _cargarFavoritos();
  }

  Future<void> _cargarFavoritos() async {
    if (recetas.isEmpty) return;
    
    try {
      final favoritos = await _manageFavoritosUseCase.obtenerTodosFavoritos();
      setState(() {
        for (var receta in recetas) {
          receta.isFavorite = favoritos.contains(receta.id);
        }
      });
    } catch (e) {
      print('Error al cargar favoritos: $e');
    }
  }

  void onToggleFavorite(Receta receta) {
    setState(() {
      receta.isFavorite = !receta.isFavorite;
      final index = recetas.indexWhere((r) => r.id == receta.id);
      if (index != -1) {
        recetas[index].isFavorite = receta.isFavorite;
      }
    });
  }

  void updateRecetas(List<Receta> nuevasRecetas) {
    setState(() {
      recetas = nuevasRecetas;
    });
    _cargarFavoritos();
  }

  @override
  Widget build(BuildContext context) {
    final List<Widget> _pages = [
      RecetasPage(
        onToggleFavorite: onToggleFavorite,
        onRecetasLoaded: updateRecetas,
        recetas: recetas,
      ),
      FavoritosPage(
        recetas: recetas,
        onToggleFavorite: onToggleFavorite,
      ),
      ListaComprasPage(),
    ];

    return Scaffold(
      body: _pages[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: (index) async {
          setState(() {
            _selectedIndex = index;
          });
          await _cargarFavoritos();
        },
        items: [
          BottomNavigationBarItem(
            icon: Icon(Icons.restaurant_menu),
            label: 'Recetas',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.favorite),
            label: 'Favoritos',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.shopping_cart),
            label: 'Lista de Compras',
          ),
        ],
      ),
    );
  }
}
