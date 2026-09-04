import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import '../widgets/cultural_theme.dart';

class PodcastPlayerScreen extends StatefulWidget {
  final String title;
  final String category;
  final String subtitle;
  final String image;
  final String duration;

  const PodcastPlayerScreen({
    super.key,
    required this.title,
    required this.category,
    required this.subtitle,
    required this.image,
    required this.duration,
  });

  @override
  State<PodcastPlayerScreen> createState() => _PodcastPlayerScreenState();
}

class _PodcastPlayerScreenState extends State<PodcastPlayerScreen> {
  final AudioPlayer _player = AudioPlayer();
  bool _isPlaying = false;
  Duration _position = Duration.zero;
  Duration _total = const Duration(minutes: 14, seconds: 30);
  String _selectedLang = 'fr';
  double _speed = 1.0;

  final List<String> _langs = ['fr', 'en', 'bm'];

  @override
  void initState() {
    super.initState();
    _player.playerStateStream.listen((state) {
      if (mounted) {
        setState(() {
          _isPlaying = state.playing && state.processingState != ProcessingState.completed;
        });
      }
    });

    _player.positionStream.listen((pos) {
      if (mounted) {
        setState(() {
          _position = pos;
        });
      }
    });
  }

  @override
  void dispose() {
    _player.dispose();
    super.dispose();
  }

  String _mapLanguageName(String code) {
    switch (code) {
      case 'fr': return 'Français';
      case 'bm': return 'Bambara';
      case 'en': return 'English';
      default: return code;
    }
  }

  String _formatDuration(Duration d) {
    final m = d.inMinutes.remainder(60).toString().padLeft(2, '0');
    final s = d.inSeconds.remainder(60).toString().padLeft(2, '0');
    return '$m:$s';
  }

  void _togglePlay() {
    setState(() {
      _isPlaying = !_isPlaying;
    });
  }

  void _cycleSpeed() {
    setState(() {
      if (_speed == 1.0) {
        _speed = 1.25;
      } else if (_speed == 1.25) {
        _speed = 1.5;
      } else {
        _speed = 1.0;
      }
      _player.setSpeed(_speed);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF141210), // Fond sombre immersif selon Figma
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
        centerTitle: true,
        title: Text(
          widget.category.toUpperCase(),
          style: const TextStyle(
            color: CulturalTheme.primaryOcre,
            fontSize: 12,
            fontWeight: FontWeight.bold,
            letterSpacing: 1.5,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.share, color: Colors.white),
            onPressed: () {},
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 10.0),
        child: Column(
          children: [
            // Grande jaquette avec lueur chaleureuse
            Container(
              height: 280,
              width: double.infinity,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(24),
                image: DecorationImage(
                  image: AssetImage(widget.image),
                  fit: BoxFit.cover,
                ),
                boxShadow: [
                  BoxShadow(
                    color: CulturalTheme.primaryDarkOcre.withOpacity(0.3),
                    blurRadius: 20,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(24),
                  gradient: LinearGradient(
                    colors: [Colors.transparent, Colors.black.withOpacity(0.7)],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Titre & Sous-titre
            Text(
              widget.title,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 22,
                fontWeight: FontWeight.bold,
                height: 1.3,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              widget.subtitle,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Colors.white60,
                fontSize: 13,
                height: 1.4,
              ),
            ),
            const SizedBox(height: 20),

            // Sélecteur de langue en pilules
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: _langs.map((lang) {
                final isSelected = lang == _selectedLang;
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4.0),
                  child: InkWell(
                    onTap: () => setState(() => _selectedLang = lang),
                    borderRadius: BorderRadius.circular(16),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                      decoration: BoxDecoration(
                        color: isSelected ? CulturalTheme.primaryOcre : Colors.white12,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: isSelected ? CulturalTheme.primaryOcre : Colors.white24,
                        ),
                      ),
                      child: Text(
                        _mapLanguageName(lang),
                        style: TextStyle(
                          color: isSelected ? Colors.black : Colors.white,
                          fontSize: 12,
                          fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                        ),
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 30),

            // Barre de progression
            SliderTheme(
              data: SliderTheme.of(context).copyWith(
                trackHeight: 4,
                thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 7),
                activeTrackColor: CulturalTheme.primaryOcre,
                inactiveTrackColor: Colors.white24,
                thumbColor: CulturalTheme.primaryOcre,
                overlayColor: CulturalTheme.primaryOcre.withOpacity(0.2),
              ),
              child: Slider(
                value: (_position.inSeconds / _total.inSeconds).clamp(0.0, 1.0),
                onChanged: (val) {
                  setState(() {
                    _position = Duration(seconds: (val * _total.inSeconds).toInt());
                  });
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(_formatDuration(_position), style: const TextStyle(color: Colors.white60, fontSize: 12)),
                  Text(_formatDuration(_total), style: const TextStyle(color: Colors.white60, fontSize: 12)),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Commandes du lecteur
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                TextButton(
                  onPressed: _cycleSpeed,
                  child: Text(
                    '${_speed}x',
                    style: const TextStyle(color: CulturalTheme.primaryOcre, fontWeight: FontWeight.bold, fontSize: 13),
                  ),
                ),
                const SizedBox(width: 14),
                IconButton(
                  onPressed: () {
                    setState(() {
                      final newSec = (_position.inSeconds - 10).clamp(0, _total.inSeconds);
                      _position = Duration(seconds: newSec);
                    });
                  },
                  icon: const Icon(Icons.replay_10, color: Colors.white, size: 30),
                ),
                const SizedBox(width: 16),
                // Gros bouton Play / Pause
                InkWell(
                  onTap: _togglePlay,
                  child: Container(
                    width: 68,
                    height: 68,
                    decoration: BoxDecoration(
                      color: CulturalTheme.primaryOcre,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: CulturalTheme.primaryOcre.withOpacity(0.4),
                          blurRadius: 16,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Icon(
                      _isPlaying ? Icons.pause : Icons.play_arrow,
                      color: Colors.black,
                      size: 38,
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                IconButton(
                  onPressed: () {
                    setState(() {
                      final newSec = (_position.inSeconds + 30).clamp(0, _total.inSeconds);
                      _position = Duration(seconds: newSec);
                    });
                  },
                  icon: const Icon(Icons.forward_30, color: Colors.white, size: 30),
                ),
                const SizedBox(width: 14),
                IconButton(
                  onPressed: () {},
                  icon: const Icon(Icons.playlist_play, color: Colors.white70, size: 28),
                ),
              ],
            ),
            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }
}
