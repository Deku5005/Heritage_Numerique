import 'package:flutter/material.dart';
import 'dart:math';

// Importez les modèles et le service
import '../model/FamilleModel.dart';
import '../model/Membre.dart';
import '../service/ArbreGenealogiqueService.dart';

// 🔑 Assurez-vous d'avoir le bon chemin vers l'écran d'ajout de membre
import 'CreateTreeScreen.dart';
import 'AppDrawer.dart';

// --- Constantes de Couleurs Globales ---
const Color _mainAccentColor = Color(0xFFAA7311);
const Color _backgroundColor = Colors.white;
const Color _cardTextColor = Color(0xFF2E2E2E);
const Color _lightCardColor = Color(0xFFF7F2E8);

// 🔑 URL DE BASE POUR LES IMAGES
// L'IP 10.0.2.2 est correcte pour l'émulateur Android.
const String _baseUrl = "http://10.0.2.2:8080";


// --- FamilyTreeScreen ---
class FamilyTreeScreen extends StatefulWidget {
  final int familyId;

  const FamilyTreeScreen({super.key, required this.familyId});

  @override
  State<FamilyTreeScreen> createState() => _FamilyTreeScreenState();
}

class _FamilyTreeScreenState extends State<FamilyTreeScreen> {
  // --- Ajout de l'état pour les données et le chargement ---
  Famille? _familleData;
  bool _isLoading = true;
  String? _errorMessage;

  final ArbreGenealogiqueService _apiService = ArbreGenealogiqueService();

  @override
  void initState() {
    super.initState();
    _fetchFamilyTree();
  }

  Future<void> _fetchFamilyTree() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });
    try {
      final famille = await _apiService.fetchFamille(familleId: widget.familyId);
      setState(() {
        _familleData = famille;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Erreur de chargement de l\'arbre généalogique : $e';
        _isLoading = false;
        debugPrint(_errorMessage);
      });
    }
  }

  void _navigateToAddMember() async {
    final bool? shouldRefresh = await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => CreateTreeScreen(familyId: widget.familyId),
      ),
    );

    if (shouldRefresh == true) {
      _fetchFamilyTree();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _backgroundColor,
      drawer: AppDrawer(familyId: widget.familyId),
      body: SingleChildScrollView(
        padding: EdgeInsets.only(top: MediaQuery.of(context).padding.top + 10, bottom: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Builder(
                builder: (BuildContext innerContext) {
                  return _buildCustomHeader(innerContext);
                }
            ),
            const SizedBox(height: 10),
            _buildContent(),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _navigateToAddMember,
        backgroundColor: _mainAccentColor,
        child: const Icon(Icons.person_add, color: Colors.white),
        tooltip: 'Ajouter un nouveau membre',
      ),
    );
  }
// -------------------------------------------------------------------
// --- STRUCTURE DE LA PAGE (Dynamique) ---
// -------------------------------------------------------------------
  Widget _buildContent() {
    if (_isLoading) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(50.0),
          child: Column(
            children: [
              const CircularProgressIndicator(color: _mainAccentColor),
              const SizedBox(height: 10),
              Text('Chargement de l\'arbre généalogique...', style: TextStyle(color: Colors.grey.shade600)),
            ],
          ),
        ),
      );
    }

    if (_errorMessage != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(30.0),
          child: Column(
            children: [
              const Icon(Icons.error_outline, color: Colors.red, size: 40),
              const SizedBox(height: 10),
              Text(_errorMessage!, textAlign: TextAlign.center, style: const TextStyle(color: Colors.red)),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _fetchFamilyTree,
                style: ElevatedButton.styleFrom(backgroundColor: _mainAccentColor),
                child: const Text('Réessayer', style: TextStyle(color: Colors.white)),
              )
            ],
          ),
        ),
      );
    }

    if (_familleData != null) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildStats(),
          const SizedBox(height: 30),

          // 🔑 Appel de la structure d'arbre dynamique par séquence
          _buildFamilyTreeLayoutBySequence(),
        ],
      );
    }

    return const Center(child: Text("Aucune donnée disponible."));
  }
// -------------------------------------------------------------------
// --- WIDGETS DE L'ARBRE (Maintien de la Structure Fixe) ---
// -------------------------------------------------------------------

  // **Structure Statique de l'Arbre Remplie par Séquence**
  Widget _buildFamilyTreeLayoutBySequence() {
    if (_familleData == null || _familleData!.membres.isEmpty) {
      return const Center(child: Text("Ajoutez le premier membre à votre arbre !"));
    }

    List<Membre> membres = _familleData!.membres;
    int memberIndex = 0; // Le membre le plus âgé est à l'index 0

    // Fonction utilitaire pour obtenir le prochain membre
    Membre? getNextMember() {
      if (memberIndex < membres.length) {
        return membres[memberIndex++];
      }
      return null; // Retourne null si plus de membres disponibles
    }

    return Center(
      child: Column(
        children: [
          // Ligne 1 : Niveau supérieur (Membre le plus âgé - Index 0)
          _buildMemberCardDynamic(getNextMember()),
          _buildConnectionLine(),

          // Ligne 2 : Niveau intermédiaire (Membre suivant - Index 1)
          _buildMemberCardDynamic(getNextMember()),
          _buildConnectionLine(),

          // Ligne 3 : Niveau 3 (Membres suivants - Index 2 et 3)
          _buildHorizontalLevel([
            _buildMemberCardDynamic(getNextMember()), // Index 2
            _buildMemberCardDynamic(getNextMember()), // Index 3
          ], maxWidth: MediaQuery.of(context).size.width - 32), // 🔑 Utilise la largeur de l'écran
          _buildConnectionLine(isVertical: true, height: 20),

          // Ligne 4 : Niveau 4 (Membres suivants - Index 4 et 5)
          _buildHorizontalLevel([
            _buildMemberCardDynamic(getNextMember()), // Index 4
            _buildMemberCardDynamic(getNextMember()), // Index 5
          ], maxWidth: MediaQuery.of(context).size.width - 32), // 🔑 Utilise la largeur de l'écran

          // 🔑 GESTION DES MEMBRES RESTANTS (Plus de 6)
          if (memberIndex < membres.length)
            _buildRemainingMembersList(membres.sublist(memberIndex)),

        ],
      ),
    );
  }

  // **Liste des membres restants (pour l'évolutivité)**
  Widget _buildRemainingMembersList(List<Membre> remainingMembers) {
    if (remainingMembers.isEmpty) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.only(top: 30.0, left: 16.0, right: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: Text(
              '${remainingMembers.length} autres Membres (membres les plus jeunes)',
              style: const TextStyle(fontWeight: FontWeight.bold, color: _cardTextColor, fontSize: 16),
            ),
          ),

          // Liste simple des membres restants
          ...remainingMembers.map((membre) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 8.0),
              child: _buildMemberCardDynamic(membre), // Réutilise la carte corrigée
            );
          }).toList(),
        ],
      ),
    );
  }


  // **Carte de membre dynamique** (Correction du débordement)
  Widget _buildMemberCardDynamic(Membre? membre) {
    // Si le membre n'est pas trouvé (indice dépassé), affiche un placeholder
    if (membre == null) {
      return _buildMemberCardPlaceholder();
    }

    int birthYear = 0;
    try {
      if (membre.dateNaissance.contains('-')) {
        birthYear = int.tryParse(membre.dateNaissance.split('-').first) ?? 0;
      }
    } catch (_) { /* ignore */ }

    const int contributions = 0;

    // Construction de l'URL complète pour la photo
    final String fullPhotoUrl = (membre.photoUrl != null && membre.photoUrl!.isNotEmpty)
        ? '$_baseUrl/${membre.photoUrl!}'
        : '';
    final bool hasPhoto = fullPhotoUrl.isNotEmpty;

    return Container(
      // 🔑 RETIRER width: 280
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.grey.shade300),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 3,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Image de profil (fixe)
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Container(
              width: 50,
              height: 50,
              color: Colors.grey.shade200,
              child: hasPhoto
                  ? Image.network(
                fullPhotoUrl,
                fit: BoxFit.cover,
                // 🔑 Si Image.network échoue (URL incorrecte, serveur down), afficher l'icône.
                errorBuilder: (context, error, stackTrace) => const Icon(Icons.person, color: Colors.grey, size: 30),
              )
              // 🔑 Si hasPhoto est false (pas d'URL), afficher l'icône.
                  : const Icon(Icons.person, color: Colors.grey, size: 30),
            ),
          ),
          const SizedBox(width: 10),
          // 🔑 Expanded pour prendre l'espace restant sans déborder
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  membre.nomComplet, // DYNAMIQUE
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: _cardTextColor),
                  overflow: TextOverflow.ellipsis, // 🔑 Empêche le débordement horizontal
                ),
                Text(
                  membre.relationFamiliale, // DYNAMIQUE
                  style: const TextStyle(fontSize: 10, color: Colors.grey),
                ),
                Text(
                  birthYear > 0 ? 'Né en $birthYear' : 'Date de naissance inconnue', // DYNAMIQUE
                  style: const TextStyle(fontSize: 10, color: Colors.grey),
                ),
                const SizedBox(height: 5),
                Row(
                  children: [
                    const Icon(Icons.people_alt_outlined, size: 12, color: _mainAccentColor),
                    const SizedBox(width: 4),
                    Text(
                      '$contributions Contributions', // STATIQUE
                      style: TextStyle(fontSize: 10, color: _mainAccentColor),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Carte de membre POUBELLE (si non trouvé dans l'API)
  Widget _buildMemberCardPlaceholder() {
    return Container(
      // 🔑 RETIRER width: 280
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Row(
        children: [
          // 🔑 Icône générique pour l'emplacement vide
          const Icon(Icons.person, color: Colors.grey, size: 30),
          const SizedBox(width: 10),
          Expanded( // 🔑 Ajout d'Expanded
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Emplacement libre',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: _cardTextColor),
                  overflow: TextOverflow.ellipsis,
                ),
                const Text(
                  'Ajouter un membre pour remplir cette place.',
                  style: TextStyle(fontSize: 10, color: Colors.grey),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

// -------------------------------------------------------------------
// --- WIDGETS DE STYLE ET UTILS (RÉTABLIS et CORRIGÉS) ---
// -------------------------------------------------------------------

  // Section des statistiques (Maintenant dynamique)
  Widget _buildStats() {
    final famille = _familleData;
    if (famille == null) return const SizedBox.shrink();

    int? anneeDebut;
    if (famille.membres.isNotEmpty) {
      try {
        if (famille.membres.first.dateNaissance.contains('-')) {
          anneeDebut = int.tryParse(famille.membres.first.dateNaissance.split('-').first);
        }
      } catch (_) {
        anneeDebut = null;
      }
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Arbre Généalogique de ${famille.nomFamille}',
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: _cardTextColor),
          ),
          Text(
            famille.description.isEmpty ? 'Arbre de la famille' : famille.description,
            style: const TextStyle(fontSize: 12, color: Colors.grey),
          ),
          const SizedBox(height: 15),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Les StatBox utilisent une largeur fixe, donc pas de débordement ici
              _buildStatBox(label: 'Générations', value: 'N/A'),
              _buildStatBox(label: 'Membres', value: famille.nombreMembres.toString()),
              _buildStatBox(label: 'Depuis', value: anneeDebut?.toString() ?? '...'),
            ],
          ),
        ],
      ),
    );
  }

  // En-tête Personnalisé (inchangé)
  Widget _buildCustomHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            icon: const Icon(Icons.menu, color: _cardTextColor, size: 30),
            onPressed: () {
              Scaffold.of(context).openDrawer();
            },
          ),
          const Text(
            'Héritage Numérique',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: _cardTextColor,
            ),
          ),
          IconButton(
            icon: const Icon(Icons.close, color: Colors.grey),
            onPressed: () => Navigator.pop(context),
          ),
        ],
      ),
    );
  }

  // Boîte de statistique individuelle (inchangé)
  Widget _buildStatBox({required String label, required String value}) {
    return Container(
      width: 80,
      height: 60,
      decoration: BoxDecoration(
        color: _lightCardColor,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            value,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: _mainAccentColor,
            ),
          ),
          Text(
            label,
            style: const TextStyle(
              fontSize: 10,
              color: _cardTextColor,
            ),
          ),
        ],
      ),
    );
  }

  // Simule les lignes de connexion (RÉTABLI)
  Widget _buildConnectionLine({bool isVertical = true, double height = 30}) {
    return Container(
      width: 2,
      height: height,
      color: Colors.grey.shade400,
      margin: const EdgeInsets.symmetric(vertical: 5),
    );
  }

  // Structure pour les niveaux horizontaux (frères/sœurs) (RÉTABLI et CORRIGÉ)
  Widget _buildHorizontalLevel(List<Widget> members, {required double maxWidth}) {
    // 🔑 Assurer que le conteneur horizontal ne dépasse pas la largeur de l'écran
    return SizedBox(
      width: maxWidth,
      child: Column(
        children: [
          // Ligne horizontale pour connecter les frères/sœurs
          Container(
            width: maxWidth * 0.9, // Ligne un peu plus courte que la largeur totale
            height: 2,
            color: Colors.grey.shade400,
            margin: const EdgeInsets.only(bottom: 10),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: members.map((memberCard) {
              // 🔑 Chaque carte est enveloppée dans Flexible pour partager l'espace
              return Flexible(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4.0),
                  child: memberCard,
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}