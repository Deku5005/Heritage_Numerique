// ProverbeCollectionScreen.dart

import 'package:flutter/material.dart';

// Assurez-vous que le chemin est correct pour votre projet
import 'AppDrawer.dart';
// L'importation du fichier contenant la page de détail est essentielle.
import 'detailProverbe.dart'; // Assurez-vous que ce chemin est correct


// --- Constantes de Couleurs Globales (Ajustées) ---
const Color _searchBgColor = Color(0xFFFCF8F1); // #FCF8F1 - Couleur de la barre de recherche
const Color _searchBorderColor = Color(0xFFEAE6DF); // #EAE6DF
const Color _proverbAccentColor = Color(0xC7FFC107);
const Color _primaryTextColor = Color(0xFF000000);
const Color _secondaryTextColor = Color(0xFF99928F);
const Color _searchHintColor = Color(0xFF6E6967);
const Color _proverbBorderColor = Color(0x4049521D);

const Color _proverbCardBgColor = _searchBgColor;


// =============================================================
// MODÈLE ET DONNÉES (Gardées ici UNIQUEMENT)
// =============================================================

// Modèle de données pour un proverbe (Laisser la définition ici)
class ProverbeData {
  final String text;
  final String origin;
  final String imagePath;
  final String signification;

  ProverbeData({
    required this.text,
    required this.origin,
    required this.imagePath,
    required this.signification,
  });
}

// Données de démonstration
final List<ProverbeData> proverbeList = [
  ProverbeData(
    text: "Si tu veux aller vite, marche seul. Si tu veux aller loin, marchons ensemble.",
    origin: "Proverbe africain",
    imagePath: 'assets/images/african-savanne.jpg',
    signification: "Ce proverbe souligne l'importance de la collaboration et de l'entraide. Bien que l'individualisme puisse apporter des résultats rapides, c'est l'union et la solidarité qui permettent d'accomplir de grandes choses durables.",
  ),
  ProverbeData(
    text: "Un seul doigt ne peut pas ramasser un caillou.",
    origin: "Proverbe Haya (Tanzanie)",
    imagePath: 'assets/images/african-village.jpg',
    signification: "Ce proverbe est une métaphore de la force qui réside dans le nombre et l'unité. Il signifie qu'une seule personne ne peut pas accomplir une tâche complexe ou lourde.",
  ),
  ProverbeData(
    text: "La bouche qui a mangé ne dénonce pas celle qui a volé.",
    origin: "Proverbe Bambara (Mali)",
    imagePath: 'assets/images/ancient-baobab.jpg',
    signification: "Ce proverbe met en lumière la corruption ou le silence complice : celui qui a profité d'un méfait ne peut pas dénoncer l'auteur du vol.",
  ),
  ProverbeData(
    text: "L'eau chaude n'oublie pas qu'elle a été froide.",
    origin: "Proverbe Peul (Afrique de l'Ouest)",
    imagePath: 'assets/images/african-river.jpg',
    signification: "Il rappelle l'importance de se souvenir de ses origines, des difficultés traversées, et du chemin parcouru, peu importe le succès ou la position actuelle.",
  ),
];


// =============================================================
// WIDGET CARTE DE PROVERBE (ProverbeCard)
// (Aucun changement)
// =============================================================
class ProverbeCard extends StatelessWidget {
  final ProverbeData data;

  const ProverbeCard({super.key, required this.data});

  // ... Reste du code de ProverbeCard ...
  @override
  Widget build(BuildContext context) {
    return Container(
      height: 111,
      margin: const EdgeInsets.symmetric(vertical: 6.0, horizontal: 16.0),
      decoration: BoxDecoration(
        color: _proverbCardBgColor,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.25),
            blurRadius: 4,
            offset: const Offset(0, 0),
          ),
        ],
        borderRadius: BorderRadius.circular(5),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            width: 90,
            height: 90,
            margin: const EdgeInsets.all(10.5),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(5),
              image: DecorationImage(
                image: AssetImage(data.imagePath),
                fit: BoxFit.cover,
                onError: (exception, stackTrace) {},
              ),
            ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(top: 14.0, right: 10.0, bottom: 10.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '"${data.text}"',
                    style: const TextStyle(
                      fontFamily: 'Inter',
                      fontWeight: FontWeight.w700,
                      fontSize: 12,
                      height: 1.6,
                      color: _primaryTextColor,
                    ),
                    maxLines: 4,
                    overflow: TextOverflow.ellipsis,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Expanded(
                        child: Container(
                          height: 1,
                          margin: const EdgeInsets.only(right: 5),
                          color: _proverbBorderColor,
                        ),
                      ),
                      Text(
                        data.origin,
                        style: const TextStyle(
                          fontFamily: 'Inter',
                          fontWeight: FontWeight.w700,
                          fontSize: 8,
                          color: _proverbAccentColor,
                        ),
                      ),
                      Expanded(
                        child: Container(
                          height: 1,
                          margin: const EdgeInsets.only(left: 5),
                          color: _proverbBorderColor,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
// =============================================================
// ÉCRAN PRINCIPAL
// =============================================================

class ProverbeCollectionScreen extends StatelessWidget {
  const ProverbeCollectionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // ... Reste du code de ProverbeCollectionScreen (identique) ...
    return Scaffold(
      backgroundColor: Colors.white,
      drawer: const AppDrawer(),
      appBar: AppBar(
        backgroundColor: Colors.white,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(4.0),
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.25),
                  blurRadius: 4,
                  offset: const Offset(0, 0),
                ),
              ],
            ),
          ),
        ),
        elevation: 0,
        automaticallyImplyLeading: false,
        titleSpacing: 0,
        leading: Builder(
          builder: (BuildContext innerContext) {
            return IconButton(
              icon: const Icon(Icons.menu, color: _primaryTextColor),
              onPressed: () {
                Scaffold.of(innerContext).openDrawer();
              },
            );
          },
        ),
        title: Center(
          child: Text(
            'Héritage Numérique',
            style: const TextStyle(
              fontFamily: 'Inter',
              fontWeight: FontWeight.w700,
              fontSize: 24,
              color: _primaryTextColor,
            ),
          ),
        ),
      ),
      body: CustomScrollView(
        slivers: <Widget>[
          SliverList(
            delegate: SliverChildListDelegate(
              [
                Padding(
                  padding: const EdgeInsets.only(left: 16.0, right: 16.0, top: 10.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Collection de proverbes',
                            style: TextStyle(
                              fontFamily: 'Inter',
                              fontWeight: FontWeight.w700,
                              fontSize: 20,
                              color: _primaryTextColor,
                            ),
                          ),

                        ],
                      ),
                      const Text(
                        'Cliquez sur un proverbe pour decouvrir sa sagesse',
                        style: TextStyle(
                          fontFamily: 'Roboto',
                          fontWeight: FontWeight.w700,
                          fontSize: 12,
                          color: _secondaryTextColor,
                        ),
                      ),
                      const SizedBox(height: 15),
                      Container(
                        height: 35,
                        margin: const EdgeInsets.only(bottom: 20),
                        padding: const EdgeInsets.symmetric(horizontal: 10),
                        decoration: BoxDecoration(
                          color: _searchBgColor,
                          border: Border.all(color: _searchBorderColor, width: 1),
                          borderRadius: BorderRadius.circular(5),
                        ),
                        child: const TextField(
                          decoration: InputDecoration(
                            hintText: 'Rechercher contenu...',
                            hintStyle: TextStyle(
                              fontWeight: FontWeight.w400,
                              fontSize: 10,
                              color: _searchHintColor,
                            ),
                            prefixIcon: Icon(Icons.search, color: _searchHintColor),
                            border: InputBorder.none,
                            contentPadding: EdgeInsets.only(top: 0.0), // Ajusté
                          ),
                          style: TextStyle(fontSize: 12),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Liste des Proverbes avec navigation
          SliverList(
            delegate: SliverChildBuilderDelegate(
                  (BuildContext context, int index) {
                final proverbe = proverbeList[index];
                return GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        // L'importation 'detailProverbe.dart' permet d'accéder à ProverbeDetailScreen
                        builder: (context) => ProverbeDetailScreen(proverbe: proverbe),
                      ),
                    );
                  },
                  child: ProverbeCard(data: proverbe),
                );
              },
              childCount: proverbeList.length,
            ),
          ),

          const SliverToBoxAdapter(
            child: SizedBox(height: 30),
          ),
        ],
      ),
    );
  }
}