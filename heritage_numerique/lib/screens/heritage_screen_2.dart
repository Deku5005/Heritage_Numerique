import 'package:flutter/material.dart';
import 'heritage_screen_3.dart';
import 'registration_screen.dart';

class HeritageScreen2 extends StatefulWidget {
  const HeritageScreen2({super.key});

  @override
  State<HeritageScreen2> createState() => _HeritageScreen2State();
}

class _HeritageScreen2State extends State<HeritageScreen2> {
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
        MaterialPageRoute(builder: (context) => const HeritageScreen3()),
      );
    }
  }

  void _navigateToNextScreen() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const HeritageScreen3()),
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
            // Image de fond - plus haute pour la deuxième page
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              bottom: 120, // Laisse plus d'espace en bas pour les boutons
              child: Image.asset(
                'assets/images/Heritage2.png',
                fit: BoxFit.cover,
              ),
            ),
            // Bouton "Découvrir la culture Malienne" en bas
            Positioned(
              bottom: 60,
              left: 0,
              right: 0,
              child: Center(
                child: Container(
                  margin: const EdgeInsets.symmetric(horizontal: 60),
                  padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
                  decoration: BoxDecoration(
                    color: const Color(0xFFD2691E), // Couleur ocre/dorée pour Heritage 2
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: const Text(
                          'Découvrir la culture Malienne',
                          style: TextStyle(
                            color: Colors.black,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        width: 24,
                        height: 24,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.white, width: 2),
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(10),
                          child: Image.asset(
                            'assets/images/Heritage2.png',
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            // Lien "Inscription" en bas
            Positioned(
              bottom: 20,
              left: 0,
              right: 0,
              child: Center(
                child: GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const RegistrationScreen()),
                    );
                  },
                  child: RichText(
                    text: const TextSpan(
                      style: TextStyle(
                        color: Colors.black,
                        fontSize: 12,
                      ),
                      children: [
                        TextSpan(text: 'Etes vous Intéresser? '),
                        TextSpan(
                          text: 'Inscription',
                          style: TextStyle(
                            color: Color(0xFFD2691E),
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
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