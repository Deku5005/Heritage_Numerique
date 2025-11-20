import 'package:flutter/material.dart';
import 'dart:math';

import 'package:graphview/GraphView.dart';

import '../model/FamilleModel.dart';
import '../model/Membre.dart';
import '../service/ArbreGenealogiqueService.dart';

import 'CreateTreeScreen.dart';
import 'AppDrawer.dart';
import 'MembresDetailsScreen.dart';

// --- COULEURS ---
const Color _mainAccentColor = Color(0xFFAA7311);
const Color _backgroundColor = Colors.white;
const Color _cardTextColor = Color(0xFF2E2E2E);
const Color _lightCardColor = Color(0xFFF7F2E8);
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

  // Dimensions dynamiques
  double _graphWidth = 1600;
  double _graphHeight = 1200;
  int _maxLevel = 0;

  @override
  void initState() {
    super.initState();
    _transformationController.value = Matrix4.identity()..scale(0.5);
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

      Future.delayed(const Duration(milliseconds: 200), () {
        if (mounted) _adjustInitialView();
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
      ..siblingSeparation = 250
      ..levelSeparation = 300
      ..subtreeSeparation = 250;

    Node? virtualRoot;
    if (racines.length > 1) {
      virtualRoot = Node.Id(-999);
      graph.addNode(virtualRoot);
    }

    for (var racine in racines) {
      final rootNode = _addMemberRecursively(null, racine);
      if (virtualRoot != null && rootNode != null) {
        graph.addEdge(virtualRoot, rootNode);
      }
    }

    debugPrint("Graphe final → ${graph.nodes.length} nœuds, ${graph.edges.length} arêtes");
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
      final exists = graph.edges.any((e) =>
      (e.source == parentNode && e.destination == node) ||
          (e.source == node && e.destination == parentNode));
      if (!exists) graph.addEdge(parentNode, node);
    }

    for (var enfant in membre.enfants) {
      _addMemberRecursively(membre, enfant);
    }
    return node;
  }

  // ==================== DIMENSIONS & ZOOM ====================
  void _calculateGraphDimensions() {
    _maxLevel = 0;
    int maxChildren = 0;
    Map<int, int> levelCount = {};

    void traverse(List<Membre> membres, int level) {
      _maxLevel = max(_maxLevel, level);
      levelCount[level] = (levelCount[level] ?? 0) + membres.length;
      maxChildren = max(maxChildren, levelCount[level] ?? 0);
      for (var m in membres) {
        if (m.enfants.isNotEmpty) traverse(m.enfants, level + 1);
      }
    }

    if (_familleData != null && _familleData!.membres.isNotEmpty) {
      traverse(_familleData!.membres, 0);
    }

    _graphWidth = max(1600.0, (maxChildren * 420.0) + 600.0);
    _graphHeight = max(1200.0, ((_maxLevel + 2) * 500.0) + 600.0);
  }

  void _adjustInitialView() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final size = MediaQuery.of(context).size;
      final screenWidth = size.width;
      final screenHeight = size.height - 250;

      double scale = min(screenWidth / _graphWidth, screenHeight / _graphHeight) * 0.85;
      scale = scale.clamp(0.08, 1.0);

      final scaledW = _graphWidth * scale;
      final scaledH = _graphHeight * scale;

      _transformationController.value = Matrix4.identity()
        ..translate((screenWidth - scaledW) / 2, (screenHeight - scaledH) / 2 + 50)
        ..scale(scale);
    });
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

  void _handleMemberCardTap(int? memberId) {
    if (memberId == null) {
      _navigateToAddMember(parentId: null);
    } else {
      _navigateToMemberDetail(memberId);
    }
  }

  // ==================== BUILD ====================
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
            Builder(builder: (ctx) => _buildHeader(ctx)),
            const SizedBox(height: 10),
            _isLoading || _errorMessage != null ? _buildLoadingOrError() : _buildMainContent(),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: _mainAccentColor,
        child: const Icon(Icons.person_add, color: Colors.white),
        onPressed: () => _navigateToAddMember(parentId: null),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(onPressed: () => Scaffold.of(context).openDrawer(), icon: const Icon(Icons.menu, size: 30)),
          const Text("Héritage Numérique", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          IconButton(onPressed: () => Navigator.pop(context), icon: const Icon(Icons.close)),
        ],
      ),
    );
  }

  Widget _buildLoadingOrError() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator(color: _mainAccentColor));
    }
    return Center(child: Text(_errorMessage!, style: const TextStyle(color: Colors.red)));
  }

  Widget _buildMainContent() {
    return Column(
      children: [
        _buildStats(),
        const SizedBox(height: 20),
        _buildGraphViewLayout(),
      ],
    );
  }

  Widget _buildGraphViewLayout() {
    if (_familleData!.membres.isEmpty) {
      return Center(child: _buildMemberCardPlaceholder());
    }

    return Container(
      height: MediaQuery.of(context).size.height * 0.78,
      color: _lightCardColor.withOpacity(0.15),
      child: InteractiveViewer(
        transformationController: _transformationController,
        constrained: false,
        boundaryMargin: const EdgeInsets.all(1000),
        minScale: 0.08,
        maxScale: 4.0,
        child: Center(
          child: GraphView(
            graph: graph,
            algorithm: BuchheimWalkerAlgorithm(builder, TreeEdgeRenderer(builder)),
            builder: (Node node) {
              final int? id = node.key?.value as int?;
              if (id == null || id < 0) return const SizedBox.shrink();

              final member = _findMemberInHierarchicalData(id, _familleData!.membres);
              if (member == null) return const SizedBox.shrink();

              return _buildMemberCardLarge(member);
            },
          ),
        ),
      ),
    );
  }

  // ==================== CARTE MEMBRE (CORRIGÉE - SANS dateDeces) ====================
  Widget _buildMemberCardLarge(Membre membre) {
    final photoUrl = membre.photoUrl?.isNotEmpty == true
        ? '$_baseUrl/${membre.photoUrl!}'
        : '';

    final String birthYear = membre.dateNaissance != null
        ? membre.dateNaissance!.split('-').first
        : '?';

    return GestureDetector(
      onTap: () => _handleMemberCardTap(membre.id),
      child: Container(
        width: 1500,
        height: 1300,
        margin: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: _mainAccentColor.withOpacity(0.7), width: 3),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.15),
              blurRadius: 12,
              offset: const Offset(0, 6),
            )
          ],
        ),
        child: Column(
          children: [
            // Photo
            Expanded(
              flex: 5,
              child: Container(
                margin: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(18),
                  image: photoUrl.isNotEmpty
                      ? DecorationImage(image: NetworkImage(photoUrl), fit: BoxFit.cover)
                      : null,
                  color: photoUrl.isEmpty ? _lightCardColor : null,
                ),
                child: photoUrl.isEmpty
                    ? const Icon(Icons.person, size: 1000, color: _mainAccentColor)
                    : null,
              ),
            ),
            // Texte
            Expanded(
              flex: 3,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      membre.nomComplet ?? 'Inconnu',
                      textAlign: TextAlign.center,
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 8),
                    if (membre.relationFamiliale?.isNotEmpty == true)
                      Text(
                        membre.relationFamiliale!,
                        style: const TextStyle(fontSize: 100, color: Colors.brown),
                        maxLines: 1,
                      ),
                    const SizedBox(height: 2),
                    Text(
                      "Né(e) en $birthYear",
                      style: const TextStyle(fontSize: 200, color: Colors.grey),
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

  Widget _buildMemberCardPlaceholder() {
    return GestureDetector(
      onTap: () => _handleMemberCardTap(null),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: _lightCardColor,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: _mainAccentColor, width: 3),
        ),
        child: const Column(
          children: [
            Icon(Icons.add_circle, size: 60, color: _mainAccentColor),
            SizedBox(height: 10),
            Text("Ajouter un membre", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
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

  // ==================== STATS ====================
  Widget _buildStats() {
    final f = _familleData!;
    String birthYear = '?';
    if (f.membres.isNotEmpty && f.membres.first.dateNaissance != null) {
      birthYear = f.membres.first.dateNaissance!.split('-').first;
    }

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("Arbre de ${f.nomFamille}", style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
          Text(f.description ?? "Arbre généalogique", style: const TextStyle(color: Colors.grey)),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _statBox("Générations", "${_maxLevel + 1}"),
              _statBox("Membres", f.nombreMembres?.toString() ?? "0"),
              _statBox("Depuis", birthYear),
            ],
          ),
        ],
      ),
    );
  }

  Widget _statBox(String label, String value) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: _lightCardColor, borderRadius: BorderRadius.circular(12)),
      child: Column(
        children: [
          Text(value, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: _mainAccentColor)),
          Text(label, style: const TextStyle(fontSize: 12)),
        ],
      ),
    );
  }
}