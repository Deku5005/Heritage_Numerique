import 'package:flutter/material.dart';
// Import pour la lecture audio
import 'package:audioplayers/audioplayers.dart';
// Import pour le service vocal
import '../service/LectureVocaleService.dart';
import '../service/DevinetteService1.dart';
import '../model/DevinetteTrductionModel.dart';
import 'dart:typed_data'; // Pour Uint8List

// Constantes de Couleurs
const Color _accentColor = Color(0xFFD69301); // Ocre Vif
const Color _cardTextColor = Color(0xFF2E2E2E); // Gris foncé
const Color _backgroundColor = Colors.white;
const Color _revealColor = Color(0xFF4CAF50); // Vert pour révéler

/// Écran de Détail pour les Devinettes.
class MusicDetailScreen extends StatefulWidget {
  // Propriétés adaptées au contexte des Devinettes
  final String titre;
  final String devinette;
  final String reponse;
  final String conteur;
  final String imageUrl;
  final Map<String, dynamic> details; // Doit contenir 'idDevinette' et 'lieu'

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
  // --- Propriétés de la Traduction ---
  final DevinetteService1 _devinetteService = DevinetteService1();
  DevinetteTraduction? _currentTranslation;
  String _selectedLanguageCode = 'fr';
  bool _isLoadingTranslation = false;
  String? _translationError;

  List<String> _availableLanguages = ['fr', 'bm', 'en'];

  bool _isRevealed = false;

  // --- Propriétés de la Lecture Vocale ---
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

    // Écouter les changements d'état du lecteur audio
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

  // -------------------------------------------------------------------
  // --- LOGIQUE DE LECTURE VOCALE ---
  // -------------------------------------------------------------------

  Future<void> _playTranslatedContent() async {
    // Si l'audio est déjà en lecture, mettez-le en pause
    if (_isPlaying) {
      await _audioPlayer.pause();
      return;
    }

    // Si le chargement est déjà en cours, ne faites rien
    if (_isAudioLoading) return;

    final int? devinetteId = widget.details['idDevinette'] as int?;
    if (devinetteId == null || devinetteId <= 0) {
      setState(() => _audioError = "ID de devinette invalide pour la lecture.");
      return;
    }

    // Réinitialisation de l'état
    setState(() {
      _isAudioLoading = true;
      _audioError = null;
    });

    try {
      // 💡 Appel du service pour télécharger l'audio
      final Uint8List audioData = await _lectureVocaleService.telechargerLectureVocale(
          devinetteId,
          _selectedLanguageCode,
          usePublicApi: true // Utilisation de l'API publique
      );

      // 💡 Jouer l'audio à partir des données binaires
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
  // --- LOGIQUE DE TRADUCTION (Ajustements mineurs pour la robustesse) ---
  // -------------------------------------------------------------------

  Future<void> _fetchAvailableLanguages() async {
    final dynamic idValue = widget.details['idDevinette'];
    final int? devinetteId = idValue is int ? idValue : null;

    if (devinetteId == null || devinetteId <= 0) {
      print("Erreur: idDevinette est manquant, null ou n'est pas valide.");
      return;
    }

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
    } catch (e) {
      print("Erreur lors de la récupération initiale des langues: $e");
    }
  }

  Future<void> _fetchTranslation(String langCode) async {
    if (_isLoadingTranslation || langCode == _selectedLanguageCode) return;

    if (langCode == 'fr') {
      setState(() {
        _currentTranslation = _createSourceTranslation();
        _selectedLanguageCode = 'fr';
        _translationError = null;
        _audioPlayer.stop(); // Arrêter l'audio si on change de langue
      });
      return;
    }

    setState(() {
      _isLoadingTranslation = true;
      _translationError = null;
      _selectedLanguageCode = langCode;
      _audioPlayer.stop(); // Arrêter l'audio si on change de langue
    });

    final int? devinetteId = widget.details['idDevinette'] as int?;

    if (devinetteId == null || devinetteId <= 0) {
      // ... (Gestion d'erreur inchangée)
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
      // ... (Gestion d'erreur inchangée)
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
      idContenu: widget.details['idDevinette'] ?? 0,
      titreOriginal: widget.titre,
      descriptionOriginale: widget.devinette,
      lieuOriginal: widget.details['lieu'],
      regionOriginale: widget.details['region'],
      traductionsTitre: {'fr': widget.titre},
      traductionsContenu: {'fr': widget.devinette},
      traductionsDescription: {'fr': widget.devinette},
      traductionsLieu: widget.details['lieu'] != null ? {'fr': widget.details['lieu']!} : {},
      traductionsRegion: widget.details['region'] != null ? {'fr': widget.details['region']!} : {},
      traductionsCompletes: {'fr': widget.devinette},
      languesDisponibles: const [],
      langueSource: 'fra_Latn',
      statutTraduction: 'SOURCE',
    );
  }

  // --- Fonctions d'accès au contenu traduit (inchangées) ---

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
        _selectedLanguageCode
    );
  }

  String _getDevinette() {
    return _getTranslatedText(
        widget.devinette,
        _currentTranslation?.traductionsDescription ?? {},
        _selectedLanguageCode
    );
  }

  String _getReponse() {
    return widget.reponse;
  }

  String _getLieu() {
    return _getTranslatedText(
        widget.details['lieu'],
        _currentTranslation?.traductionsLieu ?? {},
        _selectedLanguageCode
    );
  }


  // -------------------------------------------------------------------
  // --- WIDGETS DE CONSTRUCTION ---
  // -------------------------------------------------------------------

  Widget _buildLanguageSelector() {
    // ... (widget inchangé)
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 5.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // 💡 NOUVEAU : Bouton de Lecture Vocale
          _buildPlayButton(),

          Row( // Conteneur pour le sélecteur de langue et l'indicateur de chargement
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


  @override
  Widget build(BuildContext context) {
    // Récupérer le contenu traduit
    final String titreAffiche = _getTitre();
    final String devinetteAffichee = _getDevinette();
    final String reponseAffichee = _getReponse();
    final String lieuAffiche = _getLieu();

    return Scaffold(
      backgroundColor: _backgroundColor,
      appBar: AppBar(
        title: Text(titreAffiche, style: const TextStyle(color: _cardTextColor)),
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: _accentColor),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Column(
        children: [
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
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _buildRiddleBlock(titreAffiche, devinetteAffichee),
                  const SizedBox(height: 30),

                  _buildRevealButton(),
                  const SizedBox(height: 30),

                  if (_isRevealed) _buildAnswerBlock(reponseAffichee),

                  const SizedBox(height: 30),

                  _buildInformationCard(widget.conteur, lieuAffiche),

                  const SizedBox(height: 50),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ... (Le reste des widgets _buildRiddleBlock, _buildRevealButton, etc. est inchangé)

  Widget _buildRiddleBlock(String titre, String devinette) {
    return Container(
      padding: const EdgeInsets.all(20.0),
      decoration: BoxDecoration(
        color: const Color(0xFFF0EAE0),
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.quiz_outlined, color: _accentColor, size: 24),
              const SizedBox(width: 8),
              Text(
                'Énigme: $titre',
                style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: _accentColor
                ),
              ),
            ],
          ),
          const Divider(color: Colors.grey, height: 20),
          Text(
            devinette,
            style: const TextStyle(
              fontSize: 16,
              height: 1.5,
              color: _cardTextColor,
              fontStyle: FontStyle.italic,
            ),
            textAlign: TextAlign.justify,
          ),
        ],
      ),
    );
  }

  Widget _buildRevealButton() {
    return ElevatedButton.icon(
      onPressed: _toggleReveal,
      icon: Icon(_isRevealed ? Icons.visibility_off : Icons.visibility, color: Colors.white),
      label: Text(
        _isRevealed ? 'Cacher la Réponse' : 'Révéler la Réponse',
        style: const TextStyle(fontSize: 18, color: Colors.white, fontWeight: FontWeight.bold),
      ),
      style: ElevatedButton.styleFrom(
        backgroundColor: _isRevealed ? Colors.red.shade700 : _revealColor,
        padding: const EdgeInsets.symmetric(vertical: 15),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        elevation: 5,
      ),
    );
  }

  Widget _buildAnswerBlock(String reponse) {
    return Container(
      padding: const EdgeInsets.all(20.0),
      decoration: BoxDecoration(
        color: _revealColor.withOpacity(0.1),
        border: Border.all(color: _revealColor, width: 2),
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(
            color: _revealColor.withOpacity(0.2),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'La Réponse est:',
            style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: _revealColor
            ),
          ),
          const Divider(color: _revealColor, height: 20),
          Center(
            child: Text(
              reponse,
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w900,
                color: _cardTextColor,
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInformationCard(String conteur, String lieu) {
    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.grey.shade300),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Contexte Culturel',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: _cardTextColor),
          ),
          const Divider(color: Colors.grey, height: 20),

          _buildDetailRow(Icons.person, 'Conteur', conteur),
          _buildDetailRow(Icons.location_on, 'Lieu d\'Origine', lieu),
        ],
      ),
    );
  }

  Widget _buildDetailRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        children: [
          Icon(icon, size: 20, color: _accentColor),
          const SizedBox(width: 8),
          Text(
            '$label:',
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: _cardTextColor),
          ),
          const Spacer(),
          Expanded(
            child: Text(
              value,
              textAlign: TextAlign.right,
              style: TextStyle(fontSize: 16, color: _cardTextColor.withOpacity(0.7)),
            ),
          ),
        ],
      ),
    );
  }
}