// Fichier : lib/screens/FamilyTreeScreen.dart

import 'package:flutter/material.dart';
import 'dart:math';

// Importez les modèles et le service
import '../model/FamilleModel.dart';
import '../model/Membre.dart';
import '../service/ArbreGenealogiqueService.dart';

// 🔑 Assurez-vous d'avoir le bon chemin vers les écrans
import 'CreateTreeScreen.dart';
import 'AppDrawer.dart';
// 🔑 NOUVEL IMPORTATION : Écran de détails du membre
import 'MembresDetailsScreen.dart';

// --- Constantes de Couleurs Globales ---
const Color _mainAccentColor = Color(0xFFAA7311);
const Color _backgroundColor = Colors.white;
const Color _cardTextColor = Color(0xFF2E2E2E);
const Color _lightCardColor = Color(0xFFF7F2E8);

// 🔑 URL DE BASE POUR LES IMAGES
const String _baseUrl = "http://10.0.2.2:8080";

// --- FamilyTreeScreen ---
class FamilyTreeScreen extends StatefulWidget {
  final int familyId;

  const FamilyTreeScreen({super.key, required this.familyId});

  @override
  State<FamilyTreeScreen> createState() => _FamilyTreeScreenState();
}

// 🔑 Définition du type de callback pour les cartes (accepte un ID optionnel)
// NOTE : Ce type de callback n'est plus utilisé directement comme action,
// mais il reste pour définir les paramètres dans la structure de l'arbre.
typedef MemberTapCallback = void Function(int? memberId);


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
      // Tri par ID pour une structure séquentielle simple
      famille.membres.sort((a, b) => (a.id ?? 0).compareTo(b.id ?? 0));
      setState(() {
        _familleData = famille;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Erreur de chargement de l\'arbre généalogique : ${e.toString()}';
        _isLoading = false;
        debugPrint(_errorMessage);
      });
    }
  }

  // 1. Gère l'ajout d'un nouveau membre (appelé par le FAB ou le Placeholder)
  void _navigateToAddMember({int? parentId}) async {
    final bool? shouldRefresh = await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => CreateTreeScreen(
          familyId: widget.familyId,
          parentId: parentId, // ID du parent passé
        ),
      ),
    );

    if (shouldRefresh == true) {
      // Pour forcer le rafraîchissement des données après l'ajout
      await _fetchFamilyTree();
    }
  }

  // 2. 🔑 Gère l'affichage des détails d'un membre (appelé par la carte du membre)
  void _navigateToMemberDetail({required int memberId}) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => MembreDetailScreen(membreId: memberId),
      ),
    );
  }

  // 3. 🔑 Gestionnaire de clic UNIFIÉ pour les cartes
  void _handleMemberCardTap({required int? memberId, bool isPlaceholder = false}) {
    if (memberId == null || isPlaceholder) {
      // Si l'ID est null (placeholder d'ajout)
      _navigateToAddMember(parentId: memberId); // Si l'ID est null, ajoute un membre principal
    } else {
      // Si un ID est présent, affiche les détails
      _navigateToMemberDetail(memberId: memberId);
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
      // ✅ FloatingActionButton rétabli (pour ajouter un membre principal)
      floatingActionButton: FloatingActionButton(
        // L'action du FAB appelle la fonction d'ajout directe
        onPressed: () => _navigateToAddMember(parentId: null),
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

          // Appel de la structure d'arbre dynamique par séquence
          _buildFamilyTreeLayoutBySequence(),
        ],
      );
    }

    return const Center(child: Text("Aucune donnée disponible."));
  }
// -------------------------------------------------------------------
// --- WIDGETS DE L'ARBRE (Structure 1 + 7x2 = 15 cartes) ---
// -------------------------------------------------------------------

  // **Structure Statique de l'Arbre Remplie par Séquence**
  Widget _buildFamilyTreeLayoutBySequence() {
    // Si aucun membre, affiche un placeholder cliquable
    if (_familleData == null || _familleData!.membres.isEmpty) {
      return Center(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            // Le placeholder utilise le gestionnaire unifié
            child: _buildMemberCardPlaceholder(onTap: (id) => _handleMemberCardTap(memberId: id, isPlaceholder: true)),
          )
      );
    }

    List<Membre> membres = _familleData!.membres;
    int memberIndex = 0;

    // Fonction utilitaire pour obtenir le prochain membre
    Membre? getNextMember() {
      if (memberIndex < membres.length) {
        return membres[memberIndex++];
      }
      return null;
    }

    // 🔑 Le callback utilise maintenant la fonction unifiée
    final MemberTapCallback cardTap = (id) => _handleMemberCardTap(memberId: id);
    final double screenWidth = MediaQuery.of(context).size.width;

    // Fonction pour construire une ligne de 2 cartes
    Widget buildTwoMemberRow() {
      return Column(
        children: [
          // Ligne de connexion horizontale entre les 2 membres
          Container(
            width: screenWidth * 0.7, // Ligne plus courte pour 2 cartes
            height: 2,
            color: Colors.grey.shade400,
            margin: const EdgeInsets.only(bottom: 10),
          ),
          _buildHorizontalLevel([
            _buildMemberCardDynamic(getNextMember(), onTap: cardTap),
            _buildMemberCardDynamic(getNextMember(), onTap: cardTap),
          ], maxWidth: screenWidth - 32),
          _buildConnectionLine(isVertical: true, height: 20),
        ],
      );
    }

    return Center(
      child: Column(
        children: [
          // Ligne 1 : Niveau 1 (Index 0) - 1 carte
          _buildMemberCardDynamic(getNextMember(), onTap: cardTap),
          _buildConnectionLine(),

          // --- 7 Niveaux de 2 cartes pour un total de 14 cartes ---
          buildTwoMemberRow(), // Niveau 2 (Index 1 & 2)
          buildTwoMemberRow(), // Niveau 3 (Index 3 & 4)
          buildTwoMemberRow(), // Niveau 4 (Index 5 & 6)
          buildTwoMemberRow(), // Niveau 5 (Index 7 & 8)
          buildTwoMemberRow(), // Niveau 6 (Index 9 & 10)
          buildTwoMemberRow(), // Niveau 7 (Index 11 & 12)

          // Niveau 8 (Index 13 & 14)
          Column(
            children: [
              // Ligne de connexion horizontale entre les 2 membres
              Container(
                width: screenWidth * 0.7,
                height: 2,
                color: Colors.grey.shade400,
                margin: const EdgeInsets.only(bottom: 10),
              ),
              _buildHorizontalLevel([
                _buildMemberCardDynamic(getNextMember(), onTap: cardTap),
                _buildMemberCardDynamic(getNextMember(), onTap: cardTap),
              ], maxWidth: screenWidth - 32),
              // Pas de ligne verticale après le dernier niveau d'arbre
              const SizedBox(height: 20),
            ],
          ),

          // 🔑 GESTION DES MEMBRES RESTANTS (Index 15 et suivants)
          if (memberIndex < membres.length)
            _buildRemainingMembersList(membres.sublist(memberIndex)),
        ],
      ),
    );
  }

  // **Liste des membres restants (pour l'évolutivité)**
  Widget _buildRemainingMembersList(List<Membre> remainingMembers) {
    if (remainingMembers.isEmpty) return const SizedBox.shrink();

    // 🔑 Callback pour la navigation : utilise le gestionnaire unifié
    final MemberTapCallback cardTap = (id) => _handleMemberCardTap(memberId: id);

    return Padding(
      padding: const EdgeInsets.only(top: 30.0, left: 16.0, right: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: Text(
              '${remainingMembers.length} autres Membres (liste complète)',
              style: const TextStyle(fontWeight: FontWeight.bold, color: _cardTextColor, fontSize: 16),
            ),
          ),

          // Liste simple des membres restants (sous forme de cartes)
          ...remainingMembers.map((membre) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 8.0),
              // 🔑 Passage de l'ID du membre pour l'action onTap
              child: _buildMemberCardDynamic(membre, onTap: cardTap),
            );
          }).toList(),
        ],
      ),
    );
  }


  // **Carte de membre dynamique** (CORRIGÉ : Utilise le gestionnaire unifié via onTap)
  Widget _buildMemberCardDynamic(Membre? membre, {required MemberTapCallback onTap}) {
    // Si le membre n'est pas trouvé (indice dépassé), affiche un placeholder cliquable
    if (membre == null) {
      // Le placeholder utilise le gestionnaire unifié pour l'ajout
      return _buildMemberCardPlaceholder(onTap: (id) => _handleMemberCardTap(memberId: id, isPlaceholder: true));
    }

    int birthYear = 0;
    try {
      if (membre.dateNaissance.contains('-')) {
        // Le modèle Membre.dart mis à jour garantit que id n'est pas null ici (si la data est bien retournée)
        birthYear = int.tryParse(membre.dateNaissance.split('-').first) ?? 0;
      }
    } catch (_) { /* ignore */ }

    const int contributions = 0; // Donnée statique pour l'instant

    // Construction de l'URL complète pour la photo
    final String fullPhotoUrl = (membre.photoUrl != null && membre.photoUrl!.isNotEmpty)
        ? '$_baseUrl/${membre.photoUrl!}'
        : '';
    final bool hasPhoto = fullPhotoUrl.isNotEmpty;

    return GestureDetector(
      // 🔑 Le onTap final passe l'ID au gestionnaire unifié via le callback MemberTapCallback
      onTap: () => onTap(membre.id),
      child: Container(
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
                  errorBuilder: (context, error, stackTrace) => const Icon(Icons.person, color: Colors.grey, size: 30),
                )
                    : const Icon(Icons.person, color: Colors.grey, size: 30),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    membre.nomComplet, // DYNAMIQUE
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: _cardTextColor),
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text(
                    membre.relationFamiliale, // DYNAMIQUE
                    style: const TextStyle(fontSize: 10, color: Colors.grey),
                  ),
                  Text(
                    birthYear > 0 ? 'Né en $birthYear (ID: ${membre.id ?? '?'})' : 'Date de naissance inconnue', // DYNAMIQUE avec ID
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
      ),
    );
  }

  // Carte de membre POUBELLE (Placeholder) (CORRIGÉ : Utilise le gestionnaire unifié)
  Widget _buildMemberCardPlaceholder({required MemberTapCallback onTap}) {
    return GestureDetector(
      // 🔑 Le clic sur le placeholder passe null et l'indicateur isPlaceholder
      onTap: () => _handleMemberCardTap(memberId: null, isPlaceholder: true),
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: _lightCardColor,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: Colors.grey.shade400, width: 1.5),
        ),
        child: Row(
          children: [
            const Icon(Icons.add_circle_outline, color: _mainAccentColor, size: 30),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  Text(
                    'Ajouter un Membre',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: _mainAccentColor),
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text(
                    'Cliquez ici pour remplir cette place.',
                    style: TextStyle(fontSize: 10, color: Colors.grey),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

// -------------------------------------------------------------------
// --- WIDGETS DE STYLE ET UTILS (Inchangés) ---
// -------------------------------------------------------------------

  // Section des statistiques (inchangé)
  Widget _buildStats() {
    final famille = _familleData;
    if (famille == null) return const SizedBox.shrink();

    int? anneeDebut;
    if (famille.membres.isNotEmpty) {
      try {
        // CORRECTION : Fournir uniquement les arguments 'required' du constructeur Membre.
        String date = famille.membres.firstWhere(
              (m) => m.dateNaissance.isNotEmpty,
          orElse: () => Membre(
            id: 0,
            nomComplet: '',
            dateNaissance: '',
            lieuNaissance: '',
            relationFamiliale: '',
            idFamille: 0,
            nomFamille: '',
            dateCreation: '',
          ),
        ).dateNaissance;

        if (date.contains('-')) {
          anneeDebut = int.tryParse(date.split('-').first);
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
              _buildStatBox(label: 'Générations', value: 'N/A'), // La génération est complexe à calculer sans données structurées
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

  // Structure pour les niveaux horizontaux (frères/sœurs) (CORRIGÉ pour 2 cartes)
  Widget _buildHorizontalLevel(List<Widget> members, {required double maxWidth}) {
    // Si toutes les cartes sont des placeholders vides, n'affiche pas la ligne.
    // Cette vérification est complexe et pourrait être simplifiée si Membre.dart ne permet plus id=null pour les cartes affichées.
    // Laissez-la telle quelle pour la robustesse des placeholders.
    // if (members.every((w) => w is Flexible && w.child is Padding && (w.child as Padding).child is SizedBox)) return const SizedBox.shrink();

    // 🔑 Assurer que le conteneur horizontal ne dépasse pas la largeur de l'écran
    return SizedBox(
      width: maxWidth,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: members.map((memberCard) {
          // Chaque carte est enveloppée dans Flexible pour partager l'espace (2 cartes seulement)
          return Flexible(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4.0),
              child: memberCard,
            ),
          );
        }).toList(),
      ),
    );
  }
}