import 'package:flutter/material.dart';
// --- Imports pour la Traduction et l'Audio ---
import 'package:audioplayers/audioplayers.dart';
import 'dart:typed_data';
// 💡 CONSERVATION pour 'mailto:' (email)
import 'package:url_launcher/url_launcher.dart';

import '../Service/Artisanatservice1.dart';
import '../service/LectureVocaleService.dart';
import '../model/ArtisanatTraduction.dart';

import '../widgets/bottom_navigation_widget.dart';
import '../model/artisanat1.dart';
// ✅ NOUVEAU : Import pour le widget de lecture vidéo
import '../widgets/VideoPlayerWidget.dart';

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
  static const String _apiBaseUrlForImages = 'http://192.168.43.22:8080';

  // --- PROPRIÉTÉS DE TRADUCTION ---
  final ArtisanatService1 _artisanatService = ArtisanatService1();
  ArtisanatTraduction? _currentTranslation;
  String _selectedLanguageCode = 'fr';
  bool _isLoadingTranslation = false;
  String? _translationError;
  List<String> _availableLanguages = ['fr', 'bm', 'en'];

  // --- PROPRIÉTÉS DE LECTURE VOCALE ---
  final LectureVocaleService _lectureVocaleService = LectureVocaleService();
  final AudioPlayer _audioPlayer = AudioPlayer();
  bool _isAudioLoading = false;
  bool _isPlaying = false;
  String? _audioError;


  @override
  void initState() {
    super.initState();
    _currentTranslation = _createSourceTranslation();
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

  // --- LOGIQUE POUR COMPLÉTER LES URLS RELATIVES ---
  String _getFullImageUrl(String? relativePath) {
    if (relativePath == null || relativePath.isEmpty) return '';
    if (relativePath.toLowerCase().startsWith('http')) return relativePath;

    final String sanitizedPath = relativePath.startsWith('/') ? relativePath.substring(1) : relativePath;
    return '$_apiBaseUrlForImages/$sanitizedPath';
  }

  // --- LOGIQUE D'ACTION (Contacter l'Auteur) ---
  Future<void> _launchUrl(String urlString) async {
    final Uri url = Uri.parse(urlString);

    try {
      if (await launchUrl(url)) {
        // Succès
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Impossible d\'ouvrir : $urlString'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erreur lors du lancement de l\'URL: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  // --- LOGIQUE DE TRADUCTION / LECTURE VOCALE (inchangée) ---

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

    if (artisanatId == null || artisanatId <= 0) return;

    try {
      final translation = await _artisanatService.fetchArtisanatTranslationPublic(
        artisanatId: artisanatId,
        targetLanguageCode: 'bm',
      );

      if (mounted) {
        final List<String> apiLangs = translation.languesDisponibles
            .map((code) => code == 'bam_Latn' ? 'bm' : code == 'eng_Latn' ? 'en' : code)
            .toList();

        setState(() {
          _availableLanguages = {'fr', 'bm', 'en', ...apiLangs}.toSet().toList();
        });
      }
    } catch (e) {
      print("Erreur lors de la récupération initiale des langues: $e");
    }
  }

  Future<void> _fetchTranslation(String langCode) async {
    if (_isLoadingTranslation || langCode == _selectedLanguageCode) return;

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

  String _getTranslatedText(String? originalText, Map<String, String> translationsMap, String langCode) {
    if (langCode == 'fr') return originalText ?? '';

    String? translated = translationsMap[langCode];
    if (translated != null && translated.isNotEmpty) return translated;

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

  Widget _buildLanguageSelector() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 5.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _buildPlayButton(),

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

  /// 3. VIDÉO DE L'ARTISAN
  Widget _buildVideoSection(String url, String buttonLabel) {
    return Column(
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(15),
          child: Container(
            color: Colors.black,
            // ✅ Utilisation du widget de lecteur vidéo
            child: VideoPlayerWidget(videoUrl: url),
          ),
        ),
        const SizedBox(height: 10),
        // Le bouton d'action est conservé pour l'esthétique et gère maintenant
        // un message d'information pour la vidéo intégrée.
        _buildActionButton(buttonLabel, Icons.play_arrow, _actionColor, url),
      ],
    );
  }

  /// BOUTON D'ACTION
  Widget _buildActionButton(String text, IconData icon, Color color, String url) {
    final bool isEmailAction = url.startsWith('mailto:');

    return GestureDetector(
      onTap: isEmailAction ? () => _launchUrl(url) : () {
        if (!isEmailAction) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('La lecture vidéo est intégrée au-dessus.'),
              backgroundColor: _actionColor,
            ),
          );
        }
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

  @override
  Widget build(BuildContext context) {
    final Artisanat1 data = widget.artisanData;

    final String titre = _getTitre();
    final String description = _getDescription();

    final String nomAuteurComplet = '${data.prenomAuteur ?? ''} ${data.nomAuteur ?? 'Auteur inconnu'}'.trim();

    final String? videoPath = data.urlVideo;
    final String? emailAuteur = data.emailAuteur;

    final String fullVideoUrl = _getFullImageUrl(videoPath);
    final List<String> allPhotosPaths = data.urlPhotos ?? [];
    final String primaryImagePath = allPhotosPaths.isNotEmpty ? allPhotosPaths.first : '';
    final String fullPrimaryImageUrl = _getFullImageUrl(primaryImagePath);

    const String watchVideoLabel = 'Regarder la vidéo (intégrée)';
    const String supportArtisanLabel = 'Contacter l\'Auteur (Email)';

    return Scaffold(
      backgroundColor: _backgroundColor,
      bottomNavigationBar: const BottomNavigationWidget(currentPage: 'artisans'),
      body: Column(
        children: [
          _buildCustomAppBar(context, titre),
          _buildLanguageSelector(),

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
                  _buildPrimaryImage(fullPrimaryImageUrl),
                  const SizedBox(height: 30),
                  _buildArtisanProfile(
                    nomAuteurComplet,
                    emailAuteur?.isNotEmpty == true ? Icons.person : Icons.person_off,
                  ),
                  const SizedBox(height: 20),
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

                  // --- 3. VIDÉO DE L'ARTISAN (Widget intégré) ---
                  if (fullVideoUrl.isNotEmpty)
                    _buildVideoSection(fullVideoUrl, watchVideoLabel),
                  if (fullVideoUrl.isNotEmpty) const SizedBox(height: 30),

                  // --- 4. BOUTON DE SOUTIEN (Email) ---
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
}