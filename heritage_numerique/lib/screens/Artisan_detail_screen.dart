import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';
import 'dart:typed_data';
import 'package:url_launcher/url_launcher.dart';

import '../Service/Artisanatservice1.dart';
import '../service/LectureVocaleService.dart';
import '../model/ArtisanatTraduction.dart';
import '../model/Artisanat1.dart';
import '../widgets/VideoPlayerWidget.dart';
import '../widgets/cultural_theme.dart';

const Color _backgroundColor = Color(0xFFFAF7F2);
const String _apiBaseUrlForImages = 'http://10.0.2.2:8080';

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
  final ArtisanatService1 _artisanatService = ArtisanatService1();
  ArtisanatTraduction? _currentTranslation;
  String _selectedLanguageCode = 'fr';
  bool _isLoadingTranslation = false;
  String? _translationError;
  List<String> _availableLanguages = ['fr', 'bm', 'en'];

  final LectureVocaleService _lectureVocaleService = LectureVocaleService();
  final AudioPlayer _audioPlayer = AudioPlayer();
  bool _isAudioLoading = false;
  bool _isPlaying = false;
  String? _audioError;
  bool _isBookmarked = false;

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

  // --- LOGIQUE DE TRADUCTION & LECTURE VOCALE ---

  ArtisanatTraduction _createSourceTranslation() {
    final Artisanat1 data = widget.artisanData;

    return ArtisanatTraduction(
      idContenu: data.id,
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
    final int artisanatId = widget.artisanData.id;
    if (artisanatId <= 0) return;

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
      debugPrint("Erreur lors de la récupération initiale des langues: $e");
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

    final int artisanatId = widget.artisanData.id;
    if (artisanatId <= 0) {
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
          _isLoadingTranslation = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoadingTranslation = false;
          _translationError = "La traduction n'a pas pu être récupérée : ${e.toString().split(':').last.trim()}";
        });
      }
    }
  }

  String _getTranslatedText(Map<String, String> map, String defaultVal) {
    if (map.containsKey(_selectedLanguageCode)) {
      return map[_selectedLanguageCode]!;
    }
    const Map<String, String> codeMap = {
      'bm': 'bam_Latn',
      'en': 'eng_Latn',
      'fr': 'fra_Latn',
    };
    final String? longCode = codeMap[_selectedLanguageCode];
    if (longCode != null && map.containsKey(longCode)) {
      return map[longCode]!;
    }
    return map['fr'] ?? defaultVal;
  }

  String _getTitre() {
    if (_currentTranslation == null) return widget.artisanData.titre ?? 'Sans titre';
    return _getTranslatedText(_currentTranslation!.traductionsTitre, widget.artisanData.titre ?? 'Sans titre');
  }

  String _getDescription() {
    if (_currentTranslation == null) return widget.artisanData.description ?? 'Aucune description disponible.';
    return _getTranslatedText(_currentTranslation!.traductionsDescription, widget.artisanData.description ?? 'Aucune description disponible.');
  }

  String _mapLanguageCodeToName(String code) {
    switch (code) {
      case 'fr': return 'Français';
      case 'bm': return 'Bamanankan';
      case 'en': return 'English';
      default: return code.toUpperCase();
    }
  }

  Future<void> _playTranslatedContent() async {
    if (_isPlaying) {
      await _audioPlayer.pause();
      return;
    }

    if (_isAudioLoading) return;

    final int artisanatId = widget.artisanData.id;
    if (artisanatId <= 0) {
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
        usePublicApi: true,
      );

      await _audioPlayer.play(BytesSource(audioData));

      setState(() {
        _isAudioLoading = false;
      });
    } catch (e) {
      debugPrint("Erreur de lecture vocale: $e");
      if (mounted) {
        setState(() {
          _isAudioLoading = false;
          _audioError = 'Lecture vocale indisponible pour cette œuvre.';
        });
      }
    }
  }

  Widget _buildImageWidget(String path) {
    if (path.isEmpty) {
      return Image.asset('assets/images/artisanat.jpg', fit: BoxFit.cover);
    }
    if (path.startsWith('assets/')) {
      return Image.asset(path, fit: BoxFit.cover, errorBuilder: (_, __, ___) => Image.asset('assets/images/artisanat.jpg', fit: BoxFit.cover));
    }
    String url = path;
    if (!path.startsWith('http')) {
      final sanitized = path.startsWith('/') ? path.substring(1) : path;
      url = '$_apiBaseUrlForImages/$sanitized';
    }
    return Image.network(
      url,
      fit: BoxFit.cover,
      errorBuilder: (_, __, ___) => Image.asset('assets/images/artisanat.jpg', fit: BoxFit.cover),
    );
  }

  @override
  Widget build(BuildContext context) {
    final Artisanat1 data = widget.artisanData;
    final String titre = _getTitre();
    final String description = _getDescription();
    final String nomAuteurComplet = '${data.prenomAuteur ?? ''} ${data.nomAuteur ?? 'Artisan Malien'}'.trim();
    final String? videoPath = data.urlVideo;
    final String? emailAuteur = data.emailAuteur;

    final List<String> allPhotos = data.urlPhotos ?? [];
    final String primaryImg = allPhotos.isNotEmpty ? allPhotos.first : '';

    return Scaffold(
      backgroundColor: _backgroundColor,
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          _buildSliverHeader(titre, primaryImg),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 60),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Sélecteur de langue moderne
                  _buildLanguageSelector(),
                  const SizedBox(height: 18),

                  if (_translationError != null)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 12.0),
                      child: Text(_translationError!, style: const TextStyle(color: Colors.red, fontSize: 12)),
                    ),

                  // Capsule Audio / Récit de l'artisan
                  _buildAudioPlayerCard(),
                  const SizedBox(height: 24),

                  // Profil du maître artisan
                  _buildArtisanMasterCard(nomAuteurComplet, emailAuteur),
                  const SizedBox(height: 24),

                  // Toile descriptive & Savoir-faire ancestral
                  _buildCraftDescriptionCard(description),
                  const SizedBox(height: 24),

                  // Vidéo de démonstration intégrée
                  if (videoPath != null && videoPath.isNotEmpty)
                    _buildVideoMasterclassCard(videoPath),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // --- 1. Header Sliver immersif ---
  Widget _buildSliverHeader(String titre, String imagePath) {
    final String regionLabel = widget.artisanData.region ?? 'Mali';
    final String lieuLabel = widget.artisanData.lieu ?? 'Traditionnel';

    return SliverAppBar(
      expandedHeight: 320,
      pinned: true,
      backgroundColor: CulturalTheme.primaryDarkOcre,
      elevation: 0,
      leading: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.black.withValues(alpha: 0.35),
            shape: BoxShape.circle,
            border: Border.all(color: Colors.white.withValues(alpha: 0.3), width: 1),
          ),
          child: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white, size: 20),
            onPressed: () => Navigator.of(context).pop(),
          ),
        ),
      ),
      actions: [
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Container(
            decoration: BoxDecoration(
              color: Colors.black.withValues(alpha: 0.35),
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white.withValues(alpha: 0.3), width: 1),
            ),
            child: IconButton(
              icon: Icon(
                _isBookmarked ? Icons.favorite : Icons.favorite_border,
                color: _isBookmarked ? Colors.redAccent : Colors.white,
                size: 20,
              ),
              onPressed: () {
                setState(() => _isBookmarked = !_isBookmarked);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(_isBookmarked ? 'Ajouté à vos créations préférées' : 'Retiré de vos favoris'),
                    duration: const Duration(seconds: 1),
                    behavior: SnackBarBehavior.floating,
                  ),
                );
              },
            ),
          ),
        ),
      ],
      flexibleSpace: FlexibleSpaceBar(
        background: Stack(
          fit: StackFit.expand,
          children: [
            _buildImageWidget(imagePath),
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Colors.black.withValues(alpha: 0.45),
                    Colors.transparent,
                    Colors.black.withValues(alpha: 0.85),
                  ],
                  stops: const [0.0, 0.45, 1.0],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
              ),
            ),
            Positioned(
              left: 20,
              right: 20,
              bottom: 20,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                    decoration: BoxDecoration(
                      color: CulturalTheme.primaryOcre,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.3),
                          blurRadius: 6,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.place, color: Colors.white, size: 12),
                        const SizedBox(width: 4),
                        Text(
                          '$lieuLabel • $regionLabel',
                          style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold, letterSpacing: 0.5),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    titre,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w900,
                      fontSize: 22,
                      letterSpacing: 0.2,
                      shadows: [
                        Shadow(color: Colors.black87, blurRadius: 8, offset: Offset(0, 2)),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // --- 2. Sélecteur de langue horizontal (Pill tabs) ---
  Widget _buildLanguageSelector() {
    return Container(
      padding: const EdgeInsets.all(6),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(30),
        border: Border.all(color: const Color(0xFFE8E0D4)),
        boxShadow: CulturalTheme.softShadow,
      ),
      child: Row(
        children: _availableLanguages.map((lang) {
          final isSelected = lang == _selectedLanguageCode;
          return Expanded(
            child: GestureDetector(
              onTap: () => _fetchTranslation(lang),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 250),
                padding: const EdgeInsets.symmetric(vertical: 10),
                decoration: BoxDecoration(
                  color: isSelected ? CulturalTheme.primaryDarkOcre : Colors.transparent,
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: isSelected
                      ? [
                          BoxShadow(
                            color: CulturalTheme.primaryDarkOcre.withValues(alpha: 0.3),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ]
                      : [],
                ),
                child: Center(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      if (isSelected) ...[
                        const Icon(Icons.translate, color: Colors.white, size: 13),
                        const SizedBox(width: 6),
                      ],
                      Text(
                        _mapLanguageCodeToName(lang),
                        style: TextStyle(
                          color: isSelected ? Colors.white : CulturalTheme.textDark,
                          fontSize: 12,
                          fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  // --- 3. Carte Narration Vocale Haute Fidélité ---
  Widget _buildAudioPlayerCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF261D16), Color(0xFF1B140F)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.2),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          GestureDetector(
            onTap: _playTranslatedContent,
            child: Container(
              width: 50,
              height: 50,
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0xFFE5A638), Color(0xFFAA7311)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                shape: BoxShape.circle,
              ),
              child: _isAudioLoading
                  ? const Padding(
                      padding: EdgeInsets.all(12.0),
                      child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2.5),
                    )
                  : Icon(
                      _isPlaying ? Icons.pause : Icons.play_arrow,
                      color: Colors.white,
                      size: 28,
                    ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Récit de l\'Artisan',
                  style: TextStyle(color: CulturalTheme.secondaryGold, fontSize: 11, fontWeight: FontWeight.bold, letterSpacing: 0.8),
                ),
                const SizedBox(height: 2),
                Text(
                  _isPlaying ? 'Lecture en cours...' : 'Écouter l\'histoire de cette pièce',
                  style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 2),
                Text(
                  'En ${_mapLanguageCodeToName(_selectedLanguageCode)}',
                  style: const TextStyle(color: Colors.white60, fontSize: 11),
                ),
              ],
            ),
          ),
          if (_audioError != null)
            const Icon(Icons.info_outline, color: Colors.orangeAccent, size: 20),
        ],
      ),
    );
  }

  // --- 4. Profil Maître Artisan ---
  Widget _buildArtisanMasterCard(String name, String? email) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: const Color(0xFFEBE3D5)),
        boxShadow: CulturalTheme.softShadow,
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: const LinearGradient(
                    colors: [Color(0xFFDECDB9), Color(0xFFC7B198)],
                  ),
                  border: Border.all(color: CulturalTheme.primaryOcre, width: 2),
                ),
                child: const Icon(Icons.palette_outlined, size: 30, color: CulturalTheme.primaryDarkOcre),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: CulturalTheme.primaryOcre.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: const Text(
                        'Maître Artisan',
                        style: TextStyle(fontSize: 10, color: CulturalTheme.primaryDarkOcre, fontWeight: FontWeight.bold),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      name,
                      style: const TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.bold,
                        color: CulturalTheme.textDark,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '${widget.artisanData.roleAuteur ?? "Créateur d'art"} • ${widget.artisanData.region ?? "Mali"}',
                      style: const TextStyle(fontSize: 12, color: CulturalTheme.textMuted),
                    ),
                  ],
                ),
              ),
            ],
          ),
          if (email != null && email.isNotEmpty) ...[
            const Divider(height: 24, color: Color(0xFFF0EBE0)),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () async {
                  final Uri emailUri = Uri(
                    scheme: 'mailto',
                    path: email,
                    query: 'subject=Demande d\'information sur ${widget.artisanData.titre ?? "votre œuvre"}',
                  );
                  if (await canLaunchUrl(emailUri)) {
                    await launchUrl(emailUri);
                  }
                },
                icon: const Icon(Icons.mail_outline, size: 18),
                label: const Text('Contacter le créateur', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: CulturalTheme.primaryDarkOcre,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  elevation: 0,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  // --- 5. Descriptif du Savoir-Faire ---
  Widget _buildCraftDescriptionCard(String description) {
    final String firstLetter = description.isNotEmpty ? description.trim().substring(0, 1) : "L";
    final String remainingText = description.isNotEmpty ? description.trim().substring(1) : "";

    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: const Color(0xFFFFFDF9),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: const Color(0xFFE8DFD0), width: 1.2),
        boxShadow: CulturalTheme.softShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 4,
                height: 22,
                decoration: BoxDecoration(
                  color: CulturalTheme.primaryOcre,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(width: 10),
              const Text(
                'SAVOIR-FAIRE ANCESTRAL',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 1.2,
                  color: CulturalTheme.primaryDarkOcre,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          RichText(
            textAlign: TextAlign.justify,
            text: TextSpan(
              children: [
                TextSpan(
                  text: firstLetter,
                  style: const TextStyle(
                    fontSize: 38,
                    height: 0.9,
                    fontWeight: FontWeight.w900,
                    color: CulturalTheme.primaryDarkOcre,
                    fontFamily: 'serif',
                  ),
                ),
                TextSpan(
                  text: remainingText,
                  style: const TextStyle(
                    fontSize: 15,
                    height: 1.7,
                    color: Color(0xFF332B25),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // --- 6. Vidéo Masterclass Intégrée ---
  Widget _buildVideoMasterclassCard(String videoUrl) {
    String fullUrl = videoUrl;
    if (!videoUrl.startsWith('http')) {
      final sanitized = videoUrl.startsWith('/') ? videoUrl.substring(1) : videoUrl;
      fullUrl = '$_apiBaseUrlForImages/$sanitized';
    }

    return Container(
      decoration: BoxDecoration(
        color: Colors.black,
        borderRadius: BorderRadius.circular(22),
        boxShadow: CulturalTheme.softShadow,
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            color: const Color(0xFF1F1813),
            child: Row(
              children: const [
                Icon(Icons.videocam_outlined, color: CulturalTheme.accentGold, size: 20),
                SizedBox(width: 8),
                Text(
                  'Démonstration en Atelier',
                  style: TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),
          VideoPlayerWidget(videoUrl: fullUrl),
        ],
      ),
    );
  }
}