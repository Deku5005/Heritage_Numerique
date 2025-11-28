import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:heritage_numerique/screens/login_screen.dart';
import 'registration_screen.dart';
import 'home_screen.dart';

/// Écran d'onboarding avec 3 pages scrollables (Flutter StatefulWidget)
/// Présente l'application Héritage Numérique avec navigation par indicateurs (dots).
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  // Contrôleur pour gérer la navigation entre les pages
  final PageController _pageController = PageController();
  int _currentPage = 0;

  // Couleur principale du bouton (Olive Sourd)
  static const Color _actionColor = Color(0xFF9F9646);
  // Couleur Ocre utilisée sur la page 3
  static const Color _ocreColor = Color(0xFFA56C00);

  @override
  void initState() {
    super.initState();
    // Étend le contenu sous les barres système
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    // Barre de statut transparente
    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      systemNavigationBarColor: Colors.transparent,
    ));
  }

  @override
  void dispose() {
    // Réactive les barres système
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual, overlays: SystemUiOverlay.values);
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          // --- 1 Le PageView principal ---
          PageView(
            controller: _pageController,
            onPageChanged: (index) {
              setState(() {
                _currentPage = index;
              });
            },
            children: [
              /// Première page
              _buildPage1_FullImage(),
              /// Deuxième page
              _buildPage2_LogoCentral(),
              /// Troisième page
              _buildPage3_FullImageAction(),
            ],
          ),

          // --- 2 Les indicateurs (dots) en bas ---
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: _buildPageIndicators(),
          ),
        ],
      ),
    );
  }

  /// PAGE 1 : Image de fond pleine
  Widget _buildPage1_FullImage() {
    return Container(
      color: const Color(0xFFEBC15F),
      child: Image.asset(
        'assets/images/Acceui.png',
        fit: BoxFit.cover,
        alignment: Alignment.topCenter,
        errorBuilder: (context, error, stackTrace) => Container(
          color: const Color(0xFFEBC15F),
          alignment: Alignment.center,
          child: const Text('Chargement image 1...', style: TextStyle(color: Colors.black)),
        ),
      ),
    );
  }

  /// PAGE 2 : Logo central + bouton “Je démarre l’aventure”
  Widget _buildPage2_LogoCentral() {
    return SafeArea(
      child: Container(
        color: Colors.white,
        child: Column(
          children: [
            // Logo principal
            Expanded(
              flex: 4,
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.only(top: 20, left: 40, right: 40),
                child: Image.asset(
                  'assets/images/Heritage1.png',
                  fit: BoxFit.contain,
                  errorBuilder: (context, error, stackTrace) => const Center(
                    child: Icon(Icons.account_tree, size: 100, color: Colors.grey),
                  ),
                ),
              ),
            ),

            // Zone du bouton
            Expanded(
              flex: 2,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 40.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // --- BOUTON COMPLEXE ---
                    InkWell(
                      onTap: () {
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(builder: (context) => const HomeScreen()),
                        );
                      },
                      child: Container(
                        height: 60,
                        decoration: BoxDecoration(
                          color: _actionColor,
                          borderRadius: BorderRadius.circular(30),
                          boxShadow: [
                            BoxShadow(
                              color: _actionColor.withOpacity(0.3),
                              blurRadius: 10,
                              offset: const Offset(0, 5),
                            ),
                          ],
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            //  Partie blanche décalée vers la droite
                            Padding(
                              padding: const EdgeInsets.only(left: 30.0),
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(30),
                                ),
                                child: const Text(
                                  'JE DEMARRE L\'AVENTURE',
                                  style: TextStyle(
                                    color: Colors.black,
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),

                            //  Cercle à droite
                            Padding(
                              padding: const EdgeInsets.only(right: 10.0),
                              child: Container(
                                width: 40,
                                height: 40,
                                decoration: BoxDecoration(
                                  color: _actionColor,
                                  borderRadius: BorderRadius.circular(20),
                                  border: Border.all(color: Colors.white, width: 2),
                                ),
                                child: ClipOval(
                                  child: Image.asset(
                                    'assets/images/Heritage2.png',
                                    fit: BoxFit.cover,
                                    errorBuilder: (context, error, stackTrace) => const Icon(
                                      Icons.arrow_forward_ios,
                                      color: Colors.white,
                                      size: 20,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 20),

                    //  Lien “Inscription”
                    TextButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => const RegistrationScreen()),
                        );
                      },
                      child: Text(
                        'Êtes-vous intéressé ? Inscription',
                        style: TextStyle(
                          color: _ocreColor,
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          decoration: TextDecoration.underline,
                        ),
                      ),
                    ),

                    const SizedBox(height: 60),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// PAGE 3 : Image de fond avec texte et deux boutons
  /// PAGE 3 : Image de fond avec texte et deux boutons
  Widget _buildPage3_FullImageAction() {
    return Container(
      color: Colors.black,
      child: Stack(
        children: [
          // Image de fond
          Positioned.fill(
            child: Image.asset(
              'assets/images/hero-mali.jpg',
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) => Container(
                color: Colors.deepOrange.shade900,
              ),
            ),
          ),

          // Overlay sombre
          Positioned.fill(
            child: Container(color: Colors.black.withOpacity(0.5)),
          ),

          // Contenu centré verticalement
          Positioned.fill(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 40.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center, //  CHANGEMENT : Centrage vertical principal

                children: [
                  // --- BLOC DE TEXTE CENTRÉ ET STYLISÉ ---
                  const SizedBox(height: 100),
                  SafeArea(
                    child: Column(
                      children: [
                        // Titre principal
                        const Text(
                          'Héritage Numérique',
                          style: TextStyle(
                            fontSize: 40, // Plus grand
                            fontWeight: FontWeight.w900, // Ultra-gras
                            color: Colors.white,
                            letterSpacing: 2.0, // Espacement des lettres
                            shadows: [
                              Shadow(
                                offset: Offset(2, 2),
                                blurRadius: 4.0,
                                color: Color.fromARGB(150, 0, 0, 0),
                              ),
                            ],
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 25), // Augmentation de l'espace

                        // Citation / Slogan
                        const Text(
                          'Préservons nos histoires\nPartageons nos racines',
                          style: TextStyle(
                            fontSize: 24, // Plus grand
                            fontStyle: FontStyle.italic,
                            fontWeight: FontWeight.w500,
                            color: Colors.white,
                            height: 1.4,
                            shadows: [
                              Shadow(
                                offset: Offset(1, 1),
                                blurRadius: 3.0,
                                color: Color.fromARGB(100, 0, 0, 0),
                              ),
                            ],
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 40), // Augmentation de l'espace

                        // Sous-texte descriptif
                        const Text(
                          'Une plateforme malienne dédiée à la préservation et à la valorisation du patrimoine culturel africain.',
                          style: TextStyle(
                            fontSize: 16, // Légèrement plus grand
                            color: Colors.white70,
                            height: 1.5,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),

                  // Spacer pour pousser les boutons vers le bas


                  const Spacer(),
                  // Boutons d’action en bas
                  Padding(
                    padding: const EdgeInsets.only(bottom: 20.0),
                    child: Column(
                      children: [
                        ElevatedButton(
                          onPressed: () {
                            Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(builder: (context) => const HomeScreen()),
                            );
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: _ocreColor,
                            foregroundColor: Colors.white,
                            minimumSize: const Size(double.infinity, 55),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30),
                            ),
                            elevation: 8,
                          ),
                          child: const Text(
                            'Découvrir la culture malienne',
                            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                          ),
                        ),
                        const SizedBox(height: 15),
                        OutlinedButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) => const LoginScreen()),
                            );
                          },
                          style: OutlinedButton.styleFrom(
                            foregroundColor: Colors.white,
                            minimumSize: const Size(double.infinity, 55),
                            side: const BorderSide(color: Colors.white, width: 2),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30),
                            ),
                          ),
                          child: const Text(
                            'Se connecter',
                            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                          ),
                        ),
                        const SizedBox(height: 40),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Indicateurs de page (les 3 petits points)
  Widget _buildPageIndicators() {
    Color dotColor = (_currentPage == 0 || _currentPage == 2)
        ? Colors.white.withOpacity(0.8)
        : _actionColor;

    Color activeDotColor = _actionColor;

    return Container(
      height: 60,
      color: Colors.transparent,
      padding: const EdgeInsets.only(bottom: 20.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: List.generate(3, (index) {
          return AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            margin: const EdgeInsets.symmetric(horizontal: 4.0),
            width: _currentPage == index ? 20.0 : 8.0,
            height: 8.0,
            decoration: BoxDecoration(
              color: _currentPage == index ? activeDotColor : dotColor,
              borderRadius: BorderRadius.circular(4.0),
            ),
          );
        }),
      ),
    );
  }
}
