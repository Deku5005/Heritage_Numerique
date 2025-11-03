// Fichier: lib/screens/ProverbeDetailPage.dart (Avec conteneurs totalement transparents en bas)

import 'package:flutter/material.dart';
import '../model/PrvebeModel.dart'; // Import du modèle dynamique (en supposant ProverbeModel.dart)

// --- Constantes de Couleurs ---
const Color _mainAccentColor = Color(0xFFAA7311); // Jaune/Or
const String _defaultPlaceholder = 'assets/images/Djata.jpg'; // Placeholder générique
// Nouvelle constante pour l'image de marque
const String _brandImage = 'assets/images/Acceuil1.png';

class ProverbeDetailPage extends StatelessWidget {
  final Proverbe proverbe; // Utilise le modèle Proverbe dynamique

  const ProverbeDetailPage({super.key, required this.proverbe});

  // Détermine si l'URL de la photo est un lien réseau ou un asset local
  bool get _isNetworkImage => proverbe.urlPhoto != null && proverbe.urlPhoto!.startsWith('http');

  // Obtient l'URL ou le chemin de l'image (utilise un placeholder si non disponible)
  String get _imageUrl => proverbe.urlPhoto ?? _defaultPlaceholder;

  // Widget qui gère l'affichage de l'image (Asset ou Network)
  Widget _buildImageWidget({required double width, required double height, BoxFit fit = BoxFit.cover}) {
    if (_isNetworkImage) {
      return Image.network(
        _imageUrl,
        // En laissant ces attributs, l'image pourrait ne pas s'étendre
        // Nous les retirons pour laisser Positioned.fill agir, comme testé précédemment.
        fit: fit,
        // Afficher le placeholder générique en cas d'échec du chargement réseau
        errorBuilder: (context, error, stackTrace) {
          print("ERREUR DÉTAIL PROVERBE (URL: $_imageUrl): $error");
          // Conserver width/height ici pour le placeholder (fallback)
          return Image.asset(
            _defaultPlaceholder,
            width: width,
            height: height,
            fit: fit,
          );
        },
        loadingBuilder: (context, child, loadingProgress) {
          if (loadingProgress == null) return child;
          // Indicateur de chargement pour les images réseau (conserver width/height ici)
          return Container(
            width: width, height: height,
            color: Colors.black12,
            child: const Center(child: CircularProgressIndicator(color: _mainAccentColor, strokeWidth: 2)),
          );
        },
      );
    } else {
      // Asset local ou le placeholder par défaut
      return Image.asset(
        _imageUrl,
        // Retrait des attributs width et height
        fit: fit,
        // Placeholder si l'asset spécifié n'existe pas
        errorBuilder: (context, error, stackTrace) => Image.asset(
          _defaultPlaceholder,
          width: width,
          height: height,
          fit: fit,
        ),
      );
    }
  }

  // Fonction utilitaire pour créer les conteneurs opaques vides (maintenant transparents)
  Widget _buildBlackSpacerContainer(String id) {
    return Container(
      // Padding pour donner une hauteur visible au conteneur vide
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
      // Couleur noir avec opacité à 0.0 (totalement transparent)
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.0), // TOTALEMENT TRANSPARENT
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.transparent), // Pas de bordure visible
      ),
      child: const Center(
        // Remplacer le contenu par un SizedBox vide pour garantir l'absence d'écriture
        child: SizedBox(height: 14),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Construction de la chaîne d'information facultative (Auteur, Lieu, etc.)
    final String authorInfo = (proverbe.prenomAuteur != null || proverbe.nomAuteur != null)
        ? 'Posté par: ${proverbe.prenomAuteur ?? ''} ${proverbe.nomAuteur ?? ''}'
        : '';

    final String locationInfo = (proverbe.lieu != null && proverbe.lieu!.isNotEmpty)
        ? 'Lieu: ${proverbe.lieu}'
        : '';

    final String fullInfo = [authorInfo, locationInfo].where((s) => s.isNotEmpty).join(' | ');

    // Récupérer la taille de l'écran une seule fois pour la passer aux fonctions
    final double screenWidth = MediaQuery.of(context).size.width;
    final double screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      body: Stack(
        children: <Widget>[
          // 1. Image de fond (Full Screen - Utilise Positioned.fill et BoxFit.cover)
          Positioned.fill(
            child: _buildImageWidget(
              // Passage des dimensions de l'écran, utilisées uniquement pour les conteneurs de fallback/loading
              width: screenWidth,
              height: screenHeight,
              fit: BoxFit.cover,
            ),
          ),

          // 2. Grille de fond pour le dégradé sombre/opacité (noir avec 55% d'opacité)
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
                // Espace pour la barre de statut
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
                      // Titre / Proverbe (texteProverbe)
                      Text(
                        '«${proverbe.proverbe}»',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 22,
                          fontStyle: FontStyle.italic,
                          fontWeight: FontWeight.bold,
                          height: 1.4,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 15),

                      // Sous-titre (Origine)
                      Text(
                        proverbe.origine,
                        style: TextStyle(
                          color: _mainAccentColor, // Jaune
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
                          color: _mainAccentColor, // Jaune
                          fontSize: 20,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      const SizedBox(height: 10),

                      // Description / Signification (significationProverbe)
                      Text(
                        proverbe.signification,
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

                const SizedBox(height: 20),

                // --- CONTENEUR TRANSPARENT 1 (Ancien Mali) ---
                _buildBlackSpacerContainer("Conteneur 1"),
                // --- FIN CONTENEUR TRANSPARENT 1 ---

                const SizedBox(height: 10),

                // --- CONTENEUR TRANSPARENT 2 ---
                _buildBlackSpacerContainer("Conteneur 2"),
                // --- FIN CONTENEUR TRANSPARENT 2 ---

                const SizedBox(height: 10),

                // --- CONTENEUR TRANSPARENT 3 ---
                _buildBlackSpacerContainer("Conteneur 3"),
                // --- FIN CONTENEUR TRANSPARENT 3 ---

                const SizedBox(height: 10),

                // --- CONTENEUR TRANSPARENT 4 ---
                _buildBlackSpacerContainer("Conteneur 4"),
                // --- FIN CONTENEUR TRANSPARENT 4 ---

                const SizedBox(height: 10),

                // --- NOUVEAU CONTENEUR TRANSPARENT 5 ---
                _buildBlackSpacerContainer("Conteneur 5"),
                // --- FIN NOUVEAU CONTENEUR TRANSPARENT 5 ---

                const SizedBox(height: 10),

                // --- NOUVEAU CONTENEUR TRANSPARENT 6 ---
                _buildBlackSpacerContainer("Conteneur 6"),
                // --- FIN NOUVEAU CONTENEUR TRANSPARENT 6 ---

                const SizedBox(height: 30),

                // --- CONTENEUR DE MARQUE (MODIFIÉ en transparent) ---
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.0), // TOTALEMENT TRANSPARENT
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.transparent), // Bordure transparente
                  ),
                  child: const Column(
                    children: [
                      SizedBox(height: 50), // Hauteur conservée
                    ],
                  ),
                ),
                // --- FIN CONTENEUR DE MARQUE MODIFIÉ ---

                const SizedBox(height: 50), // Espace final pour le scroll

              ],
            ),
          ),

          // 4. Bouton de Fermeture (X)
          Positioned(
            top: MediaQuery.of(context).padding.top + 10,
            right: 10,
            child: IconButton(
              icon: const Icon(Icons.close, color: Colors.white, size: 30),
              onPressed: () => Navigator.of(context).pop(), // Ferme l'écran
            ),
          ),
        ],
      ),
    );
  }
}
