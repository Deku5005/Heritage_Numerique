import 'package:flutter/material.dart'; // ← ajouté
import 'screens/splash_screen.dart';

Future<void> main() async {


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