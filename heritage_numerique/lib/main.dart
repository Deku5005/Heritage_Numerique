import 'package:flutter/material.dart';
import 'package:heritage_numerique/screens/musicDash.dart';
import 'package:heritage_numerique/screens/quiz.dart';
import 'package:heritage_numerique/screens/quizQuestion.dart';
import 'package:heritage_numerique/screens/quizResultat.dart';
import 'screens/splash_screen.dart';

void main() {
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
      home: const MusicDashScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}