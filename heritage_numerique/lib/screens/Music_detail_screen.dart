import 'package:flutter/material.dart';

// Constantes de Couleurs (à placer idéalement dans un fichier de thèmes global)
const Color _accentColor = Color(0xFFD69301); // Ocre Vif
const Color _cardTextColor = Color(0xFF2E2E2E); // Gris foncé
const Color _backgroundColor = Colors.white; 

class MusicDetailScreen extends StatelessWidget {
  final String musicTitle;
  final String artistName;
  final String description;
  final String audioUrl;
  final String imageUrl;
  final Map<String, dynamic> details;

  const MusicDetailScreen({
    super.key,
    required this.musicTitle,
    required this.artistName,
    required this.description,
    required this.audioUrl,
    required this.imageUrl,
    required this.details,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _backgroundColor,
      // La BottomNavigationBar (avec les icônes Contes, Musique, etc.)
      // devrait être gérée par le widget parent ou un wrapper si elle doit apparaître ici.
      // Je ne l'inclus pas ici pour l'instant car elle n'est pas nécessaire pour le design du contenu.

      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1. En-tête et Lecteur Audio (Partie Supérieure Sombre)
            _buildAudioPlayerHeader(context),
            
            // 2. Section Description et Informations
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Description',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: _cardTextColor),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    // Utiliser le titre pour une description simple si aucune n'est disponible
                    description.isEmpty ? 'Description détaillée de $musicTitle par $artistName.' : description,
                    style: const TextStyle(fontSize: 16, color: _cardTextColor),
                  ),
                  const SizedBox(height: 20),

                  // Bloc d'Informations
                  _buildInformationCard(details),
                  
                  const SizedBox(height: 100), // Espace pour la navigation en bas si elle est utilisée
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  // --- Widgets de Construction ---

  /// Construit la section du lecteur audio avec l'image, le titre et les contrôles.
  Widget _buildAudioPlayerHeader(BuildContext context) {
    return Container(
      height: 400, // Hauteur fixe pour le lecteur
      width: double.infinity,
      decoration: const BoxDecoration(
        color: Colors.black, // Fond noir comme dans l'image
        // Optionnel: un dégradé subtil peut améliorer le look
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Color(0xFF1E1E1E), // Noir très foncé
            Color(0xFF0A0A0A), // Noir pur
          ],
        ),
      ),
      child: Stack(
        children: [
          // Bouton de retour et titre de l'AppBar
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: AppBar(
              backgroundColor: Colors.transparent,
              elevation: 0,
              leading: Padding(
                padding: const EdgeInsets.only(left: 8.0),
                child: Container(
                  decoration: BoxDecoration(color: Colors.black.withOpacity(0.2), shape: BoxShape.circle),
                  child: IconButton(
                    icon: Icon(Icons.arrow_back, color: Colors.white.withOpacity(0.9)),
                    onPressed: () => Navigator.pop(context),
                  ),
                ),
              ),
              centerTitle: true,
              title: const Text('Musiques', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
            ),
          ),
          
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const SizedBox(height: 50), // Décalage pour l'AppBar
                
                // Image/Avatar de l'artiste ou de l'instrument
                ClipRRect(
                  borderRadius: BorderRadius.circular(10.0),
                  child: Image.asset(
                    imageUrl, 
                    height: 150, 
                    width: 150, 
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) => Container(
                      height: 150, width: 150, color: Colors.grey[800],
                      child: const Icon(Icons.person, color: Colors.white70, size: 80),
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                
                // Titre
                Text(
                  musicTitle,
                  style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white),
                ),
                const SizedBox(height: 4),
                
                // Artiste
                Text(
                  artistName,
                  style: TextStyle(fontSize: 16, color: Colors.white.withOpacity(0.7)),
                ),
                const SizedBox(height: 20),
                
                // Barre de Progression (Simulée)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 40.0),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('2:17', style: TextStyle(color: _accentColor.withOpacity(0.9), fontSize: 12)), // Temps actuel simulé
                          Text('3:35', style: TextStyle(color: Colors.white.withOpacity(0.7), fontSize: 12)), // Durée totale simulée
                        ],
                      ),
                      const LinearProgressIndicator(
                        value: 0.6, // 60% de progression
                        valueColor: AlwaysStoppedAnimation<Color>(_accentColor),
                        backgroundColor: Colors.grey,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),

                // Contrôles de Lecture
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    IconButton(icon: const Icon(Icons.skip_previous, size: 40, color: Colors.white70), onPressed: () {}),
                    const SizedBox(width: 20),
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(color: _accentColor, shape: BoxShape.circle),
                      child: const Icon(Icons.play_arrow, color: Colors.white, size: 40),
                    ),
                    const SizedBox(width: 20),
                    IconButton(icon: const Icon(Icons.skip_next, size: 40, color: Colors.white70), onPressed: () {}),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Construit la carte des informations (Nom et Langue).
  Widget _buildInformationCard(Map<String, dynamic> details) {
    return Container(
      padding: const EdgeInsets.all(16.0),
      margin: const EdgeInsets.symmetric(vertical: 20.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        // Utilise un BoxShadow pour un effet de carte subtil
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
        // Ajout d'un dégradé subtil pour imiter l'effet de l'image
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.white,
            Colors.grey.shade100,
          ],
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Informations',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: _cardTextColor),
          ),
          const Divider(color: Colors.grey, height: 20),
          
          _buildDetailRow('Nom:', details['nom'] ?? 'Inconnu'),
          _buildDetailRow('Langue:', details['langue'] ?? 'Inconnu'),
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
            label,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: _cardTextColor),
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