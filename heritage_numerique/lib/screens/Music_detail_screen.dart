import 'package:flutter/material.dart';

// Constantes de Couleurs
const Color _accentColor = Color(0xFFD69301); // Ocre Vif
const Color _cardTextColor = Color(0xFF2E2E2E); // Gris foncé
const Color _backgroundColor = Colors.white;
const Color _revealColor = Color(0xFF4CAF50); // Vert pour révéler

/// Écran de Détail pour les Devinettes.
/// NOTE: La classe garde le nom 'MusicDetailScreen' selon la demande explicite
/// de l'utilisateur, mais elle est convertie en StatefulWidget pour gérer la
/// révélation de la réponse.
class MusicDetailScreen extends StatefulWidget {
  // Propriétés adaptées au contexte des Devinettes
  final String titre;
  final String devinette; // Remplacement de 'description'
  final String reponse;   // Remplacement de 'audioUrl' (réponse de l'énigme)
  final String conteur;   // Remplacement de 'artistName'
  final String imageUrl;  // Remplacé par une icône si non utilisé
  final Map<String, dynamic> details; // Utilisé pour le lieu/langue

  const MusicDetailScreen({
    super.key,
    required this.titre,
    required this.devinette,
    required this.reponse,
    required this.conteur,
    required this.imageUrl,
    required this.details,
  });

  @override
  State<MusicDetailScreen> createState() => _MusicDetailScreenState();
}

class _MusicDetailScreenState extends State<MusicDetailScreen> {
  bool _isRevealed = false;

  void _toggleReveal() {
    setState(() {
      _isRevealed = !_isRevealed;
    });
  }

  // --- Widgets de Construction ---

  @override
  Widget build(BuildContext context) {
    // Extraction du lieu si disponible (supposant qu'il est dans 'details')
    final String lieu = widget.details['lieu'] ?? 'Lieu non spécifié';

    return Scaffold(
      backgroundColor: _backgroundColor,
      appBar: AppBar(
        title: Text(widget.titre, style: const TextStyle(color: _cardTextColor)),
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: _accentColor),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // 1. Bloc de la Devinette (Remplaçant l'en-tête Audio)
            _buildRiddleBlock(),
            const SizedBox(height: 30),

            // 2. Bouton Révéler la Réponse
            _buildRevealButton(),
            const SizedBox(height: 30),

            // 3. Bloc de la Réponse (Conditionnel)
            if (_isRevealed) _buildAnswerBlock(),

            const SizedBox(height: 30),

            // 4. Informations additionnelles (Conteur et Lieu)
            _buildInformationCard(widget.conteur, lieu),

            const SizedBox(height: 50),
          ],
        ),
      ),
    );
  }

  /// Construit le bloc principal de l'énigme.
  Widget _buildRiddleBlock() {
    return Container(
      padding: const EdgeInsets.all(20.0),
      decoration: BoxDecoration(
        color: const Color(0xFFF0EAE0),
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.quiz_outlined, color: _accentColor, size: 24),
              const SizedBox(width: 8),
              Text(
                'Énigme: ${widget.titre}',
                style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: _accentColor
                ),
              ),
            ],
          ),
          const Divider(color: Colors.grey, height: 20),
          Text(
            widget.devinette,
            style: const TextStyle(
              fontSize: 16,
              height: 1.5,
              color: _cardTextColor,
              fontStyle: FontStyle.italic,
            ),
            textAlign: TextAlign.justify,
          ),
        ],
      ),
    );
  }

  /// Construit le bouton de bascule pour révéler/cacher la réponse.
  Widget _buildRevealButton() {
    return ElevatedButton.icon(
      onPressed: _toggleReveal,
      icon: Icon(_isRevealed ? Icons.visibility_off : Icons.visibility, color: Colors.white),
      label: Text(
        _isRevealed ? 'Cacher la Réponse' : 'Révéler la Réponse',
        style: const TextStyle(fontSize: 18, color: Colors.white, fontWeight: FontWeight.bold),
      ),
      style: ElevatedButton.styleFrom(
        backgroundColor: _isRevealed ? Colors.red.shade700 : _revealColor,
        padding: const EdgeInsets.symmetric(vertical: 15),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        elevation: 5,
      ),
    );
  }

  /// Construit le bloc affichant la réponse révélée.
  Widget _buildAnswerBlock() {
    return Container(
      padding: const EdgeInsets.all(20.0),
      decoration: BoxDecoration(
        color: _revealColor.withOpacity(0.1),
        border: Border.all(color: _revealColor, width: 2),
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(
            color: _revealColor.withOpacity(0.2),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'La Réponse est:',
            style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: _revealColor
            ),
          ),
          const Divider(color: _revealColor, height: 20),
          Center(
            child: Text(
              widget.reponse,
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w900,
                color: _cardTextColor,
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }

  /// Construit la carte des informations additionnelles (Conteur et Lieu).
  Widget _buildInformationCard(String conteur, String lieu) {
    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.grey.shade300),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Contexte Culturel',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: _cardTextColor),
          ),
          const Divider(color: Colors.grey, height: 20),

          _buildDetailRow(Icons.person, 'Conteur', conteur),
          _buildDetailRow(Icons.location_on, 'Lieu d\'Origine', lieu),
        ],
      ),
    );
  }

  /// Ligne pour afficher une information avec une icône.
  Widget _buildDetailRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        children: [
          Icon(icon, size: 20, color: _accentColor),
          const SizedBox(width: 8),
          Text(
            '$label:',
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: _cardTextColor),
          ),
          const Spacer(),
          Expanded(
            child: Text(
              value,
              textAlign: TextAlign.right,
              style: TextStyle(fontSize: 16, color: _cardTextColor.withOpacity(0.7)),
            ),
          ),
        ],
      ),
    );
  }
}