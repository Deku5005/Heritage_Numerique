import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // Nécessaire pour Uint8List dans la lecture audio
import '../model/ArtisanatModel.dart';
// 💡 AJOUTS POUR LA TRADUCTION
import '../service/ArtisanatService.dart';
import '../model/ArtisanatTraductionModel.dart';
// 💡 AJOUTS POUR LA LECTURE VOCALE
import '../service/LectureVocaleService.dart'; // Assurez-vous que le chemin est correct
import 'package:just_audio/just_audio.dart'; // Le player audio

// 💡 Importation du nouveau widget vidéo
import '../widgets/VideoPlayerWidget.dart';

// --- Constantes de Couleurs Globales ---
const Color _mainAccentColor = Color(0xFFAA7311);
const Color _backgroundColor = Colors.white;
const Color _cardTextColor = Color(0xFF2E2E2E);
const Color _buttonColor = Color(0xFF7B521A);
const Color _lightCardColor = Color(0xFFF7F2E8);

// ----------------------------------------------------------------------
// CLASSE PRINCIPALE : ArtisanatDetailPage (StatefulWidget)
// ----------------------------------------------------------------------
class ArtisanatDetailPage extends StatefulWidget {
  final Artisanat artisanat;

  const ArtisanatDetailPage({super.key, required this.artisanat});

  @override
  State<ArtisanatDetailPage> createState() => _ArtisanatDetailPageState();
}

class _ArtisanatDetailPageState extends State<ArtisanatDetailPage> {
  final ArtisanatService _artisanatService = ArtisanatService();
  // 💡 NOUVEAU : Service et Player audio
  final LectureVocaleService _lectureVocaleService = LectureVocaleService();
  final AudioPlayer _audioPlayer = AudioPlayer();

  ArtisanatTraduction? _currentTranslation;
  String _selectedLanguageCode = 'fr'; // Langue par défaut (Français)
  bool _isLoadingTranslation = false;
  String? _translationError;
  // 💡 NOUVEAU : État de la lecture vocale
  bool _isAudioLoading = false;
  bool _isPlayingAudio = false;

  // Liste des langues disponibles pour le sélecteur dans l'UI
  List<String> _availableLanguages = ['fr', 'en', 'bm']; // Exemple initial

  @override
  void initState() {
    super.initState();
    _fetchTranslation('fr');
    // Écouter l'état du lecteur audio pour mettre à jour l'UI
    _audioPlayer.playerStateStream.listen((state) {
      if (mounted) {
        setState(() {
          _isPlayingAudio = state.playing;
          // Si la lecture est terminée, on met à jour l'état et on réinitialise le player
          if (state.processingState == ProcessingState.completed) {
            _isPlayingAudio = false;
            _audioPlayer.seek(Duration.zero);
          }
        });
      }
    });
  }

  // 💡 NOUVEAU : Méthode dispose pour libérer les ressources
  @override
  void dispose() {
    _audioPlayer.dispose();
    _lectureVocaleService.dispose();
    super.dispose();
  }

  // --- Logique de Lecture Vocale ---
  Future<void> _playAudio() async {
    // Si l'audio est déjà en cours de lecture, on l'arrête
    if (_isPlayingAudio) {
      _audioPlayer.stop();
      return;
    }

    // Le bouton n'est visible que pour 'bm', mais on ajoute une vérif de sécurité
    if (_selectedLanguageCode != 'bm') return;

    setState(() {
      _isAudioLoading = true;
      _translationError = null; // Effacer les erreurs précédentes
    });

    try {
      // 1. Télécharger les octets audio (NON PUBLIQUE, usePublicApi: false)
      final Uint8List audioBytes = await _lectureVocaleService.telechargerLectureVocale(
        widget.artisanat.id,
        _selectedLanguageCode,
        usePublicApi: false, // Utiliser l'endpoint non public
      );

      // 2. Jouer l'audio à partir des octets (Correction pour just_audio)
      final uri = Uri.dataFromBytes(
        audioBytes,
        mimeType: 'audio/mpeg',
      );

      await _audioPlayer.setAudioSource(
        AudioSource.uri(uri),
      );

      await _audioPlayer.play();

    } catch (e) {
      if (mounted) {
        setState(() {
          _translationError = 'Échec de la lecture vocale : ${e.toString().replaceFirst('Exception: ', '')}';
        });
      }
      _audioPlayer.stop();
    } finally {
      if (mounted) {
        setState(() {
          _isAudioLoading = false;
        });
      }
    }
  }


  // --- Logique de récupération de la traduction ---
  Future<void> _fetchTranslation(String langCode) async {
    // Arrêter l'audio si la langue change
    _audioPlayer.stop();
    _isPlayingAudio = false;

    if (_isLoadingTranslation) return;

    if (langCode == 'fr') {
      // Le français est la source
      setState(() {
        _currentTranslation = _createSourceTranslation(widget.artisanat);
        _selectedLanguageCode = 'fr';
      });
      return;
    }

    setState(() {
      _isLoadingTranslation = true;
      _translationError = null;
      _selectedLanguageCode = langCode;
    });

    try {
      final translation = await _artisanatService.fetchArtisanatTranslation(
        artisanatId: widget.artisanat.id,
        targetLanguageCode: langCode,
      );

      if (mounted) {
        setState(() {
          _currentTranslation = translation;
          // Mettre à jour la liste des langues disponibles avec 'bm'
          final List<String> apiLangs = translation.languesDisponibles.map((code) => code == 'bam_Latn' ? 'bm' : code).toList();
          _availableLanguages = {'fr', ...apiLangs}.toList();
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

  // Crée un objet ArtisanatTraduction à partir de l'objet source (Artisanat)
  ArtisanatTraduction _createSourceTranslation(Artisanat source) {
    return ArtisanatTraduction(
      idContenu: source.id,
      titreOriginal: source.titre,
      descriptionOriginale: source.description,
      lieuOriginal: source.lieu,
      regionOriginale: source.region,
      traductionsTitre: {'fr': source.titre},
      traductionsDescription: {'fr': source.description},
      traductionsLieu: source.lieu != null ? {'fr': source.lieu!} : {},
      traductionsRegion: source.region != null ? {'fr': source.region!} : {},
      traductionsContenu: {'fr': source.description},
      traductionsCompletes: {'fr': source.description},
      languesDisponibles: const [],
      langueSource: 'fra_Latn',
      statutTraduction: 'SOURCE',
    );
  }

  // --- Fonctions d'accès au contenu traduit ---

  String _getTranslatedText(String? originalText, Map<String, String> translationsMap, String langCode) {
    if (langCode == 'fr') return originalText ?? '';
    return translationsMap[langCode] ?? originalText ?? 'Traduction non disponible.';
  }

  String _getTitre() {
    if (_selectedLanguageCode == 'fr') {
      return widget.artisanat.titre;
    }
    return _getTranslatedText(
        widget.artisanat.titre,
        _currentTranslation?.traductionsTitre ?? {},
        _selectedLanguageCode
    );
  }

  String _getDescription() {
    if (_selectedLanguageCode == 'fr') {
      return widget.artisanat.description;
    }
    return _getTranslatedText(
        widget.artisanat.description,
        _currentTranslation?.traductionsDescription ?? {},
        _selectedLanguageCode
    );
  }


  // --- Widgets UI ---

  // 💡 MISE À JOUR : Widget pour afficher une section d'information avec bouton de lecture vocale
  Widget _buildInfoSection(String title, String? content, {IconData? icon}) {
    if (content == null || content.isEmpty) return const SizedBox.shrink();

    // Vérification pour l'affichage de l'icône de lecture vocale
    final bool isBambaraSelected = _selectedLanguageCode == 'bm';

    return Padding(
      padding: const EdgeInsets.only(bottom: 15.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  if (icon != null) Icon(icon, size: 20, color: _mainAccentColor),
                  if (icon != null) const SizedBox(width: 8),
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: _cardTextColor,
                    ),
                  ),
                ],
              ),

              // 💡 BOUTON DE LECTURE VOCALE
              if (isBambaraSelected)
                _isAudioLoading
                    ? const SizedBox(
                  width: 20, height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2, color: _mainAccentColor),
                )
                    : IconButton(
                  icon: Icon(
                    _isPlayingAudio ? Icons.stop_circle_outlined : Icons.volume_up,
                    color: _buttonColor,
                    size: 24,
                  ),
                  onPressed: _playAudio,
                  tooltip: _isPlayingAudio ? 'Arrêter la lecture' : 'Écouter en Bambara',
                ),
            ],
          ),
          const SizedBox(height: 5),
          Padding(
            padding: const EdgeInsets.only(left: 8.0),
            child: Text(
              content,
              style: TextStyle(fontSize: 15, color: Colors.grey[700], height: 1.4),
            ),
          ),
        ],
      ),
    );
  }

  // Widget pour afficher l'auteur et la date
  Widget _buildAuthorInfo() {
    final String auteurNomComplet = '${widget.artisanat.prenomAuteur} ${widget.artisanat.nomAuteur}';
    final String dateCreation = '${widget.artisanat.dateCreation.day}/${widget.artisanat.dateCreation.month}/${widget.artisanat.dateCreation.year}';

    // Récupérer les informations de lieu/région traduites (si disponibles)
    final String translatedLieu = _getTranslatedText(
        widget.artisanat.lieu,
        _currentTranslation?.traductionsLieu ?? {},
        _selectedLanguageCode
    );
    final String translatedRegion = _getTranslatedText(
        widget.artisanat.region,
        _currentTranslation?.traductionsRegion ?? {},
        _selectedLanguageCode
    );

    String lieuRegion = '';
    if (translatedLieu != null && translatedLieu.isNotEmpty) {
      lieuRegion += translatedLieu;
    }
    if (translatedRegion != null && translatedRegion.isNotEmpty) {
      if (lieuRegion.isNotEmpty) lieuRegion += ', ';
      lieuRegion += translatedRegion;
    }

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildDetailRow(Icons.person, "Auteur", auteurNomComplet),
          const SizedBox(height: 5),
          _buildDetailRow(Icons.calendar_today, "Créé le", dateCreation),
          if (lieuRegion.isNotEmpty)
            _buildDetailRow(Icons.location_on, "Lieu", lieuRegion),
        ],
      ),
    );
  }

  // Sous-widget utilitaire pour les lignes de détails
  Widget _buildDetailRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, size: 16, color: _buttonColor),
        const SizedBox(width: 8),
        Text(
          "$label : ",
          style: const TextStyle(fontWeight: FontWeight.w600, color: _cardTextColor),
        ),
        Flexible(
          child: Text(
            value,
            style: const TextStyle(color: _cardTextColor),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  // Widget sélecteur de langue
  Widget _buildLanguageSelector() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 10.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          const Text("Langue : ", style: TextStyle(fontWeight: FontWeight.bold, color: _cardTextColor)),
          DropdownButton<String>(
            value: _selectedLanguageCode,
            icon: const Icon(Icons.arrow_drop_down),
            underline: Container(height: 1, color: _mainAccentColor),
            onChanged: _isLoadingTranslation ? null : (String? newValue) {
              if (newValue != null && newValue != _selectedLanguageCode) {
                _fetchTranslation(newValue);
              }
            },
            items: _availableLanguages.map<DropdownMenuItem<String>>((String value) {
              // MISE À JOUR DE L'AFFICHAGE POUR LE CODE 'bm'
              String displayName;
              switch (value) {
                case 'fr':
                  displayName = 'Français (Source)';
                  break;
                case 'en':
                  displayName = 'Anglais';
                  break;
                case 'bm': // Le code correct pour le Bambara
                  displayName = 'Bambara';
                  break;
                default:
                  displayName = value.toUpperCase();
              }


              return DropdownMenuItem<String>(
                value: value,
                child: Text(displayName),
              );
            }).toList(),
          ),
          if (_isLoadingTranslation)
            const Padding(
              padding: EdgeInsets.only(left: 10.0),
              child: SizedBox(
                  width: 15, height: 15,
                  child: CircularProgressIndicator(strokeWidth: 2, color: _mainAccentColor)
              ),
            ),
        ],
      ),
    );
  }


  @override
  Widget build(BuildContext context) {
    // URL de la photo principale (première de la liste ou vide)
    final String mainImageUrl = (widget.artisanat.urlPhotos.isNotEmpty)
        ? widget.artisanat.urlPhotos.first
        : 'assets/images/placeholder_artisanat.png'; // Utilisez votre propre placeholder

    // Texte à afficher
    final String titreAffiche = _getTitre();
    final String descriptionAffichee = _getDescription();

    return Scaffold(
      backgroundColor: _backgroundColor,
      appBar: AppBar(
        title: Text(titreAffiche, style: const TextStyle(color: _cardTextColor, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        iconTheme: const IconThemeData(color: _cardTextColor),
        elevation: 0,
      ),
      body: Column(
        children: [
          _buildLanguageSelector(), // Sélecteur juste sous l'AppBar

          if (_translationError != null)
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(_translationError!, style: const TextStyle(color: Colors.red)),
            ),

          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  // --- 1. Photo Principale ---
                  ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: AspectRatio(
                      aspectRatio: 16 / 9,
                      child: Image.network(
                        mainImageUrl,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) => Image.asset(
                          'assets/images/Tapis.png', // Placeholder en cas d'erreur de réseau
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),

                  // --- 2. Titre et Auteur/Lieu (Met à jour le titre avec la traduction) ---
                  Text(
                    titreAffiche,
                    style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w900, color: _cardTextColor),
                  ),
                  const SizedBox(height: 10),

                  _buildAuthorInfo(),
                  const SizedBox(height: 20),

                  // --- 3. Description Longue / Détails (Met à jour la description avec la traduction) ---
                  _buildInfoSection(
                      "Description et Détails",
                      descriptionAffichee,
                      icon: Icons.notes
                  ),

                  // --- 4. Vidéo (Si disponible) ---
                  if (widget.artisanat.urlVideo != null && widget.artisanat.urlVideo!.isNotEmpty)
                    _buildVideoSection(context, widget.artisanat.urlVideo!),

                  // --- 5. Autres photos (Si disponibles) ---
                  if (widget.artisanat.urlPhotos.length > 1)
                    _buildOtherPhotosSection(widget.artisanat.urlPhotos.sublist(1)),

                  const SizedBox(height: 50),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Widget mis à jour pour intégrer le lecteur vidéo
  Widget _buildVideoSection(BuildContext context, String videoUrl) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildInfoSection("Vidéo de Fabrication", null, icon: Icons.videocam),
          const SizedBox(height: 10),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(15),
            decoration: BoxDecoration(
                color: _lightCardColor,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.grey.shade300)
            ),
            // Remplacement du conteneur statique par le lecteur vidéo
            child: VideoPlayerWidget(videoUrl: videoUrl),
          ),
        ],
      ),
    );
  }

  // Widget pour les autres photos
  Widget _buildOtherPhotosSection(List<String> photoUrls) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildInfoSection("Galerie Photos", null, icon: Icons.photo_library),
          const SizedBox(height: 10),
          SizedBox(
            height: 100, // Hauteur fixe pour la galerie
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: photoUrls.length,
              itemBuilder: (context, index) {
                return Padding(
                  padding: const EdgeInsets.only(right: 10.0),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.network(
                      photoUrls[index],
                      width: 100,
                      height: 100,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) => Container(
                        width: 100,
                        height: 100,
                        color: Colors.grey,
                        child: const Icon(Icons.broken_image, color: Colors.white),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}