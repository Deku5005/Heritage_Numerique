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
  final int familyId;
  final String? familyName;

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
  // 🚀 État pour contrôler l'animation d'entrée
  bool _dataLoaded = false;

  @override
  void initState() {
    super.initState();
    _loadDashboardData();
  }

  // Fonction de chargement des données
  void _loadDashboardData() {
    final int id = widget.familyId;
    _dashboardData = _dashboardService.fetchFamilyDashboard(familleId: id);

    // 🚀 Déclenche l'animation une fois que le Future est terminé
    _dashboardData!.then((_) {
      if (mounted) {
        setState(() {
          _dataLoaded = true;
        });
      }
    }).catchError((_) {
      if (mounted) {
        setState(() {
          _dataLoaded = true; // S'affiche même en cas d'erreur
        });
      }
    });
    setState(() {}); // Déclenche le FutureBuilder immédiatement
  }

  @override
  Widget build(BuildContext context) {
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
          final int currentFamilyId = data.idFamille;

          return Scaffold(
            key: _scaffoldKey,
            backgroundColor: _backgroundColor,
            drawer: AppDrawer(familyId: currentFamilyId),

            // 🚀 ANIMATION D'ENTRÉE : Fait apparaître le contenu après le chargement
            body: AnimatedOpacity(
              opacity: _dataLoaded ? 1.0 : 0.0,
              duration: const Duration(milliseconds: 500),
              child: SingleChildScrollView(
                padding: EdgeInsets.only(top: MediaQuery.of(context).padding.top + 10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // 1. En-tête (Menu + Titre)
                    _buildCustomHeader(_scaffoldKey),
                    const SizedBox(height: 20),

                    // 2. Carte de Bienvenue (flottante et visiblement dansante)
                    _buildWelcomeCard(data.nomFamille),
                    const SizedBox(height: 30),

                    // 3. Grille des Statistiques (avec hover 3D/lévitation)
                    _buildStatsGrid(data),
                    const SizedBox(height: 30),
                  ],
                ),
              ),
            ),
          );
        }

        // 4. Aucune donnée
        return const Scaffold(body: Center(child: Text("Aucune donnée de tableau de bord disponible.")));
      },
    );
  }

  // --- Le reste des méthodes de construction de l'UI ---

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

  // 🚀 UTILISATION DE LA CARTE FLOTTANTE ANIMÉE
  Widget _buildWelcomeCard(String nomFamille) {
    return _FloatingWelcomeCard(
      nomFamille: nomFamille,
      welcomeCardBackground: _welcomeCardBackground,
      cardTextColor: _cardTextColor,
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
          childAspectRatio: 1.2,
        ),
        itemBuilder: (context, index) {
          final stat = stats[index];
          // 🚀 UTILISATION DU WIDGET ANIMÉ AVEC HOVER
          return _buildStatItemCard(stat['title'] as String, stat['count'] as int, stat['icon'] as IconData);
        },
      ),
    );
  }

  Widget _buildStatItemCard(String title, int count, IconData icon) {
    return _AnimatedStatCard(
      title: title,
      count: count,
      icon: icon,
      mainAccentColor: _mainAccentColor,
      cardTextColor: _cardTextColor,
    );
  }
}

// =========================================================================
// --- WIDGET : CARTE FLOTTANTE DE BIENVENUE (MAINTENANT DANSANTE ET VISIBLE) ---
// =========================================================================

class _FloatingWelcomeCard extends StatefulWidget {
  final String nomFamille;
  final Color welcomeCardBackground;
  final Color cardTextColor;

  const _FloatingWelcomeCard({
    required this.nomFamille,
    required this.welcomeCardBackground,
    required this.cardTextColor,
  });

  @override
  State<_FloatingWelcomeCard> createState() => __FloatingWelcomeCardState();
}

class __FloatingWelcomeCardState extends State<_FloatingWelcomeCard> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<Offset> _animation;

  @override
  void initState() {
    super.initState();
    // 1. Contrôleur : Durée de l'animation de respiration (3 secondes aller-retour)
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 3000),
    )..repeat(reverse: true); // Répéter l'animation en sens inverse SANS FIN

    // 2. Animation : Déplace la carte de 0 à -5% de la hauteur du widget parent
    _animation = Tween<Offset>(
      begin: const Offset(0, 0),
      end: const Offset(0, -0.05), // 🚀 Amplitude plus visible
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut, // Courbe douce
    ));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SlideTransition(
      position: _animation,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16),
        padding: const EdgeInsets.all(16.0),
        decoration: BoxDecoration(
          color: Colors.white, // Fond blanc
          borderRadius: BorderRadius.circular(15),
          boxShadow: [
            BoxShadow(
              color: widget.welcomeCardBackground.withOpacity(0.5), // Ombre plus colorée
              blurRadius: 15,
              offset: const Offset(0, 8), // Ombre portée pour effet flottant
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Bienvenue dans la mémoire familiale des ${widget.nomFamille}',
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
                color: widget.cardTextColor.withOpacity(0.7),
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }
}


// =========================================================================
// --- WIDGET ANIMÉ AVEC HOVER STYLE ANTIGRAVITY (TILT 3D) ---
// =========================================================================

class _AnimatedStatCard extends StatefulWidget {
  final String title;
  final int count;
  final IconData icon;
  final Color mainAccentColor;
  final Color cardTextColor;

  const _AnimatedStatCard({
    required this.title,
    required this.count,
    required this.icon,
    required this.mainAccentColor,
    required this.cardTextColor,
  });

  @override
  // 🚀 Ajout de SingleTickerProviderStateMixin pour l'AnimationController
  State<_AnimatedStatCard> createState() => __AnimatedStatCardState();
}

// =========================================================================
// --- WIDGET ANIMÉ AVEC HOVER STYLE ANTIGRAVITY (CORRIGÉ LateInitializationError) ---
// =========================================================================

class __AnimatedStatCardState extends State<_AnimatedStatCard> with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  // 🚀 CORRECTION : Initialisation immédiate des Animations pour éviter LateInitializationError
  // Nous les initialisons avec des tweens par défaut pour qu'elles ne soient jamais nulles
  late Animation<double> _animationElevation;
  late Animation<double> _animationTilt;

  // Nouveaux états pour gérer les valeurs cibles
  double _targetElevation = 5.0;
  double _targetTiltAngle = 0.0;

  // Micro-animation de pression
  double _scale = 1.0;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );

    // Initialisation SÛRE des animations dans initState
    // Elles sont initialisées avec leur valeur de repos (5.0 et 0.0)
    _animationElevation = Tween<double>(begin: _targetElevation, end: _targetElevation).animate(_controller);
    _animationTilt = Tween<double>(begin: _targetTiltAngle, end: _targetTiltAngle).animate(_controller);

    // Lancement immédiat de l'animation pour les tweens (pour s'assurer que .value est accessible)
    _controller.forward(from: 0.0);
    _controller.stop(); // On la stoppe car elle est à l'état de repos
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  // Met à jour les valeurs cibles et déclenche l'animation
  void _updateAnimationTargets(double newElevation, double newTilt) {
    if (!mounted) return;

    // Mise à jour de l'état uniquement si les cibles changent
    if (_targetElevation == newElevation && _targetTiltAngle == newTilt) return;

    // On s'assure que le contrôleur est reset avant de créer de nouveaux Tweens
    _controller.reset();

    // Création de NOUVEAUX Tweens à partir de la valeur ACTUELLE (.value) vers la NOUVELLE CIBLE
    _animationElevation = Tween<double>(
      begin: _animationElevation.value,
      end: newElevation,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic));

    _animationTilt = Tween<double>(
      begin: _animationTilt.value,
      end: newTilt,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic));

    _targetElevation = newElevation;
    _targetTiltAngle = newTilt;

    _controller.forward(from: 0.0); // Lance l'animation
  }

  // Micro-animation de pression
  void _onTapDown(_) {
    setState(() {
      _scale = 0.95;
    });
  }
  void _onTapUp(_) {
    setState(() {
      _scale = 1.0;
    });
  }
  void _onTapCancel() {
    setState(() {
      _scale = 1.0;
    });
  }

  // 🚀 Gestion du survol (Hover) - Effet Antigravity
  void _onHoverEnter(PointerEvent details) {
    _updateAnimationTargets(25.0, 0.08); // Haute élévation et tilt prononcé
  }

  void _onHoverExit(PointerEvent details) {
    _updateAnimationTargets(5.0, 0.0); // Retour à l'état initial
  }

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: _onHoverEnter,
      onExit: _onHoverExit,
      child: GestureDetector(
        onTapDown: _onTapDown,
        onTapUp: _onTapUp,
        onTapCancel: _onTapCancel,
        onTap: () {
          // Logique de navigation/action
        },
        child: AnimatedBuilder( // Utiliser AnimatedBuilder pour reconstruire avec les valeurs d'animation
          animation: _controller,
          builder: (context, child) {
            // 💡 Définir la transformation 3D
            Matrix4 transformMatrix = Matrix4.identity()
              ..setEntry(3, 2, 0.001) // Ajout de perspective
            // TILT agressif et rotation sur les axes X et Y
              ..rotateX(-_animationTilt.value * 0.5)
              ..rotateY(_animationTilt.value);

            return AnimatedScale(
              scale: _scale,
              duration: const Duration(milliseconds: 150),
              child: Transform( // Appliquer la transformation 3D
                alignment: Alignment.center,
                transform: transformMatrix,
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(15),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.2),
                        blurRadius: _animationElevation.value, // Valeur animée
                        offset: Offset(0, _animationElevation.value / 2),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // 1. Icone stylisée
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: widget.mainAccentColor.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Icon(
                          widget.icon,
                          color: widget.mainAccentColor,
                          size: 28,
                        ),
                      ),
                      const Spacer(),

                      // 2. Compte
                      Text(
                        widget.count.toString(),
                        style: const TextStyle(
                          color: _cardTextColor,
                          fontWeight: FontWeight.bold,
                          fontSize: 28,
                        ),
                      ),

                      // 3. Titre
                      Text(
                        widget.title,
                        style: TextStyle(
                          color: widget.cardTextColor.withOpacity(0.8),
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

}