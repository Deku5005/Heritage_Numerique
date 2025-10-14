import 'package:flutter/material.dart';
import '../widgets/bottom_navigation_widget.dart'; // Assurez-vous que ce widget existe
import 'Music_detail_screen.dart'; // L'importation de la page de détail est activée

/// Écran affichant la liste des morceaux et rythmes traditionnels Maliens.
class MusicScreen extends StatelessWidget {
  const MusicScreen({super.key});

  // Constantes de Couleurs
  // Couleur principale Ocre Vif (D69301)
  static const Color _accentColor = Color(0xFFD69301);
  // Gris foncé pour le texte des cartes pour un contraste optimal
  static const Color _cardTextColor = Color(0xFF2E2E2E);
  // Couleur de fond pour le corps de la page
  static const Color _backgroundColor = Colors.white;

  // Données de musique simulées
  final List<Map<String, dynamic>> musicTracks = const [
    {
      'title': 'Kora de Nuit',
      'artist': 'Toumani Diabaté',
      'duration': '4:32',
      'image': 'assets/images/Kora1.jpg',
      'likes': 152,
      'details': {'nom': 'Toumani', 'langue': 'Bambara'},
      'description': "Un morceau envoûtant interprété à la kora, capturant la sérénité des nuits maliennes."
    },
    {
      'title': 'Rythme Tam-Tam',
      'artist': 'Djelimoussa Kounda',
      'duration': '3:45',
      'image': 'assets/images/Djembe1.jpg',
      'likes': 98,
      'details': {'nom': 'Kounda', 'langue': 'Peul'},
      'description': "Une explosion de percussions traditionnelles jouées sur un djembe, essence des fêtes locales."
    },
    {
      'title': 'Chant des Griots',
      'artist': 'Bassekou Kouyaté',
      'duration': '5:12',
      'image': 'assets/images/Griot1.jpg',
      'likes': 210,
      'details': {'nom': 'Bassekou', 'langue': 'Malinké'},
      'description': "Les récits poétiques des griots, gardiens de la mémoire et de l'histoire du Mali."
    },
    {
      'title': 'Flûte Peule',
      'artist': 'Harouna Samake',
      'duration': '3:28',
      'image': 'assets/images/Flute1.jpg',
      'likes': 75,
      'details': {'nom': 'Harouna', 'langue': 'Peul'},
      'description': "Une mélodie douce et aérienne jouée à la flûte, typique des paysages pastoraux Peuls."
    },
    {
      'title': 'Wassoulou Blues',
      'artist': 'Oumou Sangaré',
      'duration': '6:01',
      'image': 'assets/images/Oumou.jpg',
      'likes': 320,
      'details': {'nom': 'Oumou', 'langue': 'Wassoulou'},
      'description': "Le célèbre blues de la région du Wassoulou, fusion de tradition et de modernité."
    },
    {
      'title': 'Balafon Magique',
      'artist': 'Tidiane Koné',
      'duration': '4:18',
      'image': 'assets/images/Balafon.jpg',
      'likes': 180,
      'details': {'nom': 'Tidiane', 'langue': 'Bambara'},
      'description': "Un morceau virtuose mettant en vedette le balafon, le xylophone africain ancestral."
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _backgroundColor,
      // Utilise le widget de navigation en bas
      bottomNavigationBar: const BottomNavigationWidget(currentPage: 'musique'),
      body: SingleChildScrollView(
        padding: const EdgeInsets.only(top: 0),
        child: Column(
          children: [
            // 1. EN-TÊTE ET BARRE D'APPLICATION
            _buildHeader(context),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Column(
                children: [
                  const SizedBox(height: 20),
                  // 2. BARRE DE RECHERCHE
                  _buildSearchBar(),
                  const SizedBox(height: 20),
                  // 3. GRILLE DES MORCEAUX
                  _buildMusicGrid(),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// 1. Construction de l'en-tête (Grande carte et AppBar)
  Widget _buildHeader(BuildContext context) {
    return Stack(
      children: [
        // Grande carte thématique "Les Sons du Mali"
        Container(
          height: 250,
          decoration: const BoxDecoration(
            color: Colors.black,
            borderRadius: BorderRadius.vertical(bottom: Radius.circular(30)),
          ),
          child: ClipRRect(
            borderRadius: const BorderRadius.vertical(bottom: Radius.circular(30)),
            child: Stack(
              fit: StackFit.expand,
              children: [
                Image.asset(
                  'assets/images/Musique.png', // Image de Musique Mali
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) => Container(
                    color: Colors.red.shade900,
                    child: const Center(
                      child: Text('Les Sons du Mali', style: TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.bold)),
                    ),
                  ),
                ),
                // Overlay sombre
                Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.black.withOpacity(0.3),
                        Colors.black.withOpacity(0.5),
                      ],
                    ),
                  ),
                ),
                // Texte et Icône de lecture
                Positioned(
                  bottom: 20,
                  left: 20,
                  right: 20,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        "Les Sons du Mali",
                        style: TextStyle(color: Colors.white, fontSize: 30, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text('Plongez au cœur des rythmes maliens ancestraux.',
                              style: TextStyle(color: Colors.white.withOpacity(0.9), fontSize: 14, fontWeight: FontWeight.w500),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(color: _accentColor.withOpacity(0.9), shape: BoxShape.circle),
                            child: const Icon(Icons.play_arrow, color: Colors.white, size: 30),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
        // Barre d'application
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
                decoration: BoxDecoration(color: Colors.black.withOpacity(0.2), shape: BoxShape.circle),
                child: IconButton(
                  icon: Icon(Icons.arrow_back, color: Colors.white.withOpacity(0.9)),
                  onPressed: () => Navigator.pop(context),
                ),
              ),
            ),
            centerTitle: true,
            title: const Text('Musiques', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          ),
        ),
      ],
    );
  }

  /// 2. Construction de la barre de recherche.
  Widget _buildSearchBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10),
      decoration: BoxDecoration(
        color: _accentColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: _accentColor.withOpacity(0.5), width: 1.0),
        boxShadow: [BoxShadow(color: Colors.grey.withOpacity(0.1), blurRadius: 5, offset: const Offset(0, 2))],
      ),
      child: TextField(
        decoration: InputDecoration(
          icon: const Icon(Icons.search, color: _accentColor),
          hintText: 'Rechercher des morceaux',
          hintStyle: TextStyle(color: _cardTextColor.withOpacity(0.6)),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(vertical: 14.0),
        ),
      ),
    );
  }

  /// 3. Construction de la grille de musique.
  Widget _buildMusicGrid() {
    return GridView.builder(
      physics: const NeverScrollableScrollPhysics(),
      shrinkWrap: true,
      itemCount: musicTracks.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 10,
        mainAxisSpacing: 10,
        childAspectRatio: 0.75,
      ),
      itemBuilder: (context, index) {
        final track = musicTracks[index];
        return GestureDetector(
          // **CORRECTION : La navigation est activée ici**
          onTap: () {
            // Assurez-vous que MusicDetailScreen est correctement défini (voir réponse précédente)
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => MusicDetailScreen(
                  musicTitle: track['title'] as String,
                  artistName: track['artist'] as String,
                  description: track['description'] as String,
                  audioUrl: 'url_audio_${index + 1}', // URL Audio simulé
                  imageUrl: track['image'] as String,
                  details: track['details'] as Map<String, dynamic>,
                ),
              ),
            );
          },
          child: _buildMusicCard(
            context,
            track['title'] as String,
            track['artist'] as String,
            track['duration'] as String,
            track['image'] as String,
            track['likes'] as int,
          ),
        );
      },
    );
  }

  /// 4. Construction d'une seule carte de morceau de musique.
  Widget _buildMusicCard(
      BuildContext context,
      String title,
      String artistName,
      String duration,
      String imagePath,
      int likes,
      ) {
    // Calcule la hauteur totale disponible pour la carte (basé sur childAspectRatio=0.75)
    // Nous allons utiliser un ratio approximatif de 70% pour l'image et 30% pour le texte.

    // Pour éviter les débordements (overflow) de RenderFlex, on utilise un LayoutBuilder
    // pour garantir que les enfants de Column ont des contraintes de taille précises,
    // même si on est dans un GridView.
    return LayoutBuilder(
      builder: (context, constraints) {
        // La hauteur de la carte est gérée par GridView, on utilise la largeur pour estimer la hauteur.
        final cardHeight = constraints.maxHeight;
        // CORRECTION MAJEURE: Augmentation de l'espace alloué au texte pour éviter le débordement.
        // On passe de 70/30% à 65/35% (Image/Texte)
        final imageSectionHeight = cardHeight * 0.65; // 65% pour l'image
        final textSectionHeight = cardHeight * 0.35; // 35% pour les détails

        return Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(15),
            boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 6, offset: const Offset(0, 3))],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 1. Image du morceau avec icône de lecture (Hauteur fixe)
              SizedBox(
                height: imageSectionHeight, // Hauteur calculée
                child: _buildVideoImage(imagePath),
              ),

              // 2. Section du texte et des actions (Hauteur fixe)
              SizedBox(
                height: textSectionHeight, // Hauteur calculée
                child: Padding(
                  // Garde le padding vertical à 6.0
                  padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 6.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    // Garde le mainAxisAlignment à spaceAround
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      // Titre
                      Text(title, style: const TextStyle(color: _cardTextColor, fontSize: 13, fontWeight: FontWeight.bold), maxLines: 1, overflow: TextOverflow.ellipsis),

                      // Artiste, Durée, Likes
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Flexible(
                            child: Row(
                              children: [
                                Icon(Icons.person, size: 12, color: _cardTextColor.withOpacity(0.6)),
                                const SizedBox(width: 2),
                                Expanded( // Expanded est essentiel ici pour gérer le débordement horizontal
                                  child: Text(artistName, style: TextStyle(color: _cardTextColor.withOpacity(0.6), fontSize: 9), overflow: TextOverflow.ellipsis),
                                ),
                                const SizedBox(width: 5),
                                Icon(Icons.timer, size: 12, color: _cardTextColor.withOpacity(0.6)),
                                const SizedBox(width: 2),
                                Text(duration, style: TextStyle(color: _cardTextColor.withOpacity(0.6), fontSize: 9)),
                              ],
                            ),
                          ),
                          _buildLikeButton(likes),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  /// Image du morceau avec icône de lecture au centre.
  Widget _buildVideoImage(String imagePath) {
    return ClipRRect(
      borderRadius: const BorderRadius.vertical(top: Radius.circular(15)),
      child: Container(
        color: Colors.grey[300],
        child: Stack(
          fit: StackFit.expand,
          children: [
            Image.asset(imagePath, fit: BoxFit.cover, errorBuilder: (context, error, stackTrace) => Center(child: Icon(Icons.music_note, size: 40, color: _cardTextColor.withOpacity(0.5)))),
            Container(color: Colors.black.withOpacity(0.1)),
            Center(
              child: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(color: Colors.black.withOpacity(0.6), shape: BoxShape.circle),
                child: const Icon(Icons.play_arrow, color: Colors.white, size: 30),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Bouton J'aime/Cœur en bas de la carte.
  Widget _buildLikeButton(int likes) {
    // Ce bouton a été optimisé pour un usage minimal de l'espace.
    return IconButton(
      icon: const Icon(Icons.favorite_border, size: 18, color: Colors.grey),
      onPressed: () {},
      // Supprime l'espace intérieur inutile
      padding: EdgeInsets.zero,
      // Contraintes minimales pour le bouton pour éviter de le rendre invisible.
      constraints: const BoxConstraints(minWidth: 30, minHeight: 30),
    );
  }
}
