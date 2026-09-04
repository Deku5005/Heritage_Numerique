import 'package:flutter/material.dart';
import 'package:heritage_numerique/screens/contes_screen.dart';
import 'package:heritage_numerique/screens/music_screen.dart';
import 'package:heritage_numerique/screens/proverb_screen.dart';
import 'package:heritage_numerique/widgets/bottom_navigation_widget.dart';
import 'package:heritage_numerique/widgets/cultural_theme.dart';
import 'Artisan_detail_screen.dart';
import '../model/Artisanat1.dart';
import '../Service/Artisanatservice1.dart';

/// Écran d'Artisanat selon le nouveau design Figma
class ArtisansScreen extends StatefulWidget {
  const ArtisansScreen({super.key});

  @override
  State<ArtisansScreen> createState() => _ArtisansScreenState();
}

class _ArtisansScreenState extends State<ArtisansScreen> {
  final ArtisanatService1 _artisanatService = ArtisanatService1();
  List<Artisanat1> _artisanats = [];
  bool _isLoading = true;
  String _selectedFilter = 'Artisanat';

  final List<String> _filters = ['Tous', 'Contes', 'Proverbes', 'Devinettes', 'Artisanat'];

  final List<Map<String, String>> _fallbackArtisanat = [
    {
      'title': 'Technique ancestrale de Poterie',
      'subtitle': 'L\'art des potières de Kalabougou, modelé à la main sans tour.',
      'image': 'assets/images/african-woman-pottery-clay-traditional.jpg',
      'artisan': 'Mami Kéita',
      'region': 'Ségou',
    },
    {
      'title': 'Tissage et Teinture du Bogolan',
      'subtitle': 'L\'étoffe sacrée en argile et plantes tinctoriales du Bélédougou.',
      'image': 'assets/images/bogolan.jpg',
      'artisan': 'Boubacar Doumbia',
      'region': 'San',
    },
    {
      'title': 'Bijouterie et Filigrane d\'Argent',
      'subtitle': 'La croix d\'Agadez et les parures en argent forgées par les artisans.',
      'image': 'assets/images/african-jewelry-making-silver-beads.jpg',
      'artisan': 'Mohamed Ag Oumar',
      'region': 'Tombouctou',
    },
    {
      'title': 'Sculpture sur Bois et Masques Sacrés',
      'subtitle': 'Les masques Kanaga et statuettes taillés dans les bois nobles.',
      'image': 'assets/images/african-wood-carving-sculptor-working.jpg',
      'artisan': 'Ousmane Guindo',
      'region': 'Pays Dogon',
    },
  ];

  @override
  void initState() {
    super.initState();
    _fetchArtisanats();
  }

  Future<void> _fetchArtisanats() async {
    try {
      final data = await _artisanatService.getArtisanats();
      if (mounted) {
        setState(() {
          _artisanats = data;
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
    }
  }

  String _getFullImageUrl(String? relativePath) {
    if (relativePath == null || relativePath.isEmpty) return '';
    if (relativePath.toLowerCase().startsWith('http')) return relativePath;
    final String sanitizedPath = relativePath.startsWith('/') ? relativePath.substring(1) : relativePath;
    return 'http://10.0.2.2:8080/$sanitizedPath';
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
                    image: AssetImage('assets/images/artisanat.jpg'),
                    fit: BoxFit.cover,
                  ),
                  boxShadow: CulturalTheme.softShadow,
                ),
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(18),
                    gradient: LinearGradient(
                      colors: [Colors.black.withValues(alpha: 0.75), Colors.black.withValues(alpha: 0.3)],
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
                        'Savoir-faire, métiers & créations des maîtres artisans',
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

          // Filtres horizontaux
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
                'En vedette',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: CulturalTheme.textDark,
                ),
              ),
            ),
          ),

          SliverToBoxAdapter(
            child: SizedBox(
              height: 140,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: _fallbackArtisanat.length,
                separatorBuilder: (_, __) => const SizedBox(width: 14),
                itemBuilder: (context, index) {
                  final item = _fallbackArtisanat[index];
                  return InkWell(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ArtisanDetailScreen(artisanData: _fallbackToArtisan(item, index)),
                        ),
                      );
                    },
                    borderRadius: BorderRadius.circular(16),
                    child: Container(
                      width: 240,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(16),
                        image: DecorationImage(
                          image: AssetImage(item['image']!),
                          fit: BoxFit.cover,
                        ),
                        boxShadow: CulturalTheme.softShadow,
                      ),
                      child: Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(16),
                          gradient: const LinearGradient(
                            colors: [Colors.transparent, Colors.black87],
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            Text(
                              item['title']!,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              '${item['artisan']} • ${item['region']}',
                              style: const TextStyle(color: Colors.white70, fontSize: 11),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ),

          // Titre section
          const SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.fromLTRB(16, 22, 16, 10),
              child: Text(
                'Techniques & Créations',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: CulturalTheme.textDark,
                ),
              ),
            ),
          ),

          // Liste des créations
          _buildArtisansList(),

          const SliverToBoxAdapter(child: SizedBox(height: 40)),
        ],
      ),
    );
  }

  Widget _buildArtisansList() {
    if (_isLoading) {
      return const SliverToBoxAdapter(
        child: Center(
          child: Padding(
            padding: EdgeInsets.all(30.0),
            child: CircularProgressIndicator(color: CulturalTheme.primaryOcre),
          ),
        ),
      );
    }

    if (_artisanats.isNotEmpty) {
      return SliverList(
        delegate: SliverChildBuilderDelegate(
          (context, index) {
            final art = _artisanats[index];
            final String? photoPath = (art.urlPhotos != null && art.urlPhotos!.isNotEmpty) ? art.urlPhotos!.first : null;
            final fullImg = _getFullImageUrl(photoPath);
            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 6.0),
              child: InkWell(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ArtisanDetailScreen(artisanData: art),
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
                          width: 80,
                          height: 80,
                          child: fullImg.isNotEmpty
                              ? Image.network(
                                  fullImg,
                                  fit: BoxFit.cover,
                                  errorBuilder: (_, __, ___) => Image.asset('assets/images/artisanat.jpg', fit: BoxFit.cover),
                                )
                              : Image.asset('assets/images/artisanat.jpg', fit: BoxFit.cover),
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              art.titre ?? '',
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
                              art.description ?? '',
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
                              '${art.prenomAuteur ?? ''} ${art.nomAuteur ?? ''}'.trim().isNotEmpty
                                  ? '${art.prenomAuteur ?? ''} ${art.nomAuteur ?? ''}'.trim()
                                  : 'Artisan Malien',
                              style: const TextStyle(fontSize: 11, color: CulturalTheme.primaryDarkOcre, fontWeight: FontWeight.w600),
                            ),
                          ],
                        ),
                      ),
                      const Icon(Icons.arrow_forward_ios, size: 14, color: CulturalTheme.primaryDarkOcre),
                    ],
                  ),
                ),
              ),
            );
          },
          childCount: _artisanats.length,
        ),
      );
    }

    return SliverList(
      delegate: SliverChildBuilderDelegate(
        (context, index) {
          final item = _fallbackArtisanat[index];
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 6.0),
            child: InkWell(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ArtisanDetailScreen(artisanData: _fallbackToArtisan(item, index)),
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
                        width: 80,
                        height: 80,
                        child: Image.asset(item['image']!, fit: BoxFit.cover),
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            item['title']!,
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
                            item['subtitle']!,
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
                            '${item['artisan']} • ${item['region']}',
                            style: const TextStyle(fontSize: 11, color: CulturalTheme.primaryDarkOcre, fontWeight: FontWeight.w600),
                          ),
                        ],
                      ),
                    ),
                    const Icon(Icons.arrow_forward_ios, size: 14, color: CulturalTheme.primaryDarkOcre),
                  ],
                ),
              ),
            ),
          );
        },
        childCount: _fallbackArtisanat.length,
      ),
    );
  }

  Artisanat1 _fallbackToArtisan(Map<String, String> item, int index) {
    return Artisanat1(
      id: index + 1,
      titre: item['title'] ?? 'Artisanat d\'art',
      description: "${item['title']} : une œuvre artisanale d'exception.\n\n${item['subtitle'] ?? ''}\n\nFabriqué selon des techniques séculaires transmises de génération en génération au Mali, chaque matière première est choisie avec respect. Les motifs sculptés ou tissés incarnent l'histoire, la spiritualité et l'identité des peuples du fleuve Niger et du Sahel.",
      nomAuteur: item['artisan'] ?? 'Artisan Malien',
      prenomAuteur: '',
      emailAuteur: 'artisanat@heritage.ml',
      roleAuteur: 'Maître Artisan',
      urlPhotos: [item['image'] ?? 'assets/images/artisanat.jpg'],
      lieu: item['region'] ?? 'Mali',
      region: item['region'] ?? 'Mali',
    );
  }
}