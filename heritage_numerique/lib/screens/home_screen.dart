import 'package:flutter/material.dart';
import 'heritage_screen_1.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();
    _navigateToNext();
  }

  _navigateToNext() async {
    await Future.delayed(const Duration(seconds: 3), () {});
    if (mounted) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const HeritageScreen1()),
      );
    }
  }

  void _navigateToNextScreen() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const HeritageScreen1()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          color: Colors.white,
        ),
        child: GestureDetector(
          onPanEnd: (details) {
            // Détection du glissement vers la droite
            if (details.velocity.pixelsPerSecond.dx > 0) {
              _navigateToNextScreen();
            }
          },
          child: Stack(
            children: [
              // Image de fond - descendue et taille réduite
              Positioned(
                top: -40, // Fait descendre l'image un peu plus bas
                left: 0,
                right: 0,
                height: MediaQuery.of(context).size.height * 0.7, // Taille réduite à 70%
                child: Image.asset(
                  'assets/images/Acceuil1.png',
                  fit: BoxFit.cover,
                  width: double.infinity,
                  alignment: Alignment.topCenter, // Aligne vers le haut
                ),
              ),
              // Texte "Découvrir la culture Malienne" en bas
              Positioned(
                bottom: 80,
                left: 0,
                right: 0,
                child: Center(
                  child: Container(
                    margin: const EdgeInsets.symmetric(horizontal: 40),
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.9),
                      borderRadius: BorderRadius.circular(25),
                    ),
                    child: const Text(
                      'Découvrir la culture Malienne',
                      style: TextStyle(
                        color: Colors.black,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
              ),
              // Texte d'instruction pour le glissement
              Positioned(
                bottom: 40,
                left: 0,
                right: 0,
                child: Center(
                  child: Container(
                    margin: const EdgeInsets.symmetric(horizontal: 40),
                    padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 8),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.7),
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: const Text(
                      'Glissez vers la droite pour continuer',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
