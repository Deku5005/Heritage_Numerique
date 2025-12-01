import 'package:flutter/material.dart';

import '../model/FamilleModel.dart';
import '../model/Membre.dart';
import '../service/ArbreGenealogiqueService.dart';

import 'CreateTreeScreen.dart';
import 'AppDrawer.dart'; // <--- Import de AppDrawer
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

  // Clé pour accéder au Scaffold et ouvrir le Drawer
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>(); // AJOUTÉ

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

    // Marge de sécurité pour le centrage
    final contentWidth = totalWidth + 250;

    // Centrer l'arbre complet (largeur totale) au centre de l'écran (size.width)
    const double initialScale = 0.85;

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
        // Ajouter le membre s'il n'est pas déjà dans la map
        if (!memberMap.containsKey(membre.id)) {
          allMembers.add(membre);
          memberMap[membre.id] = membre;
        }
        // Utiliser les enfants du membre actuel pour continuer la récursion
        if (membre.enfants.isNotEmpty) {
          collectAllMembers(membre.enfants);
        }
      }
    }

    collectAllMembers(_familleData!.membres);

    final levels = <int, List<Membre>>{};
    final memberLevels = <int, int>{};

    // Trouver les racines
    // Un membre est racine s'il est dans _familleData!.membres
    final rootMembers = _familleData!.membres;

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
          // On ne gère que les enfants présents dans la liste et non encore assignés à un niveau
          if (memberMap.containsKey(enfant.id) && !memberLevels.containsKey(enfant.id)) {
            nextLevelMembers.add(memberMap[enfant.id]!);
            memberLevels[enfant.id] = currentLevel + 1;
            hasNextLevel = true;
          }
        }
      }

      if (nextLevelMembers.isNotEmpty) {
        // Éliminer les doublons et conserver l'ordre
        final uniqueNextLevel = nextLevelMembers.toSet().toList();
        levels[currentLevel + 1] = uniqueNextLevel;
      }
      currentLevel++;
    }

    // NOTE: La logique pour inclure les membres orphelins est commentée car elle peut être
    // complexe et moins pertinente pour un arbre hiérarchique descendant pur.
    // L'arbre est construit uniquement à partir des racines et de leurs descendants.

    return levels;
  }

  // ==================== CONSTRUCTION DE L'ARBRE COMPLET (Tous les membres avec relations) ====================
  Widget _buildHorizontalTree() {
    if (_familleData == null || _familleData!.membres.isEmpty) {
      return const Center(
        child: Text("Aucun membre de la famille n'a été trouvé. Veuillez en ajouter un.", textAlign: TextAlign.center),
      );
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
    final totalLevels = sortedLevels.length;
    // La largeur totale du contenu de la Row
    final totalContentWidth = totalLevels * (_nodeWidth + 10) +
        (totalLevels > 1 ? (totalLevels - 1) * _horizontalSpacing : 0);

    print("Largeur totale calculée: $totalContentWidth (${sortedLevels.length} niveaux)");
    print("Hauteur totale calculée: $totalTreeHeight");


    // 💡 CORRECTION: On retourne directement la Row pour qu'elle puisse s'étendre au-delà de l'écran.
    // InteractiveViewer s'occupera du défilement.
    return Row( // La Row n'est plus contrainte par un SizedBox parent avec une largeur calculée
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min, // Utiliser Min pour que la Row prenne la largeur totale de ses enfants
      children: sortedLevels.map((levelIndex) {
        final members = levels[levelIndex] ?? [];
        final nextLevelIndex = sortedLevels.indexOf(levelIndex) + 1;
        final nextLevelMembers = nextLevelIndex < sortedLevels.length
            ? levels[sortedLevels[nextLevelIndex]] ?? []
            : <Membre>[];

        return _buildLevelColumn(members, levelIndex, nextLevelMembers, memberPositions, totalTreeHeight);
      }).toList(),
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

      // Si le niveau suivant n'existe pas, ou si c'est le dernier niveau calculé
      if (level == sortedLevels.first || !memberPositions.containsKey(level + 1)) {
        // Dernier niveau : distribuer uniformément
        for (int i = 0; i < members.length; i++) {
          positions[members[i].id] = i * (_nodeHeight + _verticalSpacing) + _nodeHeight / 2;
        }
      } else {
        // Niveaux précédents : centrer par rapport aux enfants
        final nextLevelPositions = memberPositions[level + 1]!;

        // D'abord, essayer de positionner par rapport aux enfants
        for (var member in members) {
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
          }
        }

        // Ensuite, gérer les membres sans enfants (ou avec enfants non positionnés)
        // en les insérant logiquement pour éviter les chevauchements
        double lastY = -_verticalSpacing; // Point de départ

        for(var member in members) {
          if (!positions.containsKey(member.id)) {
            // Positionner ce membre après le dernier positionné + espacement minimum
            positions[member.id] = lastY + (_nodeHeight + _verticalSpacing);
          }
          lastY = positions[member.id]!;
        }

        // Ajuster les positions pour éviter les chevauchements (même s'ils sont déjà centrés)
        _adjustPositionsForOverlap(members, positions);
      }
    }

    // Normaliser toutes les positions pour que le centre du premier nœud soit à _nodeHeight / 2
    for (var level in sortedLevels.reversed) {
      final positions = memberPositions[level]!;
      if (positions.isEmpty) continue;

      // Trouver la position Y la plus petite
      final minPos = positions.values.reduce((a, b) => a < b ? a : b);

      // Décalage nécessaire pour que le centre du nœud le plus haut (minPos) soit à _nodeHeight / 2
      final offset = minPos - _nodeHeight / 2;

      for (var key in positions.keys) {
        positions[key] = positions[key]! - offset;
      }
    }
  }

  // Ajuster les positions pour éviter les chevauchements
  void _adjustPositionsForOverlap(List<Membre> members, Map<int, double> positions) {
    if (members.length <= 1) return;

    final sortedMembers = List<Membre>.from(members);
    // Assurer que tous les membres ont une position avant de trier
    sortedMembers.removeWhere((m) => !positions.containsKey(m.id));

    sortedMembers.sort((a, b) => positions[a.id]!.compareTo(positions[b.id]!));

    // L'espacement minimum est la hauteur du nœud + l'espacement vertical
    double minCenterToCenterSpacing = _nodeHeight + _verticalSpacing;

    for (int i = 0; i < sortedMembers.length - 1; i++) {
      final currentY = positions[sortedMembers[i].id]!;
      final nextY = positions[sortedMembers[i + 1].id]!;
      final overlap = minCenterToCenterSpacing - (nextY - currentY);

      if (overlap > 0) {
        // Déplacer le nœud suivant vers le bas pour éliminer le chevauchement
        positions[sortedMembers[i + 1].id] = nextY + overlap;
      }
    }
  }

  Widget _buildLevelColumn(
      List<Membre> members,
      int level,
      List<Membre> nextLevelMembers,
      Map<int, Map<int, double>> memberPositions,
      double totalTreeHeight, // Passer la hauteur totale calculée
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

    return SizedBox(
      height: totalTreeHeight, // 💡 Utiliser la hauteur totale de l'arbre pour aligner les colonnes
      child: Row(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start, // Aligner en haut
        children: [
          // Colonne de membres avec Stack pour positionnement précis
          SizedBox(
            width: _nodeWidth + 10, // Ajouter 10 pour les marges (5 de chaque côté)
            height: totalTreeHeight,
            child: Stack(
              clipBehavior: Clip.none,
              children: sortedMembers.map((membre) {
                final yPos = positions[membre.id] ?? 0.0;
                return Positioned(
                  top: yPos - _nodeHeight / 2, // Position Y est le centre du nœud
                  left: 5, // petite marge de 5
                  child: _buildMemberCard(membre),
                );
              }).toList(),
            ),
          ),
          // Lignes de connexion vers le niveau suivant (style MyHeritage)
          if (nextLevelMembers.isNotEmpty)
            SizedBox(
              width: _horizontalSpacing,
              height: totalTreeHeight,
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

  // ==================== WIDGETS DE L'ARBRE ====================
  Widget _buildMemberCard(Membre membre) {
    return InkWell(
      onTap: () => _navigateToMemberDetail(membre.id),
      child: Container(
        width: _nodeWidth,
        height: _nodeHeight,
        decoration: BoxDecoration(
          color: _cardBackground,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 5,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          children: [
            // Image de profil
            Container(
              height: _nodeHeight * 0.55,
              width: double.infinity,
              decoration: BoxDecoration(
                color: _goldPrimary.withOpacity(0.1),
                borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
              ),
              child: const Center(
                child: Icon(Icons.person, size: 40, color: _goldPrimary),
              ),
            ),
            // Nom et informations
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      membre.nomComplet!,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                        color: _textDark,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'ID: ${membre.id}',
                      style: TextStyle(
                        fontSize: 10,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(
        top: MediaQuery.of(context).padding.top + 10,
        bottom: 10,
        left: 16,
        right: 16,
      ),
      color: _creamBackground,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Bouton Menu pour ouvrir le Drawer
          IconButton(
            icon: const Icon(Icons.menu, color: _textDark, size: 30),
            // CORRECTION CLÉ : Utiliser la clé du Scaffold pour ouvrir le drawer
            onPressed: () => _scaffoldKey.currentState?.openDrawer(),
          ),
          const Text(
            'Arbre Généalogique',
            style: TextStyle(color: _textDark, fontWeight: FontWeight.bold, fontSize: 20),
          ),
          const SizedBox(width: 48), // Pour l'alignement
        ],
      ),
    );
  }

  Widget _buildTreeView() {
    return InteractiveViewer(
      transformationController: _transformationController,
      constrained: false, // Permet au contenu de dépasser la taille de l'écran
      minScale: 0.1,
      maxScale: 2.0,
      boundaryMargin: const EdgeInsets.all(100.0), // Marge pour le défilement
      child: Padding(
        padding: const EdgeInsets.all(50.0), // Marge autour de l'arbre
        child: _buildHorizontalTree(), // Le contenu de l'arbre
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

  // ==================== BUILD FINAL ====================
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey, // <-- AJOUT DE LA CLÉ DU SCAFFOLD
      backgroundColor: _creamBackground,
      drawer: AppDrawer(familyId: widget.familyId), // <-- AJOUT DU DRAWER
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
                  heroTag: 'zoom_in',
                  mini: true,
                  backgroundColor: _brownDark,
                  onPressed: () {
                    final currentScale = _transformationController.value.getMaxScaleOnAxis();
                    _transformationController.value = _transformationController.value * Matrix4.diagonal3Values(1.2, 1.2, 1.0);
                  },
                  child: const Icon(Icons.zoom_in, color: Colors.white),
                ),
                const SizedBox(height: 10),
                FloatingActionButton(
                  heroTag: 'zoom_out',
                  mini: true,
                  backgroundColor: _brownDark,
                  onPressed: () {
                    final currentScale = _transformationController.value.getMaxScaleOnAxis();
                    _transformationController.value = _transformationController.value * Matrix4.diagonal3Values(0.8, 0.8, 1.0);
                  },
                  child: const Icon(Icons.zoom_out, color: Colors.white),
                ),
                const SizedBox(height: 10),
                FloatingActionButton(
                  heroTag: 'center_view',
                  mini: true,
                  backgroundColor: _brownDark,
                  onPressed: _centerTree,
                  child: const Icon(Icons.center_focus_strong, color: Colors.white),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ==================== PAINTER POUR LES LIGNES ====================
// Le code de ConnectionLinePainter est conservé tel quel pour la complétion.
class _ConnectionLinePainter extends CustomPainter {
  final Color color;
  final List<Membre> parentMembers;
  final List<Membre> childMembers;
  final double nodeHeight;
  final double nodeWidth;
  final Map<int, double> parentPositions;
  final Map<int, double> childPositions;

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
    final Paint paint = Paint()
      ..color = color
      ..strokeWidth = 2.0
      ..style = PaintingStyle.stroke;

    final double halfSpacing = size.width / 2;

    // Dessiner les lignes pour chaque parent
    for (var parent in parentMembers) {
      final parentYCenter = parentPositions[parent.id] ?? -1.0;

      if (parentYCenter == -1.0) continue;

      // Chercher tous les enfants de ce parent qui se trouvent dans le niveau suivant
      final childrenYCenters = <double>[];
      for (var child in parent.enfants) {
        if (childPositions.containsKey(child.id)) {
          childrenYCenters.add(childPositions[child.id]!);
        }
      }

      if (childrenYCenters.isEmpty) continue;

      childrenYCenters.sort();
      final minChildY = childrenYCenters.first;
      final maxChildY = childrenYCenters.last;

      // 1. Ligne horizontale de sortie (Parent)
      // Point de départ : centre vertical du parent, à l'extrême droite de la carte
      final p1 = Offset(0, parentYCenter);
      // Point d'arrêt : au milieu de l'espacement
      final p2 = Offset(halfSpacing, parentYCenter);
      canvas.drawLine(p1, p2, paint);

      // 2. Ligne verticale (Branche principale)
      // Cette ligne relie la ligne horizontale du parent au centre vertical des enfants
      final p3 = Offset(halfSpacing, minChildY.clamp(0, size.height));
      final p4 = Offset(halfSpacing, maxChildY.clamp(0, size.height));
      canvas.drawLine(p3, p4, paint);

      // 3. Lignes horizontales d'entrée (Enfants)
      for (var childY in childrenYCenters) {
        final p5 = Offset(halfSpacing, childY);
        final p6 = Offset(size.width, childY);
        canvas.drawLine(p5, p6, paint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true; // Simplement repaindre à chaque changement d'état
  }
}

// FIN DU FICHIER