import 'package:flutter/material.dart';
import 'dart:math';

import 'package:graphview/GraphView.dart';

import '../model/FamilleModel.dart';
import '../model/Membre.dart';
import '../service/ArbreGenealogiqueService.dart';

import 'CreateTreeScreen.dart';
import 'AppDrawer.dart';
import 'MembresDetailsScreen.dart';

// --- PALETTE DE COULEURS PREMIUM ---
const Color _goldPrimary = Color(0xFFAA7311);
const Color _goldLight = Color(0xFFFFD700);
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

  // GraphView
  final Graph graph = Graph();
  final BuchheimWalkerConfiguration builder = BuchheimWalkerConfiguration();
  final Map<int, Node> _memberNodes = {};
  final TransformationController _transformationController = TransformationController();

  // Dimensions des cartes
  final double _nodeWidth = 180.0;
  final double _nodeHeight = 240.0;
  
  // Dimensions du canvas (calculées dynamiquement)
  double _graphWidth = 2000;
  double _graphHeight = 1500;

  @override
  void initState() {
    super.initState();
    _transformationController.value = Matrix4.identity()..scale(0.8);
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
      graph.nodes.clear();
      graph.edges.clear();
      _memberNodes.clear();
    });

    try {
      final famille = await _apiService.fetchArbreHierarchique(familleId: widget.familyId);

      setState(() {
        _familleData = famille;
        _isLoading = false;
        _buildGraphFromHierarchicalData(famille.membres);
        _calculateGraphDimensions();
      });

      // Centrer la vue après le rendu
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) _centerGraph();
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Erreur de chargement : $e';
        _isLoading = false;
      });
    }
  }

  // ==================== CONSTRUCTION DU GRAPHE ====================
  void _buildGraphFromHierarchicalData(List<Membre> racines) {
    builder
      ..orientation = BuchheimWalkerConfiguration.ORIENTATION_TOP_BOTTOM
      ..siblingSeparation = 40  // Espace entre frères/sœurs
      ..levelSeparation = 80    // Espace vertical entre générations
      ..subtreeSeparation = 50; // Espace entre cousins

    // Racine virtuelle pour gérer plusieurs ancêtres de même niveau
    Node? virtualRoot;
    if (racines.length > 1) {
      virtualRoot = Node.Id(-999);
      graph.addNode(virtualRoot);
    }

    for (var racine in racines) {
      final rootNode = _addMemberRecursively(null, racine);
      if (virtualRoot != null && rootNode != null) {
        // IMPORTANT : On doit fournir un Paint même pour les arêtes invisibles
        // sinon GraphView peut planter (Null check operator used on a null value)
        graph.addEdge(virtualRoot, rootNode, paint: Paint()
          ..color = Colors.transparent
          ..strokeWidth = 0.0
          ..style = PaintingStyle.stroke
        );
      }
    }
  }

  Node _addMemberRecursively(Membre? parent, Membre membre) {
    Node node;
    if (_memberNodes.containsKey(membre.id)) {
      node = _memberNodes[membre.id]!;
    } else {
      node = Node.Id(membre.id);
      graph.addNode(node);
      _memberNodes[membre.id] = node;
    }

    if (parent != null) {
      final parentNode = _memberNodes[parent.id]!;
      // Vérifier si l'arête existe déjà pour éviter les doublons
      final exists = graph.edges.any((e) =>
      (e.source == parentNode && e.destination == node) ||
          (e.source == node && e.destination == parentNode));
      
      if (!exists) {
        graph.addEdge(parentNode, node, paint: Paint()
          ..color = _brownDark.withOpacity(0.6)
          ..strokeWidth = 2.0
          ..style = PaintingStyle.stroke
        );
      }
    }

    for (var enfant in membre.enfants) {
      _addMemberRecursively(membre, enfant);
    }
    return node;
  }

  // ==================== DIMENSIONS & ZOOM ====================
  void _calculateGraphDimensions() {
    // Estimation simple basée sur le nombre de nœuds pour agrandir le canvas si nécessaire
    int totalNodes = _memberNodes.length;
    _graphWidth = max(2000.0, totalNodes * 100.0);
    _graphHeight = max(1500.0, totalNodes * 100.0);
  }

  void _centerGraph() {
    if (_memberNodes.isEmpty) return;
    
    // Réinitialiser à une vue centrée et dézoomée pour tout voir
    final size = MediaQuery.of(context).size;
    // On essaie de centrer la racine (premier élément)
    // C'est une approximation, GraphView ne donne pas facilement les coordonnées exactes avant le rendu
    _transformationController.value = Matrix4.identity()
      ..translate(size.width / 2 - _nodeWidth, 50.0) 
      ..scale(0.6);
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
          // Fond décoratif subtil (optionnel)
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
                        : _buildGraphViewLayout(),
              ),
            ],
          ),

          // Bouton flottant personnalisé
          Positioned(
            bottom: 30,
            right: 30,
            child: FloatingActionButton.extended(
              backgroundColor: _goldPrimary,
              icon: const Icon(Icons.person_add, color: Colors.white),
              label: const Text("Ajouter un membre", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
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
                    _transformationController.value *= Matrix4.identity()..scale(1.2);
                  },
                ),
                const SizedBox(height: 10),
                FloatingActionButton(
                  heroTag: "zoom_out",
                  mini: true,
                  backgroundColor: Colors.white,
                  child: const Icon(Icons.remove, color: _textDark),
                  onPressed: () {
                    _transformationController.value *= Matrix4.identity()..scale(0.8);
                  },
                ),
                const SizedBox(height: 10),
                FloatingActionButton(
                  heroTag: "center",
                  mini: true,
                  backgroundColor: Colors.white,
                  child: const Icon(Icons.center_focus_strong, color: _textDark),
                  onPressed: _centerGraph,
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
          IconButton(
            onPressed: () => Scaffold.of(context).openDrawer(),
            icon: const Icon(Icons.menu, color: _brownDark),
          ),
          Column(
            children: [
              const Text("Arbre Généalogique", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: _brownDark)),
              if (_familleData != null)
                Text(_familleData!.nomFamille ?? "Famille", style: const TextStyle(fontSize: 14, color: _goldPrimary, fontStyle: FontStyle.italic)),
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

  Widget _buildGraphViewLayout() {
    if (_familleData!.membres.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.account_tree_outlined, size: 80, color: Colors.grey),
            const SizedBox(height: 20),
            const Text("Votre arbre est vide pour le moment.", style: TextStyle(fontSize: 18, color: Colors.grey)),
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
      constrained: false,
      boundaryMargin: const EdgeInsets.all(2000), // Grande marge pour le pan
      minScale: 0.1,
      maxScale: 3.0,
      child: GraphView(
        graph: graph,
        algorithm: BuchheimWalkerAlgorithm(builder, TreeEdgeRenderer(builder)),
        paint: Paint()
          ..color = _brownDark.withOpacity(0.8)
          ..strokeWidth = 2.0
          ..style = PaintingStyle.stroke,
        builder: (Node node) {
          final int? id = node.key?.value as int?;
          if (id == null || id < 0) return const SizedBox.shrink();

          final member = _findMemberInHierarchicalData(id, _familleData!.membres);
          if (member == null) return const SizedBox.shrink();

          return _buildMemberCard(member);
        },
      ),
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

    return GestureDetector(
      onTap: () => _showMemberOptions(membre),
      child: Container(
        width: _nodeWidth,
        height: _nodeHeight,
        margin: const EdgeInsets.all(10), // Marge autour du nœud pour éviter que les lignes ne touchent
        child: Stack(
          alignment: Alignment.topCenter,
          children: [
            // Carte principale
            Positioned(
              top: 40, // Laisse de la place pour la photo qui dépasse
              left: 0,
              right: 0,
              bottom: 0,
              child: Container(
                decoration: BoxDecoration(
                  color: _cardBackground,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 10,
                      offset: const Offset(0, 5),
                    ),
                  ],
                  border: Border.all(color: _goldPrimary.withOpacity(0.3), width: 1),
                ),
                child: Padding(
                  padding: const EdgeInsets.only(top: 50, left: 10, right: 10, bottom: 10),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        membre.nomComplet ?? 'Inconnu',
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                          color: _textDark,
                          fontFamily: 'Serif', // Optionnel : utiliser une police serif si disponible
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Container(height: 1, width: 40, color: _goldPrimary.withOpacity(0.5)),
                      const SizedBox(height: 4),
                      Text(
                        membre.relationFamiliale ?? 'Membre',
                        style: const TextStyle(fontSize: 12, color: _brownDark, fontStyle: FontStyle.italic),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const Spacer(),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: _creamBackground,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          birthYear,
                          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.grey),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            // Photo de profil (Cercle qui dépasse)
            Positioned(
              top: 0,
              child: Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white,
                  border: Border.all(color: _goldPrimary, width: 3),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.2),
                      blurRadius: 8,
                      offset: const Offset(0, 4),
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
      child: const Icon(Icons.person, size: 40, color: _goldPrimary),
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
                      Text(membre.relationFamiliale ?? "Membre de la famille", style: const TextStyle(color: Colors.grey)),
                    ],
                  ),
                ),
              ],
            ),
            const Divider(height: 30),
            ListTile(
              leading: const Icon(Icons.info_outline, color: _brownDark),
              title: const Text("Voir les détails complets"),
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

  Membre? _findMemberInHierarchicalData(int? id, List<Membre> list) {
    if (id == null) return null;
    for (var m in list) {
      if (m.id == id) return m;
      final found = _findMemberInHierarchicalData(id, m.enfants);
      if (found != null) return found;
    }
    return null;
  }
}