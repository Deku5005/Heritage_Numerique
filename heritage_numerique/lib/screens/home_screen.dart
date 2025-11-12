import 'package:flutter/material.dart';
import 'package:heritage_numerique/screens/dashboard_screen.dart';
import 'contes_screen.dart';
import 'artisans_screen.dart';
import 'music_screen.dart';
import 'proverb_screen.dart';
import 'splash_screen.dart'; // IMPORTANT: Assurez-vous d'importer votre SplashScreen ici

/// Écran principal de l'application affichant les catégories de patrimoine culturel.
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  // Couleur principale mise à jour : Ocre Vif (D69301)
  static const Color _accentColor = Color(0xFFD69301);

  // Liste des catégories affichées sur le Dashboard
  final List<Map<String, String>> categories = const [
    {
      'title': 'Contes',
      'subtitle': 'Histoires ancestrales et légendes transmises de génération en génération.',
      'image_path': 'assets/images/contes.jpg',
    },
    {
      'title': 'Devinette',
      'subtitle': 'Mélodies traditionnelles et chants qui expriment notre histoire.',
      'image_path': 'assets/images/musiques.jpg',
    },
    {
      'title': 'Artisanat',
      'subtitle': 'Savoir-faire, objets et créations d\'artistes des villages.',
      'image_path': 'assets/images/artisanat.jpg',
    },
    {
      'title': 'Proverbes',
      'subtitle': 'Sagesse ancestrale et enseignements de nos aînés.',
      'image_path': 'assets/images/proverbes.jpg',
    },
  ];

  // Définition des styles de BorderRadius uniques pour chaque carte
  static const double largeRadius = 50.0;
  static const double smallRadius = 00.0;

  final List<BorderRadius> uniqueCardBorders = const [
    // 0: Contes (Top-Left/Bottom-Right dominant)
    BorderRadius.only(
      topLeft: Radius.circular(largeRadius),
      topRight: Radius.circular(largeRadius),
      bottomLeft: Radius.circular(largeRadius),
      bottomRight: Radius.circular(smallRadius),
    ),
    // 1: Musiques (Top-Right/Bottom-Left dominant)
    BorderRadius.only(
      topLeft: Radius.circular(largeRadius),
      topRight: Radius.circular(largeRadius),
      bottomLeft: Radius.circular(smallRadius),
      bottomRight: Radius.circular(largeRadius),
    ),
    // 2: Artisanat (Inversé: Top-Right/Bottom-Left dominant)
    BorderRadius.only(
      topLeft: Radius.circular(largeRadius),
      topRight: Radius.circular(smallRadius),
      bottomLeft: Radius.circular(largeRadius),
      bottomRight: Radius.circular(largeRadius),
    ),
    // 3: Proverbes (Inversé: Top-Left/Bottom-Right dominant)
    BorderRadius.only(
      topLeft: Radius.circular(smallRadius),
      topRight: Radius.circular(largeRadius),
      bottomLeft: Radius.circular(largeRadius),
      bottomRight: Radius.circular(largeRadius),
    ),
  ];


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: CustomScrollView(
        slivers: [
          // --- 1. BARRE D'APPLICATION (Avec flèche de retour) ---
          SliverAppBar(
            backgroundColor: Colors.white,
            automaticallyImplyLeading: false,
            pinned: true,
            titleSpacing: 0,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back, color: _accentColor),
              onPressed: () {
                // MODIFICATION CLÉ: Utilisation de pushAndRemoveUntil pour vider la pile
                // et revenir à l'écran de splash (la racine).
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (context) => const DashboardScreen()),
                      (Route<dynamic> route) => false, // Supprime toutes les routes précédentes
                );
              },
            ),
          ),

          // --- 2. CONTENU PRINCIPAL (Logo, Texte, Cartes) ---
          SliverList(
            delegate: SliverChildListDelegate([
              const SizedBox(height: 20),

              // --- 2.1 LOGO/IMAGE EN HAUT ---
              Center(
                child: Container(
                  width: 140,
                  height: 140,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: _accentColor, width: 3),
                  ),
                  child: Image.asset(
                    'assets/images/Afrique.png',
                    errorBuilder: (context, error, stackTrace) => CircleAvatar(
                      radius: 70,
                      backgroundColor: Colors.white,
                      child: Icon(Icons.public, size: 80, color: _accentColor.withOpacity(0.8)),
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 20),

              // --- 2.2 TITRES ---
              const Text(
                'Découvrir',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontFamily: 'Serif',
                  fontSize: 30,
                  fontWeight: FontWeight.w400,
                  color: _accentColor,
                  fontStyle: FontStyle.italic,
                ),
              ),
              const SizedBox(height: 8),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 40.0),
                child: Text(
                  'Explorez les trésors de notre patrimoine culturel',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.black54,
                  ),
                ),
              ),

              const SizedBox(height: 30),

              // --- 3. GRILLE DES CATÉGORIES (Grid View) ---
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10.0),
                child: GridView.builder(
                  physics: const NeverScrollableScrollPhysics(),
                  shrinkWrap: true,
                  itemCount: categories.length,
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 10,
                    mainAxisSpacing: 10,
                    childAspectRatio: 0.85,
                  ),
                  itemBuilder: (context, index) {
                    return _buildCategoryCard(
                      context,
                      categories[index]['title']!,
                      categories[index]['subtitle']!,
                      categories[index]['image_path']!,
                      index, // PASSAGE DE L'INDEX
                    );
                  },
                ),
              ),

              const SizedBox(height: 40),
            ]),
          ),
        ],
      ),
    );
  }

  /// Fonction pour construire chaque carte de catégorie
  Widget _buildCategoryCard(
      BuildContext context,
      String title,
      String subtitle,
      String imagePath,
      int index, // NOUVEAU PARAMÈTRE: l'index de la carte dans la grille
      ) {

    // Sélectionne le BorderRadius unique basé sur l'index
    final BorderRadius cardRadius = uniqueCardBorders[index];

    return GestureDetector(
      onTap: () {
        // Navigation vers la page correspondante
        Widget targetScreen;
        switch (title) {
          case 'Contes':
            targetScreen = const ContesScreen();
            break;
          case 'Devinette':
            targetScreen = const MusicScreen();
            break;
          case 'Artisanat':
            targetScreen = const ArtisansScreen();
            break;
          case 'Proverbes':
            targetScreen = const ProverbScreen();
            break;
          default:
            return;
        }

        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => targetScreen),
        );
      },
      child: Container(
        decoration: BoxDecoration(
          borderRadius: cardRadius, // Applique le BorderRadius dynamique et unique
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: cardRadius, // Applique le même BorderRadius au contenu de la carte (image)
          child: Stack(
            fit: StackFit.expand,
            children: [
              // 1. Image de fond
              Image.asset(
                imagePath,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => Container(
                  color: _accentColor.withOpacity(0.5),
                  child: Center(
                    child: Text(
                      title,
                      style: const TextStyle(color: Colors.white, fontSize: 20),
                    ),
                  ),
                ),
              ),

              // 2. Overlay sombre pour la lisibilité du texte
              Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.black.withOpacity(0.1),
                      Colors.black.withOpacity(0.6),
                    ],
                  ),
                ),
              ),

              // 3. Texte (Aligné en bas à gauche)
              Padding(
                padding: const EdgeInsets.all(12.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        shadows: [Shadow(blurRadius: 5, color: Colors.black)],
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.85),
                        fontSize: 12,
                        shadows: const [Shadow(blurRadius: 3, color: Colors.black)],
                      ),
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
