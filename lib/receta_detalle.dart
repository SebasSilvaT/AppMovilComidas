import 'package:flutter/material.dart';
import 'receta.dart';

class RecetaDetallePage extends StatelessWidget {
  final Receta receta;

  RecetaDetallePage({required this.receta});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(receta.nombre)),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("Ingredientes",
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              ...receta.ingredientes.map((i) => ListTile(
                    title: Text(i.nombre),
                    subtitle: Text(i.cantidad),
                  )),
              SizedBox(height: 20),
              Text("Instrucciones",
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              Text(receta.instrucciones, style: TextStyle(fontSize: 16)),
            ],
          ),
        ),
      ),
    );
  }
}
