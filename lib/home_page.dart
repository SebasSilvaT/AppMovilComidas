import 'package:flutter/material.dart';
import 'recetas_page.dart';
import 'favoritos_page.dart';
import 'receta.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _selectedIndex = 0;
  List<Receta> recetas = [];

  void onToggleFavorite(Receta receta) {
    setState(() {
      receta.isFavorite = !receta.isFavorite;
    });
  }

  void updateRecetas(List<Receta> nuevasRecetas) {
    setState(() {
      recetas = nuevasRecetas;
    });
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
    ];

    return Scaffold(
      body: _pages[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: (index) {
          setState(() {
            _selectedIndex = index;
          });
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
        ],
      ),
    );
  }
}
