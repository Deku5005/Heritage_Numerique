import 'package:flutter/material.dart';
import 'dart:convert';
import '../service/ArbreGenealogiqueService.dart';
import '../model/ContributionFamilleModel.dart';
import 'AppDrawer.dart';

// --- Constantes de Couleurs Globales ---
const Color _mainAccentColor = Color(0xFFAA7311);
const Color _backgroundColor = Colors.white;
const Color _cardTextColor = Color(0xFF2E2E2E);
const Color _searchBackground = Color(0xFFF7F2E8);
const Color _roleAdminColor = Color(0xFFE5B0B0); // Rouge pâle pour Administrateur
const Color _roleEditorColor = Color(0xFFF7E8D8); // Beige/Jaune pâle pour Éditeur
const Color _roleContributorColor = Color(0xFFE6F3E6); // Vert pâle pour Contributeur
const Color _roleTextColor = Color(0xFF7B521A); // Couleur marron foncé pour le texte des rôles

// 🔑 URL DE BASE POUR LES IMAGES (Doit correspondre à celle du service)
const String _baseUrl = "http://10.0.2.2:8080";


// 1. Transformer en StatefulWidget pour gérer l'état
class ContributionsScreen extends StatefulWidget {
  final int? familyId;

  const ContributionsScreen({super.key, required this.familyId});

  @override
  State<ContributionsScreen> createState() => _ContributionsScreenState();
}

class _ContributionsScreenState extends State<ContributionsScreen> {
  final ArbreGenealogiqueService _apiService = ArbreGenealogiqueService();
  ContributionsFamilleModel? _contributionsData;
  bool _isLoading = true;
  String? _errorMessage;
  String _searchQuery = ''; // État pour la recherche

  @override
  void initState() {
    super.initState();
    _fetchContributions();
  }

  Future<void> _fetchContributions() async {
    if (widget.familyId == null) {
      setState(() {
        _errorMessage = "ID de famille non spécifié.";
        _isLoading = false;
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final data = await _apiService.fetchContributionsFamille(familleId: widget.familyId!);
      setState(() {
        _contributionsData = data;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Erreur de chargement des contributions : ${e.toString()}';
        _isLoading = false;
        debugPrint(_errorMessage);
      });
    }
  }

  // --- Widgets de Construction de l'Écran (Mise à jour) ---

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
            const SizedBox(height: 20),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Contributions de la famille ${_contributionsData?.nomFamille ?? '...'}',
                    style: const TextStyle(
                      color: _cardTextColor,
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 5),
                  const Text(
                    'Découvrez les contributions de chaque membre de la famille',
                    style: TextStyle(
                      color: Colors.grey,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Barre de recherche
                  _buildSearchBar(),
                  const SizedBox(height: 20),

                  // Liste des Contributions (Maintenant dynamique)
                  _buildContentBody(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Gère l'affichage du contenu selon l'état
  Widget _buildContentBody() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator(color: _mainAccentColor));
    }
    if (_errorMessage != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Text(_errorMessage!, textAlign: TextAlign.center, style: const TextStyle(color: Colors.red)),
        ),
      );
    }
    if (_contributionsData == null || _contributionsData!.contributionsMembres.isEmpty) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(20.0),
          child: Text('Aucune contribution trouvée pour cette famille.', textAlign: TextAlign.center),
        ),
      );
    }

    return _buildContributionList();
  }

  Widget _buildCustomHeader(BuildContext context) {
    // Reste inchangé
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
              color: _cardTextColor,
              fontWeight: FontWeight.bold,
              fontSize: 20,
            ),
          ),
          IconButton(
            icon: const Icon(Icons.close, color: Colors.grey, size: 24),
            onPressed: () => Navigator.pop(context),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10),
      decoration: BoxDecoration(
        color: _searchBackground,
        borderRadius: BorderRadius.circular(5),
      ),
      child: TextField(
        onChanged: (value) {
          setState(() {
            _searchQuery = value;
          });
        },
        decoration: const InputDecoration(
          hintText: 'Rechercher un membre ou une contribution...',
          hintStyle: TextStyle(color: Colors.grey, fontSize: 14),
          border: InputBorder.none,
          prefixIcon: Icon(Icons.search, color: Colors.grey, size: 20),
          contentPadding: EdgeInsets.symmetric(vertical: 12),
        ),
        style: const TextStyle(fontSize: 14),
      ),
    );
  }

  Widget _buildContributionList() {
    if (_contributionsData == null) return const SizedBox.shrink();

    // 🔑 Filtrage des membres selon la recherche
    final filteredMembers = _contributionsData!.contributionsMembres.where((member) {
      final fullName = '${member.prenom} ${member.nom}'.toLowerCase();
      final query = _searchQuery.toLowerCase();

      return fullName.contains(query);
    }).toList();

    // 🔑 CORRECTION APPLIQUÉE ICI: Utilisation des guillemets triples (''')
    if (filteredMembers.isEmpty && _searchQuery.isNotEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.only(top: 20),
          child: Text(
              '''Aucun membre ne correspond à '$_searchQuery'.''',
              style: const TextStyle(color: Colors.grey)
          ),
        ),
      );
    }

    return Column(
      children: filteredMembers.map((member) {
        return _buildMemberCard(member: member);
      }).toList(),
    );
  }

  // 🔑 Adaptation de la carte pour utiliser ContributionMembreModel
  Widget _buildMemberCard({required ContributionMembreModel member}) {
    // Logique de couleur basée sur le rôle
    Color roleColor;
    String roleLabel = member.roleFamille;
    if (roleLabel == 'ADMIN') {
      roleColor = _roleAdminColor;
    } else if (roleLabel == 'EDITEUR') {
      roleColor = _roleEditorColor;
    } else {
      roleColor = _roleContributorColor; // Par défaut
    }

    // Remplacement des clés statiques par les noms réels de l'API
    final Map<String, int> contributions = {
      'Contes': member.nombreContes,
      'Proverbes': member.nombreProverbes,
      'Artisanats': member.nombreArtisanats,
      'Devinettes': member.nombreDevinettes,
    };

    // Pour l'instant, photoUrl n'est pas dans le modèle, nous utilisons null pour le placeholder
    final String? photoUrl = null;

    final String fullName = '${member.prenom} ${member.nom}';


    return Padding(
      padding: const EdgeInsets.only(bottom: 15.0),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.1),
              spreadRadius: 1,
              blurRadius: 5,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(12.0),
              child: Row(
                children: [
                  // Photo de profil (Dynamique - utilise le placeholder pour l'instant)
                  _buildProfileAvatar(
                      photoUrl: photoUrl,
                      fullName: fullName
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          fullName, // DYNAMIQUE
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                            color: _cardTextColor,
                          ),
                        ),
                        Text(
                          'Lien : ${member.lienParente}', // DYNAMIQUE
                          style: const TextStyle(
                            fontSize: 12,
                            color: Colors.grey,
                          ),
                        ),
                      ],
                    ),
                  ),
                  // Étiquette de Rôle (DYNAMIQUE)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: roleColor,
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: Text(
                      roleLabel,
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: _roleTextColor,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Séparateur
            const Divider(height: 1, thickness: 1, color: Color(0xFFF7F2E8)),

            // Détail des contributions
            Padding(
              padding: const EdgeInsets.all(12.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Total des contributions',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey,
                        ),
                      ),
                      // Bloc total (DYNAMIQUE)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF0D9D9), // Fond Rouge/Rose pâle
                          borderRadius: BorderRadius.circular(5),
                        ),
                        child: Text(
                          member.totalContributions.toString(), // DYNAMIQUE
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFFC80000), // Rouge foncé
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),

                  // Grille des types de contributions (DYNAMIQUE)
                  Wrap(
                    spacing: 10,
                    runSpacing: 10,
                    children: [
                      _buildContributionItem(
                        icon: Icons.book_outlined,
                        label: 'Contes',
                        count: contributions['Contes'] ?? 0,
                        color: const Color(0xFFE6F3E6), // Vert pâle
                      ),
                      _buildContributionItem(
                        icon: Icons.chat_bubble_outline,
                        label: 'Proverbes',
                        count: contributions['Proverbes'] ?? 0,
                        color: const Color(0xFFF3EAE6), // Beige pâle
                      ),
                      _buildContributionItem(
                        icon: Icons.palette_outlined,
                        label: 'Artisanats',
                        count: contributions['Artisanats'] ?? 0,
                        color: const Color(0xFFEEDDFF), // Violet pâle
                      ),
                      _buildContributionItem(
                        icon: Icons.quiz_outlined, // Nouvelle icône pour les devinettes
                        label: 'Devinettes',
                        count: contributions['Devinettes'] ?? 0,
                        color: const Color(0xFFE6F3E6), // Vert pâle
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

  // 🔑 Widget pour gérer l'affichage de la photo de profil (avec fallback sur l'initiale)
  Widget _buildProfileAvatar({String? photoUrl, required String fullName}) {
    final String fullPhotoUrl = (photoUrl != null && photoUrl.isNotEmpty)
        ? '$_baseUrl/$photoUrl'
        : '';
    final bool hasPhoto = fullPhotoUrl.isNotEmpty;

    // Génère une initiale si la photo n'est pas disponible
    final String initial = fullName.isNotEmpty ? fullName[0].toUpperCase() : '?';

    return ClipRRect(
      borderRadius: BorderRadius.circular(24),
      child: Container(
        width: 48,
        height: 48,
        color: Colors.grey.shade300,
        child: hasPhoto
            ? Image.network(
          fullPhotoUrl,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) => Center(
            child: Text(initial, style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
          ),
        )
            : Center(
          child: Text(initial, style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
        ),
      ),
    );
  }

  Widget _buildContributionItem({
    required IconData icon,
    required String label,
    required int count,
    required Color color,
  }) {
    // Reste inchangé, mais les valeurs 'count' sont maintenant dynamiques
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(5),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: _cardTextColor),
          const SizedBox(width: 4),
          Text(
            label,
            style: const TextStyle(fontSize: 12, color: _cardTextColor),
          ),
          const SizedBox(width: 8),
          // Nombre de contributions
          Text(
            count.toString(),
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: _cardTextColor,
            ),
          ),
        ],
      ),
    );
  }
}