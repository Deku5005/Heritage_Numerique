import 'package:flutter/material.dart';
import '../widgets/bottom_navigation_widget.dart';
import 'Artisan_detail_screen.dart'; // Importez le nouvel écran de détail

/// Écran affichant la liste des produits d'artisanat Malien (adapté au design fourni).
class ArtisansScreen extends StatelessWidget {
  const ArtisansScreen({super.key});

  // Couleur principale Ocre Vif (D69301)
  static const Color _accentColor = Color(0xFFD69301);
  static const Color _cardTextColor = Color(0xFF2E2E2E);
  static const Color _actionColor = Color(0xFF9F9646); // Utilisée pour les actions

  // NOUVEAU : Données d'Artisans/Catégories multilingues
  final List<Map<String, dynamic>> artisans = const [
    {
      'artisan_name': 'Fatoumata Diawara', // Nom statique pour le profil
      'profile_image': 'assets/images/Artisan_Fatoumata.jpg', // Image de l'artisan (pour l'en-tête du détail)
      'primary_image': 'assets/images/Tissage.jpg', // Image principale pour la carte
      'small_images': ['assets/images/Tissage2.jpg', 'assets/images/Tissage3.jpg'], // Galerie
      'video_url': 'https://www.youtube.com/watch?v=fatou_bogolan',
      'support_link': 'https://www.example.com/support_fatoumata',
      'content': {
        'Français': {
          'category_title': 'TISSAGE de Bogolan',
          'description': 'Tissus traditionnels Bogolan, Indigo, et pagnes. Techniques anciennes. Un savoir-faire unique.',
          'artisan_bio': 'Maîtresse tisserande spécialisée dans le Bogolan, Fatoumata Diawara préserve des techniques ancestrales et travaille principalement à Ségou.',
          'video_title': 'La tradition du Bogolan Malien',
          'gallery_title': 'Galerie des créations',
          'watch_video_label': 'Regarder la vidéo (Tissage)',
          'support_artisan_label': 'Soutenir l\'Artisan',
        },
        'Bambara': {
          'category_title': 'Bogolan Dilili',
          'description': 'Bogolan, Indigo, ni kafodenw ka dililiw. Dilili yɔrɔ kɔrɔw. Dɔnko kɛrɛnkɛrɛnnen.',
          'artisan_bio': 'Dilili dɔnnikɛla kɔrɔba, Fatoumata Diawara bɛ dɔnko kɔrɔw mara ani a bɛ baara kɛ Segu.',
          'video_title': 'Mali ka Bogolan Kuma',
          'gallery_title': 'Baarakɛlaw Jɛkulu',
          'watch_video_label': 'Videwo lajɛ (Dilili)',
          'support_artisan_label': 'Dɔnnikɛla Dɛmɛ',
        },
        'Anglais': {
          'category_title': 'Bogolan Weaving',
          'description': 'Traditional Bogolan, Indigo fabrics. Ancient techniques. A unique expertise.',
          'artisan_bio': 'Master weaver specializing in Bogolan, Fatoumata Diawara preserves ancestral techniques and primarily works in Ségou.',
          'video_title': 'The Malian Bogolan Tradition',
          'gallery_title': 'Creation Gallery',
          'watch_video_label': 'Watch Video (Weaving)',
          'support_artisan_label': 'Support the Artisan',
        },
      },
    },
    {
      'artisan_name': 'Amadou Traoré',
      'profile_image': 'assets/images/Artisan_Amadou.jpg',
      'primary_image': 'assets/images/Poterie.jpg',
      'small_images': ['assets/images/Poterie2.jpg', 'assets/images/Poterie3.jpg'],
      'video_url': 'https://www.youtube.com/watch?v=amadou_poterie',
      'support_link': 'https://www.example.com/support_amadou',
      'content': {
        'Français': {
          'category_title': 'Poterie en Terre Cuite',
          'description': 'Poteries en terre cuite et objets décoratifs. Art ancestral Malien.',
          'artisan_bio': 'Amadou Traoré est un potier reconnu pour ses jarres et ustensiles traditionnels, perpétuant l\'art de la terre dans la région de Djenné.',
          'video_title': 'L\'art de la Poterie au Mali',
          'gallery_title': 'Pièces maîtresses',
          'watch_video_label': 'Regarder la vidéo (Poterie)',
          'support_artisan_label': 'Soutenir l\'Artisan',
        },
        'Bambara': {
          'category_title': 'Bɔgɔ Dilan',
          'description': 'Bɔgɔw ni fɛn dilannaw. Mali ka dɔnko kɔrɔba.',
          'artisan_bio': 'Amadou Traoré ye bɔgɔ dilannikɛla min dɔnna ni a ka kurusow ani minɛnw ye.',
          'video_title': 'Mali ka Bɔgɔ Dilan Dɔnko',
          'gallery_title': 'Baara Jɛkulu',
          'watch_video_label': 'Videwo lajɛ (Bɔgɔ)',
          'support_artisan_label': 'Dɔnnikɛla Dɛmɛ',
        },
        'Anglais': {
          'category_title': 'Terracotta Pottery',
          'description': 'Terracotta pots and decorative objects. Ancestral Malian art.',
          'artisan_bio': 'Amadou Traoré is a potter renowned for his traditional jars and utensils, perpetuating the art of the earth in the Djenné region.',
          'video_title': 'The Art of Pottery in Mali',
          'gallery_title': 'Masterpieces',
          'watch_video_label': 'Watch Video (Pottery)',
          'support_artisan_label': 'Support the Artisan',
        },
      },
    },
    // Ajoutez d'autres éléments ici
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      bottomNavigationBar: const BottomNavigationWidget(currentPage: 'artisans'), 
      body: SingleChildScrollView(
        padding: const EdgeInsets.only(top: 0),
        child: Column(
          children: [
            _buildHeader(context),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Column(
                children: [
                  const SizedBox(height: 20),
                  _buildSearchBar(),
                  const SizedBox(height: 20),
                  _buildCraftsGrid(),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// 1. Construction de l'en-tête (Basé sur l'image fournie)
  Widget _buildHeader(BuildContext context) {
    // ... (Reste de la méthode _buildHeader inchangée) ...
    return Stack(
      children: [
        Container(
          height: 250,
          decoration: BoxDecoration(
            color: Colors.grey[200],
            borderRadius: const BorderRadius.vertical(bottom: Radius.circular(30)),
          ),
          child: ClipRRect(
            borderRadius: const BorderRadius.vertical(bottom: Radius.circular(30)),
            child: Stack(
              fit: StackFit.expand,
              children: [
                Image.asset(
                  'assets/images/mali_craftsman.jpg', 
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) => Container(
                    color: _accentColor.withOpacity(0.2),
                    child: const Center(child: Text('Artisanat', style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold))),
                  ),
                ),
                Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [Colors.black.withOpacity(0.3), Colors.black.withOpacity(0.5)],
                    ),
                  ),
                ),
                Positioned(
                  bottom: 20,
                  left: 20,
                  child: Text(
                    "L'artisanat Malien",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 30,
                      fontWeight: FontWeight.bold,
                      shadows: [Shadow(blurRadius: 10, color: Colors.black.withOpacity(0.8))],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        Positioned(
          top: 0,
          left: 0,
          right: 0,
          child: AppBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            leading: Padding(
              padding: const EdgeInsets.only(left: 8.0),
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.2), 
                  shape: BoxShape.circle,
                ),
                child: IconButton(
                  icon: Icon(Icons.arrow_back, color: Colors.white.withOpacity(0.9)),
                  onPressed: () => Navigator.pop(context),
                ),
              ),
            ),
            centerTitle: true,
            title: const Text(
              'Artisanat',
              style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
            ),
          ),
        ),
      ],
    );
  }

  /// 2. Construction de la barre de recherche.
  Widget _buildSearchBar() {
    // ... (Code de _buildSearchBar inchangé) ...
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10),
      decoration: BoxDecoration(
        color: _accentColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: Colors.grey.shade300, width: 1.5), 
        boxShadow: [BoxShadow(color: Colors.grey.withOpacity(0.1), blurRadius: 5, offset: const Offset(0, 2))],
      ),
      child: TextField(
        decoration: InputDecoration(
          icon: Icon(Icons.search, color: _accentColor),
          hintText: 'Rechercher des artisans',
          hintStyle: TextStyle(color: _cardTextColor.withOpacity(0.6)),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(vertical: 14.0),
        ),
      ),
    );
  }

  /// 3. Construction de la grille d'artisanat.
  Widget _buildCraftsGrid() {
    return GridView.builder(
      physics: const NeverScrollableScrollPhysics(),
      shrinkWrap: true,
      itemCount: artisans.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 10,
        mainAxisSpacing: 10,
        childAspectRatio: 0.65, 
      ),
      itemBuilder: (context, index) {
        final craft = artisans[index];
        // Utiliser la version française pour l'affichage de la carte
        final frenchContent = craft['content']['Français']; 
        
        return _buildCraftCard(
          context,
          craft['primary_image']! as String,
          frenchContent['description']! as String,
          frenchContent['category_title']! as String, // Titre Français pour la carte
          craft['small_images'] as List<String>,
          craft, // Passe tout l'objet pour la navigation
        );
      },
    );
  }

  /// 4. Construction d'une seule carte d'artisanat.
  Widget _buildCraftCard(
    BuildContext context,
    String primaryImagePath,
    String description,
    String categoryTitle, // Nouveau paramètre pour le titre affiché
    List<String> smallImagePaths,
    Map<String, dynamic> artisanData, // Toutes les données pour la navigation
  ) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 8, offset: const Offset(0, 4))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 4.1. IMAGE PRINCIPALE
          Expanded(
            flex: 6,
            child: _buildPrimaryImage(primaryImagePath, categoryTitle), // Utilise categoryTitle pour le Tag
          ),
            
          // 4.2. DESCRIPTION
          Padding(
            padding: const EdgeInsets.only(left: 8.0, right: 8.0, top: 8.0),
            child: Text(
              description,
              style: TextStyle(
                color: _cardTextColor.withOpacity(0.6),
                fontSize: 10,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          const SizedBox(height: 8),

          // 4.3. PETITES IMAGES
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: _buildSmallImageRow(smallImagePaths),
          ),
          const SizedBox(height: 8),

          // 4.4. BOUTON DÉCOUVRIR (Remplace les deux anciens boutons pour pointer vers le détail)
          Padding(
            padding: const EdgeInsets.only(left: 8.0, right: 8.0, bottom: 8.0),
            child: _buildDiscoverButton(context, artisanData), // Nouveau bouton d'action
          ),
        ],
      ),
    );
  }

  /// Bouton DÉCOUVRIR pour la navigation.
  Widget _buildDiscoverButton(BuildContext context, Map<String, dynamic> artisanData) {
    return GestureDetector(
      onTap: () {
        // Navigation vers l'écran de détail avec toutes les données multilingues
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ArtisanDetailScreen(
              artisanData: artisanData,
            ),
          ),
        );
      },
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 8),
        decoration: BoxDecoration(
          color: _accentColor,
          borderRadius: BorderRadius.circular(8),
        ),
        child: const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.brush, size: 16, color: Colors.white),
            SizedBox(width: 6),
            Text(
              'Découvrir l\'artisan',
              style: TextStyle(
                color: Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }


  /// Section d'image principale (Grande section en haut).
  Widget _buildPrimaryImage(String imagePath, String categoryTitle) {
    return ClipRRect(
      borderRadius: const BorderRadius.vertical(top: Radius.circular(15)),
      child: Container(
        color: Colors.grey[300],
        child: Stack(
          fit: StackFit.expand,
          children: [
            Image.asset(
              imagePath,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) => Center(
                child: Icon(Icons.brush, size: 40, color: _cardTextColor.withOpacity(0.5)),
              ),
            ),
            // Tag "PRODUIT" (coin supérieur droit)
            Positioned(
              top: 8,
              right: 8,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                decoration: BoxDecoration(
                  color: _accentColor.withOpacity(0.8),
                  borderRadius: BorderRadius.circular(5),
                ),
                child: Text(
                  categoryTitle.toUpperCase(), // Utilise le titre de la catégorie comme tag
                  style: const TextStyle(color: Colors.white, fontSize: 8, fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Section des deux petites images (En bas).
  Widget _buildSmallImageRow(List<String> imagePaths) {
    return Row(
      children: [
        Expanded(
          child: _buildSmallImageCard(imagePaths.isNotEmpty ? imagePaths[0] : '', 'Détail 1'),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _buildSmallImageCard(imagePaths.length > 1 ? imagePaths[1] : '', 'Détail 2'),
        ),
      ],
    );
  }

  /// Petite carte pour chaque image (avec texte en dessous).
  Widget _buildSmallImageCard(String imagePath, String label) {
    return Column(
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(10),
          child: Container(
            color: Colors.grey[300],
            height: 60, 
            child: Stack(
              children: [
                Image.asset(
                  imagePath,
                  fit: BoxFit.cover,
                  width: double.infinity,
                  errorBuilder: (context, error, stackTrace) => Center(
                    child: Icon(Icons.image_not_supported, size: 20, color: _cardTextColor.withOpacity(0.5)),
                  ),
                ),
                Positioned(
                  bottom: 0,
                  left: 0,
                  right: 0,
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 2),
                    color: Colors.black.withOpacity(0.5),
                    child: const Center(
                      child: Text(
                        'Détail produit',
                        style: TextStyle(color: Colors.white, fontSize: 8),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}