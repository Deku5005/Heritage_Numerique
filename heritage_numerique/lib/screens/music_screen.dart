import 'package:flutter/material.dart';
import '../widgets/bottom_navigation_widget.dart';
import '../model/Devinette1.dart'; // Importation du modèle Devinette
import '../Service/DevinetteService1.dart'; // Importation du service Devinette
import 'Music_detail_screen.dart'; // Écran de détail adapté aux Devinettes

/// Écran affichant la liste des Devinettes.
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
      bottomNavigationBar: const BottomNavigationWidget(currentPage: 'devinette'),
      body: CustomScrollView(
        slivers: [
          // 1. EN-TÊTE ET BARRE D'APPLICATION
          _buildHeader(context),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Column(
                children: [
                  const SizedBox(height: 24),
                  // 2. BARRE DE RECHERCHE
                  _buildSearchBar(),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
          // 3. GRILLE DES DEVINETTES
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            sliver: _buildDevinettesGrid(),
          ),
          const SliverToBoxAdapter(child: SizedBox(height: 100)),
        ],
      ),
    );
  }

  // -------------------------------------------------------------------
  // --- WIDGETS DE CONSTRUCTION ---
  // -------------------------------------------------------------------

  /// 1. Construction de l'en-tête
  Widget _buildHeader(BuildContext context) {
    return SliverAppBar(
      automaticallyImplyLeading: false,
      expandedHeight: 280,
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
        ),
        background: Stack(
          children: [
            // Grande carte thématique "Devinettes et Énigmes"
            Container(
              decoration: const BoxDecoration(
                color: Colors.black,
                borderRadius: BorderRadius.vertical(bottom: Radius.circular(35)),
              ),
              child: ClipRRect(
                borderRadius: const BorderRadius.vertical(bottom: Radius.circular(35)),
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    // Image de fond
                    Image.asset(
                      'assets/images/three-african-brothers-adventure-forest.jpg',
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) => Container(
                        color: _accentColor.withOpacity(0.6),
                        child: const Center(
                          child: Text(
                            'Jeu de Devinettes',
                            style: TextStyle(color: Colors.white, fontSize: 30, fontWeight: FontWeight.bold),
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
                            Colors.black.withOpacity(0.5),
                          ],
                        ),
                      ),
                    ),
                    // Texte et Icône
                    Positioned(
                      bottom: 45,
                      left: 20,
                      right: 20,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            "Devinettes et Énigmes",
                            style: TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 12),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                child: Text(
                                  'Testez votre esprit avec la sagesse ancestrale.',
                                  style: TextStyle(color: Colors.white.withOpacity(0.9), fontSize: 18, fontWeight: FontWeight.w500),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
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
                    decoration: BoxDecoration(color: Colors.black.withOpacity(0.3), shape: BoxShape.circle),
                    child: IconButton(
                      icon: Icon(Icons.arrow_back, color: Colors.white.withOpacity(1)),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ),
                ),
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
      padding: const EdgeInsets.symmetric(horizontal: 15),
      decoration: BoxDecoration(
        color: _accentColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: _accentColor.withOpacity(0.5), width: 1.0),
        boxShadow: [BoxShadow(color: Colors.grey.withOpacity(0.15), blurRadius: 8, offset: const Offset(0, 4))],
      ),
      child: TextField(
        style: const TextStyle(fontSize: 16),
        decoration: InputDecoration(
          icon: const Icon(Icons.search, color: _accentColor, size: 24),
          hintText: 'Rechercher des devinettes ou énigmes',
          hintStyle: TextStyle(color: _cardTextColor.withOpacity(0.7), fontSize: 16),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(vertical: 16.0),
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
              style: const TextStyle(color: Colors.red, fontSize: 18),
            ),
          ),
        ),
      );
    }

    if (_devinettes.isEmpty) {
      return const SliverToBoxAdapter(child: Center(child: Padding(
        padding: EdgeInsets.all(40.0),
        child: Text('Aucune devinette trouvée.', style: TextStyle(fontSize: 18, color: _cardTextColor)),
      )));
    }

    return SliverGrid(
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        childAspectRatio: 0.82,
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
                    imageUrl: 'assets/icons/riddle.png',
                    details: {
                      // 💡 CORRECTION : Utilisation de 'id' qui est le nom du champ dans Devinette1
                      'idDevinette': devinette.id,
                      'nom': devinette.titre ?? 'Énigme',
                      'langue':  'Inconnue',
                      'lieu': devinette.lieu ?? 'Inconnu',
                    },
                  ),
                ),
              );
            },
            // Utilisation de la carte modernisée
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
    const Color modernCardColor = Color(0xFFF7F7F7);
    const Color primaryAccent = _accentColor;

    return Container(
      decoration: BoxDecoration(
        color: modernCardColor,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: primaryAccent.withOpacity(0.15),
            blurRadius: 10,
            spreadRadius: 1,
            offset: const Offset(0, 4),
          ),
        ],
        border: Border.all(color: primaryAccent.withOpacity(0.4), width: 1.5),
      ),
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Icône et Titre sur la même ligne
          Row(
            children: [
              const Icon(Icons.psychology_outlined, color: primaryAccent, size: 28),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    color: _cardTextColor,
                    fontSize: 17,
                    fontWeight: FontWeight.w800,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),

          // Séparateur fin
          Divider(color: primaryAccent.withOpacity(0.5), height: 1, thickness: 1),
          const SizedBox(height: 10),

          // Texte de la Devinette (mis en valeur)
          Expanded(
            child: Text(
              riddleText,
              style: TextStyle(
                color: _cardTextColor.withOpacity(0.9),
                fontSize: 14,
                fontStyle: FontStyle.normal,
                height: 1.4,
              ),
              maxLines: 4,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          const SizedBox(height: 12),

          // Lieu (utilisant un Chip pour le style)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
              color: primaryAccent.withOpacity(0.15),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.map_outlined, size: 16, color: primaryAccent),
                const SizedBox(width: 6),
                Text(
                  location,
                  style: const TextStyle(
                    color: primaryAccent,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),

          // Bouton Révéler / Jouer (Visuel)
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: null,
              style: ElevatedButton.styleFrom(
                backgroundColor: primaryAccent,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 4,
                padding: const EdgeInsets.symmetric(vertical: 10),
              ),
              child: const Text(
                'Voir l\'Énigme',
                style: TextStyle(
                  fontSize: 14,
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