import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import '../config/api_config.dart';

// ⚠️ VÉRIFIEZ ET AJUSTEZ CES CHEMINS SI NÉCESSAIRE
import 'package:heritage_numerique/model/Recits_model.dart';
import 'package:heritage_numerique/model/Traduction-conte-model.dart';
import 'package:heritage_numerique/service/RecitService.dart';
import 'package:heritage_numerique/service/LectureVocaleService.dart';

// --- Constantes de Couleurs Globales ---
const Color _mainAccentColor = Color(0xFFAA7311);
const Color _backgroundColor = Colors.white;
const Color _cardTextColor = Color(0xFF2E2E2E);
const Color _serviceErrorColor = Colors.red;

// ✅ BASE URL UTILISÉE POUR CONSTRUIRE L'URL DE L'IMAGE (centralisée via ApiConfig)
String get _imageHostUrl => ApiConfig.baseUrl;

class RecitDetailScreen extends StatefulWidget {
  final Recit recit;

  const RecitDetailScreen({super.key, required this.recit});

  @override
  State<RecitDetailScreen> createState() => _RecitDetailScreenState();
}

class _RecitDetailScreenState extends State<RecitDetailScreen> {
  // Liste des codes courts utilisés dans l'UI (fr, bm, en)
  final List<String> _availableLangs = ['fr', 'bm', 'en'];

  // Langue par défaut pour le premier appel : le code court 'fr'
  String _selectedLanguageCodeUI = 'fr';
  late Future<TraductionConte> _traductionFuture;
  final RecitService _recitService = RecitService();

  // 🎙️ SERVICES ET VARIABLES D'ÉTAT POUR L'AUDIO
  final LectureVocaleService _lectureVocaleService = LectureVocaleService(); // <-- NOUVEAU SERVICE
  late AudioPlayer _audioPlayer; // <-- NOUVEAU LECTEUR
  bool _isPlaying = false;
  bool _isLoadingAudio = false;

  @override
  void initState() {
    super.initState();
    // 1. Initialise le chargement avec le code UI par défaut ('fr')
    _traductionFuture = _fetchTranslation(_selectedLanguageCodeUI);

    // 2. Initialise le lecteur audio
    _audioPlayer = AudioPlayer();
    _audioPlayer.playerStateStream.listen((state) {
      if (state.playing != _isPlaying) {
        setState(() {
          _isPlaying = state.playing;
        });
      }
      // Réinitialiser l'état de chargement lorsque la lecture est terminée
      if (state.processingState == ProcessingState.completed) {
        setState(() {
          _isLoadingAudio = false;
        });
      }
    });
  }

  // 🗑️ DISPOSE : FERMER LES RESSOURCES
  @override
  void dispose() {
    _audioPlayer.stop();
    _audioPlayer.dispose();
    _lectureVocaleService.dispose();
    super.dispose();
  }

  /// 🎯 Mappe le code court de l'interface utilisateur (UI) vers le code long
  String _mapUiCodeToApiJsonKey(String uiCode) {
    switch (uiCode) {
      case 'fr': return 'fra_Latn';
      case 'bm': return 'bam_Latn';
      case 'en': return 'eng_Latn';
      default: return uiCode;
    }
  }

  // Méthode pour appeler le service avec une langue donnée
  Future<TraductionConte> _fetchTranslation(String uiLanguageCode) {
    return _recitService.fetchConteTraduction(
      conteId: widget.recit.id,
      langueCode: uiLanguageCode,
    );
  }

  // Méthode pour changer de langue et recharger le contenu
  void _changeLanguageAndReload(String newLanguageCodeUI) {
    if (newLanguageCodeUI != _selectedLanguageCodeUI) {
      // ⚠️ Arrête la lecture audio si la langue change
      _audioPlayer.stop();
      setState(() {
        _selectedLanguageCodeUI = newLanguageCodeUI;
        _traductionFuture = _fetchTranslation(newLanguageCodeUI);
      });
    }
  }

  // 🎙️ NOUVELLE LOGIQUE : GÉRER LA LECTURE AUDIO
  Future<void> _toggleAudioPlayback() async {
    if (_isPlaying) {
      await _audioPlayer.pause();
      return;
    }

    // Si la lecture est déjà chargée et n'est pas en cours (mise en pause), la reprendre
    if (_audioPlayer.processingState != ProcessingState.idle) {
      await _audioPlayer.play();
      return;
    }

    // 1. Démarrer l'état de chargement
    setState(() {
      _isLoadingAudio = true;
    });

    try {
      // 2. Télécharger les octets audio pour la langue actuellement sélectionnée
      final List<int> audioBytes = await _lectureVocaleService.telechargerLectureVocale(
        widget.recit.id,
        _selectedLanguageCodeUI, // Utilise le code court UI (fr, bm, en) pour l'URL
      );

      // 3. Charger les octets dans le lecteur Just Audio
      final audioSource = AudioSource.uri(
        Uri.dataFromBytes(
          audioBytes,
          mimeType: 'audio/mpeg', // Assurez-vous que le mimeType correspond au format de votre serveur
        ),
      );

      await _audioPlayer.setAudioSource(audioSource);

      // 4. Lancer la lecture
      await _audioPlayer.play();

    } catch (e) {
      print('Erreur lecture vocale: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Échec du chargement de l'audio: ${e.toString()}"),
          backgroundColor: _serviceErrorColor,
        ),
      );
    } finally {
      // 5. Arrêter l'état de chargement
      setState(() {
        _isLoadingAudio = false;
      });
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _backgroundColor,
      appBar: AppBar(
        // ... (Le reste de votre AppBar)
        toolbarHeight: 135.0,
        backgroundColor: _backgroundColor,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: _cardTextColor),
          onPressed: () => Navigator.of(context).pop(),
        ),

        title: _buildAppBarTitle(),
        centerTitle: false,
        actions: [
          // 1. MENU DÉROULANT LANGUE
          _buildLanguageDropdown(),
          const SizedBox(width: 10),

          // 🎙️ NOUVEAU BOUTON PLAY/PAUSE
          _buildAudioPlaybackButton(), // <-- NOUVEAU WIDGET

          // Bouton Quiz
          if (widget.recit.quiz != null)
            Padding(
              padding: const EdgeInsets.only(right: 8.0),
              child: ActionChip(
                backgroundColor: _mainAccentColor,
                label: const Text('Quiz', style: TextStyle(color: Colors.white, fontSize: 12)),
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Lancer le Quiz !')),
                  );
                },
              ),
            ),

          // 2. BOUTON FERMER
          IconButton(
            icon: const Icon(Icons.close, color: _cardTextColor),
            onPressed: () => Navigator.of(context).pop(),
          ),
        ],
      ),
      // Le FutureBuilder englobe le contenu pour gérer l'état de chargement
      body: FutureBuilder<TraductionConte>(
        // ... (Le reste du FutureBuilder reste inchangé)
        future: _traductionFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator(color: _mainAccentColor));
          } else if (snapshot.hasError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Text(
                  'Erreur de chargement du contenu : ${snapshot.error}',
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: _serviceErrorColor, fontSize: 16),
                ),
              ),
            );
          } else if (!snapshot.hasData) {
            return const Center(child: Text('Aucun contenu de récit disponible.'));
          } else {
            // Affichage des données réelles
            final TraductionConte data = snapshot.data!;
            return SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 1. Image du Récit
                  _buildRecitImage(),
                  const SizedBox(height: 20),

                  // 2. Contenu du Récit
                  _buildRecitContentSection(data),
                  const SizedBox(height: 20),

                  // 3. Informations additionnelles
                  _buildAdditionalInfoSection(data),
                  const SizedBox(height: 20),
                ],
              ),
            );
          }
        },
      ),
    );
  }

  // 🎙️ NOUVEAU WIDGET : Bouton Lecture
  Widget _buildAudioPlaybackButton() {
    return Padding(
      padding: const EdgeInsets.only(right: 8.0),
      child: IconButton(
        icon: _isLoadingAudio
            ? const SizedBox(
          width: 24,
          height: 24,
          child: CircularProgressIndicator(
            color: _mainAccentColor,
            strokeWidth: 2,
          ),
        )
            : Icon(
          _isPlaying ? Icons.pause_circle_filled : Icons.play_circle_fill,
          color: _mainAccentColor,
          size: 32,
        ),
        onPressed: _isLoadingAudio ? null : _toggleAudioPlayback,
      ),
    );
  }

  // --- WIDGETS DE CONSTRUCTION (Restants inchangés) ---

  Widget _buildAppBarTitle() {
    // ... (Logique inchangée)
    return FutureBuilder<TraductionConte>(
      future: _traductionFuture,
      builder: (context, snapshot) {
        final String jsonKey = _mapUiCodeToApiJsonKey(_selectedLanguageCodeUI);
        final String title = snapshot.hasData
            ? snapshot.data!.traductionsTitre.traductions[jsonKey] ?? widget.recit.titre
            : widget.recit.titre;

        return Text(
          title,
          style: const TextStyle(
            color: _cardTextColor,
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        );
      },
    );
  }

  Widget _buildLanguageDropdown() {
    // ... (Logique inchangée)
    return DropdownButtonHideUnderline(
      child: DropdownButton<String>(
        value: _selectedLanguageCodeUI,
        icon: const Icon(Icons.keyboard_arrow_down, color: _mainAccentColor),
        items: _availableLangs
            .map<DropdownMenuItem<String>>((String value) {
          final String displayName = _mapLanguageCodeToName(value);
          return DropdownMenuItem<String>(
            value: value,
            child: Text(displayName, style: const TextStyle(color: _cardTextColor, fontSize: 14)),
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

  String _mapLanguageCodeToName(String code) {
    // ... (Logique inchangée)
    switch(code) {
      case 'fr': return 'Français';
      case 'bm': return 'Bambara';
      case 'en': return 'Anglais';
      default: return code;
    }
  }

  Widget _buildRecitImage() {
    // ... (Logique inchangée)
    String imagePath = widget.recit.urlPhoto;
    if (imagePath.isEmpty) {
      return Container(
        height: 220,
        width: double.infinity,
        decoration: BoxDecoration(
          color: Colors.grey.shade200,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Center(
          child: Icon(Icons.image_not_supported, size: 60, color: Colors.grey.shade500),
        ),
      );
    }

    String finalUrl = imagePath;
    if (!imagePath.startsWith('http')) {
      finalUrl = Uri.parse(_imageHostUrl).resolve(imagePath).toString();
    }

    return Container(
      height: 220,
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.grey.shade200,
        borderRadius: BorderRadius.circular(12),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Image.network(
          finalUrl,
          fit: BoxFit.cover,
          loadingBuilder: (context, child, loadingProgress) {
            if (loadingProgress == null) return child;
            return Center(
              child: CircularProgressIndicator(
                color: _mainAccentColor,
                value: loadingProgress.expectedTotalBytes != null
                    ? loadingProgress.cumulativeBytesLoaded / loadingProgress.expectedTotalBytes!
                    : null,
              ),
            );
          },
          errorBuilder: (context, error, stackTrace) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.broken_image, size: 50, color: _serviceErrorColor),
                  const SizedBox(height: 8),
                  const Text('Image introuvable', style: TextStyle(color: _serviceErrorColor, fontSize: 12)),
                  Text('URL TENTÉE: $finalUrl',
                      textAlign: TextAlign.center,
                      style: const TextStyle(color: Colors.grey, fontSize: 10)),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildRecitContentSection(TraductionConte data) {
    // ... (Logique inchangée)
    final String jsonKey = _mapUiCodeToApiJsonKey(_selectedLanguageCodeUI);
    final String content = data.traductionsContenu.traductions[jsonKey] ??
        data.descriptionOriginale;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Text(
        content,
        style: const TextStyle(
          color: _cardTextColor,
          fontSize: 16,
          height: 1.5,
        ),
        textAlign: TextAlign.justify,
      ),
    );
  }

  Widget _buildAdditionalInfoSection(TraductionConte data) {
    // ... (Logique inchangée)
    final String jsonKey = _mapUiCodeToApiJsonKey(_selectedLanguageCodeUI);
    final String lieu = data.traductionsLieu.traductions[jsonKey] ?? data.lieuOriginal;
    final String region = data.traductionsRegion.traductions[jsonKey] ?? data.regionOriginale;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Auteur: ${widget.recit.prenomAuteur} ${widget.recit.nomAuteur}', style: const TextStyle(fontSize: 14, color: _cardTextColor)),
        Text('Famille: ${widget.recit.nomFamille}', style: const TextStyle(fontSize: 14, color: _cardTextColor)),
        Text('Lieu: $lieu', style: const TextStyle(fontSize: 14, color: _cardTextColor)),
        Text('Région: $region', style: const TextStyle(fontSize: 14, color: _cardTextColor)),
        Text('Date de création: ${widget.recit.dateCreation.day}/${widget.recit.dateCreation.month}/${widget.recit.dateCreation.year}', style: const TextStyle(fontSize: 14, color: _cardTextColor)),
      ],
    );
  }
}