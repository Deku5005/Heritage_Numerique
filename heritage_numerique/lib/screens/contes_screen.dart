import 'package:flutter/material.dart';
import '../widgets/bottom_navigation_widget.dart';
import 'affichage_contes_screen.dart'; 

/// Écran affichant la liste des contes pour la catégorie "Contes".
class ContesScreen extends StatelessWidget {
  const ContesScreen({super.key});

  // Couleur principale Ocre Vif (D69301)
  static const Color _accentColor = Color(0xFFD69301);
  static const Color _cardTextColor = Color(0xFF2E2E2E);

  // Données de contes simulées (AVEC CONTENU MULTILINGUE COMPLET)
  final List<Map<String, dynamic>> tales = const [
    {
      'subtitle': 'Un conte malien classique sur l\'intelligence et la malice face à la force brute.',
      'image_path': 'assets/images/Lion.jpg',
      'content': {
        'Français': {
          'title': 'Le Lion et le Lièvre Rusé',
          'text': "Le lièvre Rusé et le lion est un conte populaire d'Afrique de l'Ouest. Le lièvre, petit et faible, utilise son intelligence pour tromper le lion, grand et fort. Cette histoire symbolise la victoire de l'esprit sur la force brute. Le lièvre parvient souvent à échapper aux pièges du lion, ou même à le faire tomber dans les siens, démontrant que la malice peut vaincre la puissance. C'est un conte largement répandu et apprécié pour sa morale sur l'ingéniosité. Le lièvre Rusé et le lion. Le lièvre Rusé et le lion. Le lièvre Rusé et le lion. Le lièvre Rusé et le lion. Le lièvre Rusé et le lion. Le lièvre Rusé et le lion. (Texte long en français)",
          'narrator': 'Fanta Coulibaly',
          'duration': '5:30 min',
        },
        'Bambara': {
          'title': 'Jara ni Sulukalɛ', // Jara = Lion, Sulukalɛ = Lièvre
          'text': "Sulukalɛ ni Jara ye Mali jamanadenw ka jɛgɛnw dɔ ye. Sulukalɛ, dɔgɔman ani barika tɛ, a bɛ a ka hakiliw kɛ ka Jara wili, bamanankɛ ani barikama. Tariku in bɛ hakili ka dɛsɛ yira barika kɔnɔ. A ka ɲi ka fɔ ko Sulukalɛ bɛ minɛnɔgɔw bɛɛ tiɲɛ, ani a bɛ Jara yɛrɛ lajɛ. (Texte long en bambara)",
          'narrator': 'Sékou Traoré',
          'duration': '6:15 min',
        },
        'Anglais': {
          'title': 'The Lion and the Cunning Hare',
          'text': "The Cunning Hare and the Lion is a popular tale from West Africa. The hare, small and weak, uses its intelligence to trick the lion, big and strong. This story symbolizes the victory of wit over brute force. The hare often manages to escape the lion's traps, or even make the lion fall into its own, demonstrating that cunning can overcome power. (Long text in English)",
          'narrator': 'Aminata Cissé',
          'duration': '5:00 min',
        },
      },
    },
    {
      'subtitle': 'L\'histoire d\'un arbre millénaire qui détient le savoir des ancêtres.',
      'image_path': 'assets/images/Baobab.jpg',
      'content': {
        'Français': {
          'title': 'La Sagesse du Vieux Baobab',
          'text': "Le vieux Baobab est un témoin silencieux de l'histoire du Mali. Il a vu des générations passer et détient la sagesse des anciens. C'est un lieu de rassemblement et de médiation. Ses racines sont profondément ancrées dans la terre, tout comme la culture malienne dans l'histoire. Ce conte parle de respect, de nature, et de la transmission du savoir intergénérationnel. (Texte long en français)",
          'narrator': 'Amadou Traoré',
          'duration': '4:00 min',
        },
        'Bambara': {
          'title': 'Sankalan Ba Kolo Ba Hakili',
          'text': "Sankalan Ba Kolo Ba ye Mali tariku ka sebere gɛlɛn dɔ ye. A ye mɔgɔ kɔrɔw ye ka tɛmɛ, ani a bɛ kɔrɔw ka hakili mara. A ye jɔyɔrɔ dɔ ye ka mɔgɔw lajɛ ani ka hakili kɛ. (Texte long en bambara)",
          'narrator': 'Amadou Traoré',
          'duration': '4:30 min',
        },
        'Anglais': {
          'title': 'The Wisdom of the Old Baobab',
          'text': "The old Baobab tree is a silent witness to the history of Mali. It has seen generations pass and holds the wisdom of the elders. It is a place of gathering and meditation. Its roots are deeply anchored in the earth, just like Malian culture in history. (Long text in English)",
          'narrator': 'Aminata Cissé',
          'duration': '3:45 min',
        },
      },
    },
    {
      'subtitle': 'La jeunesse du fondateur de l\'Empire du Mali et ses épreuves.',
      'image_path': 'assets/images/Djata.jpg',
      'content': {
        'Français': {
          'title': 'L\'Initiation de Soundjata',
          'text': "Soundjata Keita, le fondateur de l'Empire du Mali, n'a pas eu une jeunesse facile. Né infirme, il a surmonté de nombreuses épreuves pour devenir le 'Maître du Mandé'. Ce conte épique raconte son initiation, ses combats, et comment il a unifié les peuples pour créer l'un des plus grands empires de l'histoire de l'Afrique de l'Ouest. C'est un récit de courage, de destinée et de leadership. (Texte long en français)",
          'narrator': 'Mariam Diarra',
          'duration': '8:00 min',
        },
        'Bambara': {
          'title': 'Sunjata Ka Ladili',
          'text': "Sunjata Kɛyta, Mali Mansamara datigɛla, a ka dencɛya tun tɛ nɔgɔn na. A jiginna ni gɛlɛya ye, a ye gɛlɛyaw bɛɛ kɔnɔ ka kɛ 'Mandɛ Kuntigi' ye. Tariku in bɛ a ka ladili, a ka kɛlɛw, ani a ka mɔgɔw ka ɲɔgɔn sɔrɔ yɔrɔ jira. (Texte long en bambara)",
          'narrator': 'Mariam Diarra',
          'duration': '8:45 min',
        },
        'Anglais': {
          'title': 'The Initiation of Sundiata',
          'text': "Sundiata Keita, the founder of the Mali Empire, did not have an easy youth. Born disabled, he overcame many trials to become the 'Master of Mandé'. This epic tale tells of his initiation, his battles, and how he unified the people to create one of the largest empires in West African history. It is a story of courage, destiny, and leadership. (Long text in English)",
          'narrator': 'Aminata Cissé',
          'duration': '7:30 min',
        },
      },
    },
    // Vous pouvez ajouter plus de contes ici
  ];

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
            sliver: _buildTalesGrid(context),
          ),
          const SliverToBoxAdapter(child: SizedBox(height: 50)),
        ],
      ),
    );
  }

  /// 1. Construction de l'en-tête (AppBar)
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

  /// 2. Barre de recherche simulée.
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

  /// 3. Construction de la grille des contes.
  Widget _buildTalesGrid(BuildContext context) {
    return SliverGrid(
      delegate: SliverChildBuilderDelegate(
        (context, index) {
          final tale = tales[index];
          // Nous prenons les données initiales du français pour l'affichage de la carte
          final frenchContent = tale['content']['Français'] as Map<String, String>; 
          
          return _buildTaleCard(
            context,
            frenchContent['title']!, // Titre par défaut (Français)
            tale['subtitle']!,
            tale['image_path']!,
            tale['content'] as Map<String, Map<String, String>>, // Passe TOUTES les données de contenu
          );
        },
        childCount: tales.length,
      ),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 10,
        mainAxisSpacing: 10,
        childAspectRatio: 0.7,
      ),
    );
  }

  /// 4. Construction d'une seule carte de conte.
  Widget _buildTaleCard(
    BuildContext context,
    String title,
    String subtitle,
    String imagePath,
    Map<String, Map<String, String>> allContent, // Le nouveau paramètre
  ) {
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
          // Image du conte
          Expanded(
            child: ClipRRect(
              borderRadius: const BorderRadius.vertical(top: Radius.circular(15)),
              child: Stack(
                fit: StackFit.expand,
                children: [
                  Image.asset(
                    imagePath,
                    fit: BoxFit.cover,
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
          // Boutons "Lire" et "Partager"
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildActionButton(context, 'Lire', Icons.book, _accentColor, 
                  onTap: () {
                    // Navigation vers l'écran de détail AVEC le bloc de contenu multilingue
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => AffichageContesScreen(
                          allContent: allContent, // LE PARAMÈTRE CLÉ
                          imagePath: imagePath,
                        ),
                      ),
                    );
                  }),
                _buildActionButton(context, 'Partager', Icons.share, Colors.grey, 
                  onTap: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Partager : Partager'),
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

  /// 5. Construction d'un bouton d'action.
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