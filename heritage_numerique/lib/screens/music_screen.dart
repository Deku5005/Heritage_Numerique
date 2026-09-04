import 'package:flutter/material.dart';
import 'package:heritage_numerique/screens/artisans_screen.dart';
import 'package:heritage_numerique/screens/contes_screen.dart';
import 'package:heritage_numerique/screens/proverb_screen.dart';
import 'package:heritage_numerique/widgets/bottom_navigation_widget.dart';
import 'package:heritage_numerique/widgets/cultural_theme.dart';
import '../model/Devinette1.dart';
import '../Service/DevinetteService1.dart';
import 'Music_detail_screen.dart';

/// Écran des Devinettes selon le nouveau design Figma
class MusicScreen extends StatefulWidget {
  const MusicScreen({super.key});

  @override
  State<MusicScreen> createState() => _MusicScreenState();
}

class _MusicScreenState extends State<MusicScreen> {
  final DevinetteService1 _devinetteService = DevinetteService1();
  List<Devinette1> _devinettes = [];
  bool _isLoading = true;
  String _selectedFilter = 'Devinettes';

  final List<String> _filters = ['Tous', 'Contes', 'Proverbes', 'Devinettes', 'Artisanat'];

  final List<Map<String, String>> _fallbackDevinettes = [
    {
      'title': "L'énigme du Baobab",
      'devinette': "Je suis souvent mon favorable, grand sans échelle, qui suis-je ?",
      'reponse': "L'Ombre du Baobab",
      'author': 'Vieux sage de Mopti',
      'image': 'assets/images/ancient-baobab.jpg',
    },
    {
      'title': "L'eau qui ne mouille pas",
      'devinette': "Je traverse le fleuve Niger sans jamais toucher une goutte d'eau.",
      'reponse': "Le Soleil",
      'author': 'Tradition orale',
      'image': 'assets/images/african-river.jpg',
    },
    {
      'title': "Le voyageur immobile",
      'devinette': "J'ai un pied mais je ne marche pas, j'ai une tête mais je ne pense pas.",
      'reponse': "Le Pilon",
      'author': 'Contes mandingues',
      'image': 'assets/images/african-village.jpg',
    },
  ];

  @override
  void initState() {
    super.initState();
    _fetchDevinettes();
  }

  Future<void> _fetchDevinettes() async {
    try {
      final data = await _devinetteService.getDevinettes();
      if (mounted) {
        setState(() {
          _devinettes = data;
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
                    image: AssetImage('assets/images/musiques.jpg'),
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
                        'Énigmes & Devinettes ancestrales du Mali',
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
                itemCount: _fallbackDevinettes.length,
                separatorBuilder: (_, __) => const SizedBox(width: 14),
                itemBuilder: (context, index) {
                  final item = _fallbackDevinettes[index];
                  return Container(
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
                            item['author']!,
                            style: const TextStyle(color: Colors.white70, fontSize: 11),
                          ),
                        ],
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
                'Toutes les devinettes',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: CulturalTheme.textDark,
                ),
              ),
            ),
          ),

          // Liste des devinettes
          _buildDevinettesList(),

          const SliverToBoxAdapter(child: SizedBox(height: 40)),
        ],
      ),
    );
  }

  Widget _buildDevinettesList() {
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

    if (_devinettes.isNotEmpty) {
      return SliverList(
        delegate: SliverChildBuilderDelegate(
          (context, index) {
            final dev = _devinettes[index];
            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 6.0),
              child: InkWell(
                onTap: () {
                  final String titre = dev.titre ?? 'Devinette';
                  final String questionText = dev.devinette ?? '';
                  final String reponseText = dev.reponse ?? '';
                  final String auteurText = '${dev.prenomAuteur ?? ''} ${dev.nomAuteur ?? ''}'.trim().isNotEmpty
                      ? '${dev.prenomAuteur ?? ''} ${dev.nomAuteur ?? ''}'.trim()
                      : 'Tradition orale';

                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => MusicDetailScreen(
                        titre: titre,
                        devinette: questionText,
                        reponse: reponseText,
                        conteur: auteurText,
                        imageUrl: 'assets/images/musiques.jpg',
                        details: {'idDevinette': dev.id ?? 1, 'lieu': dev.lieu ?? 'Mali', 'region': dev.region ?? 'Mali'},
                      ),
                    ),
                  );
                },
                borderRadius: BorderRadius.circular(16),
                child: Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: const Color(0xFFF0EBE0)),
                    boxShadow: CulturalTheme.softShadow,
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 50,
                        height: 50,
                        decoration: BoxDecoration(
                          color: CulturalTheme.primaryOcre.withOpacity(0.15),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.help_outline, color: CulturalTheme.primaryDarkOcre, size: 26),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              dev.titre ?? 'Devinette',
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
                              dev.devinette ?? '',
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
                      const Icon(Icons.arrow_forward_ios, size: 14, color: CulturalTheme.primaryDarkOcre),
                    ],
                  ),
                ),
              ),
            );
          },
          childCount: _devinettes.length,
        ),
      );
    }

    return SliverList(
      delegate: SliverChildBuilderDelegate(
        (context, index) {
          final item = _fallbackDevinettes[index];
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 6.0),
            child: InkWell(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => MusicDetailScreen(
                      titre: item['title']!,
                      devinette: item['devinette']!,
                      reponse: item['reponse']!,
                      conteur: item['author']!,
                      imageUrl: item['image']!,
                      details: const {'idDevinette': 1, 'lieu': 'Mali'},
                    ),
                  ),
                );
              },
              borderRadius: BorderRadius.circular(16),
              child: Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: const Color(0xFFF0EBE0)),
                  boxShadow: CulturalTheme.softShadow,
                ),
                child: Row(
                  children: [
                    Container(
                      width: 50,
                      height: 50,
                      decoration: BoxDecoration(
                        color: CulturalTheme.primaryOcre.withOpacity(0.15),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.help_outline, color: CulturalTheme.primaryDarkOcre, size: 26),
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
                            item['devinette']!,
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
                    const Icon(Icons.arrow_forward_ios, size: 14, color: CulturalTheme.primaryDarkOcre),
                  ],
                ),
              ),
            ),
          );
        },
        childCount: _fallbackDevinettes.length,
      ),
    );
  }
}