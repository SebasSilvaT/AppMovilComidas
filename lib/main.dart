import 'package:flutter/material.dart';
import 'recetas_page.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'App de Recetas',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: RecetasPage(),
    );
  }
}
