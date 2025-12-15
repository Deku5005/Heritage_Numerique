import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
// import 'package:just_audio/just_audio.dart' show MediaItem; // RÉTIRÉ
import 'dart:typed_data';
import 'package:audio_session/audio_session.dart';

// --- VÉRIFIEZ ET AJUSTEZ CES CHEMINS DANS VOTRE PROJET ---
import '../model/conte.dart';
import '../model/traduction_conte_model.dart';
import '../Service/conteService.dart';
import '../Service/LectureVocaleService.dart';
import '../widgets/bottom_navigation_widget.dart';
import '../screens/quizscreenn.dart';

// --- Constantes de Couleurs Globales ---
const Color _mainAccentColor = Color(0xFFAA7311);
const Color _backgroundColor = Colors.white;
const Color _cardTextColor = Color(0xFF2E2E2E);
const Color _serviceErrorColor = Colors.red;
const Color _quizButtonColor = Color(0xFF6A994E);

// ✅ BASE URL UTILISÉE POUR CONSTRUIRE L'URL DE L'IMAGE
const String _imageHostUrl = "http://192.168.43.22:8080";


class AffichageContesScreen extends StatefulWidget {
  final Conte conte;

  const AffichageContesScreen({super.key, required this.conte});

  @override
  State<AffichageContesScreen> createState() => _AffichageContesScreenState();
}

class _AffichageContesScreenState extends State<AffichageContesScreen> {

  // --- Services ---
  final ConteService _conteService = ConteService();
  final LectureVocaleService _lectureVocaleService = LectureVocaleService();

  // --- Audio Player State ---
  final AudioPlayer _audioPlayer = AudioPlayer();
  bool _isAudioLoading = false;
  bool _isPlaying = false;

  // --- Traduction State ---
  final List<String> _availableLangs = ['fr', 'bm', 'en'];
  String _selectedLanguageCodeUI = 'fr';
  late Future<TraductionConteModel> _traductionFuture;


  @override
  void initState() {
    super.initState();
    _initAudioSession();
    _traductionFuture = _fetchTranslation(_selectedLanguageCodeUI);

    _audioPlayer.playerStateStream.listen((state) {
      if (state.processingState == ProcessingState.completed) {
        setState(() {
          _isPlaying = false;
        });
      }
    });
  }

  Future<void> _initAudioSession() async {
    final session = await AudioSession.instance;
    await session.configure(const AudioSessionConfiguration.speech());
  }

  @override
  void dispose() {
    _audioPlayer.dispose();
    super.dispose();
  }

  // ------------------------------------------------------------------
  // --- LOGIQUE DE TRADUCTION ET DE LECTURE VOCALE ---
  // ------------------------------------------------------------------

  String _mapUiCodeToApiJsonKey(String uiCode) {
    switch (uiCode) {
      case 'fr': return 'fra_Latn';
      case 'bm': return 'bam_Latn';
      case 'en': return 'eng_Latn';
      default: return uiCode;
    }
  }

  Future<TraductionConteModel> _fetchTranslation(String uiLanguageCode) {
    return _conteService.getConteTraduction(
      conteId: widget.conte.id,
      langCode: uiLanguageCode,
    );
  }

  void _changeLanguageAndReload(String newLanguageCodeUI) {
    if (newLanguageCodeUI != _selectedLanguageCodeUI) {
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

  // --- MÉTHODES AUDIO ---

  void _toggleAudioPlayback() async {
    if (_isPlaying) {
      _stopAudio();
    } else {
      await _playAudio();
    }
  }

  void _stopAudio() async {
    if (_audioPlayer.processingState != ProcessingState.idle) {
      await _audioPlayer.stop();
    }
    setState(() {
      _isPlaying = false;
      _isAudioLoading = false;
    });
  }

  Future<void> _playAudio() async {
    final String currentLang = _selectedLanguageCodeUI;

    if (_isAudioLoading || _isPlaying) return;

    setState(() {
      _isAudioLoading = true;
    });

    try {
      final List<int> audioBytes = await _lectureVocaleService.telechargerLectureVocale(
        widget.conte.id,
        currentLang,
      );

      final Uint8List uint8Bytes = Uint8List.fromList(audioBytes);

      await _audioPlayer.setAudioSource(
        AudioByteStream(uint8Bytes),
      );

      await _audioPlayer.play();

      setState(() {
        _isPlaying = true;
        _isAudioLoading = false;
      });

    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erreur de lecture vocale pour la langue $currentLang. ${e.toString().split(':').last.trim()}'),
          backgroundColor: _serviceErrorColor,
        ),
      );
      setState(() {
        _isAudioLoading = false;
        _isPlaying = false;
      });
    }
  }

  // ------------------------------------------------------------------
  // --- WIDGETS DE CONSTRUCTION ---
  // ------------------------------------------------------------------

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _backgroundColor,
      bottomNavigationBar: const BottomNavigationWidget(currentPage: 'contes'),
      appBar: AppBar(
        toolbarHeight: 60.0,
        backgroundColor: _backgroundColor,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: _cardTextColor),
          onPressed: () => Navigator.of(context).pop(),
        ),
        centerTitle: true,
        title: _buildAppBarTitle(),
      ),

      body: FutureBuilder<TraductionConteModel>(
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
                  'Erreur de chargement de la traduction. Affichage du contenu original. Erreur: ${snapshot.error}',
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: _serviceErrorColor, fontSize: 14),
                ),
              ),
            );
          }

          final TraductionConteModel? data = snapshot.data;

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildLanguageSelector(),
                const SizedBox(height: 15),

                _buildRecitImage(),
                const SizedBox(height: 20),

                _buildRecitContentSection(data),
                const SizedBox(height: 20),

                if (widget.conte.quiz != null && widget.conte.quiz!.questions.isNotEmpty)
                  _buildQuizButton(),
                if (widget.conte.quiz != null && widget.conte.quiz!.questions.isNotEmpty)
                  const SizedBox(height: 20),

                _buildAdditionalInfoSection(data),
                const SizedBox(height: 20),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildAppBarTitle() {
    return FutureBuilder<TraductionConteModel>(
      future: _traductionFuture,
      builder: (context, snapshot) {
        final String jsonKey = _mapUiCodeToApiJsonKey(_selectedLanguageCodeUI);
        final String title = snapshot.hasData && snapshot.data != null
            ? snapshot.data!.traductionsTitre.traductions[jsonKey] ?? widget.conte.titre
            : widget.conte.titre;

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

  Widget _buildLanguageSelector() {
    return Center(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(25),
          border: Border.all(color: _mainAccentColor, width: 1.5),
        ),
        child: DropdownButtonHideUnderline(
          child: DropdownButton<String>(
            value: _selectedLanguageCodeUI,
            icon: const Icon(Icons.arrow_drop_down, color: _mainAccentColor),
            items: _availableLangs
                .map<DropdownMenuItem<String>>((String code) {
              final String displayName = _mapLanguageCodeToName(code);
              return DropdownMenuItem<String>(
                value: code,
                child: Text(displayName, style: const TextStyle(color: _cardTextColor, fontSize: 14)),
              );
            }).toList(),
            onChanged: (String? newCode) {
              if (newCode != null) {
                _changeLanguageAndReload(newCode);
              }
            },
          ),
        ),
      ),
    );
  }

  Widget _buildRecitImage() {
    String imagePath = widget.conte.urlPhoto;
    String finalUrl = imagePath;

    if (imagePath.isNotEmpty && !imagePath.startsWith('http')) {
      final String sanitizedPath = imagePath.startsWith('/') ? imagePath.substring(1) : imagePath;
      finalUrl = '$_imageHostUrl/$sanitizedPath';
    }

    return Container(
      height: 220,
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.grey.shade200,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
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
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildRecitContentSection(TraductionConteModel? data) {
    final String jsonKey = _mapUiCodeToApiJsonKey(_selectedLanguageCodeUI);
    String content = widget.conte.contenuFichier;

    if (data != null) {
      content = data.traductionsContenu.traductions[jsonKey] ?? widget.conte.contenuFichier;
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              'Récit - ${_mapLanguageCodeToName(_selectedLanguageCodeUI)}',
              style: const TextStyle(
                color: _cardTextColor,
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
            ),
            const Spacer(),

            IconButton(
              icon: _isAudioLoading
                  ? const SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(
                  strokeWidth: 2.5,
                  color: _mainAccentColor,
                ),
              )
                  : Icon(
                _isPlaying ? Icons.pause_circle_filled : Icons.volume_up,
                color: _mainAccentColor,
                size: 30,
              ),
              onPressed: _toggleAudioPlayback,
            ),
          ],
        ),
        const SizedBox(height: 10),

        Container(
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
        ),
      ],
    );
  }

  Widget _buildQuizButton() {
    return Center(
      child: ElevatedButton.icon(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => QuizScreen(quiz: widget.conte.quiz!),
            ),
          );
        },
        icon: const Icon(Icons.school, size: 24),
        label: const Text('Commencer le Quiz !', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        style: ElevatedButton.styleFrom(
          backgroundColor: _quizButtonColor,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
          elevation: 5,
        ),
      ),
    );
  }

  Widget _buildAdditionalInfoSection(TraductionConteModel? data) {
    final String jsonKey = _mapUiCodeToApiJsonKey(_selectedLanguageCodeUI);
    String lieu = widget.conte.lieu;
    String region = widget.conte.region;

    if (data != null) {
      lieu = data.traductionsLieu.traductions[jsonKey] ?? widget.conte.lieu;
      region = data.traductionsRegion.traductions[jsonKey] ?? widget.conte.region;
    }

    final Map<String, String> labels = {
      'fr': {'title': 'Informations sur le Conte', 'lieu': 'Lieu', 'region': 'Région'},
      'bm': {'title': 'Kunnafoni', 'lieu': 'Yɔrɔ', 'region': 'Jamanan'},
      'en': {'title': 'Tale Information', 'lieu': 'Location', 'region': 'Region'},
    }[_selectedLanguageCodeUI] ?? {'title': 'Informations sur le Conte', 'lieu': 'Lieu', 'region': 'Région'};


    return Card(
      elevation: 2,
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              labels['title']!,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: _mainAccentColor),
            ),
            const Divider(height: 20, color: Colors.grey),
            _buildInfoRow('Conteur', '${widget.conte.prenomAuteur} ${widget.conte.nomAuteur}'),
            _buildInfoRow('Famille', widget.conte.nomFamille),
            _buildInfoRow(labels['lieu']!, lieu),
            _buildInfoRow(labels['region']!, region),
            _buildInfoRow('Création', widget.conte.dateCreation.split('T').first),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              '$label:',
              style: const TextStyle(
                color: _cardTextColor,
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                color: _cardTextColor,
                fontSize: 14,
              ),
            ),
          ),
        ],
      ),
    );
  }
}


// ------------------------------------------------------------------
// --- CLASSE D'AIDE CORRIGÉE (MediaItem retiré pour compilation) ---
// ------------------------------------------------------------------

class AudioByteStream extends StreamAudioSource {
  final Uint8List bytes;

  AudioByteStream(this.bytes) : super(tag: 'AudioFromBytes');

  @override
  Future<StreamAudioResponse> request([int? start, int? end]) async {
    final int effectiveStart = start ?? 0;
    final int effectiveEnd = end ?? bytes.length;
    final int effectiveLength = effectiveEnd - effectiveStart;

    final sublist = bytes.sublist(effectiveStart, effectiveEnd);

    // ⚠️ MediaItem a été retiré pour corriger l'erreur de compilation, car
    // l'import n'est pas résolu dans cette version ou configuration.
    // L'instanciation de MediaItem est maintenant inutile et retirée.

    return StreamAudioResponse(
      sourceLength: bytes.length,
      contentLength: effectiveLength,
      offset: effectiveStart,
      contentType: 'audio/mpeg',
      stream: Stream.value(sublist),
    );
  }
}