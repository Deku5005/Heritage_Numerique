// Fichier: lib/screens/ProverbeDetailPage.dart (FINAL avec lecture vocale)

import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:typed_data'; // Nécessaire pour Uint8List
import 'package:audioplayers/audioplayers.dart'; // ⚠️ NOUVEL IMPORT
import '../model/PrvebeModel.dart';
import '../model/TraductionProverbe.dart';
import '../service/ProverbeService.dart';
import '../service/LectureVocaleService.dart'; // ⚠️ NOUVEL IMPORT

// --- Constantes de Couleurs ---
const Color _mainAccentColor = Color(0xFFAA7311);
const Color _serviceErrorColor = Colors.red;
const String _defaultPlaceholder = 'assets/images/Djata.jpg';
const String _imageHostUrl = "http://192.168.43.22:8080";

class ProverbeDetailPage extends StatefulWidget {
  final Proverbe proverbe;

  const ProverbeDetailPage({super.key, required this.proverbe});

  @override
  State<ProverbeDetailPage> createState() => _ProverbeDetailPageState();
}

class _ProverbeDetailPageState extends State<ProverbeDetailPage> {
  // Services et État
  final ProverbeService _proverbeService = ProverbeService();
  final LectureVocaleService _lectureVocaleService = LectureVocaleService(); // ⚠️ NOUVEAU SERVICE
  final AudioPlayer _audioPlayer = AudioPlayer(); // ⚠️ NOUVEL AUDIO PLAYER

  String _selectedLanguageCodeUI = 'fr';
  late Future<TraductionProverbe> _traductionFuture;

  final List<String> _availableLangs = ['fr', 'bm', 'en'];

  bool _isPlaying = false;
  bool _isAudioLoading = false;
  String? _audioErrorMessage;

  @override
  void initState() {
    super.initState();
    _traductionFuture = _fetchTranslation(_selectedLanguageCodeUI);

    // Écouteur de statut du lecteur audio pour mettre à jour le bouton
    _audioPlayer.onPlayerComplete.listen((event) {
      setState(() {
        _isPlaying = false;
      });
    });
  }

  @override
  void dispose() {
    _audioPlayer.dispose();
    _lectureVocaleService.dispose();
    super.dispose();
  }

  // --- LOGIQUE DE TRADUCTION (Inchangée) ---

  String _mapUiCodeToApiJsonKey(String uiCode) {
    switch (uiCode) {
      case 'fr': return 'fra_Latn';
      case 'bm': return 'bam_Latn';
      case 'en': return 'eng_Latn';
      default: return uiCode;
    }
  }

  Future<TraductionProverbe> _fetchTranslation(String uiLanguageCode) {
    return _proverbeService.fetchProverbeTraduction(
      proverbeId: widget.proverbe.id!,
      langueCode: uiLanguageCode,
    );
  }

  void _changeLanguageAndReload(String newLanguageCodeUI) {
    if (newLanguageCodeUI != _selectedLanguageCodeUI) {
      // Arrête la lecture si la langue change
      _stopAudio();
      setState(() {
        _selectedLanguageCodeUI = newLanguageCodeUI;
        _traductionFuture = _fetchTranslation(newLanguageCodeUI);
      });
    }
  }

  String _mapLanguageCodeToName(String code) {
    switch(code) {
      case 'fr': return 'Français';
      case 'bm': return 'Bambara';
      case 'en': return 'Anglais';
      default: return code;
    }
  }

  // --- LOGIQUE DE LECTURE VOCALE ---

  Future<void> _toggleAudioPlayback() async {
    if (_isPlaying) {
      await _stopAudio();
    } else {
      await _playAudio();
    }
  }

  Future<void> _playAudio() async {
    // 1. Début du chargement
    setState(() {
      _isAudioLoading = true;
      _audioErrorMessage = null;
    });

    try {
      // 2. Téléchargement du fichier audio (Endpoint NON public)
      final List<int> audioBytes = await _lectureVocaleService.telechargerLectureVocale(
        widget.proverbe.id!,
        _selectedLanguageCodeUI,
        usePublicApi: false, // <-- Utilise l'endpoint NON public
      );

      // 3. Conversion en Uint8List et lecture
      final Uint8List audioData = Uint8List.fromList(audioBytes);
      await _audioPlayer.play(BytesSource(audioData));

      // 4. Succès de la lecture
      setState(() {
        _isPlaying = true;
        _isAudioLoading = false;
      });

    } catch (e) {
      // 5. Erreur
      print("Erreur Lecture Vocale: $e");
      setState(() {
        _isPlaying = false;
        _isAudioLoading = false;
        _audioErrorMessage = 'Erreur: Échec de la lecture vocale. ($e)';
        // Afficher un SnackBar pour l'erreur
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(_audioErrorMessage!, style: const TextStyle(color: Colors.white)),
            backgroundColor: _serviceErrorColor,
            duration: const Duration(seconds: 4),
          ),
        );
      });
    }
  }

  Future<void> _stopAudio() async {
    await _audioPlayer.stop();
    setState(() {
      _isPlaying = false;
    });
  }

  // --- LOGIQUE DE L'IMAGE (Inchangée) ---

  bool get _isNetworkImage => widget.proverbe.urlPhoto != null && widget.proverbe.urlPhoto!.startsWith('http');
  String get _imageUrl {
    String? path = widget.proverbe.urlPhoto;
    if (path == null || path.isEmpty) {
      return _defaultPlaceholder;
    }
    if (!path.startsWith('http') && !path.startsWith('assets')) {
      return Uri.parse(_imageHostUrl).resolve(path).toString();
    }
    return path;
  }

  Widget _buildImageWidget({required double width, required double height, BoxFit fit = BoxFit.cover}) {
    if (_isNetworkImage && !widget.proverbe.urlPhoto!.startsWith('assets')) {
      return Image.network(
        _imageUrl,
        fit: fit,
        errorBuilder: (context, error, stackTrace) {
          print("ERREUR DÉTAIL PROVERBE (URL: $_imageUrl): $error");
          return Image.asset(_defaultPlaceholder, width: width, height: height, fit: fit);
        },
        loadingBuilder: (context, child, loadingProgress) {
          if (loadingProgress == null) return child;
          return Container(
            width: width, height: height,
            color: Colors.black12,
            child: const Center(child: CircularProgressIndicator(color: _mainAccentColor, strokeWidth: 2)),
          );
        },
      );
    } else {
      return Image.asset(
        _imageUrl,
        fit: fit,
        errorBuilder: (context, error, stackTrace) => Image.asset(
          _defaultPlaceholder,
          width: width,
          height: height,
          fit: fit,
        ),
      );
    }
  }

  // --- WIDGETS D'AFFICHAGE ---

  Widget _buildLanguageDropdown() {
    return DropdownButtonHideUnderline(
      child: DropdownButton<String>(
        value: _selectedLanguageCodeUI,

        // Options pour un fond sombre (Option 2 du précédent échange)
        dropdownColor: Colors.black,

        // Texte sélectionné (le bouton) est en BLANC
        style: const TextStyle(color: Colors.white, fontSize: 14),
        icon: const Icon(Icons.keyboard_arrow_down, color: Colors.white),

        items: _availableLangs
            .map<DropdownMenuItem<String>>((String value) {
          final String displayName = _mapLanguageCodeToName(value);

          // Texte des options : BLANC pour être lisible sur le fond noir du menu
          return DropdownMenuItem<String>(
            value: value,
            child: Text(displayName, style: const TextStyle(color: Colors.white, fontSize: 14)),
          );
        }).toList(),
        onChanged: (String? newValue) {
          if (newValue != null) {
            _changeLanguageAndReload(newValue);
          }
        },
      ),
    );
  }

  // Widget du bouton Play/Stop
  Widget _buildAudioButton() {
    return Container(
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: _mainAccentColor.withOpacity(0.8),
      ),
      child: IconButton(
        icon: _isAudioLoading
            ? const SizedBox(
          width: 20,
          height: 20,
          child: CircularProgressIndicator(
            strokeWidth: 2.5,
            color: Colors.white,
          ),
        )
            : Icon(
          _isPlaying ? Icons.pause : Icons.volume_up,
          color: Colors.white,
          size: 28,
        ),
        onPressed: _isAudioLoading ? null : _toggleAudioPlayback, // Désactiver pendant le chargement
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final double screenWidth = MediaQuery.of(context).size.width;
    final double screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      body: FutureBuilder<TraductionProverbe>(
        future: _traductionFuture,
        builder: (context, snapshot) {

          if (snapshot.connectionState == ConnectionState.waiting) {
            return Stack(
              children: [
                Positioned.fill(child: _buildImageWidget(width: screenWidth, height: screenHeight, fit: BoxFit.cover)),
                Positioned.fill(child: Container(color: Colors.black.withOpacity(0.55))),
                const Center(child: CircularProgressIndicator(color: _mainAccentColor)),
                _buildCloseButton(context),
              ],
            );
          }

          if (snapshot.hasError) {
            return _buildErrorScreen(context, snapshot.error.toString());
          }

          if (!snapshot.hasData) {
            return _buildErrorScreen(context, 'Aucun contenu de proverbe traduit disponible.');
          }

          // --- Affichage des données réelles (SNAPSHOT.HASDATA) ---
          final TraductionProverbe data = snapshot.data!;
          final String jsonKey = _mapUiCodeToApiJsonKey(_selectedLanguageCodeUI);

          // Déterminer le contenu traduit ou utiliser le Fallback
          final String proverbeText = data.traductionsContenu[jsonKey] ?? widget.proverbe.proverbe;
          final String origineText = data.traductionsDescription[jsonKey] ?? widget.proverbe.origine;
          final String significationText = data.traductionsDescription[jsonKey] ?? widget.proverbe.signification;
          final String lieuText = data.traductionsLieu[jsonKey] ?? widget.proverbe.lieu ?? '';
          final String regionText = data.traductionsRegion[jsonKey] ?? widget.proverbe.region ?? '';

          final String authorInfo = (widget.proverbe.prenomAuteur != null || widget.proverbe.nomAuteur != null)
              ? 'Posté par: ${widget.proverbe.prenomAuteur ?? ''} ${widget.proverbe.nomAuteur ?? ''}'
              : '';

          final String locationInfo = (lieuText.isNotEmpty) ? 'Lieu: $lieuText' : '';
          final String regionInfo = (regionText.isNotEmpty) ? 'Région: $regionText' : '';
          final String fullInfo = [authorInfo, locationInfo, regionInfo].where((s) => s.isNotEmpty).join(' | ');


          return Stack(
            children: <Widget>[
              // 1. Image de fond
              Positioned.fill(
                child: _buildImageWidget(width: screenWidth, height: screenHeight, fit: BoxFit.cover),
              ),

              // 2. Dégradé sombre
              Positioned.fill(
                child: Container(
                  color: Colors.black.withOpacity(0.55),
                ),
              ),

              // 3. Contenu principal (scrollable)
              SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 80),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: <Widget>[
                    SizedBox(height: MediaQuery.of(context).padding.top),

                    // --- Conteneur Noir Semi-Transparent pour le Texte du Proverbe ---
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.4),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          // Titre / Proverbe
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Expanded(
                                child: Text(
                                  '«$proverbeText»',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 22,
                                    fontStyle: FontStyle.italic,
                                    fontWeight: FontWeight.bold,
                                    height: 1.4,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ),
                              const SizedBox(width: 10),
                              // ⚠️ Bouton de lecture à côté du proverbe
                              _buildAudioButton(),
                            ],
                          ),

                          const SizedBox(height: 15),

                          // Sous-titre (Origine)
                          Text(
                            origineText,
                            style: TextStyle(
                              color: _mainAccentColor,
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 15),

                          // Ligne jaune de séparation
                          Divider(color: _mainAccentColor, thickness: 1),
                          const SizedBox(height: 20),

                          // Signification (Titre en Jaune)
                          Text(
                            "Signification",
                            style: TextStyle(
                              color: _mainAccentColor,
                              fontSize: 20,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                          const SizedBox(height: 10),

                          // Description / Signification
                          Text(
                            significationText,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              height: 1.5,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 30),

                    // Informations supplémentaires (Auteur, Lieu, etc.)
                    if (fullInfo.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.only(top: 10.0),
                        child: Text(
                          fullInfo,
                          style: const TextStyle(color: Colors.white70, fontSize: 12),
                          textAlign: TextAlign.center,
                        ),
                      ),

                    const SizedBox(height: 200),
                  ],
                ),
              ),

              // 4. Bouton de Fermeture (X) et Menu Langue
              _buildCloseButton(context),
              _buildLanguageMenu(context),
            ],
          );
        },
      ),
    );
  }

  // Widget pour le bouton Fermer (inchangé)
  Widget _buildCloseButton(BuildContext context) {
    return Positioned(
      top: MediaQuery.of(context).padding.top + 10,
      right: 10,
      child: IconButton(
        icon: const Icon(Icons.close, color: Colors.white, size: 30),
        onPressed: () => Navigator.of(context).pop(),
      ),
    );
  }

  // Widget pour le menu de langue (Transparent)
  Widget _buildLanguageMenu(BuildContext context) {
    return Positioned(
      top: MediaQuery.of(context).padding.top + 15,
      right: 60,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        decoration: BoxDecoration(
            color: Colors.transparent,
            borderRadius: BorderRadius.circular(8)
        ),
        child: _buildLanguageDropdown(),
      ),
    );
  }

  // Widget pour l'écran d'erreur (inchangé)
  Widget _buildErrorScreen(BuildContext context, String error) {
    return Stack(
      children: [
        Positioned.fill(child: Container(color: Colors.black)),
        Center(
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Text(
              'Erreur de chargement du proverbe : $error',
              textAlign: TextAlign.center,
              style: const TextStyle(color: _serviceErrorColor, fontSize: 16),
            ),
          ),
        ),
        _buildCloseButton(context),
      ],
    );
  }
}