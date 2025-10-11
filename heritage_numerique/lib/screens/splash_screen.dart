import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // Import pour SystemChrome
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
  // Couleur Ocre de la Page 2/3 (Utilisée pour les boutons de la page 3)
  static const Color _ocreColor = Color(0xFFA56C00); 

  @override
  void initState() {
    super.initState();
    // Permet au contenu de s'étendre sous les barres de statut/navigation
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    // Rend la barre de statut transparente
    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      systemNavigationBarColor: Colors.transparent,
    ));
  }

  @override
  void dispose() {
    // Rétablit les barres de statut lorsque l'écran est fermé
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual, overlays: SystemUiOverlay.values);
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      // Suppression de extendBodyBehindBottomBar, on utilise un Stack à la place.
      // Le bottomNavigationBar est supprimé.
      body: Stack(
        children: [
          // 1. Le PageView prend tout l'espace
          PageView(
            controller: _pageController,
            onPageChanged: (index) {
              setState(() {
                _currentPage = index;
              });
            },
            children: [
              // ORDRE 1: PAGE 1 (Image de fond SANS ÉCRITURE)
              _buildPage1_FullImage(),
              // ORDRE 2: PAGE 2 (Logo central + Bouton complexe)
              _buildPage2_LogoCentral(),
              // ORDRE 3: PAGE 3 (Image de fond + Texte + Boutons d'action)
              _buildPage3_FullImageAction(),
            ],
          ),
          // 2. Les indicateurs de page flottent en bas du PageView
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

  /// Page 1: Image de fond Plein Écran SANS AUCUN TEXTE (Acceui.png)
  Widget _buildPage1_FullImage() {
    return Container(
      color: const Color(0xFFEBC15F), 
      child: Image.asset(
        'assets/images/Acceui.png', // Image de l'homme en habit traditionnel
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

  /// Page 2: Logo central, Texte, et Bouton complexe (Heritage1.png / 1ère photo)
  Widget _buildPage2_LogoCentral() {
    // SafeArea est ajoutée pour éviter que le contenu ne soit masqué par la barre de statut.
    return SafeArea(
      child: Container(
        color: Colors.white,
        child: Column(
          children: [
            // Zone du logo central (Flex 4: Moins d'espace en haut, remonte les éléments)
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
            
            // Zone du bouton d'action complexe (Flex 2: Plus d'espace en bas, remonte les éléments)
            Expanded(
              flex: 2, 
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 40.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center, // Utilisation de center pour centrer le bloc de boutons dans son Expanded
                  children: [
                    // Suppression des deux widgets Text ici: 'Héritage Numérique' et 'Découvrez la richesse...'

                    // BOUTON COMPLEXE (Couleur 9F9646, partie blanche, cercle image)
                    InkWell(
                      onTap: () {
                        // Action : Navigue vers l'écran d'accueil
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(builder: (context) => const HomeScreen()),
                        );
                      },
                      child: Container(
                        height: 60,
                        decoration: BoxDecoration(
                          color: _actionColor, // Olive Sourd (9F9646)
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
                            // Partie blanche avec écriture noire
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(30),
                              ),
                              child: const Text(
                                'JE DÉMARRE L\'AVENTURE',
                                style: TextStyle(
                                  color: Colors.black,
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            // Cercle avec image et bordure blanche
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
                    // Lien "Inscription" sous le bouton complexe (comme sur la photo 1)
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
                          color: _ocreColor, // Utilisez Ocre pour le lien
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          decoration: TextDecoration.underline,
                        ),
                      ),
                    ),
                    // Espace pour le dot qui est en position fixe
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
  
  /// Page 3: Image de fond avec texte et boutons d'action (Heritage3.png / 2e photo)
  Widget _buildPage3_FullImageAction() {
    return Container(
      color: Colors.black, // Couleur de fallback si l'image ne charge pas
      child: Stack(
        children: [
          // L'image de fond qui prend TOUTE LA PAGE
          Positioned.fill(
            child: Image.asset(
              'assets/images/hero-mali.jpg', // Image de fond paysage
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) => Container(
                color: Colors.deepOrange.shade900, // Couleur sombre si image non trouvée
              ),
            ),
          ),
          
          // Overlay sombre (pour lisibilité)
          Positioned.fill(
             child: Container(
                color: Colors.black.withOpacity(0.5), 
              ),
          ),

          // Contenu (Texte et Boutons)
          Positioned.fill(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 40.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Texte principal (en haut)
                  SafeArea(
                    child: Column(
                      children: const [
                        Text(
                          'Héritage Numérique',
                          style: TextStyle(
                            fontSize: 32,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        SizedBox(height: 20),
                        Text(
                          'Préservons nos histoires\npartageons nos racines',
                          style: TextStyle(
                            fontSize: 20,
                            fontStyle: FontStyle.italic,
                            color: Colors.white,
                            height: 1.5,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        SizedBox(height: 30),
                         Text(
                          'Une plateforme malienne dédiée à la préservation et à la valorisation du patrimoine culturel africain',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.white70,
                            height: 1.5,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),

                  // DEUX BOUTONS D'ACTION (en bas, alignés sur la photo)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 20.0), 
                    child: Column(
                      children: [
                        // Bouton 1: "Découvrir la culture malienne" (Bouton rempli couleur Ocre/Marron)
                        ElevatedButton(
                          onPressed: () {
                            // Navigue vers l'écran d'accueil
                            Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(builder: (context) => const HomeScreen()),
                            );
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: _ocreColor, // Couleur Ocre/Marron de la photo
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
  
                        // Bouton 2: "Créer un compte" (Bouton outline blanc)
                        OutlinedButton(
                          onPressed: () {
                            // Navigue vers l'écran d'enregistrement
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) => const RegistrationScreen()),
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
                            'Créer un compte',
                            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                          ),
                        ),
                        // Espace pour le dot qui est en position fixe
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

  /// Indicateurs de page (dots)
  Widget _buildPageIndicators() {
    // Détermine la couleur des indicateurs en fonction de la page
    Color dotColor = (_currentPage == 0 || _currentPage == 2) 
        ? Colors.white.withOpacity(0.8) // Blanc sur les pages avec image de fond sombre (1 & 3)
        : _actionColor; // Couleur action sur la page 2 (fond blanc)

    Color activeDotColor = _actionColor; // L'indicateur actif reste la couleur d'action (Olive Sourd)

    // L'indicateur est placé dans un conteneur simple
    return Container(
      height: 60, 
      color: Colors.transparent, // Reste transparent pour l'effet flottant
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
              color: _currentPage == index
                  ? activeDotColor
                  : dotColor,
              borderRadius: BorderRadius.circular(4.0),
            ),
          );
        }),
      ),
    );
  }
}
