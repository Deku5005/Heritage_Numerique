import 'package:flutter/material.dart';
import 'dart:async'; // Nécessaire pour les Futures

// Imports de vos fichiers (vérifiez les chemins)
import '../model/conte.dart';
import '../Service/conteService.dart';
import '../widgets/bottom_navigation_widget.dart';
import 'affichage_contes_screen.dart';

/// Écran affichant la liste des contes.
class ContesScreen extends StatefulWidget {
  const ContesScreen({super.key});

  @override
  State<ContesScreen> createState() => _ContesScreenState();
}

class _ContesScreenState extends State<ContesScreen> {

  // Instance du service pour appeler l'API
  final ConteService _conteService = ConteService();
  // Future pour contenir le résultat de l'appel API
  late Future<List<Conte>> _contesFuture;

  // Constantes de style
  static const Color _accentColor = Color(0xFFD69301);
  static const Color _cardTextColor = Color(0xFF2E2E2E);

  @override
  void initState() {
    super.initState();
    // Déclenchement de l'appel API lors de l'initialisation de l'état
    _contesFuture = _conteService.getContes();
  }

  // --- Méthode de construction principale (inchangée) ---
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      bottomNavigationBar: const BottomNavigationWidget(currentPage: 'contes'),
      body: CustomScrollView(
        slivers: [
          _buildHeader(),
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0),
            sliver: SliverList(
              delegate: SliverChildListDelegate(
                [
                  _buildSearchBar(),
                  const SizedBox(height: 20),
                  const Text(
                    'Contes Populaires Maliens',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: _cardTextColor,
                    ),
                  ),
                  const SizedBox(height: 15),
                ],
              ),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 15.0),
            // *** Changement ici : Remplacement de la grille statique par FutureBuilder ***
            sliver: _buildContesFutureBuilder(context),
          ),
          const SliverToBoxAdapter(child: SizedBox(height: 50)),
        ],
      ),
    );
  }

  // ----------------------------------------------------
  // --- NOUVELLE MÉTHODE : GESTION DU CHARGEMENT API ---
  // ----------------------------------------------------

  Widget _buildContesFutureBuilder(BuildContext context) {
    return FutureBuilder<List<Conte>>(
      future: _contesFuture,
      builder: (context, snapshot) {
        // 1. État d'erreur (ex: réseau coupé, erreur serveur)
        if (snapshot.hasError) {
          print('Erreur FutureBuilder: ${snapshot.error}'); // Utile pour le debug
          return SliverToBoxAdapter(
            child: Center(
              child: Padding(
                padding: const EdgeInsets.all(30.0),
                child: Text(
                  '⚠️ Erreur de chargement: ${snapshot.error.toString().replaceAll("Exception:", "")}',
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: Colors.red),
                ),
              ),
            ),
          );
        }

        // 2. État de chargement (en attente)
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const SliverToBoxAdapter(
            child: Center(
              child: Padding(
                padding: EdgeInsets.only(top: 50.0),
                child: CircularProgressIndicator(color: _accentColor),
              ),
            ),
          );
        }

        // 3. État de réussite (données prêtes)
        if (snapshot.hasData) {
          final List<Conte> contes = snapshot.data!;
          if (contes.isEmpty) {
            return const SliverToBoxAdapter(
              child: Center(
                child: Padding(
                  padding: EdgeInsets.only(top: 30.0),
                  child: Text('Aucun conte trouvé pour l\'instant.'),
                ),
              ),
            );
          }
          // Afficher la grille si les données sont présentes
          return _buildTalesGrid(context, contes);
        }

        // Retour par défaut (ne devrait normalement pas être atteint)
        return const SliverToBoxAdapter(child: SizedBox.shrink());
      },
    );
  }

  // -------------------------------------------------------------------
  // --- MÉTHODES EXISTANTES ADAPTÉES POUR UTILISER LA CLASSE CONTE ---
  // -------------------------------------------------------------------

  // 1. Construction de l'en-tête (inchangée)
  Widget _buildHeader() {
    return SliverAppBar(
      backgroundColor: Colors.white,
      floating: true,
      snap: true,
      elevation: 0,
      centerTitle: true,
      title: const Text(
        'Contes Traditionnels',
        style: TextStyle(
          color: _cardTextColor,
          fontWeight: FontWeight.bold,
          fontSize: 24,
        ),
      ),
    );
  }

  // 2. Barre de recherche simulée (inchangée)
  Widget _buildSearchBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 5),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(30),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: const TextField(
        decoration: InputDecoration(
          hintText: 'Rechercher un conte...',
          border: InputBorder.none,
          icon: Icon(Icons.search, color: _accentColor),
        ),
      ),
    );
  }

  // 3. Construction de la grille des contes (avec la List<Conte> réelle)
  Widget _buildTalesGrid(BuildContext context, List<Conte> contes) {
    return SliverGrid(
      delegate: SliverChildBuilderDelegate(
            (context, index) {
          final conte = contes[index];

          return _buildTaleCard(
            context,
            conte, // Passe l'objet Conte complet
          );
        },
        childCount: contes.length,
      ),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 10,
        mainAxisSpacing: 10,
        childAspectRatio: 0.7,
      ),
    );
  }

  // 4. Construction d'une seule carte de conte (mise à jour)
  Widget _buildTaleCard(
      BuildContext context,
      Conte conte, // Reçoit maintenant l'objet Conte
      ) {
    // Les champs de votre API sont maintenant utilisés
    final String title = conte.titre;
    final String subtitle = conte.description; // Utilisation de la description pour le sous-titre
    final String imageUrl = conte.urlPhoto; // Utilisation de l'URL de la photo

    // NOTE: Il faudra peut-être adapter l'écran AffichageContesScreen pour recevoir
    // l'objet Conte plutôt que le Map de contenu multilingue statique.

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
          // Image du conte (doit maintenant charger depuis une URL)
          Expanded(
            child: ClipRRect(
              borderRadius: const BorderRadius.vertical(top: Radius.circular(15)),
              child: Stack(
                fit: StackFit.expand,
                children: [
                  Image.network( // Utilisation de Image.network
                    imageUrl,
                    fit: BoxFit.cover,
                    loadingBuilder: (context, child, loadingProgress) {
                      if (loadingProgress == null) return child;
                      return Container(
                        color: Colors.grey[200],
                        child: Center(
                          child: CircularProgressIndicator(
                            color: _accentColor.withOpacity(0.8),
                            value: loadingProgress.expectedTotalBytes != null
                                ? loadingProgress.cumulativeBytesLoaded / loadingProgress.expectedTotalBytes!
                                : null,
                          ),
                        ),
                      );
                    },
                    errorBuilder: (context, error, stackTrace) => Container(
                      color: Colors.grey[300],
                      child: Center(
                        child: Icon(Icons.menu_book, size: 40, color: _accentColor.withOpacity(0.8)),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          // Texte
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: _cardTextColor,
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: TextStyle(
                    color: _cardTextColor.withOpacity(0.6),
                    fontSize: 10,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          // Boutons "Lire" et "Quiz" (si présent)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildActionButton(context, 'Lire', Icons.book, _accentColor,
                    onTap: () {
                      // NOTE: Vous devez mettre à jour AffichageContesScreen
                      // pour accepter l'objet Conte à la place du Map multilingue
                      // Navigator.push(context, MaterialPageRoute(builder: (context) => AffichageContesScreen(conte: conte)));
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Naviguer vers le détail du conte...'),
                          backgroundColor: _accentColor,
                        ),
                      );
                    }),

                // Afficher le bouton Quiz SEULEMENT si conte.quiz n'est pas null
                if (conte.quiz != null)
                  _buildActionButton(context, 'Quiz', Icons.question_answer, Colors.green,
                      onTap: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Lancer le Quiz: ${conte.quiz!.titre}'),
                            backgroundColor: Colors.green,
                          ),
                        );
                      }),

                if (conte.quiz == null)
                  _buildActionButton(context, 'Partager', Icons.share, Colors.grey,
                      onTap: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Partager ce conte.'),
                            backgroundColor: Colors.grey,
                          ),
                        );
                      }),
              ],
            ),
          ),
          const SizedBox(height: 5),
        ],
      ),
    );
  }

  // 5. Construction d'un bouton d'action. (inchangée)
  Widget _buildActionButton(BuildContext context, String label, IconData icon, Color color, {required VoidCallback onTap}) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        decoration: BoxDecoration(
          border: Border.all(color: color.withOpacity(0.5)),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Row(
          children: [
            Icon(icon, color: color, size: 14),
            const SizedBox(width: 5),
            Text(
              label,
              style: TextStyle(
                color: color,
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}