import 'package:flutter/material.dart';
import 'package:heritage_numerique/Service/Auth-service.dart';
import 'package:heritage_numerique/Service/dashboardServices.dart';
import 'package:heritage_numerique/model/family_response_dashboard.dart';

// CORRECTION D'IMPORTATION : Assurez-vous que ce chemin est correct.
import 'AppDrawer.dart';

// --- Constantes de Couleurs Globales ---
const Color _mainAccentColor = Color(0xFFAA7311);
const Color _backgroundColor = Colors.white;
const Color _cardTextColor = Color(0xFF2E2E2E);
const Color _welcomeCardBackground = Color(0xFFF7F2E8);

class HomeDashboardScreen extends StatefulWidget {
  // 💡 CORRECTION : L'ID de la famille est maintenant obligatoire (non-nullable)
  final int familyId;
  final String? familyName;

  // 💡 familyId est marqué comme 'required'
  const HomeDashboardScreen({super.key, required this.familyId, this.familyName});

  @override
  State<HomeDashboardScreen> createState() => _HomeDashboardScreenState();
}

class _HomeDashboardScreenState extends State<HomeDashboardScreen> {
  // Services
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final DashboardService _dashboardService = DashboardService();

  // État des données
  Future<FamilyDashboardResponse>? _dashboardData;
  // ❌ _mockFamilyId est supprimé car familyId est maintenant obligatoire.

  @override
  void initState() {
    super.initState();
    _loadDashboardData();
  }

  // Fonction de chargement des données
  void _loadDashboardData() {
    // 🚀 UTILISE DIRECTEMENT l'ID requis, sans vérifier le mock
    final int id = widget.familyId;
    setState(() {
      _dashboardData = _dashboardService.fetchFamilyDashboard(familleId: id);
    });
  }

  @override
  Widget build(BuildContext context) {
    // 💡 Déplacement du FutureBuilder pour gérer le Scaffold et le Drawer
    return FutureBuilder<FamilyDashboardResponse>(
      future: _dashboardData,
      builder: (context, snapshot) {
        // 1. État de chargement
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator(color: _mainAccentColor)),
          );
        }

        // 2. État d'erreur
        if (snapshot.hasError) {
          return Scaffold(
            body: Center(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Text(
                  "Erreur de chargement: ${snapshot.error.toString().replaceAll('Exception: ', '')}",
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: Colors.red),
                ),
              ),
            ),
          );
        }

        // 3. État des données prêtes
        if (snapshot.hasData) {
          final data = snapshot.data!;
          final int currentFamilyId = data.idFamille; // Récupération de l'ID dynamique

          // 💡 Le Scaffold est construit ICI avec l'ID de famille
          return Scaffold(
            key: _scaffoldKey,
            backgroundColor: _backgroundColor,
            // 💡 Transmission de l'ID au Drawer
            drawer: AppDrawer(familyId: currentFamilyId),

            body: SingleChildScrollView(
              padding: EdgeInsets.only(top: MediaQuery.of(context).padding.top + 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 1. En-tête (Menu + Titre)
                  _buildCustomHeader(_scaffoldKey),
                  const SizedBox(height: 20),

                  // 2. Carte de Bienvenue (avec le nom de famille réel)
                  _buildWelcomeCard(data.nomFamille),
                  const SizedBox(height: 30),

                  // 3. Grille des Statistiques (avec les données réelles)
                  _buildStatsGrid(data),
                  const SizedBox(height: 30),
                ],
              ),
            ),
          );
        }

        // 4. Aucune donnée
        return const Scaffold(body: Center(child: Text("Aucune donnée de tableau de bord disponible.")));
      },
    );
  }

  // --- Le reste des méthodes de construction de l'UI est inchangé ---

  Widget _buildCustomHeader(GlobalKey<ScaffoldState> scaffoldKey) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.menu, color: _cardTextColor, size: 30),
            onPressed: () {
              scaffoldKey.currentState?.openDrawer();
            },
          ),
          const SizedBox(width: 8),
          const Text(
            'Héritage Numérique',
            style: TextStyle(
              color: _cardTextColor,
              fontWeight: FontWeight.bold,
              fontSize: 20,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWelcomeCard(String nomFamille) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: _welcomeCardBackground,
        borderRadius: BorderRadius.circular(15),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Bienvenue dans la mémoire familiale des $nomFamille',
            style: const TextStyle(
              color: _cardTextColor,
              fontWeight: FontWeight.bold,
              fontSize: 18,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Un lieu pour préserver, partager et transmettre votre héritage à travers les générations.',
            style: TextStyle(
              color: _cardTextColor.withOpacity(0.7),
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsGrid(FamilyDashboardResponse data) {
    final List<Map<String, dynamic>> stats = [
      {'title': 'Membres', 'count': data.nombreMembres, 'icon': Icons.group_outlined},
      {'title': 'Contenus Publics', 'count': data.nombreContenusPublics, 'icon': Icons.public},
      {'title': 'Contenus Privés', 'count': data.nombreContenusPrives, 'icon': Icons.lock_outline},
      {'title': 'Quiz Actifs', 'count': data.nombreQuizActifs, 'icon': Icons.quiz_outlined},
      {'title': 'Invitations', 'count': data.nombreInvitationsEnAttente, 'icon': Icons.mail_outline},
      {'title': 'Arbres', 'count': data.nombreArbreGenealogiques, 'icon': Icons.account_tree_outlined},
    ];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: GridView.builder(
        physics: const NeverScrollableScrollPhysics(),
        shrinkWrap: true,
        itemCount: stats.length,
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
          childAspectRatio: 2.2,
        ),
        itemBuilder: (context, index) {
          final stat = stats[index];
          return _buildStatItemCard(stat['title'] as String, stat['count'] as int, stat['icon'] as IconData);
        },
      ),
    );
  }

  Widget _buildStatItemCard(String title, int count, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 5,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                count.toString(),
                style: const TextStyle(
                  color: _cardTextColor,
                  fontWeight: FontWeight.bold,
                  fontSize: 24,
                ),
              ),
            ],
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: _cardTextColor,
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          Icon(icon, color: _mainAccentColor, size: 30),
        ],
      ),
    );
  }
}
