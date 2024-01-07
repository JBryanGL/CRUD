/*
José Bryan Gómez Landeros
Tecnologias usadas: Flutter/Dart
Tipo de aplicación: monolítica 
Prueba de CRUD para la empresa Made In Web
*/
import 'package:crud/crud.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color.fromARGB(255, 255, 255, 255)),
        useMaterial3: true,
        fontFamily: 'Roboto',
      ),
      home:  Crud(),
      //ocultar la etiqueta de "debug"
      debugShowCheckedModeBanner: false,
    );
  }
}
