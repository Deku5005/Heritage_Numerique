import 'package:flutter/material.dart';

import '../model/FamilleModel.dart';
import '../model/Membre.dart';
import '../service/ArbreGenealogiqueService.dart';

import 'CreateTreeScreen.dart';
import 'AppDrawer.dart';
import 'MembresDetailsScreen.dart';

// --- PALETTE DE COULEURS PREMIUM ---
const Color _goldPrimary = Color(0xFFAA7311);
const Color _brownDark = Color(0xFF5D4037);
const Color _creamBackground = Color(0xFFF9F5F0);
const Color _cardBackground = Colors.white;
const Color _textDark = Color(0xFF2E2E2E);
const String _baseUrl = "http://10.0.2.2:8080";

class FamilyTreeScreen extends StatefulWidget {
  final int familyId;
  const FamilyTreeScreen({super.key, required this.familyId});

  @override
  State<FamilyTreeScreen> createState() => _FamilyTreeScreenState();
}

class _FamilyTreeScreenState extends State<FamilyTreeScreen> {
  Famille? _familleData;
  bool _isLoading = true;
  String? _errorMessage;
  final ArbreGenealogiqueService _apiService = ArbreGenealogiqueService();
  final TransformationController _transformationController = TransformationController();

  Membre? _selectedMember; // Membre au centre de la vue (Racine de l'arbre descendant)

  // Dimensions des cartes (style MyHeritage)
  final double _nodeWidth = 130.0;
  final double _nodeHeight = 180.0;
  final double _horizontalSpacing = 120.0;
  final double _verticalSpacing = 40.0;

  @override
  void initState() {
    super.initState();
    _fetchFamilyTree();
  }

  @override
  void dispose() {
    _transformationController.dispose();
    super.dispose();
  }

  Future<void> _fetchFamilyTree() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final famille = await _apiService.fetchArbreHierarchique(familleId: widget.familyId);

      setState(() {
        _familleData = famille;
        // Debug: afficher tous les membres de la famille
        print("=== DONNÉES FAMILLE ===");
        print("Nombre total de membres racines: ${famille.membres.length}");
        for (var membre in famille.membres) {
          print("Membre racine: ${membre.nomComplet} (ID: ${membre.id}) - ${membre.enfants.length} enfants");
          _printMemberTree(membre, 0);
        }

        // Optionnel : sélectionner le premier membre comme racine initiale
        if (_familleData!.membres.isNotEmpty && _selectedMember == null) {
          _selectedMember = _familleData!.membres.first;
        }

        _isLoading = false;
      });

      WidgetsBinding.instance.addPostFrameCallback((_) => _centerTree());
    } catch (e) {
      setState(() {
        _errorMessage = 'Erreur de chargement : $e';
        _isLoading = false;
      });
    }
  }

  void _centerTree() {
    if (_familleData == null || _familleData!.membres.isEmpty) return;

    final size = MediaQuery.of(context).size;

    // Déterminer la largeur totale de l'arbre (en utilisant la même logique que _buildHorizontalTree)
    final levels = _getLevels();
    final sortedLevels = levels.keys.toList()..sort();
    final totalLevels = sortedLevels.length;
    final totalWidth = totalLevels * (_nodeWidth + 10) +
        (totalLevels > 1 ? (totalLevels - 1) * _horizontalSpacing : 0);

    // Utiliser la même marge de sécurité que dans _buildHorizontalTree
    final contentWidth = totalWidth + 250;

    // Centrer l'arbre complet (largeur totale) au centre de l'écran (size.width)
    final initialScale = 0.85;

    _transformationController.value = Matrix4.identity()
      ..translate(
          size.width / 2 - (contentWidth * initialScale) / 2, // Centrage horizontal initial
          size.height / 2 - 200 // Centrage vertical approximatif
      )
      ..scale(initialScale);
  }

  void _selectMember(Membre membre) {
    setState(() {
      _selectedMember = membre;
    });
    _centerTree();
  }

  // Fonction utilitaire pour afficher l'arbre des membres (debug)
  void _printMemberTree(Membre membre, int depth) {
    final indent = "  " * depth;
    print("$indent- ${membre.nomComplet} (ID: ${membre.id}) - ${membre.enfants.length} enfants");
    for (var enfant in membre.enfants) {
      _printMemberTree(enfant, depth + 1);
    }
  }

  // Fonction pour extraire et organiser les membres par niveaux
  Map<int, List<Membre>> _getLevels() {
    if (_familleData == null) return {};

    final allMembers = <Membre>[];
    final memberMap = <int, Membre>{};

    void collectAllMembers(List<Membre> membres) {
      for (var membre in membres) {
        if (!memberMap.containsKey(membre.id)) {
          allMembers.add(membre);
          memberMap[membre.id] = membre;
        }
        if (membre.enfants.isNotEmpty) {
          collectAllMembers(membre.enfants);
        }
      }
    }

    collectAllMembers(_familleData!.membres);

    final levels = <int, List<Membre>>{};
    final memberLevels = <int, int>{};

    // Trouver les racines (ceux qui n'ont pas de parent dans l'arbre affiché)
    final allMemberIds = memberMap.keys.toSet();
    final rootMembers = allMembers.where((m) {
      // Un membre est racine si AUCUN autre membre affiché ne le référence comme enfant
      return !allMembers.any((other) => other.enfants.any((e) => e.id == m.id && allMemberIds.contains(e.id)));
    }).toList();

    // Assigner le niveau 0 aux racines
    levels[0] = rootMembers;
    for (var member in rootMembers) {
      memberLevels[member.id] = 0;
    }

    // Organiser les autres membres par niveaux
    int currentLevel = 0;
    bool hasNextLevel = true;
    while (hasNextLevel) {
      hasNextLevel = false;
      final nextLevelMembers = <Membre>[];
      final currentLevelMembers = levels[currentLevel] ?? [];

      for (var member in currentLevelMembers) {
        for (var enfant in member.enfants) {
          // On ne gère que les enfants présents dans la liste (memberMap)
          if (memberMap.containsKey(enfant.id) && !memberLevels.containsKey(enfant.id)) {
            nextLevelMembers.add(memberMap[enfant.id]!);
            memberLevels[enfant.id] = currentLevel + 1;
            hasNextLevel = true;
          }
        }
      }

      if (nextLevelMembers.isNotEmpty) {
        final uniqueNextLevel = nextLevelMembers.toSet().toList();
        levels[currentLevel + 1] = uniqueNextLevel;
      }
      currentLevel++;
    }

    // Assurer que les membres orphelins sont inclus
    for (var member in allMembers) {
      if (!memberLevels.containsKey(member.id)) {
        if (!levels.containsKey(0)) {
          levels[0] = [];
        }
        if (!levels[0]!.contains(member)) {
          levels[0]!.add(member);
          memberLevels[member.id] = 0;
        }
      }
    }

    return levels;
  }

  // ==================== CONSTRUCTION DE L'ARBRE COMPLET (Tous les membres avec relations) ====================
  Widget _buildHorizontalTree() {
    if (_familleData == null || _familleData!.membres.isEmpty) {
      return const SizedBox.shrink();
    }

    // Étape 1 & 2: Organisation par niveaux
    final levels = _getLevels();

    if (levels.isEmpty) {
      return const SizedBox.shrink();
    }

    // Étape 3: Calculer les positions verticales pour chaque niveau
    final memberPositions = <int, Map<int, double>>{};
    _calculatePositionsForLevels(levels, memberPositions);

    // 🚀 NOUVELLE ÉTAPE 4: Calculer la hauteur totale de l'arbre
    double maxGlobalY = 0.0;
    for (var positions in memberPositions.values) {
      for (var yPos in positions.values) {
        if (yPos > maxGlobalY) {
          maxGlobalY = yPos;
        }
      }
    }

    // La hauteur finale de l'arbre est la position du centre du nœud le plus bas + la moitié de la hauteur du nœud.
    final totalTreeHeight = (maxGlobalY + _nodeHeight / 2).clamp(_nodeHeight * 2, double.infinity);


    // Calculer la largeur totale nécessaire
    final sortedLevels = levels.keys.toList()..sort();
    final totalWidth = sortedLevels.length * (_nodeWidth + 10) +
        (sortedLevels.length > 1 ? (sortedLevels.length - 1) * _horizontalSpacing : 0);

    // Ajouter une marge de sécurité (250) à la largeur
    final double contentWidth = totalWidth + 250;

    print("Largeur totale calculée: $totalWidth (${sortedLevels.length} niveaux)");
    print("Hauteur totale calculée: $totalTreeHeight");


    return SizedBox(
      width: contentWidth,
      height: totalTreeHeight, // 👈 UTILISER LA HAUTEUR TOTALE CALCULÉE
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.max,
        children: sortedLevels.map((levelIndex) {
          final members = levels[levelIndex] ?? [];
          final nextLevelIndex = sortedLevels.indexOf(levelIndex) + 1;
          final nextLevelMembers = nextLevelIndex < sortedLevels.length
              ? levels[sortedLevels[nextLevelIndex]] ?? []
              : <Membre>[];

          return _buildLevelColumn(members, levelIndex, nextLevelMembers, memberPositions);
        }).toList(),
      ),
    );
  }

  // Calculer les positions verticales pour les niveaux
  void _calculatePositionsForLevels(
      Map<int, List<Membre>> levels,
      Map<int, Map<int, double>> memberPositions,
      ) {
    // Initialiser les maps de positions
    for (var level in levels.keys) {
      memberPositions[level] = {};
    }

    if (levels.isEmpty) return;

    // Calculer les positions de la dernière niveau vers la première
    final sortedLevels = levels.keys.toList()..sort((a, b) => b.compareTo(a));

    for (var level in sortedLevels) {
      final members = levels[level]!;
      final positions = memberPositions[level]!;

      if (level == sortedLevels.first) {
        // Dernier niveau : distribuer uniformément depuis 0
        for (int i = 0; i < members.length; i++) {
          positions[members[i].id] = i * (_nodeHeight + _verticalSpacing) + _nodeHeight / 2;
        }
      } else {
        // Niveaux précédents : centrer par rapport aux enfants
        final nextLevelPositions = memberPositions[level + 1]!;

        for (var member in members) {
          if (member.enfants.isEmpty) {
            // Pas d'enfants : utiliser une position par défaut basée sur l'index (fall-back)
            final index = members.indexOf(member);
            positions[member.id] = index * (_nodeHeight + _verticalSpacing) + _nodeHeight / 2;
          } else {
            // Avoir des enfants : centrer par rapport à eux
            final childPositions = <double>[];

            for (var enfant in member.enfants) {
              if (nextLevelPositions.containsKey(enfant.id)) {
                childPositions.add(nextLevelPositions[enfant.id]!);
              }
            }

            if (childPositions.isNotEmpty) {
              childPositions.sort();
              final minY = childPositions.first;
              final maxY = childPositions.last;
              positions[member.id] = (minY + maxY) / 2;
            } else {
              // Fallback
              final index = members.indexOf(member);
              positions[member.id] = index * (_nodeHeight + _verticalSpacing) + _nodeHeight / 2;
            }
          }
        }

        // Ajuster les positions pour éviter les chevauchements
        _adjustPositionsForOverlap(members, positions);
      }
    }

    // Normaliser toutes les positions pour qu'elles commencent à 0
    // Cette étape est essentielle pour que le 'maxGlobalY' fonctionne dans _buildHorizontalTree
    for (var level in sortedLevels.reversed) {
      final positions = memberPositions[level]!;
      if (positions.isEmpty) continue;

      final minPos = positions.values.reduce((a, b) => a < b ? a : b);
      // Remarque : Nous enlevons ici le décalage de + _nodeHeight / 2 car la normalisation doit
      // commencer à 0, et l'ajustement pour le centre du premier nœud sera fait plus tard.
      final offset = minPos - _nodeHeight / 2; // Le centre du premier nœud doit être à _nodeHeight / 2

      for (var key in positions.keys) {
        positions[key] = positions[key]! - offset;
      }
    }
  }

  // Ajuster les positions pour éviter les chevauchements
  void _adjustPositionsForOverlap(List<Membre> members, Map<int, double> positions) {
    if (members.length <= 1) return;

    final sortedMembers = List<Membre>.from(members);
    sortedMembers.sort((a, b) => positions[a.id]!.compareTo(positions[b.id]!));

    double minSpacing = _nodeHeight + _verticalSpacing;

    for (int i = 0; i < sortedMembers.length - 1; i++) {
      final currentY = positions[sortedMembers[i].id]!;
      final nextY = positions[sortedMembers[i + 1].id]!;

      if (nextY - currentY < minSpacing) {
        positions[sortedMembers[i + 1].id] = currentY + minSpacing;
      }
    }
  }

  Widget _buildLevelColumn(
      List<Membre> members,
      int level,
      List<Membre> nextLevelMembers,
      Map<int, Map<int, double>> memberPositions,
      ) {
    if (members.isEmpty) {
      return const SizedBox.shrink();
    }

    final positions = memberPositions[level] ?? {};

    // Trier les membres par position Y
    final sortedMembers = List<Membre>.from(members);
    sortedMembers.sort((a, b) {
      final posA = positions[a.id] ?? 0.0;
      final posB = positions[b.id] ?? 0.0;
      return posA.compareTo(posB);
    });

    // Calculer la hauteur réelle nécessaire de cette colonne
    double maxPos = 0.0;
    for (var member in sortedMembers) {
      final pos = positions[member.id] ?? 0.0;
      if (pos > maxPos) maxPos = pos;
    }

    final calculatedHeight = maxPos + _nodeHeight / 2;

    // S'assurer qu'il y a une hauteur minimale
    final minHeight = _nodeHeight + _verticalSpacing;
    final finalHeight = calculatedHeight.clamp(minHeight, double.infinity);


    return SizedBox(
      height: finalHeight,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Colonne de membres avec Stack pour positionnement précis
          SizedBox(
            width: _nodeWidth + 10, // Ajouter 10 pour les marges (5 de chaque côté)
            height: finalHeight,
            child: Stack(
              clipBehavior: Clip.none,
              children: sortedMembers.map((membre) {
                final yPos = positions[membre.id] ?? 0.0;
                return Positioned(
                  top: yPos - _nodeHeight / 2, // Position Y est le centre du nœud
                  left: 0,
                  child: _buildMemberCard(membre),
                );
              }).toList(),
            ),
          ),
          // Lignes de connexion vers le niveau suivant (style MyHeritage)
          if (members.isNotEmpty && nextLevelMembers.isNotEmpty)
            SizedBox(
              width: _horizontalSpacing,
              height: finalHeight,
              child: CustomPaint(
                painter: _ConnectionLinePainter(
                  color: _brownDark.withOpacity(0.5),
                  parentMembers: members,
                  childMembers: nextLevelMembers,
                  nodeHeight: _nodeHeight,
                  nodeWidth: _nodeWidth,
                  parentPositions: memberPositions[level] ?? {},
                  childPositions: memberPositions[level + 1] ?? {},
                ),
              ),
            ),
        ],
      ),
    );
  }

  // ==================== NAVIGATION ====================
  void _navigateToAddMember({int? parentId}) async {
    final refresh = await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => CreateTreeScreen(familyId: widget.familyId, parentId: parentId)),
    );
    if (refresh == true) _fetchFamilyTree();
  }

  void _navigateToMemberDetail(int memberId) {
    Navigator.push(context, MaterialPageRoute(builder: (_) => MembreDetailScreen(membreId: memberId)));
  }

  // ==================== BUILD ====================
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _creamBackground,
      drawer: AppDrawer(familyId: widget.familyId),
      body: Stack(
        children: [
          // Fond décoratif
          Positioned.fill(
            child: Opacity(
              opacity: 0.05,
              child: Image.asset('assets/images/Heritage1.png', repeat: ImageRepeat.repeat, scale: 4),
            ),
          ),

          Column(
            children: [
              _buildHeader(context),
              Expanded(
                child: _isLoading
                    ? const Center(child: CircularProgressIndicator(color: _goldPrimary))
                    : _errorMessage != null
                    ? Center(child: Text(_errorMessage!, style: const TextStyle(color: Colors.red)))
                    : _buildTreeView(),
              ),
            ],
          ),

          // Bouton flottant
          Positioned(
            bottom: 30,
            right: 30,
            child: FloatingActionButton.extended(
              backgroundColor: _goldPrimary,
              icon: const Icon(Icons.person_add, color: Colors.white),
              label: const Text("Ajouter", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
              onPressed: () => _navigateToAddMember(parentId: null),
              elevation: 4,
            ),
          ),

          // Contrôles de zoom
          Positioned(
            bottom: 30,
            left: 30,
            child: Column(
              children: [
                FloatingActionButton(
                  heroTag: "zoom_in",
                  mini: true,
                  backgroundColor: Colors.white,
                  child: const Icon(Icons.add, color: _textDark),
                  onPressed: () {
                    _transformationController.value = _transformationController.value.clone()..scale(1.2);
                  },
                ),
                const SizedBox(height: 10),
                FloatingActionButton(
                  heroTag: "zoom_out",
                  mini: true,
                  backgroundColor: Colors.white,
                  child: const Icon(Icons.remove, color: _textDark),
                  onPressed: () {
                    _transformationController.value = _transformationController.value.clone()..scale(0.8);
                  },
                ),
                const SizedBox(height: 10),
                FloatingActionButton(
                  heroTag: "center",
                  mini: true,
                  backgroundColor: Colors.white,
                  child: const Icon(Icons.center_focus_strong, color: _textDark),
                  onPressed: _centerTree,
                ),
              ],
            ),
          )
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(top: MediaQuery.of(context).padding.top + 10, left: 16, right: 16, bottom: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 5, offset: const Offset(0, 2))
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Utilisation de Builder pour avoir le bon contexte pour Scaffold.of()
          Builder(
            builder: (context) => IconButton(
              onPressed: () => Scaffold.of(context).openDrawer(),
              icon: const Icon(Icons.menu, color: _brownDark),
            ),
          ),
          Column(
            children: [

              const Text("Arbre Familial", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: _brownDark)),

              if (_selectedMember != null)
                Text(_selectedMember!.nomComplet ?? "Membre", style: const TextStyle(fontSize: 12, color: _goldPrimary, fontStyle: FontStyle.italic)),

            ],
          ),
          IconButton(
            onPressed: () => Navigator.pop(context),
            icon: const Icon(Icons.close, color: _brownDark),
          ),
        ],
      ),
    );
  }

  // Dans FamilyTreeScreen.dart, autour de la ligne 860

  Widget _buildTreeView() {
    if (_familleData!.membres.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.account_tree_outlined, size: 80, color: Colors.grey),
            const SizedBox(height: 20),
            const Text("Votre arbre est vide.", style: TextStyle(fontSize: 18, color: Colors.grey)),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () => _navigateToAddMember(parentId: null),
              style: ElevatedButton.styleFrom(backgroundColor: _goldPrimary, foregroundColor: Colors.white),
              child: const Text("Créer le premier ancêtre"),
            )
          ],
        ),
      );
    }

    return InteractiveViewer(
      transformationController: _transformationController,
      boundaryMargin: const EdgeInsets.all(2000),
      minScale: 0.1,
      maxScale: 4.0,
      // 🚀 CORRECTION : Retirer le ClipRect qui pourrait couper prématurément le contenu.
      child: _buildHorizontalTree(),
    );
  }

  // ==================== CARTE MEMBRE PREMIUM ====================
  Widget _buildMemberCard(Membre membre) {
    final photoUrl = membre.photoUrl?.isNotEmpty == true
        ? '$_baseUrl/${membre.photoUrl!}'
        : '';

    final String birthYear = membre.dateNaissance != null
        ? membre.dateNaissance!.split('-').first
        : '????';

    final bool isSelected = _selectedMember?.id == membre.id;

    return GestureDetector(
      onTap: () => _showMemberOptions(membre),
      child: Container(
        width: _nodeWidth - 10, // Soustraire les marges horizontales (5 de chaque côté)
        height: _nodeHeight - 10, // Soustraire les marges verticales
        margin: const EdgeInsets.all(5),
        child: Stack(
          alignment: Alignment.topCenter,
          children: [
            // Carte principale
            Positioned(
              top: 30,
              left: 0,
              right: 0,
              bottom: 0,
              child: Container(
                decoration: BoxDecoration(
                  color: isSelected ? _goldPrimary.withOpacity(0.1) : _cardBackground,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    ),
                  ],
                  border: Border.all(
                      color: isSelected ? _goldPrimary : _goldPrimary.withOpacity(0.3),
                      width: isSelected ? 2 : 1
                  ),
                ),
                child: Padding(
                  padding: const EdgeInsets.only(top: 40, left: 8, right: 8, bottom: 8),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        membre.nomComplet ?? 'Inconnu',
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                          color: _textDark,
                          fontFamily: 'Serif',
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 3),
                      Container(height: 1, width: 30, color: _goldPrimary.withOpacity(0.5)),
                      const SizedBox(height: 3),
                      Text(
                        membre.relationFamiliale ?? 'Membre',
                        style: const TextStyle(fontSize: 10, color: _brownDark, fontStyle: FontStyle.italic),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const Spacer(),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                        decoration: BoxDecoration(
                          color: _creamBackground,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          birthYear,
                          style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.grey),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            // Photo de profil
            Positioned(
              top: 0,
              child: Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white,
                  border: Border.all(color: _goldPrimary, width: 2),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.2),
                      blurRadius: 6,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: ClipOval(
                  child: photoUrl.isNotEmpty
                      ? Image.network(
                    photoUrl,
                    fit: BoxFit.cover,
                    errorBuilder: (ctx, err, stack) => _buildPlaceholderAvatar(),
                  )
                      : _buildPlaceholderAvatar(),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPlaceholderAvatar() {
    return Container(
      color: _creamBackground,
      child: const Icon(Icons.person, size: 30, color: _goldPrimary),
    );
  }

  // ==================== BOTTOM SHEET OPTIONS ====================
  void _showMemberOptions(Membre membre) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 30,
                  backgroundColor: _goldPrimary,
                  backgroundImage: (membre.photoUrl?.isNotEmpty == true)
                      ? NetworkImage('$_baseUrl/${membre.photoUrl!}')
                      : null,
                  child: (membre.photoUrl?.isEmpty ?? true) ? const Icon(Icons.person, color: Colors.white) : null,
                ),
                const SizedBox(width: 15),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(membre.nomComplet ?? "Inconnu", style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                      Text(membre.relationFamiliale ?? "Membre", style: const TextStyle(color: Colors.grey)),
                    ],
                  ),
                ),
              ],
            ),
            const Divider(height: 30),
            ListTile(
              leading: const Icon(Icons.center_focus_strong, color: _goldPrimary),
              title: const Text("Définir comme racine"),
              onTap: () {
                Navigator.pop(context);
                _selectMember(membre);
              },
            ),
            ListTile(
              leading: const Icon(Icons.info_outline, color: _brownDark),
              title: const Text("Voir les détails"),
              onTap: () {
                Navigator.pop(context);
                _navigateToMemberDetail(membre.id);
              },
            ),
            ListTile(
              leading: const Icon(Icons.add_circle_outline, color: _goldPrimary),
              title: const Text("Ajouter un parent/enfant"),
              onTap: () {
                Navigator.pop(context);
                _navigateToAddMember(parentId: membre.id);
              },
            ),
          ],
        ),
      ),
    );
  }
}

// Custom painter pour les lignes de connexion (style MyHeritage)
class _ConnectionLinePainter extends CustomPainter {
  final Color color;
  final List<Membre> parentMembers;
  final List<Membre> childMembers;
  final double nodeHeight;
  final double nodeWidth;
  final Map<int, double> parentPositions; // memberId -> yPosition
  final Map<int, double> childPositions; // memberId -> yPosition

  _ConnectionLinePainter({
    required this.color,
    required this.parentMembers,
    required this.childMembers,
    required this.nodeHeight,
    required this.nodeWidth,
    required this.parentPositions,
    required this.childPositions,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 2.5
      ..style = PaintingStyle.stroke;

    // Grouper les enfants par parent
    final Map<int, List<Membre>> childrenByParent = {};

    for (var parent in parentMembers) {
      childrenByParent[parent.id] = [];
      for (var child in childMembers) {
        // Vérifier si l'enfant appartient à ce parent
        if (parent.enfants.any((e) => e.id == child.id)) {
          childrenByParent[parent.id]!.add(child);
        }
      }
    }

    // Dessiner les connexions pour chaque parent
    for (var parent in parentMembers) {
      final children = childrenByParent[parent.id] ?? [];
      if (children.isEmpty) continue;

      final parentY = parentPositions[parent.id] ?? 0.0;

      if (children.length == 1) {
        // Un seul enfant : ligne en forme de 'Z' inversé
        final childY = childPositions[children[0].id] ?? 0.0;
        final midX = size.width / 2;

        // 1. Ligne horizontale depuis le centre du parent (Y)
        canvas.drawLine(
          Offset(0, parentY),
          Offset(midX, parentY),
          paint,
        );
        // 2. Ligne verticale au milieu (du parentY au childY)
        canvas.drawLine(
          Offset(midX, parentY),
          Offset(midX, childY),
          paint,
        );
        // 3. Ligne horizontale vers l'enfant (Y)
        canvas.drawLine(
          Offset(midX, childY),
          Offset(size.width, childY),
          paint,
        );
      } else if (children.length > 1) {
        // Plusieurs enfants : lignes en T avec barre verticale
        final childrenYs = children.map((c) => childPositions[c.id] ?? 0.0).toList()..sort();
        final minChildY = childrenYs.first;
        final maxChildY = childrenYs.last;
        final midX = size.width / 2;

        // 1. Ligne horizontale depuis le centre du parent vers le centre de la colonne
        canvas.drawLine(
          Offset(0, parentY),
          Offset(midX, parentY),
          paint,
        );
        // 2. Ligne verticale principale (du parentY au maxChildY, pour couvrir la zone des enfants)
        canvas.drawLine(
          Offset(midX, parentY),
          Offset(midX, maxChildY),
          paint,
        );
        // Lignes horizontales vers chaque enfant
        for (var childY in childrenYs) {
          canvas.drawLine(
            Offset(midX, childY),
            Offset(size.width, childY),
            paint,
          );
        }
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}