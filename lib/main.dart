import 'package:flutter/material.dart';
import 'presentation/pages/home_page.dart';
import 'core/config/dependency_injection.dart';

void main() async {
  // Ensure Flutter bindings are initialized
  WidgetsFlutterBinding.ensureInitialized();
  
  try {
    // Initialize dependencies
    await DependencyInjection.initialize();
    runApp(MyApp());
  } catch (e) {
    print('Error initializing app: $e');
    runApp(MyApp()); // Run the app anyway to show error messages to user
  }
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'App de Recetas',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: HomePage(),
      debugShowCheckedModeBanner: false, // Esta línea desactiva el banner de debug
    );
  }
}
