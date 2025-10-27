import 'package:flutter/material.dart';
import 'package:heritage_numerique/services/api_service.dart';
import 'screens/splash_screen.dart';

void main() {
  // Initialiser l'API avant de démarrer l'application
  ApiService().initialize();
  runApp(const HeritageNumeriqueApp());
}

class HeritageNumeriqueApp extends StatelessWidget {
  const HeritageNumeriqueApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Héritage Numérique',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.amber),
        useMaterial3: true,
      ),
      home: const SplashScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}