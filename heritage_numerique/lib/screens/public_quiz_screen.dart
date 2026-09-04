import 'package:flutter/material.dart';
import 'package:heritage_numerique/Service/token-storage-service.dart';
import 'package:heritage_numerique/screens/login_screen.dart';
import 'package:heritage_numerique/screens/registration_screen.dart';
import 'package:heritage_numerique/widgets/bottom_navigation_widget.dart';
import 'package:heritage_numerique/widgets/cultural_theme.dart';

class PublicQuizScreen extends StatefulWidget {
  const PublicQuizScreen({super.key});

  @override
  State<PublicQuizScreen> createState() => _PublicQuizScreenState();
}

class _PublicQuizScreenState extends State<PublicQuizScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  bool _isLoggedIn = false;

  final List<Map<String, dynamic>> _quizzes = [
    {
      'title': 'Les grands empires du Mali',
      'subtitle': 'Soundiata Keïta, Kankou Moussa et la charte de Kouroukan Fouga.',
      'questionsCount': 10,
      'duration': '5 min',
      'points': 50,
      'image': 'assets/images/Djata.jpg',
      'level': 'Débutant',
    },
    {
      'title': 'Sagesse des Proverbes Bambara',
      'subtitle': 'Découvrez les énigmes et vérités cachées dans les paroles des anciens.',
      'questionsCount': 8,
      'duration': '4 min',
      'points': 40,
      'image': 'assets/images/ancient-baobab.jpg',
      'level': 'Intermédiaire',
    },
    {
      'title': 'Artisanat & Symboles Dogons',
      'subtitle': 'Poterie, tissage du Bogolan et sculptures sacrées.',
      'questionsCount': 12,
      'duration': '6 min',
      'points': 60,
      'image': 'assets/images/bogolan.jpg',
      'level': 'Avancé',
    },
    {
      'title': 'Instruments traditionnels mandingues',
      'subtitle': 'Reconnaître la Kora, le Balafon, le N\'goni et le Djembe.',
      'questionsCount': 10,
      'duration': '5 min',
      'points': 50,
      'image': 'assets/images/balafon.jpg',
      'level': 'Débutant',
    },
  ];

  final List<Map<String, dynamic>> _leaderboard = [
    {'rank': 1, 'name': 'Amadou Traoré', 'points': 420, 'city': 'Bamako', 'badge': '🥇'},
    {'rank': 2, 'name': 'Fatoumata Diarra', 'points': 380, 'city': 'Ségou', 'badge': '🥈'},
    {'rank': 3, 'name': 'Bakary Coulibaly', 'points': 345, 'city': 'Mopti', 'badge': '🥉'},
    {'rank': 4, 'name': 'Mariam Keïta', 'points': 290, 'city': 'Sikasso', 'badge': '⭐'},
    {'rank': 5, 'name': 'Sekou Touré', 'points': 250, 'city': 'Kayes', 'badge': '⭐'},
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _checkAuth();
  }

  Future<void> _checkAuth() async {
    final token = await TokenStorageService().getAuthToken();
    if (mounted) {
      setState(() {
        _isLoggedIn = token != null && token.isNotEmpty;
      });
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _showRegistrationPrompt() {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext ctx) {
        return Dialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
          elevation: 10,
          backgroundColor: Colors.white,
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Badge cadenas / trophée
                Container(
                  width: 70,
                  height: 70,
                  decoration: BoxDecoration(
                    color: CulturalTheme.primaryOcre.withOpacity(0.12),
                    shape: BoxShape.circle,
                  ),
                  child: const Center(
                    child: Icon(
                      Icons.lock_outline,
                      color: CulturalTheme.primaryDarkOcre,
                      size: 34,
                    ),
                  ),
                ),
                const SizedBox(height: 18),
                const Text(
                  'Quiz Culturels',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: CulturalTheme.textDark,
                  ),
                ),
                const SizedBox(height: 12),
                const Text(
                  'Veuillez créer un compte et vous inscrire pour voir plus, participer et tester vos connaissances.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 14,
                    color: CulturalTheme.textMuted,
                    height: 1.45,
                  ),
                ),
                const SizedBox(height: 24),
                // Bouton Créer un compte
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.pop(ctx);
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const RegistrationScreen()),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: CulturalTheme.primaryDarkOcre,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(24),
                      ),
                      elevation: 3,
                    ),
                    child: const Text(
                      'Créer un compte',
                      style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                // Bouton Se connecter
                TextButton(
                  onPressed: () {
                    Navigator.pop(ctx);
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const LoginScreen()),
                    );
                  },
                  child: const Text(
                    'Pas de compte ? S\'inscrire',
                    style: TextStyle(
                      color: CulturalTheme.primaryDarkOcre,
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: CulturalTheme.backgroundLight,
      bottomNavigationBar: const BottomNavigationWidget(currentPage: 'quiz'),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        automaticallyImplyLeading: false,
        title: const Text(
          'Quiz culturels',
          style: TextStyle(
            color: CulturalTheme.textDark,
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        actions: [
          // Badge des points
          Container(
            margin: const EdgeInsets.only(right: 16, top: 10, bottom: 10),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            decoration: BoxDecoration(
              color: CulturalTheme.primaryOcre.withOpacity(0.15),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: CulturalTheme.primaryOcre.withOpacity(0.4)),
            ),
            child: Row(
              children: const [
                Icon(Icons.emoji_events, color: CulturalTheme.primaryDarkOcre, size: 18),
                SizedBox(width: 6),
                Text(
                  '75 pts',
                  style: TextStyle(
                    color: CulturalTheme.primaryDarkOcre,
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          labelColor: CulturalTheme.primaryDarkOcre,
          unselectedLabelColor: CulturalTheme.textMuted,
          indicatorColor: CulturalTheme.primaryDarkOcre,
          indicatorWeight: 3,
          labelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
          tabs: const [
            Tab(text: 'Quiz disponibles'),
            Tab(text: 'Classements'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildAvailableQuizzesTab(),
          _buildLeaderboardTab(),
        ],
      ),
    );
  }

  Widget _buildAvailableQuizzesTab() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // Bannière d'invitation
        Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            gradient: CulturalTheme.heroGradient,
            borderRadius: BorderRadius.circular(20),
            boxShadow: CulturalTheme.softShadow,
          ),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: const [
                    Text(
                      'Défiez vos connaissances !',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    SizedBox(height: 6),
                    Text(
                      'Découvrez des anecdotes fascinantes sur le patrimoine et devenez un champion.',
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 12,
                        height: 1.3,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 10),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.25),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.school, color: Colors.white, size: 30),
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),

        // Boîte incitative d'avertissement pour visiteur public
        if (!_isLoggedIn)
          Container(
            margin: const EdgeInsets.only(bottom: 16),
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            decoration: BoxDecoration(
              color: Colors.amber.shade50,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: Colors.amber.shade300),
            ),
            child: Row(
              children: [
                const Icon(Icons.info_outline, color: CulturalTheme.primaryDarkOcre, size: 22),
                const SizedBox(width: 10),
                const Expanded(
                  child: Text(
                    'Connectez-vous pour débloquer tous les quiz et enregistrer vos scores.',
                    style: TextStyle(fontSize: 12, color: Color(0xFF6B4800)),
                  ),
                ),
                TextButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const LoginScreen()),
                    );
                  },
                  child: const Text(
                    'Connexion',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: CulturalTheme.primaryDarkOcre),
                  ),
                ),
              ],
            ),
          ),

        // Liste des quiz
        ..._quizzes.map((quiz) => _buildQuizCard(quiz)),
      ],
    );
  }

  Widget _buildQuizCard(Map<String, dynamic> quiz) {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFEFE8DA)),
        boxShadow: CulturalTheme.softShadow,
      ),
      child: InkWell(
        onTap: _showRegistrationPrompt,
        borderRadius: BorderRadius.circular(18),
        child: Padding(
          padding: const EdgeInsets.all(14.0),
          child: Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(14),
                child: SizedBox(
                  width: 75,
                  height: 75,
                  child: Image.asset(
                    quiz['image'] as String,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => Container(
                      color: CulturalTheme.primaryOcre.withOpacity(0.2),
                      child: const Icon(Icons.quiz, color: CulturalTheme.primaryOcre),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                          decoration: BoxDecoration(
                            color: CulturalTheme.primaryOcre.withOpacity(0.12),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            quiz['level'] as String,
                            style: const TextStyle(
                              color: CulturalTheme.primaryDarkOcre,
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          '${quiz['questionsCount']} questions • ${quiz['duration']}',
                          style: const TextStyle(fontSize: 10, color: CulturalTheme.textMuted),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text(
                      quiz['title'] as String,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: CulturalTheme.textDark,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      quiz['subtitle'] as String,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 12,
                        color: CulturalTheme.textMuted,
                        height: 1.3,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              // Cadenas ou flèche
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: CulturalTheme.primaryOcre.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.lock_outline,
                  color: CulturalTheme.primaryDarkOcre,
                  size: 18,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLeaderboardTab() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // Carte podium
        Container(
          padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: CulturalTheme.softShadow,
          ),
          child: Column(
            children: [
              const Text(
                'Top Champions Culturels',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: CulturalTheme.textDark,
                ),
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  // 2ème place
                  _buildPodiumStep('2', _leaderboard[1]['name'] as String, '${_leaderboard[1]['points']} pts', 75, Colors.blueGrey.shade300),
                  // 1ère place
                  _buildPodiumStep('1', _leaderboard[0]['name'] as String, '${_leaderboard[0]['points']} pts', 100, const Color(0xFFFFD700)),
                  // 3ème place
                  _buildPodiumStep('3', _leaderboard[2]['name'] as String, '${_leaderboard[2]['points']} pts', 60, const Color(0xFFCD7F32)),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),

        // Carte d'incitation à participer
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: CulturalTheme.backgroundLight,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: CulturalTheme.primaryOcre.withOpacity(0.3)),
          ),
          child: Row(
            children: [
              const Icon(Icons.star, color: CulturalTheme.primaryDarkOcre, size: 28),
              const SizedBox(width: 12),
              const Expanded(
                child: Text(
                  'Inscrivez-vous pour entrer dans le classement et représenter votre famille.',
                  style: TextStyle(fontSize: 12, color: CulturalTheme.textDark),
                ),
              ),
              ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const RegistrationScreen()),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: CulturalTheme.primaryDarkOcre,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                ),
                child: const Text('Rejoindre', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),

        // Reste du classement
        ..._leaderboard.map((player) {
          return Container(
            margin: const EdgeInsets.only(bottom: 10),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: const Color(0xFFF0EBE0)),
            ),
            child: Row(
              children: [
                Text(
                  player['badge'] as String,
                  style: const TextStyle(fontSize: 20),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        player['name'] as String,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: CulturalTheme.textDark,
                        ),
                      ),
                      Text(
                        player['city'] as String,
                        style: const TextStyle(fontSize: 11, color: CulturalTheme.textMuted),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: CulturalTheme.primaryOcre.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    '${player['points']} pts',
                    style: const TextStyle(
                      color: CulturalTheme.primaryDarkOcre,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ),
          );
        }),
      ],
    );
  }

  Widget _buildPodiumStep(String rank, String name, String points, double height, Color color) {
    return Column(
      children: [
        Text(
          name.split(' ').first,
          style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 4),
        Text(
          points,
          style: const TextStyle(fontSize: 10, color: CulturalTheme.textMuted),
        ),
        const SizedBox(height: 6),
        Container(
          width: 65,
          height: height,
          decoration: BoxDecoration(
            color: color.withOpacity(0.85),
            borderRadius: const BorderRadius.vertical(top: Radius.circular(10)),
          ),
          child: Center(
            child: Text(
              rank,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 20,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
