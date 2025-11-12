import 'package:flutter/material.dart';
import '../widgets/bottom_navigation_widget.dart';
import '../model/artisanat1.dart';

/// Écran affichant le profil détaillé d'un artisan et ses créations.
class ArtisanDetailScreen extends StatefulWidget {
  final Artisanat1 artisanData;

  const ArtisanDetailScreen({
    super.key,
    required this.artisanData,
  });

  @override
  State<ArtisanDetailScreen> createState() => _ArtisanDetailScreenState();
}

class _ArtisanDetailScreenState extends State<ArtisanDetailScreen> {
  // COULEURS
  static const Color _accentColor = Color(0xFFD69301);
  static const Color _cardTextColor = Color(0xFF2E2E2E);
  static const Color _actionColor = Color(0xFF9F9646);

  // URL DE BASE POUR LES IMAGES
  static const String _apiBaseUrlForImages = 'http://10.0.2.2:8080';

  @override
  void initState() {
    super.initState();
  }

  // LOGIQUE POUR COMPLÉTER LES URLS RELATIVES
  String _getFullImageUrl(String? relativePath) {
    if (relativePath == null || relativePath.isEmpty) {
      return '';
    }
    if (relativePath.toLowerCase().startsWith('http')) {
      return relativePath;
    }

    final String sanitizedPath = relativePath.startsWith('/') ? relativePath.substring(1) : relativePath;

    return '$_apiBaseUrlForImages/$sanitizedPath';
  }

  @override
  Widget build(BuildContext context) {
    final Artisanat1 data = widget.artisanData;

    // 1. GESTION DU NULL-SAFETY ET VALEURS PAR DÉFAUT
    final String titre = data.titre ?? 'Détail Artisanat';
    final String description = data.description ?? 'Description non spécifiée par l\'artisan.';

    final String nomAuteurComplet = '${data.prenomAuteur ?? ''} ${data.nomAuteur ?? 'Auteur inconnu'}'.trim();

    final String? videoPath = data.urlVideo;
    final String? emailAuteur = data.emailAuteur;

    // 2. CONSTRUCTION DES URLS COMPLÈTES POUR L'IMAGE PRINCIPALE ET LA VIDÉO
    final String fullVideoUrl = _getFullImageUrl(videoPath);

    // On prend toutes les photos (ou une liste vide si null)
    final List<String> allPhotosPaths = data.urlPhotos ?? [];

    // URL de l'image principale (utilisée comme bannière dans le détail)
    final String primaryImagePath = allPhotosPaths.isNotEmpty ? allPhotosPaths.first : '';
    final String fullPrimaryImageUrl = _getFullImageUrl(primaryImagePath);

    // *** LOGIQUE POUR LA GALERIE RETIRÉE ***

    // Libellés
    const String watchVideoLabel = 'Regarder la vidéo';
    const String supportArtisanLabel = 'Contacter l\'Auteur';

    return Scaffold(
      backgroundColor: Colors.white,
      bottomNavigationBar: const BottomNavigationWidget(currentPage: 'artisans'),
      body: SingleChildScrollView(
        child: Column(
          children: [
            _buildCustomAppBar(context, 'Artisanat : $titre'),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const SizedBox(height: 20),

                  // --- IMAGE PRINCIPALE DE L'ARTISANAT ---
                  _buildPrimaryImage(fullPrimaryImageUrl),
                  const SizedBox(height: 30),


                  // --- 1. PROFIL ARTISAN ---
                  _buildArtisanProfile(
                    nomAuteurComplet,
                    // Utilisation de ?.isNotEmpty == true pour la vérification sécurisée
                    emailAuteur?.isNotEmpty == true ? Icons.person : Icons.person_off,
                  ),
                  const SizedBox(height: 20),

                  // --- 2. BIO/DESCRIPTION ---
                  Text(
                    description,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: _cardTextColor.withOpacity(0.7),
                      fontSize: 16,
                      height: 1.4,
                    ),
                  ),
                  const SizedBox(height: 30),

                  // --- 3. VIDÉO DE L'ARTISAN ---
                  // Vérification sécurisée si l'URL complète n'est pas vide
                  if (fullVideoUrl.isNotEmpty)
                    _buildVideoSection(fullVideoUrl, watchVideoLabel),
                  if (fullVideoUrl.isNotEmpty) const SizedBox(height: 30),


                  // --- 4. BOUTON DE SOUTIEN ---
                  // Vérification sécurisée
                  if (emailAuteur?.isNotEmpty == true)
                    _buildActionButton(supportArtisanLabel, Icons.email, _accentColor, 'mailto:${emailAuteur!}'),

                  // Séparateur (Reste si le bouton est là, ou si c'est la fin du contenu)
                  const SizedBox(height: 50),

                  // *** LA GALERIE A ÉTÉ RETIRÉE ICI ***
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // --- WIDGETS DE STRUCTURE ---

  Widget _buildCustomAppBar(BuildContext context, String title) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.only(top: 10, left: 20, right: 20, bottom: 10),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Container(
              decoration: BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    ),
                  ]
              ),
              child: IconButton(
                icon: const Icon(Icons.arrow_back, color: _accentColor),
                onPressed: () => Navigator.pop(context),
              ),
            ),
            SizedBox(
              width: MediaQuery.of(context).size.width * 0.5,
              child: Text(
                title,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: _cardTextColor,
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),
            ),
            const SizedBox(width: 48),
          ],
        ),
      ),
    );
  }

  /// Image Principale de l'Artisanat
  Widget _buildPrimaryImage(String imageUrl) {
    if (imageUrl.isEmpty) {
      return Container(); // Retourne vide si l'URL n'est pas disponible
    }

    return ClipRRect(
      borderRadius: BorderRadius.circular(15),
      child: Container(
        height: 200,
        width: double.infinity,
        color: Colors.grey[300],
        child: Image.network(
          imageUrl,
          fit: BoxFit.cover,
          loadingBuilder: (context, child, loadingProgress) {
            if (loadingProgress == null) return child;
            return Center(
              child: CircularProgressIndicator(
                color: _accentColor,
                value: loadingProgress.expectedTotalBytes != null
                    ? loadingProgress.cumulativeBytesLoaded / loadingProgress.expectedTotalBytes!
                    : null,
              ),
            );
          },
          errorBuilder: (context, error, stackTrace) => Center(
            child: Icon(Icons.image_not_supported, size: 50, color: _cardTextColor.withOpacity(0.5)),
          ),
        ),
      ),
    );
  }


  /// 1. PROFIL ARTISAN
  Widget _buildArtisanProfile(String name, IconData icon) {
    return Column(
      children: [
        CircleAvatar(
          radius: 60,
          backgroundColor: _accentColor.withOpacity(0.2),
          child: Icon(icon, size: 60, color: _accentColor),
        ),
        const SizedBox(height: 10),
        Text(
          name,
          style: const TextStyle(
            color: _cardTextColor,
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  /// 3. VIDÉO DE L'ARTISAN (Le titre a été enlevé car il était fixe et redondant)
  Widget _buildVideoSection(String url, String buttonLabel) {
    return Column(
      children: [
        // Utilisation d'une image de placeholder pour la miniature de la vidéo
        AspectRatio(
          aspectRatio: 16 / 9,
          child: Container(
            decoration: BoxDecoration(
              color: Colors.black,
              borderRadius: BorderRadius.circular(15),
              image: const DecorationImage(
                image: NetworkImage('https://via.placeholder.com/300x168.png?text=Video+Placeholder'),
                fit: BoxFit.cover,
                colorFilter: ColorFilter.mode(Colors.black54, BlendMode.darken),
              ),
            ),
            child: Center(
              child: Container(
                decoration: BoxDecoration(
                  color: _accentColor.withOpacity(0.8),
                  shape: BoxShape.circle,
                ),
                child: IconButton(
                  icon: const Icon(Icons.play_arrow, color: Colors.white, size: 50),
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('$buttonLabel (URL: $url)'),
                        backgroundColor: _actionColor,
                      ),
                    );
                  },
                ),
              ),
            ),
          ),
        ),
        const SizedBox(height: 10),
        _buildActionButton(buttonLabel, Icons.play_arrow, _actionColor, url),
      ],
    );
  }

  /// BOUTON D'ACTION
  Widget _buildActionButton(String text, IconData icon, Color color, String url) {
    return GestureDetector(
      onTap: () {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('$text (URL: $url)'),
            backgroundColor: color,
          ),
        );
      },
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(10),
          boxShadow: [BoxShadow(color: color.withOpacity(0.4), blurRadius: 10, offset: const Offset(0, 5))],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 20, color: Colors.white),
            const SizedBox(width: 8),
            Text(
              text,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

// La méthode _buildGallery a été complètement retirée.
}