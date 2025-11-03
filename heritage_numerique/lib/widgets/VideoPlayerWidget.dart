// Fichier: lib/widgets/VideoPlayerWidget.dart

import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

// --- Constantes de Couleurs Globales (utilisées pour la barre de progression) ---
const Color _mainAccentColor = Color(0xFFAA7311);

class VideoPlayerWidget extends StatefulWidget {
  final String videoUrl;

  const VideoPlayerWidget({super.key, required this.videoUrl});

  @override
  State<VideoPlayerWidget> createState() => _VideoPlayerWidgetState();
}

class _VideoPlayerWidgetState extends State<VideoPlayerWidget> {
  late VideoPlayerController _controller;
  late Future<void> _initializeVideoPlayerFuture;
  bool _isPlaying = false;
  bool _isDisposed = false;

  @override
  void initState() {
    super.initState();
    // 1. Initialiser le contrôleur avec l'URL
    _controller = VideoPlayerController.networkUrl(Uri.parse(widget.videoUrl));

    // 2. Initialiser la promesse d'initialisation
    _initializeVideoPlayerFuture = _controller.initialize().then((_) {
      // S'assurer que la première image est affichée
      if (mounted) {
        setState(() {});
      }
    });

    // 3. Ajouter un listener pour mettre à jour l'icône de lecture/pause
    _controller.addListener(_videoListener);
  }

  void _videoListener() {
    // Vérifier si la lecture a commencé ou s'est arrêtée
    if (_controller.value.isPlaying != _isPlaying && mounted) {
      setState(() {
        _isPlaying = _controller.value.isPlaying;
      });
    }

    // Gestion de la fin de la vidéo
    if (_controller.value.position == _controller.value.duration && mounted) {
      // Optionnel : revenir au début
      _controller.seekTo(Duration.zero);
      _controller.pause();
    }
  }

  // 4. Libérer les ressources
  @override
  void dispose() {
    _controller.removeListener(_videoListener);
    _controller.dispose();
    _isDisposed = true; // Marquer comme dispoosé pour éviter les erreurs futures
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_isDisposed) {
      return const SizedBox.shrink(); // Ne rien afficher si le widget est détruit
    }

    return FutureBuilder(
      future: _initializeVideoPlayerFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.done) {
          // Si le contrôleur est initialisé
          if (_controller.value.hasError) {
            return _buildErrorWidget("Erreur de chargement : ${_controller.value.errorDescription ?? 'Inconnu'}", Icons.error);
          }

          return Column(
            children: [
              // 1. Zone du lecteur (Aspect Ratio pour éviter le clignotement)
              AspectRatio(
                aspectRatio: _controller.value.aspectRatio,
                child: VideoPlayer(_controller),
              ),

              // 2. Contrôles (Bouton Play/Pause)
              VideoProgressIndicator(
                _controller,
                allowScrubbing: true,
                padding: const EdgeInsets.symmetric(vertical: 6.0),
                colors: const VideoProgressColors(
                  playedColor: _mainAccentColor,
                  bufferedColor: Colors.white70,
                  backgroundColor: Colors.grey,
                ),
              ),

              // 3. Barre de boutons
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  IconButton(
                    icon: Icon(
                      _isPlaying ? Icons.pause_circle_filled : Icons.play_circle_filled,
                      size: 40,
                      color: _mainAccentColor,
                    ),
                    onPressed: () {
                      if (_controller.value.isInitialized) {
                        // Lecture/Pause
                        _controller.value.isPlaying
                            ? _controller.pause()
                            : _controller.play();
                      }
                    },
                  ),
                ],
              ),
            ],
          );
        } else {
          // Pendant le chargement
          return const Center(
            child: Padding(
              padding: EdgeInsets.all(20.0),
              child: CircularProgressIndicator(color: _mainAccentColor),
            ),
          );
        }
      },
    );
  }

  Widget _buildErrorWidget(String message, IconData icon) {
    return Container(
      alignment: Alignment.center,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
          color: Colors.red.shade50,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.red.shade200)
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: Colors.red, size: 24),
          const SizedBox(width: 10),
          Flexible(child: Text(message, style: const TextStyle(color: Colors.red))),
        ],
      ),
    );
  }
}