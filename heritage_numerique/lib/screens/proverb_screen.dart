import 'package:flutter/material.dart';
import '../widgets/bottom_navigation_widget.dart';
import 'Proverb_detail_screen.dart'; // Importation de la page de détail
import '../model/proverbe1.dart'; // Importation du modèle
import '../Service/proverbeservice1.dart'; // Importation du service

/// Écran affichant la liste des Proverbes traditionnels Maliens.
class ProverbScreen extends StatefulWidget {
  const ProverbScreen({super.key});

  @override
  State<ProverbScreen> createState() => _ProverbScreenState();
}

class _ProverbScreenState extends State<ProverbScreen> {
  // Constantes de Couleurs
  static const Color _accentColor = Color(0xFFD69301); // Ocre Vif
  static const Color _cardTextColor = Color(0xFF2E2E2E);
  static const Color _actionColor = Color(0xFF9F9646);

  // Déclaration des états et du service
  final ProverbeService1 _proverbeService = ProverbeService1();
  List<Proverbe1> _proverbes = [];
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _fetchProverbs();
  }

  Future<void> _fetchProverbs() async {
    try {
      final data = await _proverbeService.getProverbes();
      setState(() {
        _proverbes = data;
        _isLoading = false;
        _errorMessage = null;
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Impossible de charger les proverbes: ${e.toString()}';
        _isLoading = false;
      });
      debugPrint('Erreur de chargement des proverbes: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      bottomNavigationBar: const BottomNavigationWidget(currentPage: 'proverb'),
      body: SingleChildScrollView(
        padding: const EdgeInsets.only(top: 0),
        child: Column(
          children: [
            // --- 1. EN-TÊTE ET BARRE D'APPLICATION ---
            _buildHeader(context),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Column(
                children: [
                  const SizedBox(height: 20),
                  // --- 2. BARRE DE RECHERCHE ---
                  _buildSearchBar(),
                  const SizedBox(height: 20),
                  // --- 3. GRILLE DES PROVERBES (Dynamique) ---
                  _buildProverbsGrid(),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// 1. Construction de l'en-tête, y compris la grande carte thématique.
  Widget _buildHeader(BuildContext context) {
    return Stack(
      children: [
        // Grande carte thématique "Les Proverbes du Mali"
        Container(
          height: 250,
          decoration: BoxDecoration(
            color: Colors.grey[200],
            borderRadius: const BorderRadius.vertical(bottom: Radius.circular(30)),
          ),
          child: ClipRRect(
            borderRadius: const BorderRadius.vertical(bottom: Radius.circular(30)),
            child: Stack(
              fit: StackFit.expand,
              children: [
                // Image de fond (chemin simulé)
                Image.asset(
                  'assets/images/Proverbe.png',
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) => Container(
                    color: _accentColor.withOpacity(0.2),
                    child: const Center(
                      child: Text(
                        'Les Proverbes du Mali',
                        style: TextStyle(
                          color: Colors.black,
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ),
                // Overlay sombre pour améliorer la lisibilité du texte
                Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.black.withOpacity(0.3),
                        Colors.black.withOpacity(0.5),
                      ],
                    ),
                  ),
                ),
                // Texte de la citation centrée (Utilise un proverbe par défaut si la liste est vide)
                Padding(
                  padding: const EdgeInsets.all(30.0),
                  child: Center(
                    child: Text(
                      _proverbes.isNotEmpty
                          ? '"${_proverbes.first.proverbe ?? 'Sagesse africaine'}"'
                          : '"La parole est une graine une fois semée, elle porte ses fruits"',
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 26,
                        fontWeight: FontWeight.w500,
                        shadows: [
                          Shadow(
                            blurRadius: 10,
                            color: Colors.black,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        // Barre d'application / Flèche de retour et Titre
        Positioned(
          top: 0,
          left: 0,
          right: 0,
          child: AppBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            leading: IconButton(
              icon: Icon(Icons.arrow_back, color: Colors.white.withOpacity(0.9)),
              onPressed: () => Navigator.pop(context),
            ),
            centerTitle: true,
            title: const Text(
              'Proverbes',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
      ],
    );
  }

  /// 2. Construction de la barre de recherche.
  Widget _buildSearchBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: _accentColor.withOpacity(0.5), width: 1.5),
        boxShadow: [
          BoxShadow(
            color: _accentColor.withOpacity(0.1),
            blurRadius: 5,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: TextField(
        decoration: InputDecoration(
          icon: const Icon(Icons.search, color: _accentColor),
          hintText: 'Rechercher des proverbes',
          hintStyle: TextStyle(color: _cardTextColor.withOpacity(0.6)),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(vertical: 14.0),
        ),
      ),
    );
  }

  /// 3. Construction de la grille des proverbes.
  Widget _buildProverbsGrid() {
    if (_isLoading) {
      return const Center(child: Padding(
        padding: EdgeInsets.all(40.0),
        child: CircularProgressIndicator(color: _accentColor),
      ));
    }

    if (_errorMessage != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(40.0),
          child: Text(
            'Erreur de chargement: $_errorMessage',
            textAlign: TextAlign.center,
            style: const TextStyle(color: Colors.red, fontSize: 16),
          ),
        ),
      );
    }

    if (_proverbes.isEmpty) {
      return const Center(child: Padding(
        padding: EdgeInsets.all(40.0),
        child: Text('Aucun proverbe trouvé.', style: TextStyle(fontSize: 16, color: _cardTextColor)),
      ));
    }

    return GridView.builder(
      physics: const NeverScrollableScrollPhysics(),
      shrinkWrap: true,
      itemCount: _proverbes.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 10,
        mainAxisSpacing: 10,
        childAspectRatio: 0.85,
      ),
      itemBuilder: (context, index) {
        final proverbe = _proverbes[index];

        // **CORRECTION: Suppression de 'proverbeData' et passage des quatre String requis**
        return GestureDetector(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => ProverbDetailScreen(
                  // Les paramètres String requis par le nouvel écran de détail
                  proverbText: proverbe.proverbe ?? 'Proverbe non spécifié',
                  source: proverbe.origine ?? 'Source inconnue',
                  conteur: '${proverbe.prenomAuteur ?? ''} ${proverbe.nomAuteur ?? 'Auteur inconnu'}'.trim(),
                  langue: proverbe.nomFamille ?? 'Langue inconnue',
                ),
              ),
            );
          },
          child: _buildProverbCard(
            context,
            proverbe.proverbe ?? 'Proverbe non spécifié',
            proverbe.origine ?? 'Source inconnue',
          ),
        );
      },
    );
  }

  /// 4. Construction d'une seule carte de proverbe.
  Widget _buildProverbCard(
      BuildContext context,
      String text,
      String source,
      ) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Texte du proverbe
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(12.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    text,
                    style: const TextStyle(
                      color: _cardTextColor,
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      fontStyle: FontStyle.italic,
                    ),
                    maxLines: 4,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const Spacer(),
                  Text(
                    '— $source',
                    style: TextStyle(
                      color: _accentColor,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ),
          // Boutons d'action
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildActionButton(context, 'Lire', Icons.book, _accentColor),
                _buildActionButton(context, 'Soutenir', Icons.favorite, _actionColor),
              ],
            ),
          ),
          const SizedBox(height: 5),
        ],
      ),
    );
  }

  /// Construction d'un bouton d'action pour la carte.
  Widget _buildActionButton(BuildContext context, String text, IconData icon, Color color) {
    return GestureDetector(
      onTap: () {
        // L'action réelle (navigation) est sur la carte entière, ici c'est un feedback visuel
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Action : $text'),
            backgroundColor: color,
          ),
        );
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: color.withOpacity(0.15),
          borderRadius: BorderRadius.circular(5),
          border: Border.all(color: color, width: 1),
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
      ),
    );
  }
}