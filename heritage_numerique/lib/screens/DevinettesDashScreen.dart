// Fichier: lib/screens/DevinettesDashScreen.dart (CORRIGÉ avec navigation)

import 'package:flutter/material.dart';
import 'dart:async'; // Nécessaire pour Future
// Importez les services et modèles requis
import '../model/DevinetteModel.dart';
import '../Service/DevinetteApiService.dart';
import 'AppDrawer.dart';
// 💡 NOUVEL IMPORT : La page de détail que nous allons créer
import 'DevinetteDetailPage.dart';

// --- Constantes de Couleurs Globales ---
const Color _mainAccentColor = Color(0xFFAA7311);
const Color _backgroundColor = Colors.white;
const Color _cardTextColor = Color(0xFF2E2E2E);
const Color _searchBackground = Color(0xFFF7F2E8);
const Color _buttonColor = Color(0xFF7B521A);
const Color _tagColor = Color(0xFF808080);
const Color _pendingColor = Colors.orange;
const Color _publishedColor = Colors.green;
const Color _rejectedColor = Color(0xFFD32F2E);


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

  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _questionController = TextEditingController();
  final _answerController = TextEditingController();
  final int _idCategorieDefault = 1;


  @override
  void initState() {
    super.initState();
    _devinettesFuture = _fetchData();
  }

  Future<void> _refreshDevinettes() async {
    setState(() {
      _devinettesFuture = _fetchData();
    });
    await _devinettesFuture;
  }

  Future<List<Devinette>> _fetchData() async {
    try {
      return await _apiService.fetchDevinettesByFamily(widget.familyId);
    } catch (e) {
      print("Erreur de chargement des devinettes : $e");
      rethrow;
    }
  }

  // ------------------------------------
  // --- Fonctionnalité de Création (Popup) ---
  // ------------------------------------

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

  void _handleCreateRiddle(BuildContext dialogContext) async {
    Navigator.of(dialogContext).pop();

    try {
      await _apiService.createDevinette(
        idFamille: widget.familyId,
        idCategorie: _idCategorieDefault,
        titre: _titleController.text.isNotEmpty ? _titleController.text : 'Nouvelle Devinette',
        texteDevinette: _questionController.text,
        reponseDevinette: _answerController.text,
      );

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Devinette créée avec succès!')),
      );
      _refreshDevinettes();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erreur lors de la création: ${e.toString()}')),
      );
    } finally {
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

  Widget _buildCreateButton() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
      child: ElevatedButton.icon(
        onPressed: _showCreateRiddleDialog,
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
          backgroundColor: _buttonColor,
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
      body: RefreshIndicator(
        onRefresh: _refreshDevinettes,
        color: _mainAccentColor,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
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

                    final List<Devinette> devinettes = snapshot.data!;

                    return ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: devinettes.length,
                      itemBuilder: (context, index) {
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 15.0),
                          child: _DevinetteCard(
                            devinette: devinettes[index],
                            apiService: _apiService,
                            onActionComplete: _refreshDevinettes,
                          ),
                        );
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}


// ------------------------------------------------
// --- WIDGET D'UNE CARTE DE DEVIINETTE (STATEFUL) ---
// ------------------------------------------------

class _DevinetteCard extends StatefulWidget {
  final Devinette devinette;
  final DevinetteApiService apiService;
  final VoidCallback onActionComplete;

  const _DevinetteCard({
    required this.devinette,
    required this.apiService,
    required this.onActionComplete,
  });

  @override
  State<_DevinetteCard> createState() => _DevinetteCardState();
}

class _DevinetteCardState extends State<_DevinetteCard> {
  bool _showAnswer = false;
  late String _currentApiStatus;
  bool _isRequesting = false;


  @override
  void initState() {
    super.initState();
    _currentApiStatus = (widget.devinette.statut ?? 'BROUILLON').toUpperCase();
  }

  @override
  void didUpdateWidget(covariant _DevinetteCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.devinette.statut != widget.devinette.statut) {
      _currentApiStatus = (widget.devinette.statut ?? 'BROUILLON').toUpperCase();
    }
  }


  // --- Logique de la demande de publication ---
  void _requestPublication() async {
    if (!mounted || _isRequesting) return;

    setState(() {
      _isRequesting = true;
    });

    try {
      final responseMap = await widget.apiService.requestPublication(contenuId: widget.devinette.id!);
      final String newStatus = responseMap['newStatus'];

      if (mounted) {
        setState(() {
          _currentApiStatus = newStatus.toUpperCase();
          _isRequesting = false;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Demande de publication réussie. Statut: $newStatus.'),
            backgroundColor: Colors.green,
          ),
        );

        widget.onActionComplete();
      }

    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Échec de la demande: ${e.toString().replaceFirst('Exception: ', '')}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isRequesting = false;
        });
      }
    }
  }

  void _toggleAnswerVisibility() {
    setState(() {
      _showAnswer = !_showAnswer;
    });
  }

  // --- Affichage du Badge de Statut ---
  Widget _buildStatusBadge() {
    Color color;
    String text;
    IconData icon;
    final String status = _currentApiStatus;

    switch (status) {
      case 'BROUILLON':
        color = Colors.grey.shade400;
        text = 'Brouillon';
        icon = Icons.edit;
        break;
      case 'EN_ATTENTE':
        color = _pendingColor;
        text = 'En Attente';
        icon = Icons.schedule;
        break;
      case 'PUBLIE':
        color = _publishedColor;
        text = 'Publié';
        icon = Icons.check_circle;
        break;
      case 'REJETE':
        color = _rejectedColor;
        text = 'Rejeté';
        icon = Icons.cancel;
        break;
      default:
        color = Colors.grey;
        text = 'Inconnu';
        icon = Icons.help_outline;
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withOpacity(0.15),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: color, width: 0.5),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: color),
          const SizedBox(width: 4),
          Text(
            text,
            style: TextStyle(
              color: color,
              fontSize: 10,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  // --- Construction du Bouton d'Action ---
  Widget _buildActionButton() {
    if (_isRequesting) {
      return SizedBox(
          width: 15,
          height: 15,
          child: CircularProgressIndicator(color: _mainAccentColor, strokeWidth: 2)
      );
    }

    if (_currentApiStatus == 'BROUILLON') {
      return ElevatedButton.icon(
        onPressed: _requestPublication,
        icon: const Icon(Icons.send, color: Colors.white, size: 12),
        label: const Text(
          'Publier',
          style: TextStyle(fontSize: 10, color: Colors.white, fontWeight: FontWeight.bold),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: _mainAccentColor,
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
          elevation: 0,
        ),
      );
    }

    return const SizedBox.shrink();
  }

  // ------------------------------------------------------------------
  // 💡 NOUVELLE MÉTHODE DE NAVIGATION
  // ------------------------------------------------------------------
  void _navigateToDetail(BuildContext context) {
    // Si la devinette n'est pas publiée, on permet la modification (ou la vue)
    // Si le statut est "PUBLIE", on permet uniquement la consultation détaillée.
    Navigator.push(
      context,
      MaterialPageRoute(
        // Navigation vers la page de détail, en passant l'objet Devinette complet
        builder: (context) => DevinetteDetailPage(devinette: widget.devinette),
      ),
      // 💡 Attendre le retour de la page de détail pour rafraîchir la liste
    ).then((_) {
      widget.onActionComplete();
    });
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector( // 💡 Ajout du GestureDetector pour rendre la carte cliquable
      onTap: () => _navigateToDetail(context), // Appel de la fonction de navigation
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
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
                    color: Colors.grey.shade200,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(Icons.lightbulb_outline, color: _mainAccentColor, size: 20),
                ),
                const SizedBox(width: 10),
                // Texte de la Question
                Expanded(
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
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade200,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
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

            // 3. LIGNE ACTION : Bouton Afficher/Masquer + Statut + Bouton Publier
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // 3.1 Bouton Afficher/Masquer la Réponse
                // ⚠️ On utilise un GestureDetector séparé pour s'assurer que l'action ne déclenche pas la navigation.
                GestureDetector(
                  onTap: _toggleAnswerVisibility,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
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
                          _showAnswer ? 'Masquer' : 'Réponse',
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

                // 3.2 Statut et Bouton de Publication (Alignés à droite)
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _buildStatusBadge(),
                    const SizedBox(width: 8),
                    _buildActionButton(),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}