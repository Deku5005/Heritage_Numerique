import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';
import 'dart:typed_data';

// --- Imports des Services et Modèles API ---
import '../Service/proverbeservice1.dart'; // Vérifier le chemin (Service vs services)
import '../service/LectureVocaleService.dart';
import '../model/ProverbeTraduction.dart';

// Constantes de Couleurs
const Color _accentColor = Color(0xFFD69301); // Ocre Vif
const Color _cardTextColor = Color(0xFF2E2E2E); // Gris foncé
const Color _backgroundColor = Colors.white;

class ProverbDetailScreen extends StatefulWidget {
  // Les données source sont cruciales

  // CORRECTION CLÉ : Le champ est bien nommé 'proverbeId' (avec 'e')
  final int proverbeId;
  final String proverbText;
  final String source;
  final String conteur;
  final String langue; // Langue source (ex: Français)

  const ProverbDetailScreen({
    super.key,
    // CORRECTION CLÉ : Le paramètre du constructeur est bien 'proverbeId' (avec 'e')
    required this.proverbeId,
    required this.proverbText,
    required this.source,
    required this.conteur,
    required this.langue,
  });

  @override
  State<ProverbDetailScreen> createState() => _ProverbDetailScreenState();
}

class _ProverbDetailScreenState extends State<ProverbDetailScreen> {
  // --- Propriétés de la Traduction ---
  final ProverbeService1 _proverbeService = ProverbeService1();
  ProverbeTraduction? _currentTranslation;

  // Codes de langue : 'fr', 'en', 'bm'
  String _selectedLanguageCode = 'fr';
  List<String> _availableLanguages = ['fr', 'bm', 'en']; // Langues par défaut

  bool _isLoadingTranslation = false;
  String? _translationError;

  // --- Propriétés de la Lecture Vocale ---
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
    // S'assurer que les services sont correctement disposés
    _lectureVocaleService.dispose();
    _audioPlayer.dispose();
    super.dispose();
  }

  // -------------------------------------------------------------------
  // --- LOGIQUE DE TRADUCTION ---
  // -------------------------------------------------------------------

  // Crée l'objet de traduction pour le contenu source (Français)
  ProverbeTraduction _createSourceTranslation() {
    return ProverbeTraduction(
      idContenu: widget.proverbeId,
      titreOriginal: widget.proverbText,
      descriptionOriginale: widget.proverbText,
      lieuOriginal: widget.source,
      regionOriginale: widget.source,
      traductionsTitre: {'fr': widget.proverbText},
      traductionsContenu: {'fr': widget.proverbText},
      traductionsDescription: {'fr': widget.proverbText},
      traductionsLieu: {'fr': widget.source},
      traductionsRegion: {'fr': widget.source},
      traductionsCompletes: {'fr': widget.proverbText},
      languesDisponibles: const [],
      langueSource: 'fra_Latn',
      statutTraduction: 'SOURCE',
    );
  }

  Future<void> _fetchAvailableLanguages() async {
    if (widget.proverbeId <= 0) return;

    try {
      // Appel à 'bm' pour potentiellement récupérer la liste complète des langues
      final translation = await _proverbeService.fetchProverbeTranslationPublic(
        proverbeId: widget.proverbeId,
        targetLanguageCode: 'bm',
      );

      if (mounted) {
        // Convertir les codes longs de l'API (bam_Latn, eng_Latn) en codes courts (bm, en)
        final List<String> apiLangs = translation.languesDisponibles
            .map((code) => code == 'bam_Latn' ? 'bm' : code == 'eng_Latn' ? 'en' : code)
            .toList();

        setState(() {
          // Maintien des langues connues + ajout des langues de l'API
          _availableLanguages = {'fr', 'bm', 'en', ...apiLangs}.toSet().toList();
        });
      }
    } catch (e) {
      debugPrint("Erreur lors de la récupération initiale des langues: $e");
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

    if (widget.proverbeId <= 0) {
      if (mounted) {
        setState(() {
          _translationError = "Impossible de traduire : ID de proverbe invalide.";
          _isLoadingTranslation = false;
        });
      }
      return;
    }

    try {
      final translation = await _proverbeService.fetchProverbeTranslationPublic(
        proverbeId: widget.proverbeId,
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
          // Simplifier le message d'erreur pour l'utilisateur
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

    // Vérification des codes longs d'API (fallback)
    if (langCode == 'bm') {
      translated = translationsMap['bam_Latn'];
      if (translated != null && translated.isNotEmpty) return translated;
    }
    if (langCode == 'en') {
      translated = translationsMap['eng_Latn'];
      if (translated != null && translated.isNotEmpty) return translated;
    }

    // Retourne le texte original si la traduction est introuvable
    return originalText ?? 'Traduction non disponible.';
  }

  String _getProverbText() {
    // On utilise `traductionsDescription` car c'est généralement là que le texte principal se trouve
    return _getTranslatedText(
        widget.proverbText,
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

    if (widget.proverbeId <= 0) {
      setState(() => _audioError = "ID proverbe invalide pour la lecture.");
      return;
    }

    setState(() {
      _isAudioLoading = true;
      _audioError = null;
    });

    try {
      final Uint8List audioData = await _lectureVocaleService.telechargerLectureVocale(
          widget.proverbeId,
          _selectedLanguageCode,
          usePublicApi: true
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
          _audioError = 'Échec de la lecture vocale. (Veuillez vérifier la connexion ou l\'existence du fichier)';
        });
      }
    }
  }

  // -------------------------------------------------------------------
  // --- WIDGETS DE CONSTRUCTION ---
  // -------------------------------------------------------------------

  // Retourne le nom de la langue à partir du code
  String _getLanguageDisplayName(String code) {
    switch (code) {
      case 'fr': return 'Français';
      case 'en': return 'Anglais';
      case 'bm': return 'Bambara';
      default: return code.toUpperCase();
    }
  }

  // Retourne l'icône ou le drapeau (simplifié)
  Widget _getIconForLanguage(String code) {
    String icon;
    if (code == 'en') {
      icon = '🇬🇧';
    } else if (code == 'bm') {
      icon = '🇲🇱';
    } else {
      icon = '🇫🇷';
    }
    return Text(icon, style: const TextStyle(fontSize: 20));
  }

  /// Construit l'en-tête (AppBar transparente, titre et sélecteur de langue).
  Widget _buildHeader(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(top: MediaQuery.of(context).padding.top, bottom: 20),
      color: _backgroundColor,
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Flèche de retour à gauche
                IconButton(
                  icon: const Icon(Icons.arrow_back, color: _accentColor),
                  onPressed: () => Navigator.pop(context),
                ),

                // Titre "Proverbe"
                const Text(
                  'Proverbe',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),

                // Espacement pour alignement
                const SizedBox(width: 48),
              ],
            ),
          ),
          const SizedBox(height: 10),

          // 💡 Sélecteur de langue et Bouton de Lecture
          _buildLanguageAndPlayBar(),
        ],
      ),
    );
  }

  Widget _buildLanguageAndPlayBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _buildPlayButton(),

          Row(
            children: [
              if (_isLoadingTranslation)
                const Padding(
                  padding: EdgeInsets.only(right: 10.0),
                  child: SizedBox(
                      width: 15, height: 15,
                      child: CircularProgressIndicator(strokeWidth: 2, color: _accentColor)
                  ),
                ),
              // Sélecteur de langue
              _buildLanguageDropdown(),
            ],
          ),
        ],
      ),
    );
  }

  /// Construit le menu déroulant de sélection de la langue.
  Widget _buildLanguageDropdown() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 0),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(5),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: _selectedLanguageCode,
          icon: const Icon(Icons.keyboard_arrow_down, color: _accentColor),
          style: const TextStyle(fontSize: 14, color: _cardTextColor),
          onChanged: (String? newCode) {
            if (newCode != null) {
              _fetchTranslation(newCode);
            }
          },
          items: _availableLanguages.map<DropdownMenuItem<String>>((String code) {
            return DropdownMenuItem<String>(
              value: code,
              child: Row(
                children: [
                  _getIconForLanguage(code),
                  const SizedBox(width: 8),
                  Text(_getLanguageDisplayName(code)),
                ],
              ),
            );
          }).toList(),
        ),
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
    // 💡 Récupération du proverbe traduit
    final currentProverbText = _getProverbText();
    final currentLanguageDisplay = _getLanguageDisplayName(_selectedLanguageCode);

    return Scaffold(
      backgroundColor: _backgroundColor,
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // --- 1. EN-TÊTE et Titre (Inclut le sélecteur de langue) ---
            _buildHeader(context),

            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // --- Affichage des erreurs ---
                  if (_translationError != null)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 8.0),
                      child: Text(_translationError!, style: const TextStyle(color: Colors.red)),
                    ),
                  if (_audioError != null)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 8.0),
                      child: Text(_audioError!, style: const TextStyle(color: Colors.red, fontSize: 14)),
                    ),

                  // --- 2. Bloc du Proverbe ---
                  _buildProverbBlock(currentProverbText),
                  const SizedBox(height: 30),

                  // --- 3. Bloc d'Informations ---
                  _buildInformationCard(widget.conteur, currentLanguageDisplay),

                  const SizedBox(height: 100),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Construit le bloc contenant le texte du proverbe.
  Widget _buildProverbBlock(String text) {
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
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 16,
          height: 1.5,
          color: _cardTextColor,
        ),
        textAlign: TextAlign.justify,
      ),
    );
  }

  /// Construit la carte des informations (Conteur et Langue).
  Widget _buildInformationCard(String conteur, String langue) {
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
            'Informations',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: _cardTextColor),
          ),
          const Divider(color: Colors.grey, height: 20),

          _buildDetailRow('Conteur', conteur),
          _buildDetailRow('Langue Actuelle', langue), // Étiquette mise à jour
        ],
      ),
    );
  }

  /// Ligne pour afficher une information (clé/valeur).
  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            '$label :',
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: _accentColor),
          ),
          Text(
            value,
            style: TextStyle(fontSize: 16, color: _cardTextColor.withOpacity(0.7)),
          ),
        ],
      ),
    );
  }
}