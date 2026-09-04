import 'package:flutter/material.dart';
import 'package:heritage_numerique/Service/token-storage-service.dart';
import 'package:heritage_numerique/Service/Auth-service.dart';
import 'package:heritage_numerique/Service/conteService.dart';
import 'package:heritage_numerique/model/conte.dart';
import 'package:heritage_numerique/model/Artisanat1.dart';
import 'package:heritage_numerique/screens/affichage_contes_screen.dart';
import 'package:heritage_numerique/screens/Artisan_detail_screen.dart';
import 'package:heritage_numerique/screens/proverb_detail_screen.dart';
import 'package:heritage_numerique/screens/contes_screen.dart';
import 'package:heritage_numerique/screens/login_screen.dart';
import 'package:heritage_numerique/screens/music_screen.dart';
import 'package:heritage_numerique/screens/dashboard_screen.dart';
import 'package:heritage_numerique/widgets/bottom_navigation_widget.dart';
import 'package:heritage_numerique/widgets/cultural_theme.dart';

class PublicHomeScreen extends StatefulWidget {
  const PublicHomeScreen({super.key});

  @override
  State<PublicHomeScreen> createState() => _PublicHomeScreenState();
}

class _PublicHomeScreenState extends State<PublicHomeScreen> {
  final ConteService _conteService = ConteService();
  final TextEditingController _searchController = TextEditingController();

  List<Conte> _apiContes = [];
  bool _isLoading = true;
  bool _isLoggedIn = false;
  String _userName = 'Oumar DOLO';
  String _userInitials = 'OD';
  String _searchQuery = '';

  // Carrousel "En vedette" (Écran 1 de la maquette Figma)
  final List<Map<String, dynamic>> _enVedetteItems = [
    {
      'title': "L'épopée de Soundiata Keïta",
      'tag': 'Conte',
      'timeAgo': 'il y a 2h',
      'duration': '15 min',
      'likes': 2,
      'image': 'assets/images/Djata.jpg',
      'category': 'Contes',
      'author': 'Grand-mère Aminata',
    },
    {
      'title': "L'épopée de Soundiata Keïta",
      'tag': 'Podcast',
      'timeAgo': 'il y a 2h',
      'duration': '15 min',
      'likes': 2,
      'image': 'assets/images/african-traditional-music-instruments.jpg',
      'category': 'Podcasts',
      'author': 'Grand-père Amadou',
    },
    {
      'title': "Poterie de Kalabougou",
      'tag': 'Artisanat',
      'timeAgo': 'il y a 2h',
      'duration': '15 min',
      'likes': 2,
      'image': 'assets/images/african-woman-pottery-clay-traditional.jpg',
      'category': 'Artisanat',
      'author': 'Potières du Niger',
    },
  ];

  // Liste "Découvrir" (Écran 1 de la maquette Figma)
  final List<Map<String, dynamic>> _decouvrirItems = [
    {
      'title': 'Le Baobab Sacré de Bamako',
      'author': 'Grand père Amadou',
      'category': 'Conte',
      'duration': '12 min',
      'likes': 2,
      'timeAgo': 'il y a 1h',
      'image': 'assets/images/african-village.jpg',
    },
    {
      'title': 'La parole est comme l\'eau',
      'author': 'Grand père Amadou',
      'category': 'Proverbe',
      'duration': '12 min',
      'likes': 2,
      'timeAgo': 'il y a 1h',
      'image': 'assets/images/ancient-baobab.jpg',
    },
    {
      'title': 'L\'énigme du sage chasseur',
      'author': 'Grand père Amadou',
      'category': 'Devinette',
      'duration': '12 min',
      'likes': 3,
      'timeAgo': 'il y a 1h',
      'image': 'assets/images/musiques.jpg',
    },
    {
      'title': 'Masque Bogolan Ancestral',
      'author': 'Grand père Amadou',
      'category': 'Artisanat',
      'duration': '15 min',
      'likes': 2,
      'timeAgo': 'il y a 1h',
      'image': 'assets/images/artisanat.jpg',
    },
  ];

  @override
  void initState() {
    super.initState();
    _checkAuth();
    _loadContes();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _checkAuth() async {
    final token = await TokenStorageService().getAuthToken();
    if (token != null && token.isNotEmpty) {
      try {
        final dashboard = await AuthService().fetchPersonnelDashboard();
        if (mounted) {
          setState(() {
            _isLoggedIn = true;
            if (dashboard.prenom.isNotEmpty) {
              _userName = dashboard.prenom;
              _userInitials = _userName.trim().isNotEmpty ? _userName.trim()[0].toUpperCase() : 'OD';
            }
          });
        }
      } catch (_) {
        if (mounted) {
          setState(() {
            _isLoggedIn = true;
          });
        }
      }
    } else {
      if (mounted) {
        setState(() {
          _isLoggedIn = false;
        });
      }
    }
  }

  Future<void> _loadContes() async {
    try {
      final contes = await _conteService.getContes();
      if (mounted) {
        setState(() {
          _apiContes = contes;
          _isLoading = false;
        });
      }
    } catch (_) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _onSearchChanged(String query) {
    setState(() {
      _searchQuery = query.toLowerCase().trim();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: CulturalTheme.backgroundLight,
      bottomNavigationBar: const BottomNavigationWidget(currentPage: 'accueil'),
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          // 1. En-tête AppBar stylisée (adaptée selon l'état connecté ou visiteur)
          _buildSliverAppBar(),

          // 2. Bannière Hero "Heritage Numerique" avec barre de recherche intégrée
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16.0, 8.0, 16.0, 16.0),
              child: _buildFeaturedBanner(),
            ),
          ),

          if (_isLoading)
            const SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 4.0),
                child: LinearProgressIndicator(
                  color: CulturalTheme.primaryOcre,
                  backgroundColor: Color(0xFFFBE8C3),
                  minHeight: 2,
                ),
              ),
            ),

          // 3. Section "⭐ En vedette" (Carrousel horizontal)
          if (_searchQuery.isEmpty) ...[
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16.0, 4.0, 16.0, 12.0),
                child: Row(
                  children: const [
                    Icon(Icons.star, color: Color(0xFFEBC15F), size: 20),
                    SizedBox(width: 6),
                    Text(
                      'En vedette',
                      style: TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.bold,
                        color: CulturalTheme.textDark,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            SliverToBoxAdapter(
              child: _buildEnVedetteCarousel(),
            ),
            const SliverToBoxAdapter(child: SizedBox(height: 20)),
          ],

          // 4. Section "Découvrir" (En-tête avec lien "Voir tout >")
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16.0, 0.0, 16.0, 10.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    _searchQuery.isEmpty ? 'Découvrir' : 'Résultats de recherche',
                    style: const TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.bold,
                      color: CulturalTheme.textDark,
                    ),
                  ),
                  if (_searchQuery.isEmpty)
                    InkWell(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => const ContesScreen()),
                        );
                      },
                      child: Row(
                        children: const [
                          Text(
                            'Voir tout',
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: CulturalTheme.primaryDarkOcre,
                            ),
                          ),
                          Icon(Icons.chevron_right, size: 16, color: CulturalTheme.primaryDarkOcre),
                        ],
                      ),
                    ),
                ],
              ),
            ),
          ),

          // 5. Liste des cartes Découvrir
          _buildDecouvrirList(),

          const SliverToBoxAdapter(child: SizedBox(height: 35)),
        ],
      ),
    );
  }

  // --- 1. En-tête AppBar ---
  Widget _buildSliverAppBar() {
    if (_isLoggedIn) {
      // Version Connectée (Écran 1 de la maquette) : Avatar initiales + "Bienvenu Oumar DOLO" + Cloche + Réglages
      return SliverAppBar(
        backgroundColor: Colors.white,
        pinned: true,
        elevation: 0,
        automaticallyImplyLeading: false,
        title: Row(
          children: [
            CircleAvatar(
              radius: 18,
              backgroundColor: const Color(0xFFFBE8C3),
              child: Text(
                _userInitials,
                style: const TextStyle(
                  color: CulturalTheme.primaryOcre,
                  fontWeight: FontWeight.bold,
                  fontSize: 13,
                ),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                'Bienvenu $_userName',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  color: CulturalTheme.textDark,
                ),
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: Stack(
              children: [
                const Icon(Icons.notifications_none_outlined, color: CulturalTheme.textDark, size: 24),
                Positioned(
                  right: 2,
                  top: 2,
                  child: Container(
                    width: 8,
                    height: 8,
                    decoration: const BoxDecoration(
                      color: Colors.redAccent,
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
              ],
            ),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Aucune nouvelle notification pour le moment.'),
                  duration: Duration(seconds: 2),
                  behavior: SnackBarBehavior.floating,
                ),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.settings_outlined, color: CulturalTheme.textDark, size: 24),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const DashboardScreen()),
              );
            },
          ),
          const SizedBox(width: 4),
        ],
      );
    }

    // Version Visiteur Non Connecté
    return SliverAppBar(
      backgroundColor: Colors.white,
      pinned: true,
      elevation: 0,
      automaticallyImplyLeading: false,
      title: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: CulturalTheme.primaryOcre, width: 1.5),
            ),
            child: ClipOval(
              child: Image.asset(
                'assets/images/Heritage1.png',
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => const Icon(Icons.account_balance, color: CulturalTheme.primaryOcre, size: 20),
              ),
            ),
          ),
          const SizedBox(width: 10),
          const Text(
            'Héritage Numérique',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w800,
              color: CulturalTheme.textDark,
              letterSpacing: 0.3,
            ),
          ),
        ],
      ),
      actions: [
        Padding(
          padding: const EdgeInsets.only(right: 12.0),
          child: TextButton.icon(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const LoginScreen()),
              );
            },
            icon: const Icon(Icons.login, size: 18, color: CulturalTheme.primaryDarkOcre),
            label: const Text(
              'Connexion',
              style: TextStyle(
                color: CulturalTheme.primaryDarkOcre,
                fontWeight: FontWeight.bold,
                fontSize: 13,
              ),
            ),
          ),
        ),
      ],
    );
  }

  // --- 2. Bannière Hero avec Barre de Recherche ---
  Widget _buildFeaturedBanner() {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(22),
        image: const DecorationImage(
          image: AssetImage('assets/images/african-village.jpg'),
          fit: BoxFit.cover,
        ),
        boxShadow: CulturalTheme.softShadow,
      ),
      child: Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(22),
          gradient: LinearGradient(
            colors: [
              Colors.black.withValues(alpha: 0.8),
              Colors.black.withValues(alpha: 0.45),
            ],
            begin: Alignment.bottomLeft,
            end: Alignment.topRight,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 10),
            const Text(
              'Heritage\nNumerique',
              style: TextStyle(
                color: Colors.white,
                fontSize: 26,
                fontWeight: FontWeight.w900,
                height: 1.15,
                letterSpacing: 0.4,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Préservez et transmettez le patrimoine culturel malien aux générations futures',
              style: TextStyle(
                color: Colors.white70,
                fontSize: 12,
                height: 1.4,
              ),
            ),
            const SizedBox(height: 18),

            // Champ de recherche intégré dans la bannière
            Container(
              height: 44,
              padding: const EdgeInsets.symmetric(horizontal: 14),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(25),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.12),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Row(
                children: [
                  const Icon(Icons.search, color: Color(0xFF9E9E9E), size: 20),
                  const SizedBox(width: 8),
                  Expanded(
                    child: TextField(
                      controller: _searchController,
                      onChanged: _onSearchChanged,
                      decoration: const InputDecoration(
                        hintText: 'Rechercher conte, proverbe...',
                        hintStyle: TextStyle(color: Color(0xFF9E9E9E), fontSize: 13),
                        border: InputBorder.none,
                        isDense: true,
                      ),
                    ),
                  ),
                  if (_searchQuery.isNotEmpty)
                    GestureDetector(
                      onTap: () {
                        _searchController.clear();
                        _onSearchChanged('');
                      },
                      child: const Icon(Icons.clear, color: Colors.grey, size: 18),
                    ),
                ],
              ),
            ),
            const SizedBox(height: 4),
          ],
        ),
      ),
    );
  }

  // --- 3. Carrousel "En vedette" ---
  Widget _buildEnVedetteCarousel() {
    return SizedBox(
      height: 145,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: _enVedetteItems.length,
        separatorBuilder: (_, __) => const SizedBox(width: 14),
        itemBuilder: (context, index) {
          final item = _enVedetteItems[index];
          return InkWell(
            onTap: () => _openItemDetail(item),
            borderRadius: BorderRadius.circular(16),
            child: Container(
              width: 230,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                image: DecorationImage(
                  image: AssetImage(item['image'] as String),
                  fit: BoxFit.cover,
                ),
                boxShadow: CulturalTheme.softShadow,
              ),
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  gradient: LinearGradient(
                    colors: [
                      Colors.black.withValues(alpha: 0.25),
                      Colors.black.withValues(alpha: 0.85),
                    ],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Tag & Date relative en haut
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: CulturalTheme.primaryOcre,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            item['tag'] as String,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        Text(
                          item['timeAgo'] as String,
                          style: const TextStyle(color: Colors.white70, fontSize: 10),
                        ),
                      ],
                    ),

                    // Titre et statistiques en bas
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          item['title'] as String,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            const Icon(Icons.access_time, size: 12, color: Colors.white70),
                            const SizedBox(width: 4),
                            Text(
                              item['duration'] as String,
                              style: const TextStyle(color: Colors.white70, fontSize: 10),
                            ),
                            const SizedBox(width: 12),
                            const Icon(Icons.favorite_border, size: 12, color: Colors.white70),
                            const SizedBox(width: 4),
                            Text(
                              '${item['likes']}',
                              style: const TextStyle(color: Colors.white70, fontSize: 10),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  // --- 4. Liste "Découvrir" ---
  Widget _buildDecouvrirList() {
    final List<Map<String, dynamic>> combined = [];

    // Ajouter les contes venant de l'API s'ils existent
    if (_apiContes.isNotEmpty) {
      for (final c in _apiContes) {
        final author = '${c.prenomAuteur} ${c.nomAuteur}'.trim();
        combined.add({
          'title': c.titre.isNotEmpty ? c.titre : 'Conte Malien',
          'author': author.isNotEmpty ? author : 'Conteur Traditionnel',
          'category': 'Conte',
          'duration': '15 min',
          'likes': 4,
          'timeAgo': 'Récent',
          'image': c.urlPhoto.isNotEmpty ? c.urlPhoto : 'assets/images/african-village.jpg',
          'conteModel': c,
        });
      }
    }

    // Ajouter les éléments de base / démo
    combined.addAll(_decouvrirItems);

    List<Map<String, dynamic>> itemsToShow = combined;

    if (_searchQuery.isNotEmpty) {
      itemsToShow = combined.where((item) {
        final title = (item['title'] as String).toLowerCase();
        final cat = (item['category'] as String).toLowerCase();
        final author = (item['author'] as String).toLowerCase();
        return title.contains(_searchQuery) || cat.contains(_searchQuery) || author.contains(_searchQuery);
      }).toList();
    }

    if (itemsToShow.isEmpty) {
      return SliverToBoxAdapter(
        child: Padding(
          padding: const EdgeInsets.all(32.0),
          child: Center(
            child: Column(
              children: const [
                Icon(Icons.search_off, size: 40, color: Colors.grey),
                SizedBox(height: 8),
                Text('Aucun contenu ne correspond à votre recherche', style: TextStyle(color: Colors.grey)),
              ],
            ),
          ),
        ),
      );
    }

    return SliverList(
      delegate: SliverChildBuilderDelegate(
        (context, index) {
          final item = itemsToShow[index];
          final String imgPath = item['image'] as String? ?? 'assets/images/african-village.jpg';
          final bool isNetwork = imgPath.startsWith('http://') || imgPath.startsWith('https://');

          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 5.0),
            child: InkWell(
              onTap: () => _openItemDetail(item),
              borderRadius: BorderRadius.circular(16),
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: const Color(0xFFF0EBE0)),
                  boxShadow: CulturalTheme.softShadow,
                ),
                child: Row(
                  children: [
                    // Miniature image carrée
                    ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: SizedBox(
                        width: 76,
                        height: 76,
                        child: isNetwork
                            ? Image.network(
                                imgPath,
                                fit: BoxFit.cover,
                                errorBuilder: (_, __, ___) => Container(
                                  color: CulturalTheme.primaryOcre.withValues(alpha: 0.2),
                                  child: const Icon(Icons.image, color: CulturalTheme.primaryOcre),
                                ),
                              )
                            : Image.asset(
                                imgPath,
                                fit: BoxFit.cover,
                                errorBuilder: (_, __, ___) => Container(
                                  color: CulturalTheme.primaryOcre.withValues(alpha: 0.2),
                                  child: const Icon(Icons.image, color: CulturalTheme.primaryOcre),
                                ),
                              ),
                      ),
                    ),
                    const SizedBox(width: 14),

                    // Informations
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                decoration: BoxDecoration(
                                  color: CulturalTheme.primaryOcre.withValues(alpha: 0.12),
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: Text(
                                  item['category'] as String,
                                  style: const TextStyle(
                                    color: CulturalTheme.primaryDarkOcre,
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              Text(
                                item['timeAgo'] as String,
                                style: const TextStyle(color: Color(0xFF9E9E9E), fontSize: 10),
                              ),
                            ],
                          ),
                          const SizedBox(height: 6),
                          Text(
                            item['title'] as String,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: CulturalTheme.textDark,
                            ),
                          ),
                          const SizedBox(height: 3),
                          Text(
                            item['author'] as String,
                            style: const TextStyle(fontSize: 11, color: CulturalTheme.textMuted),
                          ),
                          const SizedBox(height: 6),
                          Row(
                            children: [
                              const Icon(Icons.access_time, size: 12, color: CulturalTheme.textMuted),
                              const SizedBox(width: 4),
                              Text(
                                item['duration'] as String,
                                style: const TextStyle(fontSize: 11, color: CulturalTheme.textMuted),
                              ),
                              const SizedBox(width: 12),
                              const Icon(Icons.favorite_border, size: 12, color: CulturalTheme.textMuted),
                              const SizedBox(width: 4),
                              Text(
                                '${item['likes']}',
                                style: const TextStyle(fontSize: 11, color: CulturalTheme.textMuted),
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
          );
        },
        childCount: itemsToShow.length,
      ),
    );
  }

  // --- 5. Ouverture universelle de l'écran de détail ---
  void _openItemDetail(Map<String, dynamic> item) {
    if (item['conteModel'] != null && item['conteModel'] is Conte) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => AffichageContesScreen(conte: item['conteModel'] as Conte),
        ),
      );
      return;
    }

    final String cat = (item['category'] as String? ?? '').toLowerCase();

    if (cat.contains('artisanat')) {
      final artisan = Artisanat1(
        id: 1,
        titre: item['title'] as String,
        description: "${item['title']} - Un savoir-faire ancestral transmis avec fierté au Mali depuis plusieurs générations.",
        nomAuteur: item['author'] as String? ?? 'Maître Artisan Malien',
        prenomAuteur: '',
        emailAuteur: 'contact.artisan@heritage.ml',
        roleAuteur: 'Artisan d\'art',
        urlPhotos: [item['image'] as String],
        lieu: 'Ségou',
        region: 'Mali',
      );
      Navigator.push(context, MaterialPageRoute(builder: (context) => ArtisanDetailScreen(artisanData: artisan)));
    } else if (cat.contains('proverbe')) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => ProverbDetailScreen(
            proverbeId: 1,
            proverbText: item['title'] as String,
            source: 'Parole des sages sous le baobab',
            conteur: item['author'] as String? ?? 'Tradition orale Malienne',
            langue: 'Français',
          ),
        ),
      );
    } else if (cat.contains('devinette') || cat.contains('podcast')) {
      Navigator.push(context, MaterialPageRoute(builder: (context) => const MusicScreen()));
    } else {
      // Contes
      final conte = Conte(
        id: 1,
        titre: item['title'] as String,
        description: "Un conte traditionnel emblématique de notre riche patrimoine culturel.",
        nomAuteur: item['author'] as String? ?? 'Tradition orale',
        prenomAuteur: '',
        emailAuteur: '',
        roleAuteur: 'Conteur',
        lienParenteAuteur: '',
        dateCreation: '2024',
        statut: 'PUBLIE',
        urlFichier: '',
        urlPhoto: item['image'] as String,
        contenuFichier: "Il était une fois, dans les terres chaleureuses et ancestrales du Mandé...\n\nSous l'ombre bienveillante du grand baobab, les enfants du village se réunissaient à la tombée de la nuit. Le sage conteur transmettait les enseignements des ancêtres pour éclairer les générations futures sur la bravoure, l'honnêteté et la solidarité.",
        lieu: 'Mandé',
        region: 'Koulikoro',
        idFamille: 1,
        nomFamille: 'Tradition',
      );
      Navigator.push(context, MaterialPageRoute(builder: (context) => AffichageContesScreen(conte: conte)));
    }
  }
}
