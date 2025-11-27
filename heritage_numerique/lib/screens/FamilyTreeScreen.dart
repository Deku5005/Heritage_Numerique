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
  
  Membre? _selectedMember; // Membre au centre de la vue pedigree

  // Dimensions des cartes (plus compactes pour layout horizontal)
  final double _nodeWidth = 160.0;
  final double _nodeHeight = 200.0;
  final double _horizontalSpacing = 100.0;
  final double _verticalSpacing = 30.0;

  // Map pour stocker les parents de chaque membre (déduit de la structure hiérarchique)
  final Map<int, List<Membre>> _parentsOfMember = {};

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
        _preprocessFamilyData(); // Prétraitement pour trouver les parents
        
        // Sélectionner le premier membre racine par défaut
        if (famille.membres.isNotEmpty) {
          _selectedMember = famille.membres.first;
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

  void _preprocessFamilyData() {
    _parentsOfMember.clear();
    if (_familleData == null) return;

    // Fonction récursive pour parcourir l'arbre et associer les parents aux enfants
    void traverse(Membre parent) {
      for (var enfant in parent.enfants) {
        if (!_parentsOfMember.containsKey(enfant.id)) {
          _parentsOfMember[enfant.id] = [];
        }
        // Ajouter le parent à la liste des parents de l'enfant
        // On évite les doublons si l'arbre a des cycles ou références multiples
        if (!_parentsOfMember[enfant.id]!.any((p) => p.id == parent.id)) {
          _parentsOfMember[enfant.id]!.add(parent);
        }
        
        traverse(enfant);
      }
    }

    for (var racine in _familleData!.membres) {
      traverse(racine);
    }
    print("Prétraitement terminé. Relations parents trouvées pour ${_parentsOfMember.length} membres.");
  }

  void _centerTree() {
    final size = MediaQuery.of(context).size;
    _transformationController.value = Matrix4.identity()
      ..translate(100.0, size.height / 2 - 100)
      ..scale(0.9);
  }

  void _selectMember(Membre membre) {
    setState(() {
      _selectedMember = membre;
    });
    _centerTree();
  }

  // ==================== CONSTRUCTION DE L'ARBRE HORIZONTAL ====================
  Widget _buildHorizontalPedigree() {
    if (_selectedMember == null) return const SizedBox.shrink();

    // Construire les générations d'ancêtres
    final generations = <int, List<Membre>>{};
    _buildGenerations(_selectedMember!, 0, generations);

    // Calculer la hauteur totale nécessaire
    int maxMembersInGeneration = 0;
    for (var members in generations.values) {
      if (members.length > maxMembersInGeneration) {
        maxMembersInGeneration = members.length;
      }
    }

    final totalHeight = maxMembersInGeneration * (_nodeHeight + _verticalSpacing);
    // S'assurer que la hauteur est au moins suffisante pour une carte
    final safeHeight = totalHeight > 0 ? totalHeight : _nodeHeight + _verticalSpacing;

    return SizedBox(
      height: safeHeight,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: List.generate(generations.length, (genIndex) {
          final members = generations[genIndex] ?? [];
          return _buildGenerationColumn(members, genIndex, safeHeight);
        }),
      ),
    );
  }

  void _buildGenerations(Membre membre, int generation, Map<int, List<Membre>> generations) {
    print("Traitement membre: ${membre.nomComplet} (ID: ${membre.id}) - Génération: $generation");
    
    if (!generations.containsKey(generation)) {
      generations[generation] = [];
    }
    
    // Éviter les doublons visuels dans la même génération
    if (!generations[generation]!.any((m) => m.id == membre.id)) {
      generations[generation]!.add(membre);
    }

    // Ajouter les parents (génération suivante)
    // On utilise d'abord les champs explicites idPere/idMere s'ils sont valides et trouvables
    // Sinon on utilise la map déduite _parentsOfMember
    
    final List<Membre> parentsToProcess = [];
    
    // 1. Essayer via la map de prétraitement (plus fiable si hiérarchie descendante)
    if (_parentsOfMember.containsKey(membre.id)) {
      parentsToProcess.addAll(_parentsOfMember[membre.id]!);
    }
    
    // 2. Si la map est vide, essayer via les IDs explicites (si non déjà ajoutés)
    // Cela sert de fallback si le prétraitement a raté quelque chose ou si l'arbre n'est pas complet
    // (Note: _getAllMembers n'est plus nécessaire ici car on a _parentsOfMember, 
    // mais on pourrait le garder si besoin. Pour l'instant on simplifie).
    
    if (parentsToProcess.isEmpty) {
       print("  -> Aucun parent trouvé pour ${membre.nomComplet} (ni dans map, ni IDs)");
    } else {
       print("  -> ${parentsToProcess.length} parents trouvés pour ${membre.nomComplet}");
    }

    for (var parent in parentsToProcess) {
      _buildGenerations(parent, generation + 1, generations);
    }
  }

  Widget _buildGenerationColumn(List<Membre> members, int generation, double totalHeight) {
    return Row(
      children: [
        // Colonne de membres
        SizedBox(
          width: _nodeWidth,
          height: totalHeight,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: members.map((membre) => _buildMemberCard(membre)).toList(),
          ),
        ),
        // Lignes de connexion vers la génération suivante (sauf pour la dernière)
        if (members.isNotEmpty) 
          CustomPaint(
            size: Size(_horizontalSpacing, totalHeight),
            painter: _ConnectionLinePainter(
              color: _brownDark.withOpacity(0.6),
              members: members,
              nodeHeight: _nodeHeight,
              verticalSpacing: _verticalSpacing,
            ),
          ),
      ],
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

              const Text("Vue Pedigree", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: _brownDark)),
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
      boundaryMargin: const EdgeInsets.all(1000),
      minScale: 0.1,
      maxScale: 3.0,
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: SingleChildScrollView(
          scrollDirection: Axis.vertical,
          child: Padding(
            padding: const EdgeInsets.all(50),
            child: _buildHorizontalPedigree(),
          ),
        ),
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

    final bool isSelected = _selectedMember?.id == membre.id;

    return GestureDetector(
      onTap: () => _showMemberOptions(membre),
      child: Container(
        width: _nodeWidth,
        height: _nodeHeight,
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
              title: const Text("Centrer sur cette personne"),
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

// Custom painter pour les lignes de connexion horizontales
class _ConnectionLinePainter extends CustomPainter {
  final Color color;
  final List<Membre> members;
  final double nodeHeight;
  final double verticalSpacing;

  _ConnectionLinePainter({
    required this.color,
    required this.members,
    required this.nodeHeight,
    required this.verticalSpacing,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 2.0
      ..style = PaintingStyle.stroke;

    // Dessiner une ligne horizontale pour chaque membre vers la droite
    // On suppose que les membres sont distribués uniformément dans la hauteur
    final totalHeight = size.height;
    // La hauteur disponible par membre dans la colonne
    final heightPerMember = totalHeight / members.length;
    
    for (int i = 0; i < members.length; i++) {
      // Le centre vertical de la carte
      final y = (i * heightPerMember) + (heightPerMember / 2);
      
      canvas.drawLine(
        Offset(0, y),
        Offset(size.width, y),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}