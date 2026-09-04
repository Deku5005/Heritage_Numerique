import 'package:flutter/material.dart';
import 'package:heritage_numerique/widgets/bottom_navigation_widget.dart';
import 'package:heritage_numerique/widgets/cultural_theme.dart';
import '../model/conte.dart';
import '../Service/conteService.dart';
import 'affichage_contes_screen.dart';
import 'artisans_screen.dart';
import 'music_screen.dart';
import 'proverb_screen.dart';

/// Écran des Contes traditionnels selon le nouveau design Figma
class ContesScreen extends StatefulWidget {
  const ContesScreen({super.key});

  @override
  State<ContesScreen> createState() => _ContesScreenState();
}

class _ContesScreenState extends State<ContesScreen> {
  final ConteService _conteService = ConteService();
  late Future<List<Conte>> _contesFuture;
  String _selectedFilter = 'Contes';

  final List<String> _filters = ['Tous', 'Contes', 'Proverbes', 'Devinettes', 'Artisanat'];

  // Contes de secours si l'API est injoignable
  final List<Map<String, String>> _fallbackContes = [
    {
      'title': "L'épopée de Soundiata Keïta",
      'subtitle': "L'histoire légendaire du souverain mandingue qui fonda l'empire du Mali.",
      'image': 'assets/images/Djata.jpg',
      'author': 'Djeli Mamadou Kouyaté',
      'duration': '8 min',
    },
    {
      'title': "Le Lion et la Hyène",
      'subtitle': "Une ruse ancestrale dans la savane pour enseigner l'humilité aux hommes.",
      'image': 'assets/images/Hyene.jpg',
      'author': 'Tradition orale bambara',
      'duration': '5 min',
    },
    {
      'title': "Les Trois Frères et l'Arbre Magique",
      'subtitle': "Un voyage initiatique à travers les mystères de la forêt sacrée.",
      'image': 'assets/images/three-african-brothers-adventure-forest.jpg',
      'author': 'Conte sénoufo',
      'duration': '6 min',
    },
  ];

  @override
  void initState() {
    super.initState();
    _contesFuture = _conteService.getContes();
  }

  void _onFilterTap(String filter) {
    if (filter == _selectedFilter) return;
    setState(() {
      _selectedFilter = filter;
    });

    if (filter == 'Proverbes') {
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
          // AppBar avec logo et recherche
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

          // Bannière "Explorer"
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
              child: Container(
                height: 140,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(18),
                  image: const DecorationImage(
                    image: AssetImage('assets/images/african-village.jpg'),
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
                        'Découvrez le patrimoine culturel malien',
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

          // Barre d'onglets / filtres horizontaux
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

          // Titre section "En vedette"
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

          // Carrousel En vedette
          SliverToBoxAdapter(
            child: SizedBox(
              height: 140,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: _fallbackContes.length,
                separatorBuilder: (_, __) => const SizedBox(width: 14),
                itemBuilder: (context, index) {
                  final item = _fallbackContes[index];
                  return InkWell(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => AffichageContesScreen(conte: _fallbackToConte(item, index)),
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
                              item['author']!,
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

          // Titre section "Tous les contes"
          const SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.fromLTRB(16, 22, 16, 10),
              child: Text(
                'Récits & Histoires',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: CulturalTheme.textDark,
                ),
              ),
            ),
          ),

          // Liste des contes depuis l'API ou Fallback
          _buildContesList(),

          const SliverToBoxAdapter(child: SizedBox(height: 40)),
        ],
      ),
    );
  }

  Widget _buildContesList() {
    return FutureBuilder<List<Conte>>(
      future: _contesFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const SliverToBoxAdapter(
            child: Center(
              child: Padding(
                padding: EdgeInsets.all(30.0),
                child: CircularProgressIndicator(color: CulturalTheme.primaryOcre),
              ),
            ),
          );
        }

        if (snapshot.hasData && snapshot.data!.isNotEmpty) {
          final contes = snapshot.data!;
          return SliverList(
            delegate: SliverChildBuilderDelegate(
              (context, index) {
                final conte = contes[index];
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 6.0),
                  child: InkWell(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => AffichageContesScreen(conte: conte),
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
                              child: conte.urlPhoto.isNotEmpty
                                  ? Image.network(
                                      'http://10.0.2.2:8080${conte.urlPhoto}',
                                      fit: BoxFit.cover,
                                      errorBuilder: (_, __, ___) => Image.asset('assets/images/contes.jpg', fit: BoxFit.cover),
                                    )
                                  : Image.asset('assets/images/contes.jpg', fit: BoxFit.cover),
                            ),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  conte.titre,
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
                                  conte.description,
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
                                  conte.prenomAuteur.isNotEmpty ? '${conte.prenomAuteur} ${conte.nomAuteur}' : 'Tradition orale',
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
              childCount: contes.length,
            ),
          );
        }

        // Fallback gracieux si l'API ne retourne rien ou échoue
        return SliverList(
          delegate: SliverChildBuilderDelegate(
            (context, index) {
              final item = _fallbackContes[index];
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 6.0),
                child: InkWell(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => AffichageContesScreen(conte: _fallbackToConte(item, index)),
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
                                item['author']!,
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
            childCount: _fallbackContes.length,
          ),
        );
      },
    );
  }

  Conte _fallbackToConte(Map<String, String> item, int index) {
    return Conte(
      id: index + 1,
      titre: item['title'] ?? 'Conte traditionnel',
      description: item['subtitle'] ?? '',
      nomAuteur: item['author'] ?? 'Tradition orale',
      prenomAuteur: '',
      emailAuteur: '',
      roleAuteur: 'Conteur',
      lienParenteAuteur: '',
      dateCreation: '2024',
      statut: 'PUBLIE',
      urlFichier: '',
      urlPhoto: item['image'] ?? '',
      contenuFichier: "Il était une fois, dans les terres chaleureuses du Mandé, une légende transmise de génération en génération.\n\n${item['subtitle'] ?? ''}\n\nLes anciens racontent que chaque soir, sous le grand baobab protecteur, les enfants se rassemblaient pour écouter la voix douce et sage du conteur. À travers chaque mot, chaque métaphore et chaque silence, la sagesse des ancêtres illuminait les esprits et guidait les cœurs vers la justice, l'humilité et la préservation de notre précieux héritage séculaire.",
      lieu: 'Mandé',
      region: 'Koulikoro',
      idFamille: 1,
      nomFamille: 'Tradition',
    );
  }
}