import 'package:flutter/material.dart';
import 'dart:async'; // Nécessaire pour Future
// Importez les services et modèles requis
import '../model/DevinetteModel.dart'; // Import du modèle Devinette
// 💡 CORRECTION: Utilisation du chemin d'import réel que vous avez fourni
// J'ai renommé en 'DevinetteApiService.dart' si c'est le nom du fichier
import '../Service/DevinetteApiService.dart'; // Supposé être le chemin correct
import 'AppDrawer.dart'; // Supposé exister

// --- Constantes de Couleurs Globales ---
const Color _mainAccentColor = Color(0xFFAA7311);
const Color _backgroundColor = Colors.white;
const Color _cardTextColor = Color(0xFF2E2E2E);
const Color _searchBackground = Color(0xFFF7F2E8);
const Color _buttonColor = Color(0xFF7B521A);
const Color _lightCardColor = Color(0xFFF7F2E8);
const Color _tagColor = Color(0xFF808080); // Gris pour les éléments spécifiques aux devinettes

// ------------------------------------------------
// --- ÉCRAN PRINCIPAL : DevinettesDashScreen (Stateful) ---
// ------------------------------------------------

class DevinettesDashScreen extends StatefulWidget {
  final int familyId;

  const DevinettesDashScreen({super.key, required this.familyId});

  @override
  State<DevinettesDashScreen> createState() => _DevinettesDashScreenState();
}

class _DevinettesDashScreenState extends State<DevinettesDashScreen> {
  // Instance du service API
  final DevinetteApiService _apiService = DevinetteApiService();

  // État de chargement et liste des données
  late Future<List<Devinette>> _devinettesFuture;

  @override
  void initState() {
    super.initState();
    // 1. Initialiser le chargement des devinettes
    _devinettesFuture = _fetchData();
  }

  // Méthode pour recharger les devinettes après une création
  void _refreshDevinettes() {
    setState(() {
      _devinettesFuture = _fetchData();
    });
  }

  // Méthode pour charger les devinettes
  Future<List<Devinette>> _fetchData() async {
    try {
      // Utilisez l'ID de famille passé au widget
      return await _apiService.fetchDevinettesByFamily(widget.familyId);
    } catch (e) {
      // En cas d'erreur de chargement
      print("Erreur de chargement des devinettes : $e");
      // Afficher un tableau vide ou relancer l'erreur pour le FutureBuilder
      rethrow;
    }
  }

  // ------------------------------------
  // --- Fonctionnalité de Création (Popup) ---
  // ------------------------------------

  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _questionController = TextEditingController();
  final _answerController = TextEditingController();
  // Catégorie est mise en dur pour l'exemple, à adapter
  final int _idCategorieDefault = 1;

  // Méthode pour afficher le dialogue de création
  void _showCreateRiddleDialog() {
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: const Text('Créer une Nouvelle Devinette'),
          content: SingleChildScrollView(
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  TextFormField(
                    controller: _titleController,
                    decoration: const InputDecoration(labelText: 'Titre (Optionnel)'),
                  ),
                  TextFormField(
                    controller: _questionController,
                    decoration: const InputDecoration(labelText: 'Texte de la Devinette'),
                    maxLines: 3,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Veuillez entrer la question.';
                      }
                      return null;
                    },
                  ),
                  TextFormField(
                    controller: _answerController,
                    decoration: const InputDecoration(labelText: 'Réponse de la Devinette'),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Veuillez entrer la réponse.';
                      }
                      return null;
                    },
                  ),
                  // Vous pouvez ajouter ici des champs pour 'lieu' et 'region'
                ],
              ),
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Annuler', style: TextStyle(color: _tagColor)),
              onPressed: () {
                Navigator.of(dialogContext).pop();
              },
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: _buttonColor),
              child: const Text('Créer', style: TextStyle(color: _backgroundColor)),
              onPressed: () {
                if (_formKey.currentState!.validate()) {
                  _handleCreateRiddle(dialogContext);
                }
              },
            ),
          ],
        );
      },
    );
  }

  // Logique d'envoi à l'API
  void _handleCreateRiddle(BuildContext dialogContext) async {
    Navigator.of(dialogContext).pop(); // Fermer le dialogue immédiatement

    try {
      await _apiService.createDevinette(
        idFamille: widget.familyId,
        idCategorie: _idCategorieDefault, // Catégorie par défaut
        titre: _titleController.text.isNotEmpty ? _titleController.text : 'Nouvelle Devinette',
        texteDevinette: _questionController.text,
        reponseDevinette: _answerController.text,
        // photoDevinetteFile: null, // Pas de support photo dans ce formulaire simple
      );

      // Succès : Afficher un message et recharger la liste
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Devinette créée avec succès!')),
      );
      _refreshDevinettes();
    } catch (e) {
      // Erreur : Afficher un message d'erreur
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erreur lors de la création: ${e.toString()}')),
      );
    } finally {
      // Nettoyer les contrôleurs
      _titleController.clear();
      _questionController.clear();
      _answerController.clear();
    }
  }


  // ------------------------------------
  // --- Widgets de Construction de l'Écran ---
  // ------------------------------------

  Widget _buildCustomHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            icon: const Icon(Icons.menu, color: _cardTextColor, size: 30),
            onPressed: () {
              Scaffold.of(context).openDrawer();
            },
          ),
          const Text(
            'Héritage Numérique',
            style: TextStyle(
              color: _cardTextColor,
              fontWeight: FontWeight.bold,
              fontSize: 20,
            ),
          ),
          const SizedBox(width: 48),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10),
      decoration: BoxDecoration(
        color: _searchBackground,
        borderRadius: BorderRadius.circular(8),
      ),
      child: const TextField(
        decoration: InputDecoration(
          hintText: 'Rechercher une devinette...',
          hintStyle: TextStyle(color: Colors.grey, fontSize: 14),
          border: InputBorder.none,
          prefixIcon: Icon(Icons.search, color: Colors.grey, size: 20),
          contentPadding: EdgeInsets.symmetric(vertical: 12),
        ),
        style: TextStyle(fontSize: 14),
      ),
    );
  }

  // Mise à jour du widget pour appeler la fonction _showCreateRiddleDialog
  Widget _buildCreateButton() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
      child: ElevatedButton.icon(
        onPressed: _showCreateRiddleDialog, // 💡 APPEL DU POPUP
        icon: const Icon(Icons.add, color: _backgroundColor),
        label: const Text(
          'Créer Devinette',
          style: TextStyle(
            color: _backgroundColor,
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: _buttonColor, // Couleur d'accentuation
          padding: const EdgeInsets.symmetric(vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          elevation: 5,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _backgroundColor,
      drawer: AppDrawer(familyId: widget.familyId),
      body: SingleChildScrollView(
        padding: EdgeInsets.only(top: MediaQuery.of(context).padding.top + 10, bottom: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1. En-tête (Menu Burger, Titre)
            Builder(
                builder: (BuildContext innerContext) {
                  return _buildCustomHeader(innerContext);
                }
            ),
            const SizedBox(height: 20),

            // 2. Bouton "Créer Devinette"
            _buildCreateButton(),
            const SizedBox(height: 10),

            // 3. Corps de la page (Titre, Recherche)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Titre de la section Devintettes
                  const Text(
                    'Devinettes mystérieuses',
                    style: TextStyle(
                      color: _cardTextColor,
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Barre de recherche
                  _buildSearchBar(),
                  const SizedBox(height: 20),
                ],
              ),
            ),

            // 4. Zone de Liste des Devinettes (Dynamique)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: FutureBuilder<List<Devinette>>(
                future: _devinettesFuture,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator(color: _mainAccentColor));
                  } else if (snapshot.hasError) {
                    return Center(child: Text('Erreur: ${snapshot.error}. Impossible de charger les devinettes.', textAlign: TextAlign.center));
                  } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return const Center(child: Text('Aucune devinette trouvée pour cette famille.'));
                  }

                  // Données chargées avec succès
                  final List<Devinette> devinettes = snapshot.data!;

                  return ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: devinettes.length,
                    itemBuilder: (context, index) {
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 15.0),
                        // Utiliser le widget mis à jour pour accepter Devinette
                        child: _DevinetteCard(devinette: devinettes[index]),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}


// ------------------------------------------------
// --- WIDGET D'UNE CARTE DE DEVIINETTE (STATEFUL) ---
// ------------------------------------------------

// Remplacement de _RiddleCard par _DevinetteCard et de Riddle par Devinette
class _DevinetteCard extends StatefulWidget {
  final Devinette devinette;

  const _DevinetteCard({required this.devinette});

  @override
  State<_DevinetteCard> createState() => _DevinetteCardState();
}

class _DevinetteCardState extends State<_DevinetteCard> {
  // État pour contrôler l'affichage de la réponse
  bool _showAnswer = false;

  void _toggleAnswerVisibility() {
    setState(() {
      _showAnswer = !_showAnswer;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white, // Fond blanc
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 5,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 1. Question (Icône + Texte de la devinette)
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Petit Conteneur Gris pour l'icône Ampoule
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.grey.shade200, // Gris clair
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.lightbulb_outline, color: _mainAccentColor, size: 20),
              ),
              const SizedBox(width: 10),
              // Texte de la Question
              Expanded(
                // Affiche le champ 'devinette' du modèle Devinette
                child: Text(
                  widget.devinette.devinette,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: _cardTextColor,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 15),

          // 2. Réponse (Affichée conditionnellement)
          if (_showAnswer)
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Conteneur Gris pour la Réponse
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade200, // Gris clair
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    // Affiche le champ 'reponse' du modèle Devinette
                    widget.devinette.reponse,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: _cardTextColor,
                    ),
                  ),
                ),
                const SizedBox(height: 15),
              ],
            ),

          // 3. Bouton Dynamique Afficher/Masquer la Réponse
          GestureDetector(
            onTap: _toggleAnswerVisibility,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                // Conteneur gris avec opacité faible
                color: Colors.grey.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    _showAnswer ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                    color: Colors.grey.shade600,
                    size: 18,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    _showAnswer ? 'Masquer la réponse' : 'Afficher la réponse',
                    style: TextStyle(
                      color: Colors.grey.shade600,
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
