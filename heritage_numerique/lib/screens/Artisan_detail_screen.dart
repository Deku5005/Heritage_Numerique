import 'package:flutter/material.dart';
import '../widgets/bottom_navigation_widget.dart'; // Assurez-vous d'importer le widget de navigation

/// Écran affichant le profil détaillé d'un artisan et ses créations, avec support multilingue.
class ArtisanDetailScreen extends StatefulWidget {
  final Map<String, dynamic> artisanData;

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

  // État actuel de la langue sélectionnée
  late String _selectedLanguage;

  // Liste des langues disponibles
  final List<String> _languages = const ['Français', 'Bambara', 'Anglais'];

  @override
  void initState() {
    super.initState();
    // Initialise avec la première langue disponible dans le bloc de contenu (qui est 'Français' dans notre structure)
    _selectedLanguage = 'Français'; 
  }

  /// Fonction utilitaire pour obtenir les données du conte pour la langue sélectionnée
  Map<String, String> _getCurrentContent() {
    final Map<String, Map<String, String>> allContent = widget.artisanData['content'] as Map<String, Map<String, String>>;
    return allContent[_selectedLanguage] ?? allContent['Français']!;
  }

  /// Sélecteur de langue (DropdownButton) - Réutilisé du ContesScreen
  Widget _buildLanguageSelector() {
    // Filtre les langues disponibles en fonction de ce qui existe dans 'content'
    final Map<String, Map<String, String>> allContent = widget.artisanData['content'] as Map<String, Map<String, String>>;
    final availableLanguages = _languages.where((lang) => allContent.containsKey(lang)).toList();

    return Center(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 0),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: Colors.grey.shade300, width: 1),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 5,
            ),
          ]
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.flag, color: _accentColor, size: 16),
            const SizedBox(width: 8),
            
            DropdownButton<String>(
              value: _selectedLanguage,
              icon: const Icon(Icons.keyboard_arrow_down, color: _accentColor),
              iconSize: 24,
              elevation: 16,
              style: const TextStyle(color: _cardTextColor, fontWeight: FontWeight.bold),
              underline: Container(),
              onChanged: (String? newValue) {
                if (newValue != null) {
                  setState(() {
                    _selectedLanguage = newValue;
                  });
                }
              },
              items: availableLanguages.map<DropdownMenuItem<String>>((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value),
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final currentContent = _getCurrentContent();
    final artisanName = widget.artisanData['artisan_name'] as String;
    final profileImage = widget.artisanData['profile_image'] as String;
    final artisanBio = currentContent['artisan_bio']!;
    final videoTitle = currentContent['video_title']!;
    final galleryTitle = currentContent['gallery_title']!;
    final videoUrl = widget.artisanData['video_url'] as String;
    final supportLink = widget.artisanData['support_link'] as String;
    final watchVideoLabel = currentContent['watch_video_label']!;
    final supportArtisanLabel = currentContent['support_artisan_label']!;
    final smallImages = widget.artisanData['small_images'] as List<String>;

    return Scaffold(
      backgroundColor: Colors.white,
      bottomNavigationBar: const BottomNavigationWidget(currentPage: 'artisans'),
      body: SingleChildScrollView(
        child: Column(
          children: [
            _buildCustomAppBar(context, 'Artisanat'), // Basé sur la capture d'écran
            
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const SizedBox(height: 20),
                  
                  // --- 1. SÉLECTEUR DE LANGUE ---
                  _buildLanguageSelector(),
                  const SizedBox(height: 30),

                  // --- 2. PROFIL ARTISAN (Image et Nom) ---
                  _buildArtisanProfile(profileImage, artisanName),
                  const SizedBox(height: 20),
                  
                  // --- 3. BIO/DESCRIPTION (Dynamique) ---
                  Text(
                    artisanBio,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: _cardTextColor.withOpacity(0.7),
                      fontSize: 16,
                      height: 1.4,
                    ),
                  ),
                  const SizedBox(height: 30),

                  // --- 4. VIDÉO DE L'ARTISAN ---
                  _buildVideoSection(videoTitle, videoUrl, watchVideoLabel),
                  const SizedBox(height: 30),

                  // --- 5. BOUTON DE SOUTIEN ---
                  _buildActionButton(supportArtisanLabel, Icons.favorite, _accentColor, supportLink),
                  const SizedBox(height: 30),


                  // --- 6. GALERIE (Titre Dynamique) ---
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      galleryTitle,
                      style: const TextStyle(
                        color: _cardTextColor,
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(height: 15),

                  // --- 7. IMAGES DE GALERIE ---
                  _buildGallery(smallImages),
                  const SizedBox(height: 50),
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
            Text(
              title,
              style: const TextStyle(
                color: _cardTextColor,
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
            ),
            // Placeholder pour l'alignement
            const SizedBox(width: 48), 
          ],
        ),
      ),
    );
  }


  /// 2. PROFIL ARTISAN (Image et Nom)
  Widget _buildArtisanProfile(String imagePath, String name) {
    return Column(
      children: [
        CircleAvatar(
          radius: 60,
          backgroundColor: _accentColor.withOpacity(0.2),
          backgroundImage: imagePath.isNotEmpty ? AssetImage(imagePath) : null,
          child: imagePath.isEmpty ? Icon(Icons.person, size: 60, color: _accentColor) : null,
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

  /// 4. VIDÉO DE L'ARTISAN
  Widget _buildVideoSection(String title, String url, String buttonLabel) {
    return Column(
      children: [
        // Placeholder de la vidéo (simulé par un conteneur avec un bouton Play)
        AspectRatio(
          aspectRatio: 16 / 9,
          child: Container(
            decoration: BoxDecoration(
              color: Colors.black,
              borderRadius: BorderRadius.circular(15),
              image: const DecorationImage(
                image: AssetImage('assets/images/video_placeholder.jpg'), // Remplacez par une image plus appropriée
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
        // Le titre de la vidéo peut être affiché ici si nécessaire, mais on utilise le bouton pour l'action.
        _buildActionButton(buttonLabel, Icons.play_arrow, _actionColor, url),
      ],
    );
  }

  /// 5. et 7. BOUTON D'ACTION ET GALERIE
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
              text, // Libellé dynamique
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

  /// 7. IMAGES DE GALERIE
  Widget _buildGallery(List<String> imagePaths) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: imagePaths.map((path) => Expanded(
        child: Padding(
          padding: EdgeInsets.only(right: path == imagePaths.last ? 0 : 10),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: Image.asset(
              path,
              fit: BoxFit.cover,
              height: 150,
              errorBuilder: (context, error, stackTrace) => Container(
                height: 150,
                color: Colors.grey[300],
                child: Center(child: Icon(Icons.image, color: _cardTextColor.withOpacity(0.5))),
              ),
            ),
          ),
        ),
      )).toList(),
    );
  }
}