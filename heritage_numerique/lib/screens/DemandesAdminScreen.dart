import 'package:flutter/material.dart';
import '../model/DemandePublicationn.dart';
import '../service/DemandePublicationService.dart'; // Import du service créé
import 'AppDrawer.dart'; // Import de l'AppDrawer

// --- Constantes de Couleurs Globales (Adaptées) ---
const Color _mainAccentColor = Color(0xFFAA7311);
const Color _backgroundColor = Colors.white;
const Color _cardTextColor = Color(0xFF2E2E2E);
const Color _pendingColor = Colors.orange;
const Color _approvedColor = Colors.green;
const Color _rejectedColor = Color(0xFFD32F2E);
const Color _tagColor = Color(0xFF808080);

// ------------------------------------------------
// --- ÉCRAN PRINCIPAL : DemandesAdminScreen (Stateful) ---
// ------------------------------------------------

class DemandesAdminScreen extends StatefulWidget {
  final int familyId;

  const DemandesAdminScreen({super.key, required this.familyId});

  @override
  State<DemandesAdminScreen> createState() => _DemandesAdminScreenState();
}

class _DemandesAdminScreenState extends State<DemandesAdminScreen> {
  // Instance du service API
  final DemandePublicationService _demandeService = DemandePublicationService();

  // État de la liste des demandes
  List<DemandePublicationn> _demandes = [];
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _fetchDemandes();
  }

  // --- Fonction de récupération des données API ---
  Future<void> _fetchDemandes() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final List<DemandePublicationn> fetchedDemandes =
      await _demandeService.fetchDemandesByFamille(familleId: widget.familyId);

      setState(() {
        _demandes = fetchedDemandes;
        _isLoading = false;
      });

    } catch (e) {
      print("Erreur de récupération des demandes: $e");
      setState(() {
        _errorMessage = "Impossible de charger les demandes. Veuillez réessayer.";
        _isLoading = false;
      });
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _backgroundColor,

      // --- AJOUT DU DRAWER ---
      drawer: AppDrawer(familyId: widget.familyId),

      // --- 1. En-tête (AppBar) ---
      appBar: AppBar(
        backgroundColor: _backgroundColor,
        elevation: 0,
        automaticallyImplyLeading: false,
        titleSpacing: 0,

        // CORRECTION DRAWER: Utilisation de 'leading'
        leading: Builder(
          builder: (BuildContext innerContext) {
            return IconButton(
              icon: const Icon(Icons.menu, color: _cardTextColor),
              onPressed: () {
                Scaffold.of(innerContext).openDrawer();
              },
            );
          },
        ),

        title: const Padding(
          padding: EdgeInsets.only(right: 16.0),
          child: Text(
            'Gestion des Demandes',
            style: TextStyle(
              fontWeight: FontWeight.w700,
              fontSize: 20,
              color: _cardTextColor,
            ),
          ),
        ),

        // Ligne d'ombre
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(4.0),
          child: Container(
            decoration: BoxDecoration(
              color: _backgroundColor,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.15),
                  blurRadius: 4,
                  offset: const Offset(0, 0),
                ),
              ],
            ),
          ),
        ),
      ),

      // --- 2. Corps de la Page ---
      body: RefreshIndicator(
        onRefresh: _fetchDemandes,
        color: _mainAccentColor,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              // --- Titre de la section ---
              const Padding(
                padding: EdgeInsets.fromLTRB(16.0, 20.0, 16.0, 10.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Demandes de Publication',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 24,
                        color: _cardTextColor,
                      ),
                    ),
                    SizedBox(height: 5),
                    Text(
                      'Liste des contenus soumis par les membres de votre famille pour modération.',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 10),

              // --- Affichage Conditionnel de la Liste ---
              _buildDemandeListContent(),

              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

// ===============================================
// NOUVEAU WIDGETS D'ÉTAT
// ===============================================

  Widget _buildDemandeListContent() {
    if (_isLoading) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(30.0),
          child: CircularProgressIndicator(color: _mainAccentColor),
        ),
      );
    }

    if (_errorMessage != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(30.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                _errorMessage!,
                textAlign: TextAlign.center,
                style: const TextStyle(color: _rejectedColor),
              ),
              const SizedBox(height: 10),
              TextButton(
                onPressed: _fetchDemandes,
                child: const Text('Recharger les demandes', style: TextStyle(color: _mainAccentColor)),
              ),
            ],
          ),
        ),
      );
    }

    // Si la liste est vide
    if (_demandes.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(30.0),
          child: Column(
            children: [
              Icon(Icons.inbox, size: 50, color: Colors.grey.shade400),
              const SizedBox(height: 10),
              const Text(
                "Aucune demande de publication en cours.",
                style: TextStyle(color: Colors.grey),
              ),
            ],
          ),
        ),
      );
    }

    // Affichage de la liste réelle
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: _demandes.length,
      itemBuilder: (context, index) {
        return _buildDemandeTile(_demandes[index]);
      },
    );
  }


// ===============================================
// WIDGETS DE CONSTRUCTION DES CARTES
// ===============================================

  // Widget pour une seule tuile de demande
  Widget _buildDemandeTile(DemandePublicationn demande) {

    // Obtenir la couleur et l'icône basées sur le statut
    Map<String, dynamic> statusInfo = _getStatusInfo(demande.statut);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Card(
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        child: ListTile(
          contentPadding: const EdgeInsets.all(12.0),

          // Icône représentant le type de demande (ou juste le statut)
          leading: Container(
            width: 45,
            height: 45,
            decoration: BoxDecoration(
              color: statusInfo['color'].withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: statusInfo['color'], width: 1),
            ),
            child: Icon(statusInfo['icon'], color: statusInfo['color'], size: 24),
          ),

          // Titre du Contenu
          title: Text(
            demande.titreContenu,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
              color: _cardTextColor,
            ),
            overflow: TextOverflow.ellipsis,
          ),

          // Sous-titre: Demandeur et Date
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 4),
              Text(
                'Demandeur: ${demande.nomDemandeur}',
                style: const TextStyle(fontSize: 13, color: Colors.grey),
              ),
              const SizedBox(height: 2),
              Text(
                'Soumis le: ${_formatDate(demande.dateDemande)}',
                style: const TextStyle(fontSize: 12, color: _tagColor),
              ),
            ],
          ),

          // Trailing: Badge de Statut et Actions
          trailing: _buildStatusBadge(demande.statut),

          // Action au clic (Ex: Afficher les détails et les boutons Approuver/Rejeter)
          onTap: () {
            // 💡 TODO: Implémenter la navigation vers l'écran de modération/détail
            _showModerationDetails(context, demande);
          },
        ),
      ),
    );
  }

  // Helper pour formater la date
  String _formatDate(DateTime date) {
    return "${date.day}/${date.month}/${date.year}";
  }

  // Helper pour obtenir les informations de statut
  Map<String, dynamic> _getStatusInfo(String statut) {
    final String status = statut.toUpperCase();
    switch (status) {
      case 'EN_ATTENTE':
        return {'color': _pendingColor, 'text': 'En Attente', 'icon': Icons.schedule};
      case 'APPROUVEE':
        return {'color': _approvedColor, 'text': 'Approuvée', 'icon': Icons.check_circle};
      case 'REJETEE':
        return {'color': _rejectedColor, 'text': 'Rejetée', 'icon': Icons.cancel};
      default:
        return {'color': Colors.grey, 'text': 'Inconnu', 'icon': Icons.help_outline};
    }
  }

  // Helper pour construire le badge de statut
  Widget _buildStatusBadge(String statut) {
    Map<String, dynamic> info = _getStatusInfo(statut);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: info['color'].withOpacity(0.15),
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: info['color'], width: 0.5),
      ),
      child: Text(
        info['text'],
        style: TextStyle(
          color: info['color'],
          fontSize: 11,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  // Modale de Détails/Modération
  void _showModerationDetails(BuildContext context, DemandePublicationn demande) {
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: Text('Modérer: ${demande.titreContenu}'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('ID Contenu: ${demande.idContenu}'),
              Text('Statut Actuel: ${_getStatusInfo(demande.statut)['text']}'),
              Text('Demandeur: ${demande.nomDemandeur}'),
              const SizedBox(height: 10),
              // 💡 TODO: Ajouter le lien pour voir le contenu détaillé (Recit, Devinette, Proverbe)
              // TextButton(onPressed: () {}, child: Text('Voir le Contenu Original')),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('Fermer'),
            ),
            if (demande.statut.toUpperCase() == 'EN_ATTENTE')
            // Bouton Approuver
              ElevatedButton(
                onPressed: () {
                  // 💡 TODO: Implémenter l'appel API pour Approuver
                  // _approveDemande(demande.idContenu);
                  Navigator.pop(dialogContext);
                },
                style: ElevatedButton.styleFrom(backgroundColor: _approvedColor),
                child: const Text('Approuver', style: TextStyle(color: Colors.white)),
              ),
          ],
        );
      },
    );
  }
}