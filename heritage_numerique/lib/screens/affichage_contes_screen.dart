import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import 'dart:typed_data';

import '../model/conte.dart';
import '../model/traduction_conte_model.dart';
import '../Service/conteService.dart';
import '../Service/LectureVocaleService.dart';
import '../widgets/cultural_theme.dart';
import '../screens/quizscreenn.dart';

const Color _backgroundColor = Color(0xFFFAF7F2);
const Color _serviceErrorColor = Colors.red;
const String _imageHostUrl = "http://10.0.2.2:8080";

class AffichageContesScreen extends StatefulWidget {
  final Conte conte;

  const AffichageContesScreen({super.key, required this.conte});

  @override
  State<AffichageContesScreen> createState() => _AffichageContesScreenState();
}

class _AffichageContesScreenState extends State<AffichageContesScreen> {
  final ConteService _conteService = ConteService();
  final LectureVocaleService _lectureVocaleService = LectureVocaleService();

  final AudioPlayer _audioPlayer = AudioPlayer();
  bool _isAudioLoading = false;
  bool _isPlaying = false;
  Duration _currentPosition = Duration.zero;
  Duration _totalDuration = Duration.zero;

  final List<String> _availableLangs = ['fr', 'bm', 'en'];
  String _selectedLanguageCodeUI = 'fr';
  late Future<TraductionConteModel> _traductionFuture;
  bool _isBookmarked = false;

  @override
  void initState() {
    super.initState();
    _traductionFuture = _fetchTranslation(_selectedLanguageCodeUI);

    _audioPlayer.playerStateStream.listen((state) {
      if (mounted) {
        setState(() {
          _isPlaying = state.playing && state.processingState != ProcessingState.completed;
        });
      }
    });

    _audioPlayer.positionStream.listen((pos) {
      if (mounted) {
        setState(() {
          _currentPosition = pos;
        });
      }
    });

    _audioPlayer.durationStream.listen((dur) {
      if (mounted && dur != null) {
        setState(() {
          _totalDuration = dur;
        });
      }
    });
  }

  @override
  void dispose() {
    _audioPlayer.dispose();
    super.dispose();
  }

  Future<TraductionConteModel> _fetchTranslation(String langCodeUI) {
    final String apiLangCode = _mapUiCodeToApiLangCode(langCodeUI);
    return _conteService.getConteTraduction(
      conteId: widget.conte.id,
      langCode: apiLangCode,
    );
  }

  String _mapUiCodeToApiLangCode(String uiCode) {
    switch (uiCode) {
      case 'fr': return 'fr';
      case 'bm': return 'bm';
      case 'en': return 'en';
      default: return 'fr';
    }
  }

  String _mapUiCodeToApiJsonKey(String uiCode) {
    switch (uiCode) {
      case 'fr': return 'francais';
      case 'bm': return 'bambara';
      case 'en': return 'anglais';
      default: return 'francais';
    }
  }

  String _mapLanguageCodeToName(String code) {
    switch (code) {
      case 'fr': return 'Français';
      case 'bm': return 'Bamanankan';
      case 'en': return 'English';
      default: return code;
    }
  }

  void _changeLanguageAndReload(String newLangCodeUI) {
    if (newLangCodeUI == _selectedLanguageCodeUI) return;
    setState(() {
      _selectedLanguageCodeUI = newLangCodeUI;
      _traductionFuture = _fetchTranslation(newLangCodeUI);
      if (_isPlaying) {
        _audioPlayer.stop();
        _isPlaying = false;
      }
    });
  }

  String _formatDuration(Duration duration) {
    final minutes = duration.inMinutes.remainder(60).toString().padLeft(2, '0');
    final seconds = duration.inSeconds.remainder(60).toString().padLeft(2, '0');
    return '$minutes:$seconds';
  }

  void _toggleAudioPlayback() async {
    if (_isAudioLoading) return;

    if (_isPlaying) {
      await _audioPlayer.pause();
      return;
    }

    if (_audioPlayer.duration != null && _audioPlayer.position < _audioPlayer.duration!) {
      await _audioPlayer.play();
      return;
    }

    setState(() {
      _isAudioLoading = true;
    });

    final String currentLang = _selectedLanguageCodeUI;

    try {
      final Uint8List uint8Bytes = await _lectureVocaleService.telechargerLectureVocale(
        widget.conte.id,
        currentLang,
        usePublicApi: true,
      );

      await _audioPlayer.setAudioSource(AudioByteStream(uint8Bytes));
      await _audioPlayer.play();

      setState(() {
        _isPlaying = true;
        _isAudioLoading = false;
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Lecture vocale non disponible : ${e.toString().split(':').last.trim()}'),
            backgroundColor: _serviceErrorColor,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
        );
        setState(() {
          _isAudioLoading = false;
          _isPlaying = false;
        });
      }
    }
  }

  Widget _buildImageWidget(String path) {
    if (path.isEmpty) {
      return Image.asset('assets/images/contes.jpg', fit: BoxFit.cover);
    }
    if (path.startsWith('assets/')) {
      return Image.asset(path, fit: BoxFit.cover, errorBuilder: (_, __, ___) => Image.asset('assets/images/contes.jpg', fit: BoxFit.cover));
    }
    String url = path;
    if (!path.startsWith('http')) {
      final sanitized = path.startsWith('/') ? path.substring(1) : path;
      url = '$_imageHostUrl/$sanitized';
    }
    return Image.network(
      url,
      fit: BoxFit.cover,
      errorBuilder: (_, __, ___) => Image.asset('assets/images/contes.jpg', fit: BoxFit.cover),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _backgroundColor,
      body: Stack(
        children: [
          CustomScrollView(
            physics: const BouncingScrollPhysics(),
            slivers: [
              _buildSliverHeader(),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 20, 20, 130),
                  child: FutureBuilder<TraductionConteModel>(
                    future: _traductionFuture,
                    builder: (context, snapshot) {
                      final TraductionConteModel? data = snapshot.data;
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildLanguageSelector(),
                          const SizedBox(height: 24),
                          _buildReadingCanvas(data),
                          const SizedBox(height: 24),
                          _buildStoryMetadata(data),
                          const SizedBox(height: 24),
                          if (widget.conte.quiz != null && widget.conte.quiz!.questions.isNotEmpty)
                            _buildQuizChallengeCard(),
                        ],
                      );
                    },
                  ),
                ),
              ),
            ],
          ),

          // Barre de lecture audio flottante au design haute fidélité
          Positioned(
            left: 16,
            right: 16,
            bottom: 24,
            child: _buildAudioPlayerBar(),
          ),
        ],
      ),
    );
  }

  // --- 1. En-tête Sliver avec Image Parallaxe et boutons flottants ---
  Widget _buildSliverHeader() {
    return SliverAppBar(
      expandedHeight: 300,
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
                _isBookmarked ? Icons.bookmark : Icons.bookmark_border,
                color: _isBookmarked ? CulturalTheme.secondaryGold : Colors.white,
                size: 20,
              ),
              onPressed: () {
                setState(() => _isBookmarked = !_isBookmarked);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(_isBookmarked ? 'Conte ajouté à vos favoris' : 'Conte retiré de vos favoris'),
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
            _buildImageWidget(widget.conte.urlPhoto),
            // Dégradé luxueux pour une lisibilité parfaite
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Colors.black.withValues(alpha: 0.5),
                    Colors.transparent,
                    Colors.black.withValues(alpha: 0.85),
                  ],
                  stops: const [0.0, 0.45, 1.0],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
              ),
            ),
            // Badge et titre au bas du header
            Positioned(
              left: 20,
              right: 20,
              bottom: 20,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
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
                        const Icon(Icons.auto_stories, color: Colors.white, size: 12),
                        const SizedBox(width: 5),
                        Text(
                          widget.conte.region.isNotEmpty ? 'Conte du ${widget.conte.region}' : 'Conte traditionnel',
                          style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold, letterSpacing: 0.5),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    widget.conte.titre,
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
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      const Icon(Icons.person_pin, color: Colors.white70, size: 14),
                      const SizedBox(width: 6),
                      Text(
                        '${widget.conte.prenomAuteur} ${widget.conte.nomAuteur}'.trim().isNotEmpty
                            ? 'Conté par ${widget.conte.prenomAuteur} ${widget.conte.nomAuteur}'
                            : 'Tradition orale Malienne',
                        style: const TextStyle(color: Colors.white70, fontSize: 12, fontWeight: FontWeight.w500),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // --- 2. Sélecteur de Langue Moderne (Pill Tabs) ---
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
        children: _availableLangs.map((lang) {
          final isSelected = lang == _selectedLanguageCodeUI;
          return Expanded(
            child: GestureDetector(
              onTap: () => _changeLanguageAndReload(lang),
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

  // --- 3. Toile de lecture (Reading Canvas) avec lettrine et typographie d'art ---
  Widget _buildReadingCanvas(TraductionConteModel? data) {
    final String jsonKey = _mapUiCodeToApiJsonKey(_selectedLanguageCodeUI);
    String content = widget.conte.contenuFichier;
    if (data != null) {
      content = data.traductionsContenu.traductions[jsonKey] ?? widget.conte.contenuFichier;
    }

    if (content.isEmpty) {
      content = widget.conte.description;
    }

    final String firstLetter = content.isNotEmpty ? content.trim().substring(0, 1) : "I";
    final String remainingText = content.isNotEmpty ? content.trim().substring(1) : "";

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 28),
      decoration: BoxDecoration(
        color: const Color(0xFFFFFDF9), // Papier parchemin clair
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFFE8DFD0), width: 1.2),
        boxShadow: CulturalTheme.softShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // En-tête du texte avec motif ornemental
          Row(
            children: [
              Container(
                width: 4,
                height: 24,
                decoration: BoxDecoration(
                  color: CulturalTheme.primaryOcre,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(width: 10),
              const Text(
                'LE RÉCIT SACRÉ',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 1.5,
                  color: CulturalTheme.primaryDarkOcre,
                ),
              ),
              const Spacer(),
              const Icon(Icons.format_quote, color: CulturalTheme.secondaryGold, size: 28),
            ],
          ),
          const SizedBox(height: 18),

          // Lettrine stylisée et texte
          RichText(
            textAlign: TextAlign.justify,
            text: TextSpan(
              children: [
                TextSpan(
                  text: firstLetter,
                  style: const TextStyle(
                    fontSize: 42,
                    height: 0.9,
                    fontWeight: FontWeight.w900,
                    color: CulturalTheme.primaryDarkOcre,
                    fontFamily: 'serif',
                  ),
                ),
                TextSpan(
                  text: remainingText,
                  style: const TextStyle(
                    fontSize: 16,
                    height: 1.8,
                    color: Color(0xFF332B25),
                    letterSpacing: 0.2,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // Séparateur culturel subtil
          Center(
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(width: 30, height: 1, color: const Color(0xFFDECDB9)),
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 10.0),
                  child: Icon(Icons.spa, size: 14, color: CulturalTheme.primaryOcre),
                ),
                Container(width: 30, height: 1, color: const Color(0xFFDECDB9)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // --- 4. Métadonnées & Carte Conteur ---
  Widget _buildStoryMetadata(TraductionConteModel? data) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFEBE3D5)),
        boxShadow: CulturalTheme.softShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Fiche Patrimoniale',
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.bold,
              color: CulturalTheme.primaryDarkOcre,
            ),
          ),
          const Divider(height: 20, color: Color(0xFFF0EBE0)),
          _buildInfoRow(Icons.person, 'Conteur :', '${widget.conte.prenomAuteur} ${widget.conte.nomAuteur}'.trim().isNotEmpty ? '${widget.conte.prenomAuteur} ${widget.conte.nomAuteur}' : 'Tradition orale'),
          const SizedBox(height: 10),
          _buildInfoRow(Icons.place, 'Lieu & Région :', '${widget.conte.lieu.isNotEmpty ? widget.conte.lieu : "Mandé"}, ${widget.conte.region.isNotEmpty ? widget.conte.region : "Mali"}'),
          const SizedBox(height: 10),
          _buildInfoRow(Icons.language, 'Langue d\'origine :', 'Bamanankan / Mandingue'),
        ],
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 16, color: CulturalTheme.primaryOcre),
        const SizedBox(width: 8),
        Text(
          label,
          style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: CulturalTheme.textDark),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(fontSize: 13, color: CulturalTheme.textMuted),
          ),
        ),
      ],
    );
  }

  // --- 5. Défi Quiz sur ce Conte ---
  Widget _buildQuizChallengeCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF2B3A42), Color(0xFF1E272C)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.15),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: CulturalTheme.secondaryGold.withValues(alpha: 0.2),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.emoji_events, color: CulturalTheme.secondaryGold, size: 28),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                Text(
                  'Défi Culturel',
                  style: TextStyle(color: CulturalTheme.accentGold, fontSize: 11, fontWeight: FontWeight.bold, letterSpacing: 0.8),
                ),
                SizedBox(height: 2),
                Text(
                  'Avez-vous bien retenu la leçon ?',
                  style: TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          ElevatedButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => QuizScreen(quiz: widget.conte.quiz!),
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: CulturalTheme.primaryOcre,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              elevation: 2,
            ),
            child: const Text('Quiz', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  // --- 6. Barre Audio Flottante / Glassmorphism ---
  Widget _buildAudioPlayerBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: const Color(0xF21C1611), // Chocolat noir chaud translucide
        borderRadius: BorderRadius.circular(35),
        border: Border.all(color: const Color(0xFF5A4432).withValues(alpha: 0.5)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.35),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Row(
        children: [
          // Bouton Play/Pause stylisé
          GestureDetector(
            onTap: _toggleAudioPlayback,
            child: Container(
              width: 48,
              height: 48,
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
                      size: 26,
                    ),
            ),
          ),
          const SizedBox(width: 14),

          // Infos audio et curseur
          Expanded(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Écouter (${_mapLanguageCodeToName(_selectedLanguageCodeUI)})',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      '${_formatDuration(_currentPosition)} / ${_formatDuration(_totalDuration)}',
                      style: const TextStyle(color: Colors.white60, fontSize: 10),
                    ),
                  ],
                ),
                SliderTheme(
                  data: SliderTheme.of(context).copyWith(
                    trackHeight: 3,
                    thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 5),
                    overlayShape: const RoundSliderOverlayShape(overlayRadius: 10),
                    activeTrackColor: CulturalTheme.secondaryGold,
                    inactiveTrackColor: Colors.white24,
                    thumbColor: Colors.white,
                  ),
                  child: Slider(
                    value: _totalDuration.inMilliseconds > 0
                        ? (_currentPosition.inMilliseconds / _totalDuration.inMilliseconds).clamp(0.0, 1.0)
                        : 0.0,
                    onChanged: (val) {
                      if (_totalDuration.inMilliseconds > 0) {
                        _audioPlayer.seek(Duration(milliseconds: (val * _totalDuration.inMilliseconds).toInt()));
                      }
                    },
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class AudioByteStream extends StreamAudioSource {
  final Uint8List bytes;
  AudioByteStream(this.bytes) : super(tag: 'AudioFromBytes');

  @override
  Future<StreamAudioResponse> request([int? start, int? end]) async {
    final int effectiveStart = start ?? 0;
    final int effectiveEnd = end ?? bytes.length;
    final int effectiveLength = effectiveEnd - effectiveStart;
    final sublist = bytes.sublist(effectiveStart, effectiveEnd);

    return StreamAudioResponse(
      sourceLength: bytes.length,
      contentLength: effectiveLength,
      offset: effectiveStart,
      contentType: 'audio/mpeg',
      stream: Stream.value(sublist),
    );
  }
}