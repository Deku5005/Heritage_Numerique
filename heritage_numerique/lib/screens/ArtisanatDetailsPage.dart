// Fichier: lib/screens/ArtisanatDetailPage.dart

import 'package:flutter/material.dart';
import '../model/ArtisanatModel.dart'; // Assurez-vous que le chemin est correct

// 💡 Importation du nouveau widget vidéo
import '../widgets/VideoPlayerWidget.dart';

// --- Constantes de Couleurs Globales ---
const Color _mainAccentColor = Color(0xFFAA7311);
const Color _backgroundColor = Colors.white;
const Color _cardTextColor = Color(0xFF2E2E2E);
const Color _buttonColor = Color(0xFF7B521A);

// Constante manquante ajoutée
const Color _lightCardColor = Color(0xFFF7F2E8);

class ArtisanatDetailPage extends StatelessWidget {
  final Artisanat artisanat;

  const ArtisanatDetailPage({super.key, required this.artisanat});

  // Widget pour afficher une section d'information
  Widget _buildInfoSection(String title, String? content, {IconData? icon}) {
    if (content == null || content.isEmpty) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.only(bottom: 15.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
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
    final String auteurNomComplet = '${artisanat.prenomAuteur} ${artisanat.nomAuteur}';
    final String dateCreation = '${artisanat.dateCreation.day}/${artisanat.dateCreation.month}/${artisanat.dateCreation.year}';

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
          if (artisanat.lieu != null && artisanat.lieu!.isNotEmpty)
            _buildDetailRow(Icons.location_on, "Lieu", "${artisanat.lieu}, ${artisanat.region}"),
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

  @override
  Widget build(BuildContext context) {
    // URL de la photo principale (première de la liste ou vide)
    final String mainImageUrl = (artisanat.urlPhotos.isNotEmpty)
        ? artisanat.urlPhotos.first
        : 'assets/images/placeholder_artisanat.png'; // Utilisez votre propre placeholder

    return Scaffold(
      backgroundColor: _backgroundColor,
      appBar: AppBar(
        title: Text(artisanat.titre, style: const TextStyle(color: _cardTextColor, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        iconTheme: const IconThemeData(color: _cardTextColor),
        elevation: 0,
      ),
      body: SingleChildScrollView(
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

            // --- 2. Titre et Description Courte ---
            Text(
              artisanat.titre,
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w900, color: _cardTextColor),
            ),
            const SizedBox(height: 10),

            _buildAuthorInfo(),
            const SizedBox(height: 20),

            // --- 3. Description Longue / Détails ---
            _buildInfoSection(
                "Description et Détails",
                artisanat.description,
                icon: Icons.notes
            ),

            // --- 4. Vidéo (Si disponible) ---
            if (artisanat.urlVideo != null && artisanat.urlVideo!.isNotEmpty)
              _buildVideoSection(context, artisanat.urlVideo!),

            // --- 5. Autres photos (Si disponibles) ---
            if (artisanat.urlPhotos.length > 1)
              _buildOtherPhotosSection(artisanat.urlPhotos.sublist(1)),

            const SizedBox(height: 50),
          ],
        ),
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
            // 💡 Remplacement du conteneur statique par le lecteur vidéo
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