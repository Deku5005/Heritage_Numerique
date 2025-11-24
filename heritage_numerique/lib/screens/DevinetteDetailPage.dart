// Fichier: lib/screens/DevinetteDetailPage.dart (FINAL avec lecture vocale)

import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:typed_data'; //  NOUVEL IMPORT pour Uint8List
import 'package:audioplayers/audioplayers.dart'; // ⚠️ NOUVEL IMPORT
import '../model/DevinetteModel.dart';
// Import des modèles et services nécessaires
import '../model/TraductionDevinette.dart';
import '../Service/DevinetteApiService.dart';
import '../Service/LectureVocaleService.dart'; //  NOUVEL IMPORT


// --- Constantes de Couleurs ---
const Color _mainAccentColor = Color(0xFFAA7311); // Jaune/Or
const Color _backgroundColor = Colors.white;
const Color _cardTextColor = Color(0xFF2E2E2E);
const Color _serviceErrorColor = Colors.red;
const Color _answerColor = Color(0xFF558B2F); // Vert foncé pour la réponse
const Color _tagColor = Color(0xFF808080); // Gris pour les étiquettes


class DevinetteDetailPage extends StatefulWidget {
  final Devinette devinette;

  const DevinetteDetailPage({super.key, required this.devinette});

  @override
  State<DevinetteDetailPage> createState() => _DevinetteDetailPageState();
}

class _DevinetteDetailPageState extends State<DevinetteDetailPage> {
  // Services et État
  final DevinetteApiService _apiService = DevinetteApiService();
  final LectureVocaleService _lectureVocaleService = LectureVocaleService(); // ⚠️ NOUVEAU SERVICE
  final AudioPlayer _audioPlayer = AudioPlayer(); // ⚠️ NOUVEL AUDIO PLAYER

  String _selectedLanguageCodeUI = 'fr'; // Langue par défaut
  late Future<TraductionDevinette> _traductionFuture;

  // Langues disponibles
  final List<String> _availableLangs = ['fr', 'bm', 'en'];

  // --- États pour la Lecture Vocale ---
  bool _isPlaying = false;
  bool _isAudioLoading = false;
  String? _audioErrorMessage; // Pour débogage ou message d'erreur spécifique

  @override
  void initState() {
    super.initState();
    _traductionFuture = _fetchTranslation(_selectedLanguageCodeUI);

    // Écouteur de statut du lecteur audio pour mettre à jour l'état
    _audioPlayer.onPlayerComplete.listen((event) {
      if(mounted) {
        setState(() {
          _isPlaying = false;
        });
      }
    });
  }

  @override
  void dispose() {
    // ⚠️ IMPORTANT : Fermeture des ressources
    _audioPlayer.dispose();
    _lectureVocaleService.dispose();
    super.dispose();
  }

  // --- LOGIQUE DE TRADUCTION ---

  String _mapUiCodeToApiJsonKey(String uiCode) {
    switch (uiCode) {
      case 'fr': return 'fra_Latn';
      case 'bm': return 'bam_Latn';
      case 'en': return 'eng_Latn';
      default: return uiCode;
    }
  }

  Future<TraductionDevinette> _fetchTranslation(String uiLanguageCode) {
    return _apiService.fetchDevinetteTraduction(
      devinetteId: widget.devinette.id!,
      langueCode: uiLanguageCode,
    );
  }

  void _changeLanguageAndReload(String newLanguageCodeUI) {
    if (newLanguageCodeUI != _selectedLanguageCodeUI) {
      _stopAudio(); // ⚠️ Arrête la lecture si la langue change
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
    if (widget.devinette.id == null) {
      _showErrorSnackBar("Impossible de lire l'audio : ID de contenu manquant.");
      return;
    }

    // 1. Début du chargement
    setState(() {
      _isAudioLoading = true;
      _audioErrorMessage = null;
    });

    try {
      // 2. Téléchargement du fichier audio (Endpoint NON public)
      final List<int> audioBytes = await _lectureVocaleService.telechargerLectureVocale(
        widget.devinette.id!,
        _selectedLanguageCodeUI,
        usePublicApi: false, // <-- Utilise l'endpoint NON public
      );

      // 3. Conversion en Uint8List et lecture
      final Uint8List audioData = Uint8List.fromList(audioBytes);
      await _audioPlayer.play(BytesSource(audioData));

      // 4. Succès de la lecture
      if (mounted) {
        setState(() {
          _isPlaying = true;
          _isAudioLoading = false;
        });
      }

    } catch (e) {
      // 5. Erreur
      print("Erreur Lecture Vocale: $e");
      if (mounted) {
        setState(() {
          _isPlaying = false;
          _isAudioLoading = false;
        });
        // Afficher un message plus convivial pour l'utilisateur
        _showErrorSnackBar('Erreur: Échec de la lecture vocale. Le fichier audio n\'est peut-être pas disponible pour cette langue.');
      }
    }
  }

  Future<void> _stopAudio() async {
    await _audioPlayer.stop();
    if (mounted) {
      setState(() {
        _isPlaying = false;
      });
    }
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message, style: const TextStyle(color: Colors.white)),
        backgroundColor: _serviceErrorColor,
        duration: const Duration(seconds: 4),
      ),
    );
  }

  // --- WIDGETS D'INTERFACE ---

  Widget _buildAudioButton() {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
      decoration: BoxDecoration(
        color: _isAudioLoading ? Colors.grey.withOpacity(0.5) : _mainAccentColor,
        borderRadius: BorderRadius.circular(8),
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
          size: 24,
        ),
        onPressed: _isAudioLoading ? null : _toggleAudioPlayback,
      ),
    );
  }

  Widget _buildLanguageDropdown() {
    return DropdownButtonHideUnderline(
      child: DropdownButton<String>(
        value: _selectedLanguageCodeUI,

        // Style du fond et des options (fond sombre, texte blanc)
        dropdownColor: _cardTextColor,

        style: const TextStyle(color: _backgroundColor, fontSize: 14),
        icon: const Icon(Icons.keyboard_arrow_down, color: _backgroundColor),

        items: _availableLangs
            .map<DropdownMenuItem<String>>((String value) {
          final String displayName = _mapLanguageCodeToName(value);

          return DropdownMenuItem<String>(
            value: value,
            child: Text(
                displayName,
                // Texte en blanc pour être lisible sur le fond sombre du menu
                style: const TextStyle(color: _backgroundColor, fontSize: 14)
            ),
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

  Widget _buildRiddleContent({
    required String question,
    required String answer,
    required String languageName
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 1. Langue Affichée
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
          decoration: BoxDecoration(
            color: _mainAccentColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            'Langue : $languageName',
            style: TextStyle(color: _mainAccentColor, fontWeight: FontWeight.bold),
          ),
        ),
        const SizedBox(height: 20),

        // 2. Question de la Devinette
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Icon(Icons.help_outline, color: _mainAccentColor, size: 24),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                question,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: _cardTextColor,
                  height: 1.5,
                ),
              ),
            ),
          ],
        ),

        // 3. Ligne de séparation
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 30.0),
          child: Divider(color: Colors.grey.shade300, thickness: 1),
        ),

        // 4. Réponse
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: _answerColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: _answerColor, width: 1.5),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Icon(Icons.lightbulb_sharp, color: _answerColor, size: 24),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Réponse :',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: _answerColor,
                      ),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      answer,
                      style: const TextStyle(
                        fontSize: 18,
                        color: _cardTextColor,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // Widget utilitaire pour afficher une ligne d'information
  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: _tagColor, size: 18),
          const SizedBox(width: 10),
          Text(
            '$label: ',
            style: const TextStyle(fontWeight: FontWeight.w600, color: _cardTextColor),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(color: _cardTextColor),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _backgroundColor,
      appBar: AppBar(
        title: Text(
          // Utilisation de ?? 'Détail Devinette' pour garantir une String non nulle
          widget.devinette.titre?.isNotEmpty == true ? widget.devinette.titre! : 'Détail Devinette',
          style: const TextStyle(color: _cardTextColor, fontWeight: FontWeight.bold, fontSize: 18),
        ),
        backgroundColor: _backgroundColor,
        iconTheme: const IconThemeData(color: _cardTextColor),
        elevation: 1,
        actions: [
          // ⚠️ Bouton de lecture vocale
          _buildAudioButton(),

          // Sélecteur de langue dans l'AppBar
          Padding(
            padding: const EdgeInsets.only(right: 15.0),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10),
              decoration: BoxDecoration(
                color: _cardTextColor,
                borderRadius: BorderRadius.circular(8),
              ),
              child: _buildLanguageDropdown(),
            ),
          ),
        ],
      ),
      body: FutureBuilder<TraductionDevinette>(
        future: _traductionFuture,
        builder: (context, snapshot) {

          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator(color: _mainAccentColor));
          }

          if (snapshot.hasError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Text(
                  'Erreur de chargement de la traduction: ${snapshot.error}',
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: _serviceErrorColor, fontSize: 16),
                ),
              ),
            );
          }

          if (!snapshot.hasData) {
            return const Center(child: Text('Aucune donnée de traduction disponible.'));
          }

          // --- Affichage des données réelles ---
          final TraductionDevinette data = snapshot.data!;
          final String jsonKey = _mapUiCodeToApiJsonKey(_selectedLanguageCodeUI);

          // Récupération avec fallback sécurisé
          final String questionText = data.traductionsContenu[jsonKey] ?? widget.devinette.devinette;
          final String reponseText = data.traductionsDescription[jsonKey] ?? widget.devinette.reponse;
          final String languageName = _mapLanguageCodeToName(_selectedLanguageCodeUI);

          // Récupération des infos supplémentaires
          final String lieuText = data.traductionsLieu[jsonKey] ?? widget.devinette.lieu ?? '';
          final String regionText = data.traductionsRegion[jsonKey] ?? widget.devinette.region ?? '';


          return SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[

                // 1. Contenu principal (Question et Réponse)
                _buildRiddleContent(
                  question: questionText,
                  answer: reponseText,
                  languageName: languageName,
                ),

                const SizedBox(height: 30),

                // 2. Informations supplémentaires (Lieu, Région)
                if (lieuText.isNotEmpty || regionText.isNotEmpty)
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Informations Contextuelles',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: _cardTextColor,
                        ),
                      ),
                      const SizedBox(height: 10),
                      if (lieuText.isNotEmpty)
                        _buildInfoRow(Icons.location_on_outlined, 'Lieu', lieuText),
                      if (regionText.isNotEmpty)
                        _buildInfoRow(Icons.map_outlined, 'Région', regionText),
                    ],
                  ),

                const SizedBox(height: 20),
              ],
            ),
          );
        },
      ),
    );
  }
}