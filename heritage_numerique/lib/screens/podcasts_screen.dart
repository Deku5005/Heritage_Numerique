import 'package:flutter/material.dart';
import 'package:heritage_numerique/screens/artisans_screen.dart';
import 'package:heritage_numerique/screens/contes_screen.dart';
import 'package:heritage_numerique/screens/music_screen.dart';
import 'package:heritage_numerique/screens/podcast_player_screen.dart';
import 'package:heritage_numerique/screens/proverb_screen.dart';
import 'package:heritage_numerique/widgets/bottom_navigation_widget.dart';
import 'package:heritage_numerique/widgets/cultural_theme.dart';

class PodcastsScreen extends StatefulWidget {
  const PodcastsScreen({super.key});

  @override
  State<PodcastsScreen> createState() => _PodcastsScreenState();
}

class _PodcastsScreenState extends State<PodcastsScreen> {
  String _selectedFilter = 'Podcasts';

  final List<String> _filters = ['Tous', 'Contes', 'Proverbes', 'Devinettes', 'Artisanat', 'Podcasts'];

  final List<Map<String, dynamic>> _episodes = [
    {
      'title': 'Les femmes gardiennes du savoir',
      'category': 'Artisanat & Société',
      'subtitle': 'La transmission du savoir-faire des femmes dans la poterie et le textile au Mali.',
      'image': 'assets/images/african-woman-pottery-clay-traditional.jpg',
      'duration': '14 min',
      'author': 'Fanta Coulibaly',
    },
    {
      'title': 'Les mélodies sacrées de la Kora',
      'category': 'Musique Traditionnelle',
      'subtitle': 'L\'instrument des rois et des griots qui fait résonner 21 cordes vers le ciel.',
      'image': 'assets/images/kora.jpg',
      'duration': '18 min',
      'author': 'Toumani Diabaté',
    },
    {
      'title': 'La confrérie des chasseurs du Mandé',
      'category': 'Histoire & Mystères',
      'subtitle': 'Le Dozo Ton et les secrets initiatiques transmis depuis Soundiata Keïta.',
      'image': 'assets/images/touareg-musicians-desert-performance.jpg',
      'duration': '22 min',
      'author': 'Ousmane Sangaré',
    },
    {
      'title': 'Le fleuve Niger et ses génies tutélaires',
      'category': 'Mythologie & Fleuve',
      'subtitle': 'Les croyances Bozo et les légendes aquatiques qui bordent le fleuve Djoliba.',
      'image': 'assets/images/african-river.jpg',
      'duration': '15 min',
      'author': 'Alassane Bozo',
    },
    {
      'title': 'Balafon et fêtes de village',
      'category': 'Musique & Danse',
      'subtitle': 'Les réjouissances populaires au rythme des lamelles de bois enchantées.',
      'image': 'assets/images/balafon.jpg',
      'duration': '11 min',
      'author': 'Famille Kiénou',
    },
  ];

  void _onFilterTap(String filter) {
    if (filter == _selectedFilter) return;
    setState(() {
      _selectedFilter = filter;
    });

    if (filter == 'Contes') {
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const ContesScreen()));
    } else if (filter == 'Proverbes') {
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const ProverbScreen()));
    } else if (filter == 'Devinettes') {
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const MusicScreen()));
    } else if (filter == 'Artisanat') {
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const ArtisansScreen()));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: CulturalTheme.backgroundLight,
      bottomNavigationBar: const BottomNavigationWidget(currentPage: 'decouvrir'),
      body: CustomScrollView(
        slivers: [
          // AppBar
          SliverAppBar(
            backgroundColor: Colors.white,
            pinned: true,
            elevation: 0,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back, color: CulturalTheme.textDark),
              onPressed: () => Navigator.of(context).maybePop(),
            ),
            title: const Text(
              'Héritage Numérique',
              style: TextStyle(
                color: CulturalTheme.textDark,
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
            ),
            actions: [
              IconButton(
                icon: const Icon(Icons.search, color: CulturalTheme.textDark),
                onPressed: () {},
              ),
            ],
          ),

          // Bannière Explorer
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
              child: Container(
                height: 140,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(18),
                  image: const DecorationImage(
                    image: AssetImage('assets/images/african-traditional-music-instruments.jpg'),
                    fit: BoxFit.cover,
                  ),
                  boxShadow: CulturalTheme.softShadow,
                ),
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(18),
                    gradient: LinearGradient(
                      colors: [Colors.black.withOpacity(0.75), Colors.black.withOpacity(0.3)],
                      begin: Alignment.bottomLeft,
                      end: Alignment.topRight,
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: const [
                      Text(
                        'Explorer',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        'Podcasts & récits audio immersifs du Mali',
                        style: TextStyle(
                          color: Colors.white70,
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),

          // Filtres
          SliverToBoxAdapter(
            child: SizedBox(
              height: 42,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: _filters.length,
                separatorBuilder: (_, __) => const SizedBox(width: 8),
                itemBuilder: (context, index) {
                  final filter = _filters[index];
                  final isSelected = filter == _selectedFilter;
                  return InkWell(
                    onTap: () => _onFilterTap(filter),
                    borderRadius: BorderRadius.circular(20),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      decoration: BoxDecoration(
                        color: isSelected ? CulturalTheme.primaryDarkOcre : Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: isSelected ? CulturalTheme.primaryDarkOcre : const Color(0xFFE0E0E0),
                        ),
                      ),
                      child: Center(
                        child: Text(
                          filter,
                          style: TextStyle(
                            color: isSelected ? Colors.white : CulturalTheme.textDark,
                            fontSize: 12,
                            fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ),

          // En vedette
          const SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.fromLTRB(16, 20, 16, 10),
              child: Text(
                'Épisode à l\'honneur',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: CulturalTheme.textDark,
                ),
              ),
            ),
          ),

          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: InkWell(
                onTap: () {
                  final ep = _episodes.first;
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => PodcastPlayerScreen(
                        title: ep['title'] as String,
                        category: ep['category'] as String,
                        subtitle: ep['subtitle'] as String,
                        image: ep['image'] as String,
                        duration: ep['duration'] as String,
                      ),
                    ),
                  );
                },
                borderRadius: BorderRadius.circular(18),
                child: Container(
                  height: 160,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(18),
                    image: DecorationImage(
                      image: AssetImage(_episodes.first['image'] as String),
                      fit: BoxFit.cover,
                    ),
                    boxShadow: CulturalTheme.softShadow,
                  ),
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(18),
                      gradient: const LinearGradient(
                        colors: [Colors.transparent, Colors.black87],
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                      ),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              Text(
                                _episodes.first['title'] as String,
                                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                '${_episodes.first['author']} • ${_episodes.first['duration']}',
                                style: const TextStyle(color: Colors.white70, fontSize: 12),
                              ),
                            ],
                          ),
                        ),
                        Container(
                          width: 44,
                          height: 44,
                          decoration: const BoxDecoration(
                            color: CulturalTheme.primaryOcre,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.play_arrow, color: Colors.white, size: 28),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),

          // Liste des épisodes
          const SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.fromLTRB(16, 22, 16, 10),
              child: Text(
                'Tous les épisodes',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: CulturalTheme.textDark,
                ),
              ),
            ),
          ),

          SliverList(
            delegate: SliverChildBuilderDelegate(
              (context, index) {
                final ep = _episodes[index];
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 6.0),
                  child: InkWell(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => PodcastPlayerScreen(
                            title: ep['title'] as String,
                            category: ep['category'] as String,
                            subtitle: ep['subtitle'] as String,
                            image: ep['image'] as String,
                            duration: ep['duration'] as String,
                          ),
                        ),
                      );
                    },
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
                          ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: SizedBox(
                              width: 75,
                              height: 75,
                              child: Image.asset(ep['image'] as String, fit: BoxFit.cover),
                            ),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  ep['title'] as String,
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
                                  ep['subtitle'] as String,
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                    fontSize: 12,
                                    color: CulturalTheme.textMuted,
                                    height: 1.3,
                                  ),
                                ),
                                const SizedBox(height: 6),
                                Text(
                                  '${ep['author']} • ${ep['duration']}',
                                  style: const TextStyle(fontSize: 11, color: CulturalTheme.primaryDarkOcre, fontWeight: FontWeight.w600),
                                ),
                              ],
                            ),
                          ),
                          Container(
                            width: 36,
                            height: 36,
                            decoration: BoxDecoration(
                              color: CulturalTheme.primaryOcre.withOpacity(0.15),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(Icons.play_arrow, color: CulturalTheme.primaryDarkOcre, size: 22),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
              childCount: _episodes.length,
            ),
          ),

          const SliverToBoxAdapter(child: SizedBox(height: 40)),
        ],
      ),
    );
  }
}
