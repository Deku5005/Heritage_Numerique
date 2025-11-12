import 'package:flutter/material.dart';
import '../widgets/bottom_navigation_widget.dart'; // Assurez-vous que ce widget existe
import '../model/Devinette1.dart'; // Importation du modèle Devinette
import '../Service/DevinetteService1.dart'; // Importation du service Devinette
import 'Music_detail_screen.dart'; // Écran de détail adapté aux Devinettes

/// Écran affichant la liste des Devinettes.
/// La classe garde le nom 'MusicScreen' mais est adaptée aux Devinettes.
class MusicScreen extends StatefulWidget {
  const MusicScreen({super.key});

  @override
  State<MusicScreen> createState() => _MusicScreenState();
}

class _MusicScreenState extends State<MusicScreen> {
  // Constantes de Couleurs
  static const Color _accentColor = Color(0xFFD69301); // Ocre Vif
  static const Color _cardTextColor = Color(0xFF2E2E2E);
  static const Color _backgroundColor = Colors.white;

  // Déclaration des états et du service
  // NOTE : Ceci est un mock pour la démonstration. Le service réel doit être implémenté.
  final DevinetteService1 _devinetteService = DevinetteService1();
  List<Devinette1> _devinettes = [];
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _fetchDevinettes();
  }

  /// Fonction de récupération des données
  Future<void> _fetchDevinettes() async {
    // Simulation du chargement et de la récupération de données
    await Future.delayed(const Duration(seconds: 1));
    try {
      final data = await _devinetteService.getDevinettes();
      setState(() {
        _devinettes = data;
        _isLoading = false;
        _errorMessage = null;
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Impossible de charger les devinettes: ${e.toString()}';
        _isLoading = false;
      });
      debugPrint('Erreur de chargement des devinettes: $e');
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _backgroundColor,
      // Adapté pour la navigation des devinettes
      bottomNavigationBar: const BottomNavigationWidget(currentPage: 'devinette'),
      body: CustomScrollView(
        slivers: [
          // 1. EN-TÊTE ET BARRE D'APPLICATION (Adaptée)
          _buildHeader(context),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Column(
                children: [
                  const SizedBox(height: 20),
                  // 2. BARRE DE RECHERCHE (Adaptée)
                  _buildSearchBar(),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
          // 3. GRILLE DES DEVINETTES
          _buildDevinettesGrid(),
          const SliverToBoxAdapter(child: SizedBox(height: 100)),
        ],
      ),
    );
  }

  /// 1. Construction de l'en-tête (Grande carte et AppBar)
  Widget _buildHeader(BuildContext context) {
    return SliverAppBar(
      automaticallyImplyLeading: false, // On gère le leading nous-mêmes
      expandedHeight: 250,
      pinned: true,
      backgroundColor: _backgroundColor,
      elevation: 0,
      flexibleSpace: FlexibleSpaceBar(
        titlePadding: EdgeInsets.zero,
        centerTitle: true,
        title: Container(
          width: double.infinity,
          alignment: Alignment.center,
          padding: const EdgeInsets.only(bottom: 8.0, top: 40.0),
          // Affichage du titre 'Devinettes' lorsque la barre est repliée
          child: Opacity(
            opacity: 1.0, // Simplification de l'effet de fade
            child: Text(
              'Devinettes',
              style: TextStyle(
                color: Theme.of(context).brightness == Brightness.light ? _cardTextColor : Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 20,
              ),
            ),
          ),
        ),
        background: Stack(
          children: [
            // Grande carte thématique "Devinettes et Énigmes"
            Container(
              decoration: const BoxDecoration(
                color: Colors.black,
                borderRadius: BorderRadius.vertical(bottom: Radius.circular(30)),
              ),
              child: ClipRRect(
                borderRadius: const BorderRadius.vertical(bottom: Radius.circular(30)),
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    // Image de fond (chemin simulé adapté)
                    Image.asset(
                      'assets/images/riddle_theme.png', // Chemin mis à jour pour un thème de devinette
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) => Container(
                        color: _accentColor.withOpacity(0.6),
                        child: const Center(
                          child: Text(
                            'Jeu de Devinettes',
                            style: TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.bold),
                          ),
                        ),
                      ),
                    ),
                    // Overlay sombre
                    Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Colors.black.withOpacity(0.1),
                            Colors.black.withOpacity(0.4),
                          ],
                        ),
                      ),
                    ),
                    // Texte et Icône
                    Positioned(
                      bottom: 20,
                      left: 20,
                      right: 20,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            "Devinettes et Énigmes",
                            style: TextStyle(color: Colors.white, fontSize: 26, fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 4),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                child: Text(
                                  'Testez votre esprit avec la sagesse ancestrale.',
                                  style: TextStyle(color: Colors.white.withOpacity(0.9), fontSize: 14, fontWeight: FontWeight.w500),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              // Icône de question, remplace l'icône de lecture
                              Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(color: _accentColor.withOpacity(0.9), shape: BoxShape.circle),
                                child: const Icon(Icons.quiz, color: Colors.white, size: 30),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            // Barre d'application transparente avec bouton de retour
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
                // Le titre est géré par la FlexibleSpaceBar pour l'effet de scroll
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// 2. Construction de la barre de recherche.
  Widget _buildSearchBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10),
      decoration: BoxDecoration(
        color: _accentColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: _accentColor.withOpacity(0.5), width: 1.0),
        boxShadow: [BoxShadow(color: Colors.grey.withOpacity(0.1), blurRadius: 5, offset: const Offset(0, 2))],
      ),
      child: TextField(
        decoration: InputDecoration(
          icon: const Icon(Icons.search, color: _accentColor),
          hintText: 'Rechercher des devinettes',
          hintStyle: TextStyle(color: _cardTextColor.withOpacity(0.6)),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(vertical: 14.0),
        ),
      ),
    );
  }

  /// 3. Construction de la grille des devinettes.
  Widget _buildDevinettesGrid() {
    if (_isLoading) {
      return const SliverFillRemaining(child: Center(child: Padding(
        padding: EdgeInsets.all(40.0),
        child: CircularProgressIndicator(color: _accentColor),
      )));
    }

    if (_errorMessage != null) {
      return SliverToBoxAdapter(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(40.0),
            child: Text(
              'Erreur de chargement: $_errorMessage',
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.red, fontSize: 16),
            ),
          ),
        ),
      );
    }

    if (_devinettes.isEmpty) {
      return const SliverToBoxAdapter(child: Center(child: Padding(
        padding: EdgeInsets.all(40.0),
        child: Text('Aucune devinette trouvée.', style: TextStyle(fontSize: 16, color: _cardTextColor)),
      )));
    }

    return SliverGrid(
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 10,
        mainAxisSpacing: 10,
        childAspectRatio: 0.85, // Ratio adapté pour le contenu textuel
      ),
      delegate: SliverChildBuilderDelegate(
            (context, index) {
          final devinette = _devinettes[index];

          return GestureDetector(
            onTap: () {
              // --- LOGIQUE DE NAVIGATION CORRIGÉE ---
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => MusicDetailScreen(
                    titre: devinette.titre ?? 'Énigme',
                    devinette: devinette.devinette ?? 'Devinette non spécifiée',
                    reponse: devinette.reponse ?? 'Réponse non disponible',
                    conteur: '${devinette.prenomAuteur ?? ''} ${devinette.nomAuteur ?? 'Auteur inconnu'}'.trim(),
                    imageUrl: 'assets/icons/riddle.png', // Placeholder (non utilisé mais requis)
                    details: {
                      // Regrouper les infos non directes dans 'details'
                      'nom': devinette.titre ?? 'Énigme',
                      'langue':  'Inconnue',
                      'lieu': devinette.lieu ?? 'Inconnu',
                    },
                  ),
                ),
              );
            },
            child: _buildDevinetteCard(
              devinette.titre ?? 'Énigme sans titre',
              devinette.devinette ?? 'Devinette non spécifiée',
              devinette.lieu ?? 'Lieu inconnu',
            ),
          );
        },
        childCount: _devinettes.length,
      ),
    );
  }

  /// 4. Construction d'une seule carte de Devinette.
  Widget _buildDevinetteCard(
      String title,
      String riddleText,
      String location,
      ) {
    return Container(
      padding: const EdgeInsets.all(12.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: _accentColor.withOpacity(0.3)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 6,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Icône de Devinette
          const Icon(Icons.quiz_outlined, color: _accentColor, size: 28),
          const SizedBox(height: 8),

          // Titre
          Text(
            title,
            style: const TextStyle(
              color: _cardTextColor,
              fontSize: 14,
              fontWeight: FontWeight.bold,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 4),

          // Texte de la Devinette
          Expanded(
            child: Text(
              riddleText,
              style: TextStyle(
                color: _cardTextColor.withOpacity(0.8),
                fontSize: 12,
                fontStyle: FontStyle.italic,
              ),
              maxLines: 4, // Légèrement réduit pour laisser de la place
              overflow: TextOverflow.ellipsis,
            ),
          ),
          const SizedBox(height: 8),

          // Lieu
          Row(
            children: [
              Icon(Icons.location_on, size: 12, color: Colors.grey.shade600),
              const SizedBox(width: 4),
              Expanded(
                child: Text(
                  location,
                  style: TextStyle(
                    color: Colors.grey.shade600,
                    fontSize: 10,
                    fontWeight: FontWeight.w500,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),

          // Bouton Révéler / Jouer (Visuel)
          Center(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: _accentColor,
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Text(
                'Révéler',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}