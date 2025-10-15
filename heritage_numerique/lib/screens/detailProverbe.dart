// detailProverbe.dart

import 'package:flutter/material.dart';
import 'package:heritage_numerique/screens/proverbe.dart';


// IMPORTANT : Assurez-vous d'importer le fichier contenant la classe ProverbeData.
// Si vous la laissez dans ProverbeCollectionScreen.dart, vous devrez peut-être la déplacer.
// Pour l'instant, supposons que ProverbeData sera importée ici.
// import 'proverbe_data.dart'; // Si vous avez un fichier séparé pour le modèle

// Pour la compilation actuelle, laissons ProverbeData de côté dans ce bloc,
// car elle est définie dans l'autre fichier fourni.

// --- Constantes de Couleurs Spécifiques au Détail ---
const Color _detailContentBg = Color(0x75000000); // Noir, 46% opacité
const Color _detailContentBorder = Color(0xFF49521D);
const Color _detailAccentColor = Color(0xF5FFC107); // Jaune/Or, 96% opacité
const Color _detailOriginColor = Color(0xC7FFC107); // Jaune/Or, 78% opacité
const Color _detailLineColor = Color(0x80FFC107); // Jaune/Or, 50% opacité


class ProverbeDetailScreen extends StatelessWidget {
  // Définition de ProverbeData manquante, mais nous utiliserons celle du fichier de collection
  // pour éviter la redéfinition. Assurez-vous d'importer la classe ProverbeData
  // ou de la définir dans un fichier séparé.
  // Laisser ce code tel quel, en supposant que l'IDE résoudra ProverbeData par l'importation.
  final ProverbeData proverbe;

  const ProverbeDetailScreen({super.key, required this.proverbe});

  final double horizontalPadding = 40.0;
  final double contentVerticalPadding = 20.0;

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      // Reste du code du widget ProverbeDetailScreen (identique à votre première partie de code)
      body: Stack(
        children: [
          // 1. Image de fond (Frame 79)
          Positioned.fill(
            child: Image.asset(
              proverbe.imagePath,
              fit: BoxFit.cover,
            ),
          ),

          // 2. Calque d'assombrissement général (Rectangle 193)
          Positioned.fill(
            child: Container(color: Colors.black.withOpacity(0.2)),
          ),

          // 3. Bouton de Fermeture (Icône 'X')
          Positioned(
            top: 52,
            right: 20,
            child: IconButton(
              icon: const Icon(Icons.close, color: Colors.white, size: 30),
              onPressed: () => Navigator.pop(context),
            ),
          ),

          // 4. Conteneur principal du contenu (Rectangle 194)
          Positioned(
            left: 20,
            right: 20,
            top: 173,
            height: 532,
            child: Container(
              decoration: BoxDecoration(
                color: _detailContentBg,
                border: Border.all(color: _detailContentBorder, width: 1),
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(25),
                  topRight: Radius.circular(25),
                ),
              ),
              child: SingleChildScrollView(
                padding: EdgeInsets.symmetric(horizontal: horizontalPadding - 20, vertical: contentVerticalPadding),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const SizedBox(height: 10),

                    // --- 4.1 Proverbe (Centré) ---
                    Container(
                      width: 288,
                      alignment: Alignment.center,
                      child: Text(
                        '"${proverbe.text}"',
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontFamily: 'Inter',
                          fontWeight: FontWeight.w700,
                          fontSize: 15,
                          height: 1.67,
                          color: Colors.white,
                        ),
                      ),
                    ),

                    const SizedBox(height: 10),

                    // --- 4.2 Origine et Lignes (Centré) ---
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // Ligne Décorative Gauche
                        Container(
                          width: 75,
                          height: 1,
                          margin: const EdgeInsets.only(right: 8),
                          color: _detailLineColor,
                        ),

                        // Origine
                        Text(
                          proverbe.origin,
                          style: TextStyle(
                            fontFamily: 'Inter',
                            fontWeight: FontWeight.w700,
                            fontSize: 12,
                            height: 1.67,
                            color: _detailOriginColor,
                          ),
                        ),

                        // Ligne Décorative Droite
                        Container(
                          width: 77,
                          height: 1,
                          margin: const EdgeInsets.only(left: 8),
                          color: _detailLineColor,
                        ),
                      ],
                    ),

                    const SizedBox(height: 30),

                    // --- 4.3 Titre Signification ---
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        'Signification',
                        style: TextStyle(
                          fontFamily: 'Inter',
                          fontWeight: FontWeight.w700,
                          fontSize: 15,
                          height: 1.33,
                          color: _detailAccentColor,
                        ),
                      ),
                    ),

                    const SizedBox(height: 10),

                    // --- 4.4 Corps de la Signification ---
                    SizedBox(
                      width: 320,
                      child: Text(
                        proverbe.signification,
                        style: const TextStyle(
                          fontFamily: 'Inter',
                          fontWeight: FontWeight.w700,
                          fontSize: 12,
                          height: 2.08,
                          color: Colors.white,
                        ),
                      ),
                    ),

                    SizedBox(height: screenHeight * 0.1),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}