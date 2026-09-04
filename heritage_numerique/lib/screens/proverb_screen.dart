import 'package:flutter/material.dart';
import 'package:heritage_numerique/screens/artisans_screen.dart';
import 'package:heritage_numerique/screens/contes_screen.dart';
import 'package:heritage_numerique/screens/music_screen.dart';
import 'package:heritage_numerique/widgets/bottom_navigation_widget.dart';
import 'package:heritage_numerique/widgets/cultural_theme.dart';
import 'proverb_detail_screen.dart';
import '../model/proverbe1.dart';
import '../Service/proverbeservice1.dart';

/// Écran des Proverbes selon le nouveau design Figma
class ProverbScreen extends StatefulWidget {
  const ProverbScreen({super.key});

  @override
  State<ProverbScreen> createState() => _ProverbScreenState();
}

class _ProverbScreenState extends State<ProverbScreen> {
  final ProverbeService1 _proverbeService = ProverbeService1();
  List<Proverbe1> _proverbes = [];
  bool _isLoading = true;
  String _selectedFilter = 'Proverbes';

  final List<String> _filters = ['Tous', 'Contes', 'Proverbes', 'Devinettes', 'Artisanat'];

  final List<Map<String, String>> _fallbackProverbes = [
    {
      'proverbe': "Si tu vois une pirogue qui coule, ne dis pas qu'elle est légère.",
      'sens': "Ne méprise jamais une difficulté apparente sans en connaître le poids réel.",
      'origine': 'Sagesse Bozo',
      'id': '1',
    },
    {
      'proverbe': "L'arbre ne grandit pas sans ses racines, l'homme ne prospère pas sans ses aînés.",
      'sens': "Le respect des ancêtres et des traditions est le garant de toute réussite humaine.",
      'origine': 'Proverbe Mandé',
      'id': '2',
    },
    {
      'proverbe': "La parole est comme l'eau renversée, on ne peut plus la ramasser.",
      'sens': "Réfléchis avant de parler car les mots blessants ne s'effacent jamais.",
      'origine': 'Proverbe Bambara',
      'id': '3',
    },
    {
      'proverbe': "Le fer s'aiguise avec le fer, l'homme s'instruit au contact de ses semblables.",
      'sens': "L'entraide et le dialogue communautaire enrichissent l'esprit.",
      'origine': 'Sagesse Dogon',
      'id': '4',
    },
  ];

  @override
  void initState() {
    super.initState();
    _fetchProverbs();
  }

  Future<void> _fetchProverbs() async {
    try {
      final data = await _proverbeService.getProverbes();
      if (mounted) {
        setState(() {
          _proverbes = data;
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
                    image: AssetImage('assets/images/proverbes.jpg'),
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
                        'Sagesse ancestrale et enseignements de nos aînés',
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
                'Parole de sagesse du jour',
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
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const ProverbDetailScreen(
                        proverbeId: 1,
                        proverbText: "Si tu vois une pirogue qui coule, ne dis pas qu'elle est légère.",
                        source: 'Bozo',
                        conteur: 'Tradition orale',
                        langue: 'Français',
                      ),
                    ),
                  );
                },
                borderRadius: BorderRadius.circular(18),
                child: Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(18),
                    image: const DecorationImage(
                      image: AssetImage('assets/images/ancient-baobab.jpg'),
                      fit: BoxFit.cover,
                    ),
                    boxShadow: CulturalTheme.softShadow,
                  ),
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.65),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: const [
                        Icon(Icons.format_quote, color: CulturalTheme.primaryOcre, size: 28),
                        SizedBox(height: 8),
                        Text(
                          "« Si tu vois une pirogue qui coule, ne dis pas qu'elle est légère. »",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                        SizedBox(height: 8),
                        Text(
                          "— Sagesse des pêcheurs Bozo du fleuve Niger",
                          style: TextStyle(color: CulturalTheme.accentGold, fontSize: 12),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),

          // Liste des proverbes
          const SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.fromLTRB(16, 22, 16, 10),
              child: Text(
                'Tous les proverbes',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: CulturalTheme.textDark,
                ),
              ),
            ),
          ),

          _buildProverbsList(),

          const SliverToBoxAdapter(child: SizedBox(height: 40)),
        ],
      ),
    );
  }

  Widget _buildProverbsList() {
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

    if (_proverbes.isNotEmpty) {
      return SliverList(
        delegate: SliverChildBuilderDelegate(
          (context, index) {
            final p = _proverbes[index];
            final String proverbText = p.proverbe ?? p.titre ?? 'Proverbe traditionnel';
            final String sourceText = p.origine ?? 'Mali';
            final String authorText = '${p.prenomAuteur ?? ''} ${p.nomAuteur ?? ''}'.trim().isNotEmpty
                ? '${p.prenomAuteur ?? ''} ${p.nomAuteur ?? ''}'.trim()
                : 'Tradition orale';

            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 6.0),
              child: InkWell(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ProverbDetailScreen(
                        proverbeId: p.id ?? 1,
                        proverbText: proverbText,
                        source: sourceText,
                        conteur: authorText,
                        langue: 'Français',
                      ),
                    ),
                  );
                },
                borderRadius: BorderRadius.circular(16),
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: const Color(0xFFF0EBE0)),
                    boxShadow: CulturalTheme.softShadow,
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 44,
                        height: 44,
                        decoration: BoxDecoration(
                          color: CulturalTheme.primaryOcre.withOpacity(0.12),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.format_quote, color: CulturalTheme.primaryDarkOcre, size: 24),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              proverbText,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.bold,
                                color: CulturalTheme.textDark,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              p.signification != null && p.signification!.isNotEmpty
                                  ? p.signification!
                                  : sourceText,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(fontSize: 12, color: CulturalTheme.textMuted),
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
          childCount: _proverbes.length,
        ),
      );
    }

    return SliverList(
      delegate: SliverChildBuilderDelegate(
        (context, index) {
          final item = _fallbackProverbes[index];
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 6.0),
            child: InkWell(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ProverbDetailScreen(
                      proverbeId: int.parse(item['id']!),
                      proverbText: item['proverbe']!,
                      source: item['origine']!,
                      conteur: 'Tradition orale',
                      langue: 'Français',
                    ),
                  ),
                );
              },
              borderRadius: BorderRadius.circular(16),
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: const Color(0xFFF0EBE0)),
                  boxShadow: CulturalTheme.softShadow,
                ),
                child: Row(
                  children: [
                    Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: CulturalTheme.primaryOcre.withOpacity(0.12),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.format_quote, color: CulturalTheme.primaryDarkOcre, size: 24),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            item['proverbe']!,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                              color: CulturalTheme.textDark,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            item['origine']!,
                            style: const TextStyle(fontSize: 12, color: CulturalTheme.primaryDarkOcre, fontWeight: FontWeight.w600),
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
        childCount: _fallbackProverbes.length,
      ),
    );
  }
}