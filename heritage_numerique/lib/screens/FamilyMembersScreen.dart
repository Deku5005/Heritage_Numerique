import 'package:flutter/material.dart';
// NOTE: Assurez-vous que les chemins d'importation sont corrects pour votre structure de fichiers.
import 'HomeDashboardScreen.dart';
import 'AppDrawer.dart'; // Assurez-vous que le nom de fichier correspond

// --- Constantes de Couleurs Globales ---
const Color _mainAccentColor = Color(0xFFAA7311);
const Color _backgroundColor = Colors.white;
const Color _cardTextColor = Color(0xFF2E2E2E);
const Color _searchBackground = Color(0xFFF7F2E8);


class FamilyMembersScreen extends StatelessWidget {
  const FamilyMembersScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _backgroundColor,
      drawer: const AppDrawer(),
      body: SingleChildScrollView(
        padding: EdgeInsets.only(top: MediaQuery.of(context).padding.top + 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1. En-tête Personnalisé (Menu et Titre)
            Builder(
                builder: (BuildContext innerContext) {
                  return _buildCustomHeader(innerContext);
                }
            ),
            const SizedBox(height: 20),

            // 2. Titre et sous-titre
            _buildPageTitle(),
            const SizedBox(height: 20),

            // 3. Barre de recherche et Boutons d'action (Correction Débordement 46px)
            _buildActionSection(),
            const SizedBox(height: 20),

            // 4. Tableau des membres de la famille
            _buildMembersTable(),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  // --- 1. En-tête Personnalisé (Menu et Titre) ---
  Widget _buildCustomHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Row(
        children: [
          // Icône du menu (hamburger)
          IconButton(
            icon: const Icon(Icons.menu, color: _cardTextColor, size: 30),
            onPressed: () {
              Scaffold.of(context).openDrawer();
            },
          ),
          const SizedBox(width: 8),
          // Titre 'Héritage Numérique'
          const Text(
            'Héritage Numérique',
            style: TextStyle(
              color: _cardTextColor,
              fontWeight: FontWeight.bold,
              fontSize: 20,
            ),
          ),
        ],
      ),
    );
  }

  // --- 2. Titre et sous-titre de la page ---
  Widget _buildPageTitle() {
    return const Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Membres de la famille',
            style: TextStyle(
              color: _cardTextColor,
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 5),
          Text(
            'Gérer les membres de votre famille et leurs contributions',
            style: TextStyle(
              color: Colors.grey,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  // --- 3. Barre de recherche et Boutons d'action ---
  Widget _buildActionSection() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Row(
        children: [
          // Champ de recherche
          Expanded(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10),
              decoration: BoxDecoration(
                color: _searchBackground,
                borderRadius: BorderRadius.circular(5),
              ),
              child: const TextField(
                decoration: InputDecoration(
                  hintText: 'Rechercher membre...',
                  hintStyle: TextStyle(color: Colors.grey),
                  border: InputBorder.none,
                  prefixIcon: Icon(Icons.search, color: _mainAccentColor),
                  contentPadding: EdgeInsets.symmetric(vertical: 10),
                ),
                style: TextStyle(fontSize: 14),
              ),
            ),
          ),
          const SizedBox(width: 10),

          // Boutons d'action (Ajouter/Inviter)
          Expanded(
            child: _buildActionButton(
              text: 'Ajouter manuellement',
              isPrimary: false,
              onPressed: (context) => _showAddManualDialog(context),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: _buildActionButton(
              text: 'Inviter un membre',
              isPrimary: true,
              onPressed: (context) => _showInviteMemberDialog(context),
            ),
          ),
        ],
      ),
    );
  }

  // --- Construction des boutons d'action (Correction Débordement 46px) ---
  Widget _buildActionButton({
    required String text,
    required bool isPrimary,
    required Function(BuildContext) onPressed,
  }) {
    return Builder(
        builder: (context) {
          return ElevatedButton.icon(
            onPressed: () => onPressed(context),
            icon: Icon(
              isPrimary ? Icons.person_add : Icons.add,
              color: isPrimary ? Colors.white : _cardTextColor,
              size: 16,
            ),
            label: Text(
              text,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: isPrimary ? Colors.white : _cardTextColor,
                fontSize: 10,
                fontWeight: FontWeight.bold,
              ),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: isPrimary ? _mainAccentColor : _searchBackground,
              // CORRECTION: Suppression du padding horizontal (passé à 0)
              padding: const EdgeInsets.symmetric(horizontal: 0, vertical: 8),
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(5),
                side: isPrimary ? BorderSide.none : const BorderSide(color: Colors.transparent),
              ),
            ),
          );
        }
    );
  }

  // 4. Tableau des membres de la famille (Inchangé)
  Widget _buildMembersTable() {
    final List<Map<String, String>> members = [
      {'membre': 'Amadou Diakité', 'role': 'Administrateur', 'lien': 'Père', 'date': '01/10/2023', 'statut': 'Actif'},
      {'membre': 'Niskale Diakité', 'role': 'Contributeur', 'lien': 'Sœur', 'date': '07/11/2023', 'statut': 'Actif'},
      {'membre': 'Oumar Dolo', 'role': 'Contributeur', 'lien': 'Fils', 'date': '01/10/2023', 'statut': 'Actif'},
      {'membre': 'Fatoumata Diawara', 'role': 'Lecteur', 'lien': 'Mère', 'date': '01/10/2023', 'statut': 'En attente'},
    ];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Container(
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey.shade300),
          borderRadius: BorderRadius.circular(5),
        ),
        child: Column(
          children: [
            _buildTableRow(
              isHeader: true,
              data: {'membre': 'Membre', 'role': 'Rôle', 'lien': 'Lien', 'date': 'Date ajout', 'statut': 'Statut', 'action': 'Action'},
            ),

            ...members.map((member) {
              return _buildTableRow(
                isHeader: false,
                data: member..['action'] = '...',
              );
            }).toList(),
          ],
        ),
      ),
    );
  }

  // Ligne de tableau (Inchangé)
  Widget _buildTableRow({required bool isHeader, required Map<String, String> data}) {
    Color getColorForRole(String role) {
      if (role.toLowerCase().contains('admin')) return Colors.lightGreen.shade100;
      if (role.toLowerCase().contains('contributeur')) return Colors.green.shade100;
      if (role.toLowerCase().contains('lecteur')) return Colors.orange.shade100;
      return Colors.transparent;
    }

    Color getColorForStatus(String status) {
      if (status.toLowerCase() == 'actif') return Colors.green.shade50;
      if (status.toLowerCase() == 'en attente') return Colors.orange.shade50;
      return Colors.transparent;
    }

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
      decoration: BoxDecoration(
        color: isHeader ? Colors.grey.shade100 : Colors.white,
        border: Border(bottom: BorderSide(color: Colors.grey.shade200)),
      ),
      child: Row(
        children: [
          Expanded(flex: 3, child: _buildTableCell(data['membre']!, isHeader: isHeader)),
          Expanded(flex: 2, child: Center(child: _buildRoleChip(data['role']!, isHeader, getColorForRole(data['role']!)))),
          Expanded(flex: 1, child: _buildTableCell(data['lien']!, isHeader: isHeader)),
          Expanded(flex: 2, child: _buildTableCell(data['date']!, isHeader: isHeader)),
          Expanded(flex: 2, child: Center(child: _buildStatusChip(data['statut']!, isHeader, getColorForStatus(data['statut']!)))),
          Expanded(flex: 1, child: Center(child: _buildTableCell(data['action']!, isHeader: isHeader, isAction: true))),
        ],
      ),
    );
  }

  // Cellule de tableau (Texte) (Inchangé)
  Widget _buildTableCell(String text, {required bool isHeader, bool isAction = false}) {
    if (isAction && !isHeader) {
      return const Icon(Icons.more_vert, size: 18, color: Colors.grey);
    }
    return Text(
      text,
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
      style: TextStyle(
        fontWeight: isHeader ? FontWeight.bold : FontWeight.normal,
        fontSize: isHeader ? 12 : 10,
        color: isHeader ? _cardTextColor : Colors.black,
      ),
    );
  }

  // Puce (Chip) pour le rôle (Inchangé)
  Widget _buildRoleChip(String text, bool isHeader, Color color) {
    if (isHeader) return _buildTableCell(text, isHeader: true);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        text,
        style: const TextStyle(fontSize: 8, color: _cardTextColor, fontWeight: FontWeight.w600),
      ),
    );
  }

  // Puce (Chip) pour le statut (Inchangé)
  Widget _buildStatusChip(String text, bool isHeader, Color color) {
    if (isHeader) return _buildTableCell(text, isHeader: true);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        text,
        style: TextStyle(fontSize: 8, color: _cardTextColor.withOpacity(0.8), fontWeight: FontWeight.w600),
      ),
    );
  }

  // =======================================================
  // --- Fonctions des Pop-ups (MODIFIÉES) ---
  // =======================================================

  // Pop-up 1 : Ajouter un membre manuellement (Icône 'X' retirée et bouton Annuler ajouté)
  void _showAddManualDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // En-tête (Icône de fermeture 'X' retirée)
                  const Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Ajouter un membre manuellement',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: _cardTextColor),
                      ),
                      Text(
                        'Pour les membres n\'ayant pas de connexion internet',
                        style: TextStyle(fontSize: 12, color: Colors.grey),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),

                  // Champs de formulaire (inchangés)
                  _buildInputField('Nom Complet', hint: 'Ex: Niakale Diakité'),
                  _buildInputField('Lien de parenté', hint: 'Ex: Oncle, Tante, Cousin'),
                  _buildInputField('Téléphone', hint: 'Ex: +223 78787878'),
                  _buildDescriptionField('Description/ Souvenir', hint: 'Partagez quelques souvenir ou informations sur ce membre...'),

                  const SizedBox(height: 20),

                  // Bouton d'action (Ajout d'un bouton Annuler)
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      // Bouton Annuler
                      TextButton(
                        onPressed: () => Navigator.of(context).pop(),
                        child: const Text('Annuler', style: TextStyle(color: Colors.grey, fontSize: 14)),
                      ),
                      const SizedBox(width: 10),
                      // Bouton Ajouter
                      ElevatedButton(
                        onPressed: () {
                          // Logique pour ajouter le membre
                          Navigator.of(context).pop();
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: _mainAccentColor,
                          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
                        ),
                        child: const Text('Ajouter le membre', style: TextStyle(color: Colors.white, fontSize: 14)),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  // Pop-up 2 : Inviter un membre de la famille (Icône 'X' retirée + Correction Débordement 133px)
  void _showInviteMemberDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // En-tête (Icône de fermeture 'X' retirée)
                  const Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Inviter un membre de la famille',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: _cardTextColor),
                      ),
                      Text(
                        'Envoyer une invitation par email pour rejoindre votre espace familial',
                        style: TextStyle(fontSize: 12, color: Colors.grey),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),

                  // Champs de formulaire (inchangés)
                  _buildInputField('Nom Complet', hint: 'Ex: Niakale Diakité'),
                  _buildInputField('Email', hint: 'Ex: diakitetenin99@gmail.com'),
                  _buildInputField('Téléphone', hint: 'Ex: 78787878'),
                  _buildInputField('Lien de parenté', hint: 'Ex: sœur, frère'),

                  const SizedBox(height: 30),

                  // Boutons d'action (Annuler et Envoyer)
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      // Bouton Annuler (Déjà Flexible)
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () => Navigator.of(context).pop(),
                          style: OutlinedButton.styleFrom(
                            side: const BorderSide(color: Colors.grey),
                            // CORRECTION: Padding horizontal réduit (10 au lieu de 20)
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 15),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
                          ),
                          child: const Text('Annuler', style: TextStyle(color: _cardTextColor, fontSize: 14)),
                        ),
                      ),
                      const SizedBox(width: 10),
                      // Bouton Envoyer (Déjà Flexible)
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () {
                            // Logique pour envoyer l'invitation
                            Navigator.of(context).pop();
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: _mainAccentColor,
                            // CORRECTION: Padding horizontal réduit (10 au lieu de 20)
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 15),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
                          ),
                          child: const Text('Envoyer l\'invitation', style: TextStyle(color: Colors.white, fontSize: 14)),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  // Widget helper pour les champs de saisie de texte standard (Inchangé)
  Widget _buildInputField(String label, {required String hint}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 15.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(fontWeight: FontWeight.bold, color: _cardTextColor)),
          const SizedBox(height: 5),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10),
            decoration: BoxDecoration(
              color: _searchBackground,
              borderRadius: BorderRadius.circular(5),
            ),
            child: TextField(
              decoration: InputDecoration(
                hintText: hint,
                hintStyle: const TextStyle(color: Colors.grey, fontSize: 14),
                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(vertical: 12),
              ),
              style: const TextStyle(fontSize: 14),
            ),
          ),
        ],
      ),
    );
  }

  // Widget helper pour les champs de saisie de texte multiligne (Description/Souvenir) (Inchangé)
  Widget _buildDescriptionField(String label, {required String hint}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 15.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(fontWeight: FontWeight.bold, color: _cardTextColor)),
          const SizedBox(height: 5),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10),
            decoration: BoxDecoration(
              color: _searchBackground,
              borderRadius: BorderRadius.circular(5),
            ),
            child: TextField(
              maxLines: 4,
              decoration: InputDecoration(
                hintText: hint,
                hintStyle: const TextStyle(color: Colors.grey, fontSize: 14),
                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(vertical: 12),
              ),
              style: const TextStyle(fontSize: 14),
            ),
          ),
        ],
      ),
    );
  }
}