import 'package:flutter/material.dart';
import 'registration_screen.dart';

class HeritageScreen3 extends StatefulWidget {
  const HeritageScreen3({super.key});

  @override
  State<HeritageScreen3> createState() => _HeritageScreen3State();
}

class _HeritageScreen3State extends State<HeritageScreen3> {
  void _showCompletionMessage() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Félicitations ! Vous avez découvert l\'héritage numérique malien'),
        backgroundColor: Color(0xFFD2691E),
      ),
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
              _showCompletionMessage();
            }
          },
          child: Stack(
            children: [
            // Image de fond
            Positioned.fill(
              child: Image.asset(
                'assets/images/Heritage3.png',
                fit: BoxFit.cover,
              ),
            ),
            // Bouton "Découvrir la culture Malienne" en bas
            Positioned(
              bottom: 60,
              left: 0,
              right: 0,
              child: Center(
                child: GestureDetector(
                  onTap: () {
                    // Ici vous pouvez ajouter une action pour la page finale
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Félicitations ! Vous avez découvert l\'héritage numérique malien'),
                        backgroundColor: Color(0xFFD2691E),
                      ),
                    );
                  },
                  child: Container(
                    margin: const EdgeInsets.symmetric(horizontal: 60),
                    padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
                    decoration: BoxDecoration(
                      color: const Color(0xFF8B4513), // Couleur marron foncé pour Heritage 3
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
                              'assets/images/Heritage3.png',
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                      ],
                    ),
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