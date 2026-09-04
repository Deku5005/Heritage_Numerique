import 'package:flutter/material.dart';
import 'dart:io'; // Import pour la vérification de plateforme (nécessaire pour la correction)
import 'package:sqflite_common_ffi/sqflite_ffi.dart'; // Import pour sqflite_common_ffi
// Import pour databaseFactory

import 'screens/splash_screen.dart';

Future<void> main() async {

  // 1. Initialisation des bindings Flutter (requis avant toute opération non-Flutter)
  WidgetsFlutterBinding.ensureInitialized(); // 💡 AJOUTÉ ICI

  // 2. Correction de l'erreur "databaseFactory not initialized" pour flutter_cache_manager (cached_network_image)
  // Cette vérification est nécessaire pour que sqflite sache comment initialiser sa base de données
  // sur les émulateurs, tests, ou plateformes non-mobiles.
  if (Platform.isWindows || Platform.isLinux || Platform.isMacOS || Platform.isFuchsia) {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  }

  // 3. Lancement de l'application
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
      // Le splash screen gérera la navigation vers l'écran de connexion/principal
      home: const SplashScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}