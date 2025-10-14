import 'package:flutter/material.dart';

// Définition des données pour chaque catégorie
class Category {
  final String title;
  final String subtitle;
  final String imagePath;
  final BorderRadius borderRadius;
  final Alignment titleAlignment;

  Category({
    required this.title,
    required this.subtitle,
    required this.imagePath,
    required this.borderRadius,
    required this.titleAlignment,
  });
}

// Les données des quatre cartes
final List<Category> categories = [
  Category(
    title: 'Contes',
    subtitle: 'Histoires ancestrales et légendes transmises de génération en génération',
    imagePath: 'assets/images/contes.jpg',
    borderRadius: const BorderRadius.only(
      topLeft: Radius.circular(50),
      topRight: Radius.circular(50),
      bottomLeft: Radius.circular(50),
      bottomRight: Radius.circular(0),
    ),
    titleAlignment: Alignment.bottomLeft,
  ),
  Category(
    title: 'Musiques',
    subtitle: 'Mélodies traditionnelles et chants qui racontent notre histoire',
    imagePath: 'assets/images/musiques.jpg', // Remplacez par le chemin de votre image
    borderRadius: const BorderRadius.only(
      topLeft: Radius.circular(50),
      topRight: Radius.circular(50),
      bottomLeft: Radius.circular(0),
      bottomRight: Radius.circular(50),
    ),
    titleAlignment: Alignment.bottomRight,
  ),
  Category(
    title: 'Artisanat',
    subtitle: 'Savoir-faire traditionnels et créations artisanales uniques',
    imagePath: 'assets/images/artisanat.jpg', // Remplacez par le chemin de votre image
    borderRadius: const BorderRadius.only(
      topLeft: Radius.circular(50),
      topRight: Radius.circular(0),
      bottomLeft: Radius.circular(50),
      bottomRight: Radius.circular(50),
    ),
    titleAlignment: Alignment.bottomLeft,
  ),
  Category(
    title: 'Proverbes',
    subtitle: 'Sagesse ancestrale et enseignements de nos aînés',
    imagePath: 'assets/images/proverbes.jpg', // Remplacez par le chemin de votre image
    borderRadius: const BorderRadius.only(
      topLeft: Radius.circular(0),
      topRight: Radius.circular(50),
      bottomLeft: Radius.circular(50),
      bottomRight: Radius.circular(50),
    ),
    titleAlignment: Alignment.bottomRight,
  ),
];

class AccueilScreen extends StatelessWidget {
  const AccueilScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white, // Couleur de fond de la page
      body: SingleChildScrollView(
        child: Column(
          children: <Widget>[
            // --- Section Haut de Page (Bouton, Image, Texte) ---
            _buildHeader(context),

            const SizedBox(height: 20), // Espace entre le texte et la grille

            // --- Grille des Catégories (Les 4 cartes) ---
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10.0),
              child: GridView.builder(
                // Configuration de la grille
                shrinkWrap: true, // Important pour un GridView dans un SingleChildScrollView
                physics: const NeverScrollableScrollPhysics(), // Pour désactiver le scroll du GridView
                itemCount: categories.length,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2, // 2 colonnes
                  crossAxisSpacing: 10.0,
                  mainAxisSpacing: 10.0,
                  childAspectRatio: 1.0, // Carré (184px / 183px est proche de 1)
                ),
                itemBuilder: (context, index) {
                  return _buildCategoryCard(categories[index]);
                },
              ),
            ),
            const SizedBox(height: 20), // Espace en bas de la page
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      padding: const EdgeInsets.only(top: 50, bottom: 20),
      child: Column(
        children: [
          // Bouton Retour
          Align(
            alignment: Alignment.topLeft,
            child: Padding(
              padding: const EdgeInsets.only(left: 13.0),
              child: Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: const Color(0xFFAA7311),
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.25),
                      spreadRadius: 1,
                      blurRadius: 5,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: const Icon(Icons.arrow_back, color: Colors.white),
              ),
            ),
          ),
          const SizedBox(height: 30),

          // Image Afrique
          Container(
            width: 140,
            height: 140,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: const Color(0xFFAA7311), width: 1),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.25),
                  blurRadius: 15,
                ),
              ],
              image: const DecorationImage(
                image: AssetImage('assets/map_africa.png'), // Remplacez par votre image de la carte
                fit: BoxFit.cover,
              ),
            ),
          ),
          const SizedBox(height: 20),

          // Texte "Découvrir"
          const Text(
            'Découvrir',
            style: TextStyle(
              fontSize: 32,
              color: Color(0xFFAA7311),
            ),
          ),
          const SizedBox(height: 5),

          // Sous-titre
          const Text(
            'Explorez les trésors de notre\npatrimoine culturel',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontFamily: 'Playfair', // Assurez-vous d'importer cette police
              fontSize: 16,
              color: Colors.black54,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryCard(Category category) {
    // Le Card/Container pour chaque catégorie
    return Container(
      height: 183,
      clipBehavior: Clip.antiAlias, // Pour que le contenu respecte le border-radius
      decoration: BoxDecoration(
        borderRadius: category.borderRadius,
      ),
      child: Stack(
        fit: StackFit.expand,
        children: <Widget>[
          // 1. Image de fond
          Image.asset(
            category.imagePath,
            fit: BoxFit.cover,
          ),

          // 2. Calque (overlay) semi-transparent (pour la couleur de fond spécifiée dans les coordonnées)
          // Le calque est appliqué *sur* l'image pour l'effet de flou/assombrissement
          Container(
            color: Colors.black.withOpacity(
                0.27), // Utilisation d'une opacité moyenne pour se rapprocher du design
          ),

          // 3. Texte (Titre et Sous-titre)
          Padding(
            padding: const EdgeInsets.all(15.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.end,
              crossAxisAlignment: category.titleAlignment == Alignment.bottomLeft
                  ? CrossAxisAlignment.start
                  : CrossAxisAlignment.end,
              children: [
                Text(
                  category.title,
                  style: const TextStyle(
                    fontFamily: 'Playfair', // Assurez-vous d'importer cette police
                    fontSize: 32,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  category.subtitle.replaceAll(' et ', ' et\n'), // Pour forcer un retour à la ligne pour le sous-titre
                  textAlign: category.titleAlignment == Alignment.bottomLeft
                      ? TextAlign.left
                      : TextAlign.left,
                  style: const TextStyle(
                    fontFamily: 'Playfair', // Assurez-vous d'importer cette police
                    fontSize: 10,
                    fontWeight: FontWeight.w400,
                    color: Colors.white,
                    height: 1.2,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}