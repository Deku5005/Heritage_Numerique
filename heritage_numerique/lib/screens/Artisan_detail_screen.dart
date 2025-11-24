import 'package:flutter/material.dart';
// --- Imports pour la Traduction et l'Audio ---
import 'package:audioplayers/audioplayers.dart';
import 'dart:typed_data';

import '../Service/Artisanatservice1.dart'; // 💡 Nouveau service Artisanat
import '../service/LectureVocaleService.dart'; // Service audio réutilisé
import '../model/ArtisanatTraduction.dart'; // Modèle de traduction Artisanat

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
  static const Color _backgroundColor = Colors.white;

  // URL DE BASE POUR LES IMAGES
  static const String _apiBaseUrlForImages = 'http://10.0.2.2:8080';

  // --- PROPRIÉTÉS DE TRADUCTION ---
  final ArtisanatService1 _artisanatService = ArtisanatService1();
  ArtisanatTraduction? _currentTranslation;
  String _selectedLanguageCode = 'fr';
  bool _isLoadingTranslation = false;
  String? _translationError;
  List<String> _availableLanguages = ['fr', 'bm', 'en']; // Langues par défaut

  // --- PROPRIÉTÉS DE LECTURE VOCALE ---
  final LectureVocaleService _lectureVocaleService = LectureVocaleService();
  final AudioPlayer _audioPlayer = AudioPlayer();
  bool _isAudioLoading = false;
  bool _isPlaying = false;
  String? _audioError;


  @override
  void initState() {
    super.initState();
    // 1. Initialiser la traduction avec le contenu source
    _currentTranslation = _createSourceTranslation();
    // 2. Lancer la récupération des langues disponibles
    _fetchAvailableLanguages();

    _audioPlayer.onPlayerStateChanged.listen((PlayerState state) {
      if (mounted) {
        setState(() {
          _isPlaying = state == PlayerState.playing;
        });
      }
    });
  }

  @override
  void dispose() {
    _lectureVocaleService.dispose();
    _audioPlayer.dispose();
    super.dispose();
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

  // -------------------------------------------------------------------
  // --- LOGIQUE DE TRADUCTION ---
  // -------------------------------------------------------------------

  ArtisanatTraduction _createSourceTranslation() {
    final Artisanat1 data = widget.artisanData;

    return ArtisanatTraduction(
      idContenu: data.id ?? 0,
      titreOriginal: data.titre ?? '',
      descriptionOriginale: data.description ?? '',
      lieuOriginal: data.lieu,
      regionOriginale: data.region,
      traductionsTitre: {'fr': data.titre ?? ''},
      traductionsContenu: {'fr': data.description ?? ''},
      traductionsDescription: {'fr': data.description ?? ''},
      traductionsLieu: data.lieu != null ? {'fr': data.lieu!} : {},
      traductionsRegion: data.region != null ? {'fr': data.region!} : {},
      traductionsCompletes: {'fr': data.description ?? ''},
      languesDisponibles: const [],
      langueSource: 'fra_Latn',
      statutTraduction: 'SOURCE',
    );
  }

  Future<void> _fetchAvailableLanguages() async {
    final int? artisanatId = widget.artisanData.id;

    if (artisanatId == null || artisanatId <= 0) {
      print("Erreur: ID artisanat est manquant ou invalide.");
      return;
    }

    try {
      // Appel à 'bm' pour potentiellement récupérer la liste complète des langues
      final translation = await _artisanatService.fetchArtisanatTranslationPublic(
        artisanatId: artisanatId,
        targetLanguageCode: 'bm',
      );

      if (mounted) {
        final List<String> apiLangs = translation.languesDisponibles
            .map((code) => code == 'bam_Latn' ? 'bm' : code == 'eng_Latn' ? 'en' : code)
            .toList();

        setState(() {
          // Maintien des langues connues + ajout des langues de l'API
          _availableLanguages = {'fr', 'bm', 'en', ...apiLangs}.toSet().toList();
        });
      }
    } catch (e) {
      print("Erreur lors de la récupération initiale des langues: $e");
    }
  }

  Future<void> _fetchTranslation(String langCode) async {
    if (_isLoadingTranslation || langCode == _selectedLanguageCode) return;

    // Arrêter l'audio si on change de langue
    _audioPlayer.stop();

    if (langCode == 'fr') {
      setState(() {
        _currentTranslation = _createSourceTranslation();
        _selectedLanguageCode = 'fr';
        _translationError = null;
      });
      return;
    }

    setState(() {
      _isLoadingTranslation = true;
      _translationError = null;
      _selectedLanguageCode = langCode;
    });

    final int? artisanatId = widget.artisanData.id;

    if (artisanatId == null || artisanatId <= 0) {
      if (mounted) {
        setState(() {
          _translationError = "Impossible de traduire : ID d'artisanat invalide.";
          _isLoadingTranslation = false;
        });
      }
      return;
    }

    try {
      final translation = await _artisanatService.fetchArtisanatTranslationPublic(
        artisanatId: artisanatId,
        targetLanguageCode: langCode,
      );

      if (mounted) {
        setState(() {
          _currentTranslation = translation;
          final List<String> apiLangs = translation.languesDisponibles
              .map((code) => code == 'bam_Latn' ? 'bm' : code == 'eng_Latn' ? 'en' : code)
              .toList();

          _availableLanguages = {'fr', 'bm', 'en', ...apiLangs}.toSet().toList();
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _translationError = 'Erreur de traduction: ${e.toString().replaceFirst('Exception: ', '')}';
        });
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoadingTranslation = false;
        });
      }
    }
  }

  // --- Fonctions d'accès au contenu traduit ---

  String _getTranslatedText(String? originalText, Map<String, String> translationsMap, String langCode) {
    if (langCode == 'fr') return originalText ?? '';

    String? translated = translationsMap[langCode];
    if (translated != null && translated.isNotEmpty) return translated;

    // Vérification des codes longs d'API
    if (langCode == 'bm') {
      translated = translationsMap['bam_Latn'];
      if (translated != null && translated.isNotEmpty) return translated;
    }
    if (langCode == 'en') {
      translated = translationsMap['eng_Latn'];
      if (translated != null && translated.isNotEmpty) return translated;
    }

    return originalText ?? 'Traduction non disponible.';
  }

  String _getTitre() {
    return _getTranslatedText(
        widget.artisanData.titre,
        _currentTranslation?.traductionsTitre ?? {},
        _selectedLanguageCode
    );
  }

  String _getDescription() {
    return _getTranslatedText(
        widget.artisanData.description,
        _currentTranslation?.traductionsDescription ?? {},
        _selectedLanguageCode
    );
  }

  // -------------------------------------------------------------------
  // --- LOGIQUE DE LECTURE VOCALE ---
  // -------------------------------------------------------------------

  Future<void> _playTranslatedContent() async {
    if (_isPlaying) {
      await _audioPlayer.pause();
      return;
    }

    if (_isAudioLoading) return;

    final int? artisanatId = widget.artisanData.id;
    if (artisanatId == null || artisanatId <= 0) {
      setState(() => _audioError = "ID artisanat invalide pour la lecture.");
      return;
    }

    setState(() {
      _isAudioLoading = true;
      _audioError = null;
    });

    try {
      final Uint8List audioData = await _lectureVocaleService.telechargerLectureVocale(
          artisanatId,
          _selectedLanguageCode,
          usePublicApi: true
      );

      await _audioPlayer.play(BytesSource(audioData));

      setState(() {
        _isAudioLoading = false;
      });

    } catch (e) {
      print("Erreur de lecture vocale: $e");
      if (mounted) {
        setState(() {
          _isAudioLoading = false;
          _audioError = 'Échec de la lecture vocale. ($e)';
        });
      }
    }
  }

  // -------------------------------------------------------------------
  // --- WIDGETS DE CONSTRUCTION ---
  // -------------------------------------------------------------------

  // 💡 Intégration du sélecteur de langue et du bouton de lecture vocale
  Widget _buildLanguageSelector() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 5.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _buildPlayButton(), // Bouton de lecture vocale

          Row(
            children: [
              const Text("Langue : ", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: _cardTextColor)),
              DropdownButton<String>(
                value: _selectedLanguageCode,
                icon: const Icon(Icons.arrow_drop_down),
                underline: Container(height: 1, color: _accentColor),
                itemHeight: 48,
                onChanged: _isLoadingTranslation ? null : (String? newValue) {
                  if (newValue != null && newValue != _selectedLanguageCode) {
                    _fetchTranslation(newValue);
                  }
                },
                items: _availableLanguages.map<DropdownMenuItem<String>>((String value) {
                  String displayName;
                  switch (value) {
                    case 'fr':
                      displayName = 'Français (Source)';
                      break;
                    case 'en':
                      displayName = 'Anglais';
                      break;
                    case 'bm':
                      displayName = 'Bambara';
                      break;
                    default:
                      displayName = value.toUpperCase();
                  }
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(displayName, style: const TextStyle(fontSize: 14)),
                  );
                }).toList(),
              ),
              if (_isLoadingTranslation)
                const Padding(
                  padding: EdgeInsets.only(left: 10.0),
                  child: SizedBox(
                      width: 15, height: 15,
                      child: CircularProgressIndicator(strokeWidth: 2, color: _accentColor)
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPlayButton() {
    IconData icon;
    String label;
    Color color;

    if (_isAudioLoading) {
      icon = Icons.hourglass_empty;
      label = "Chargement...";
      color = Colors.grey;
    } else if (_isPlaying) {
      icon = Icons.pause;
      label = "Pause";
      color = Colors.red.shade700;
    } else {
      icon = Icons.play_arrow;
      label = "Écouter";
      color = _accentColor;
    }

    return ElevatedButton.icon(
      onPressed: (_isAudioLoading || _isLoadingTranslation) ? null : _playTranslatedContent,
      icon: Icon(icon, color: Colors.white),
      label: Text(
        label,
        style: const TextStyle(fontSize: 14, color: Colors.white, fontWeight: FontWeight.bold),
      ),
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        elevation: 3,
      ),
    );
  }

  Widget _buildCustomAppBar(BuildContext context, String title) {
    // L'App Bar est légèrement modifiée pour ne plus afficher le titre car il sera sous le sélecteur.
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.only(top: 10, left: 20, right: 20, bottom: 10),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
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
            const SizedBox(width: 15),
            Expanded(
              child: Text(
                // 💡 Affichage du titre traduit
                title,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.left,
                style: const TextStyle(
                  color: _cardTextColor,
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }


  @override
  Widget build(BuildContext context) {
    final Artisanat1 data = widget.artisanData;

    // 💡 1. GESTION DES VALEURS TRADUITES
    final String titre = _getTitre();
    final String description = _getDescription();

    final String nomAuteurComplet = '${data.prenomAuteur ?? ''} ${data.nomAuteur ?? 'Auteur inconnu'}'.trim();

    final String? videoPath = data.urlVideo;
    final String? emailAuteur = data.emailAuteur;

    final String fullVideoUrl = _getFullImageUrl(videoPath);
    final List<String> allPhotosPaths = data.urlPhotos ?? [];
    final String primaryImagePath = allPhotosPaths.isNotEmpty ? allPhotosPaths.first : '';
    final String fullPrimaryImageUrl = _getFullImageUrl(primaryImagePath);

    const String watchVideoLabel = 'Regarder la vidéo';
    const String supportArtisanLabel = 'Contacter l\'Auteur';

    return Scaffold(
      backgroundColor: _backgroundColor,
      bottomNavigationBar: const BottomNavigationWidget(currentPage: 'artisans'),
      body: Column(
        children: [
          _buildCustomAppBar(context, titre),

          // Sélecteur de langue et bouton de lecture vocale
          _buildLanguageSelector(),

          // Affichage des erreurs de traduction/audio
          if (_translationError != null)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Text(_translationError!, style: const TextStyle(color: Colors.red)),
            ),
          if (_audioError != null)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
              child: Text(_audioError!, style: const TextStyle(color: Colors.red, fontSize: 14)),
            ),

          Expanded(
            child: SingleChildScrollView(
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
                    emailAuteur?.isNotEmpty == true ? Icons.person : Icons.person_off,
                  ),
                  const SizedBox(height: 20),

                  // --- 2. BIO/DESCRIPTION (AFFICHANT LA TRADUCTION) ---
                  Text(
                    description, // 💡 Maintenant le contenu traduit
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: _cardTextColor.withOpacity(0.7),
                      fontSize: 16,
                      height: 1.4,
                    ),
                  ),
                  const SizedBox(height: 30),

                  // --- 3. VIDÉO DE L'ARTISAN ---
                  if (fullVideoUrl.isNotEmpty)
                    _buildVideoSection(fullVideoUrl, watchVideoLabel),
                  if (fullVideoUrl.isNotEmpty) const SizedBox(height: 30),

                  // --- 4. BOUTON DE SOUTIEN ---
                  if (emailAuteur?.isNotEmpty == true)
                    _buildActionButton(supportArtisanLabel, Icons.email, _accentColor, 'mailto:${emailAuteur!}'),

                  const SizedBox(height: 50),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // --- Les widgets de structure (inchangés ou simplifiés) ---

  /// Image Principale de l'Artisanat
  Widget _buildPrimaryImage(String imageUrl) {
    if (imageUrl.isEmpty) {
      return Container(
        height: 200,
        width: double.infinity,
        decoration: BoxDecoration(
          color: Colors.grey[300],
          borderRadius: BorderRadius.circular(15),
        ),
        child: Center(
            child: Icon(Icons.image_not_supported, size: 50, color: _cardTextColor.withOpacity(0.5))),
      );
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
                    // Action de lecture vidéo (à implémenter si nécessaire, ici c'est un Snackbar)
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
        // Action du bouton (par exemple, lancer un mailto ou un navigateur web)
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
}