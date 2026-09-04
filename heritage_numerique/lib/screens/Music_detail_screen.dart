import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';
import '../service/LectureVocaleService.dart';
import '../service/DevinetteService1.dart';
import '../model/DevinetteTrductionModel.dart';
import '../widgets/cultural_theme.dart';
import 'dart:typed_data';

class MusicDetailScreen extends StatefulWidget {
  final String titre;
  final String devinette;
  final String reponse;
  final String conteur;
  final String imageUrl;
  final Map<String, dynamic> details;

  const MusicDetailScreen({
    super.key,
    required this.titre,
    required this.devinette,
    required this.reponse,
    required this.conteur,
    required this.imageUrl,
    required this.details,
  });

  @override
  State<MusicDetailScreen> createState() => _MusicDetailScreenState();
}

class _MusicDetailScreenState extends State<MusicDetailScreen> {
  final DevinetteService1 _devinetteService = DevinetteService1();
  DevinetteTraduction? _currentTranslation;
  String _selectedLanguageCode = 'fr';
  bool _isLoadingTranslation = false;
  String? _translationError;

  List<String> _availableLanguages = ['fr', 'bm', 'en'];

  bool _isRevealed = false;

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

  void _toggleReveal() {
    setState(() {
      _isRevealed = !_isRevealed;
    });
  }

  Future<void> _playTranslatedContent() async {
    if (_isPlaying) {
      await _audioPlayer.pause();
      return;
    }

    if (_isAudioLoading) return;

    final int? devinetteId = widget.details['idDevinette'] as int?;
    if (devinetteId == null || devinetteId <= 0) {
      setState(() => _audioError = "ID de devinette invalide pour la lecture.");
      return;
    }

    setState(() {
      _isAudioLoading = true;
      _audioError = null;
    });

    try {
      final Uint8List audioData = await _lectureVocaleService.telechargerLectureVocale(
        devinetteId,
        _selectedLanguageCode,
        usePublicApi: true,
      );

      await _audioPlayer.play(BytesSource(audioData));

      if (mounted) {
        setState(() {
          _isAudioLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isAudioLoading = false;
          _audioError = 'Échec de la lecture vocale : $e';
        });
      }
    }
  }

  Future<void> _fetchAvailableLanguages() async {
    final dynamic idValue = widget.details['idDevinette'];
    final int? devinetteId = idValue is int ? idValue : null;

    if (devinetteId == null || devinetteId <= 0) return;

    try {
      final translation = await _devinetteService.fetchDevinetteTranslationPublic(
        devinetteId: devinetteId,
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
    } catch (_) {}
  }

  Future<void> _fetchTranslation(String langCode) async {
    if (_isLoadingTranslation || langCode == _selectedLanguageCode) return;

    if (langCode == 'fr') {
      setState(() {
        _currentTranslation = _createSourceTranslation();
        _selectedLanguageCode = 'fr';
        _translationError = null;
        _audioPlayer.stop();
      });
      return;
    }

    setState(() {
      _isLoadingTranslation = true;
      _translationError = null;
      _selectedLanguageCode = langCode;
      _audioPlayer.stop();
    });

    final int? devinetteId = widget.details['idDevinette'] as int?;
    if (devinetteId == null || devinetteId <= 0) {
      setState(() {
        _isLoadingTranslation = false;
        _translationError = "ID de devinette manquant pour la traduction.";
      });
      return;
    }

    try {
      final translation = await _devinetteService.fetchDevinetteTranslationPublic(
        devinetteId: devinetteId,
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
          _translationError = "Erreur de traduction : $e";
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

  DevinetteTraduction _createSourceTranslation() {
    return DevinetteTraduction(
      idContenu: widget.details['idDevinette'] is int ? widget.details['idDevinette'] : 0,
      titreOriginal: widget.titre,
      descriptionOriginale: widget.devinette,
      lieuOriginal: widget.details['lieu']?.toString(),
      regionOriginale: widget.details['region']?.toString(),
      traductionsTitre: {'fr': widget.titre},
      traductionsContenu: {'fr': widget.devinette},
      traductionsDescription: {'fr': widget.devinette},
      traductionsLieu: widget.details['lieu'] != null ? {'fr': widget.details['lieu'].toString()} : {},
      traductionsRegion: widget.details['region'] != null ? {'fr': widget.details['region'].toString()} : {},
      traductionsCompletes: {'fr': widget.devinette},
      languesDisponibles: const [],
      langueSource: 'fra_Latn',
      statutTraduction: 'SOURCE',
    );
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
      widget.titre,
      _currentTranslation?.traductionsTitre ?? {},
      _selectedLanguageCode,
    );
  }

  String _getDevinette() {
    return _getTranslatedText(
      widget.devinette,
      _currentTranslation?.traductionsDescription ?? {},
      _selectedLanguageCode,
    );
  }

  String _getReponse() {
    return widget.reponse;
  }

  String _getLieu() {
    return _getTranslatedText(
      widget.details['lieu']?.toString(),
      _currentTranslation?.traductionsLieu ?? {},
      _selectedLanguageCode,
    );
  }

  String _mapLanguageCodeToName(String code) {
    switch (code) {
      case 'fr': return 'Français';
      case 'bm': return 'Bambara';
      case 'en': return 'Anglais';
      default: return code.toUpperCase();
    }
  }

  @override
  Widget build(BuildContext context) {
    final String titreAffiche = _getTitre();
    final String devinetteAffichee = _getDevinette();
    final String reponseAffichee = _getReponse();
    final String lieuAffiche = _getLieu();

    return Scaffold(
      backgroundColor: CulturalTheme.backgroundLight,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: CulturalTheme.textDark),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          titreAffiche,
          style: const TextStyle(
            color: CulturalTheme.textDark,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.share, color: CulturalTheme.textDark),
            onPressed: () {},
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Sélecteur de langue en pilules
            Row(
              children: [
                const Text(
                  'Traduction :',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    color: CulturalTheme.textDark,
                  ),
                ),
                const SizedBox(width: 10),
                ..._availableLanguages.map((lang) {
                  final isSelected = lang == _selectedLanguageCode;
                  return Padding(
                    padding: const EdgeInsets.only(right: 8.0),
                    child: InkWell(
                      onTap: () => _fetchTranslation(lang),
                      borderRadius: BorderRadius.circular(16),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                        decoration: BoxDecoration(
                          color: isSelected ? CulturalTheme.primaryBrown : Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: isSelected ? CulturalTheme.primaryBrown : const Color(0xFFD6C7B2),
                          ),
                        ),
                        child: Text(
                          _mapLanguageCodeToName(lang),
                          style: TextStyle(
                            color: isSelected ? Colors.white : CulturalTheme.textDark,
                            fontSize: 12,
                            fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                          ),
                        ),
                      ),
                    ),
                  );
                }),
              ],
            ),
            const SizedBox(height: 20),

            if (_translationError != null)
              Padding(
                padding: const EdgeInsets.only(bottom: 12.0),
                child: Text(_translationError!, style: const TextStyle(color: Colors.red, fontSize: 13)),
              ),

            if (_audioError != null)
              Padding(
                padding: const EdgeInsets.only(bottom: 12.0),
                child: Text(_audioError!, style: const TextStyle(color: Colors.red, fontSize: 13)),
              ),

            // Carte énigme stylisée
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFFC89A3B), Color(0xFFAA7311)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(24),
                boxShadow: CulturalTheme.softShadow,
              ),
              child: Column(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.lightbulb, color: Colors.white, size: 36),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'DEVINETTE ANCESTRALE',
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.2,
                    ),
                  ),
                  const SizedBox(height: 14),
                  if (_isLoadingTranslation)
                    const Padding(
                      padding: EdgeInsets.all(20.0),
                      child: CircularProgressIndicator(color: Colors.white),
                    )
                  else
                    Text(
                      '« $devinetteAffichee »',
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        fontStyle: FontStyle.italic,
                        height: 1.4,
                      ),
                    ),
                  const SizedBox(height: 20),
                  ElevatedButton.icon(
                    onPressed: _playTranslatedContent,
                    icon: _isAudioLoading
                        ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(color: CulturalTheme.primaryDarkOcre, strokeWidth: 2),
                          )
                        : Icon(_isPlaying ? Icons.pause : Icons.volume_up, color: CulturalTheme.primaryDarkOcre, size: 20),
                    label: Text(
                      _isPlaying ? 'Pause' : 'Écouter la devinette',
                      style: const TextStyle(
                        color: CulturalTheme.primaryDarkOcre,
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                      elevation: 2,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 25),

            // Bouton de révélation interactive de la solution
            InkWell(
              onTap: _toggleReveal,
              borderRadius: BorderRadius.circular(18),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 16),
                decoration: BoxDecoration(
                  color: _isRevealed ? const Color(0xFFE8F5E9) : Colors.white,
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(
                    color: _isRevealed ? const Color(0xFF81C784) : CulturalTheme.primaryOcre,
                    width: 1.5,
                  ),
                  boxShadow: CulturalTheme.softShadow,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      _isRevealed ? Icons.visibility_off : Icons.visibility,
                      color: _isRevealed ? Colors.green.shade700 : CulturalTheme.primaryDarkOcre,
                    ),
                    const SizedBox(width: 10),
                    Text(
                      _isRevealed ? 'Masquer la réponse' : 'Découvrir la solution',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: _isRevealed ? Colors.green.shade700 : CulturalTheme.primaryDarkOcre,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Solution révélée
            AnimatedCrossFade(
              firstChild: const SizedBox.shrink(),
              secondChild: Padding(
                padding: const EdgeInsets.only(top: 20.0),
                child: Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(color: const Color(0xFF81C784), width: 1.5),
                    boxShadow: CulturalTheme.softShadow,
                  ),
                  child: Column(
                    children: [
                      const Text(
                        '💡 RÉPONSE :',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: Colors.green,
                          letterSpacing: 1.0,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        reponseAffichee,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: CulturalTheme.textDark,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              crossFadeState: _isRevealed ? CrossFadeState.showSecond : CrossFadeState.showFirst,
              duration: const Duration(milliseconds: 300),
            ),
            const SizedBox(height: 30),

            // Détails du conteur & Contexte
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFFEDE4D5)),
              ),
              child: Column(
                children: [
                  Row(
                    children: [
                      const Icon(Icons.person_pin, color: CulturalTheme.primaryDarkOcre, size: 26),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('Transmis par :', style: TextStyle(fontSize: 11, color: CulturalTheme.textMuted)),
                            Text(
                              widget.conteur.isNotEmpty ? widget.conteur : 'Tradition orale malienne',
                              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: CulturalTheme.textDark),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  if (lieuAffiche.isNotEmpty && lieuAffiche != 'Traduction non disponible.') ...[
                    const Divider(height: 18),
                    Row(
                      children: [
                        const Icon(Icons.location_on_outlined, color: CulturalTheme.primaryDarkOcre, size: 26),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('Lieu d\'origine :', style: TextStyle(fontSize: 11, color: CulturalTheme.textMuted)),
                              Text(
                                lieuAffiche,
                                style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: CulturalTheme.textDark),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}