import 'package:flutter/material.dart';
// NOTE: Assurez-vous que les chemins d'importation sont corrects pour votre structure de fichiers.
import 'HomeDashboardScreen.dart';
import 'AppDrawer.dart';

import 'package:heritage_numerique/Service/FamilyMemberService.dart';
import 'package:heritage_numerique/model/family_member_model.dart';

// --- Constantes de Couleurs Globales ---
const Color _mainAccentColor = Color(0xFFAA7311);
const Color _backgroundColor = Colors.white;
const Color _cardTextColor = Color(0xFF2E2E2E);
const Color _searchBackground = Color(0xFFF7F2E8);

class FamilyMembersScreen extends StatefulWidget {
  final int familleId;

  const FamilyMembersScreen({super.key, required this.familleId});

  @override
  State<FamilyMembersScreen> createState() => _FamilyMembersScreenState();
}

class _FamilyMembersScreenState extends State<FamilyMembersScreen> {
  final FamilyMemberService _memberService = FamilyMemberService();
  late Future<List<FamilyMemberModel>> _membersData;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    _loadFamilyMembers();
  }

  // Fonction de chargement des membres
  void _loadFamilyMembers() {
    final int id = widget.familleId;
    setState(() {
      _membersData = _memberService.fetchFamilyMembers(familleId: id);
    });
  }

  // 💡 Fonction utilitaire pour afficher les messages (succès ou erreur)
  void _showSnackbar(String message, {bool isError = false}) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: isError ? Colors.red : Colors.green,
          duration: const Duration(seconds: 3),
        ),
      );
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: _backgroundColor,
      drawer: AppDrawer(familyId: widget.familleId),
      body: SingleChildScrollView(
        padding: EdgeInsets.only(top: MediaQuery.of(context).padding.top + 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildCustomHeader(),
            const SizedBox(height: 20),
            _buildPageTitle(),
            const SizedBox(height: 20),
            _buildActionSection(),
            const SizedBox(height: 20),
            _buildMembersTable(),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  // Fonctions de construction de l'UI (inchangées)
  Widget _buildCustomHeader() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.menu, color: _cardTextColor, size: 30),
            onPressed: () {
              _scaffoldKey.currentState?.openDrawer();
            },
          ),
          const SizedBox(width: 8),
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

  Widget _buildActionSection() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Row(
        children: [
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

  Widget _buildMembersTable() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: FutureBuilder<List<FamilyMemberModel>>(
        future: _membersData,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator(color: _mainAccentColor));
          }
          if (snapshot.hasError) {
            return Center(
                child: Text("Erreur de chargement: ${snapshot.error.toString().replaceAll('Exception: ', '')}",
                    style: const TextStyle(color: Colors.red)
                )
            );
          }

          if (snapshot.hasData && snapshot.data!.isNotEmpty) {
            final members = snapshot.data!;

            return Container(
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
                    return _buildMemberRow(member);
                  }).toList(),
                ],
              ),
            );
          }

          return const Center(
            child: Padding(
              padding: EdgeInsets.all(16.0),
              child: Text("Aucun membre trouvé pour cette famille.", style: TextStyle(color: Colors.grey)),
            ),
          );
        },
      ),
    );
  }

  Widget _buildMemberRow(FamilyMemberModel member) {
    final String formattedDate = "${member.dateAjout.day.toString().padLeft(2, '0')}/${member.dateAjout.month.toString().padLeft(2, '0')}/${member.dateAjout.year}";
    final String lienParent = 'N/A';

    return InkWell(
      onTap: () => _showMemberDetailDialog(context, member.id),
      child: _buildTableRow(
        isHeader: false,
        data: {
          'membre': '${member.prenom} ${member.nom}',
          'role': member.roleFamille,
          'lien': lienParent,
          'date': formattedDate,
          'statut': member.statut,
          'action': '...',
        },
      ),
    );
  }

  Widget _buildTableRow({required bool isHeader, required Map<String, String> data}) {
    Color getColorForRole(String role) {
      if (role.toUpperCase().contains('ADMIN')) return Colors.lightGreen.shade100;
      if (role.toUpperCase().contains('CONTRIBUTEUR')) return Colors.green.shade100;
      if (role.toUpperCase().contains('LECTEUR')) return Colors.orange.shade100;
      return Colors.transparent;
    }

    Color getColorForStatus(String status) {
      if (status.toUpperCase() == 'ACCEPTE') return Colors.green.shade50;
      if (status.toUpperCase() == 'EN ATTENTE') return Colors.orange.shade50;
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

  void _showMemberDetailDialog(BuildContext context, int membreId) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          backgroundColor: _backgroundColor,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          child: FutureBuilder<FamilyMemberModel>(
            future: _memberService.fetchMemberDetail(membreId: membreId),
            builder: (context, snapshot) {
              return Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Détails du membre',
                      style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: _cardTextColor),
                    ),
                    const Divider(height: 20, color: Colors.grey),
                    if (snapshot.connectionState == ConnectionState.waiting)
                      const Center(
                        child: Padding(
                          padding: EdgeInsets.symmetric(vertical: 40.0),
                          child: CircularProgressIndicator(color: _mainAccentColor),
                        ),
                      )
                    else if (snapshot.hasError)
                      Center(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 20.0),
                          child: Text(
                            "Erreur: ${snapshot.error.toString().replaceAll('Exception: ', '')}",
                            style: const TextStyle(color: Colors.red),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      )
                    else if (snapshot.hasData)
                        _buildMemberDetailContent(snapshot.data!),

                    const SizedBox(height: 20),
                    Align(
                      alignment: Alignment.centerRight,
                      child: TextButton(
                        onPressed: () => Navigator.of(context).pop(),
                        child: const Text('Fermer', style: TextStyle(color: _mainAccentColor, fontSize: 14)),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        );
      },
    );
  }

  Widget _buildMemberDetailContent(FamilyMemberModel member) {
    final String formattedDateAjout = "${member.dateAjout.day.toString().padLeft(2, '0')}/${member.dateAjout.month.toString().padLeft(2, '0')}/${member.dateAjout.year}";
    final String telephone = member.telephone?.isNotEmpty == true ? member.telephone! : 'Non spécifié';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildDetailRow('Nom complet', '${member.prenom} ${member.nom}'),
        _buildDetailRow('Rôle familial', member.roleFamille),
        _buildDetailRow('Statut', member.statut),
        const SizedBox(height: 10),
        _buildDetailRow('Téléphone', telephone),
        _buildDetailRow('Email', member.email ?? 'Non spécifié'),
        _buildDetailRow('Date d\'ajout', formattedDateAjout),
      ],
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 130,
            child: Text(
              '$label :',
              style: const TextStyle(fontWeight: FontWeight.bold, color: _cardTextColor, fontSize: 13),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(color: Colors.black87, fontSize: 13),
            ),
          ),
        ],
      ),
    );
  }


  // =======================================================
  // --- 💡 LOGIQUE : Pop-ups d'Ajout/Invitation ---
  // =======================================================

  void _showAddManualDialog(BuildContext context) {
    // 💡 1. Contrôleurs pour les champs du formulaire
    final nomController = TextEditingController();
    final lienController = TextEditingController();
    final phoneController = TextEditingController();
    final descController = TextEditingController();

    showDialog(
      context: context,
      builder: (BuildContext context) {
        // 💡 2. Utilisation de StatefulBuilder pour gérer l'état de chargement local du bouton
        return StatefulBuilder(
          builder: (context, setStateLocal) {
            bool isLoading = false;

            // 💡 3. Fonction de soumission (Appel API)
            Future<void> submit() async {
              if (nomController.text.isEmpty || lienController.text.isEmpty || phoneController.text.isEmpty) {
                _showSnackbar("Veuillez remplir les champs Nom, Lien et Téléphone.", isError: true);
                return;
              }

              setStateLocal(() => isLoading = true);

              try {
                await _memberService.addFamilyMemberManual(
                  familleId: widget.familleId,
                  nomComplet: nomController.text,
                  lienParent: lienController.text,
                  telephone: phoneController.text,
                  description: descController.text,
                );

                // IMPORTANT: Vérifiez 'mounted' avant de manipuler l'interface utilisateur
                if (mounted) {
                  Navigator.of(context).pop(); // Fermer le dialogue
                  _showSnackbar("Membre ajouté manuellement avec succès.");
                  _loadFamilyMembers(); // Recharger la liste pour voir le nouveau membre
                }

              } catch (e) {
                _showSnackbar("Erreur lors de l'ajout: ${e.toString().replaceAll('Exception: ', '')}", isError: true);
                // On met à jour l'état de chargement localement si l'erreur survient (et que le dialogue est toujours là)
                setStateLocal(() => isLoading = false);
              }
            }

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
                      // 💡 Les champs utilisent maintenant les contrôleurs
                      _buildInputField('Nom Complet', nomController, hint: 'Ex: Niakale Diakité'),
                      _buildInputField('Lien de parenté', lienController, hint: 'Ex: Oncle, Tante, Cousin'),
                      _buildInputField('Téléphone', phoneController, hint: 'Ex: +223 78787878', keyboardType: TextInputType.phone),
                      _buildDescriptionField('Description/ Souvenir', descController, hint: 'Partagez quelques souvenir ou informations sur ce membre...'),

                      const SizedBox(height: 20),

                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          TextButton(
                            onPressed: isLoading ? null : () => Navigator.of(context).pop(),
                            child: const Text('Annuler', style: TextStyle(color: Colors.grey, fontSize: 14)),
                          ),
                          const SizedBox(width: 10),
                          ElevatedButton(
                            onPressed: isLoading ? null : submit, // 💡 Appel à la fonction submit
                            style: ElevatedButton.styleFrom(
                              backgroundColor: _mainAccentColor,
                              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
                            ),
                            child: isLoading
                                ? const SizedBox(
                              width: 15, height: 15,
                              child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                            )
                                : const Text('Ajouter le membre', style: TextStyle(color: Colors.white, fontSize: 14)),
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
      },
    );
  }

  void _showInviteMemberDialog(BuildContext context) {
    // 💡 1. Contrôleurs pour les champs du formulaire
    final nomController = TextEditingController();
    final emailController = TextEditingController();
    final phoneController = TextEditingController();
    final lienController = TextEditingController();

    showDialog(
      context: context,
      builder: (BuildContext context) {
        // 💡 2. Utilisation de StatefulBuilder pour gérer l'état de chargement local du bouton
        return StatefulBuilder(
          builder: (context, setStateLocal) {
            bool isLoading = false;

            // 💡 3. Fonction de soumission (Appel API)
            Future<void> submit() async {
              if (nomController.text.isEmpty || emailController.text.isEmpty) {
                _showSnackbar("Veuillez saisir le Nom et l'Email pour l'invitation.", isError: true);
                return;
              }

              setStateLocal(() => isLoading = true);

              try {
                await _memberService.inviteFamilyMember(
                  familleId: widget.familleId,
                  // 🛑 CORRECTION: Revenir aux noms de paramètres originaux pour compiler
                  nomComplet: nomController.text, // était nomInvite
                  email: emailController.text,     // était emailInvite
                  telephone: phoneController.text,
                  lienParent: lienController.text, // était lienParente
                );

                // IMPORTANT: Vérifiez 'mounted' avant de manipuler l'interface utilisateur
                if (mounted) {
                  Navigator.of(context).pop(); // Fermer le dialogue
                  _showSnackbar("Invitation envoyée avec succès.");
                  _loadFamilyMembers(); // Recharger la liste (l'invitation pourrait apparaitre en statut 'En Attente')
                }

              } catch (e) {
                _showSnackbar("Erreur lors de l'envoi de l'invitation: ${e.toString().replaceAll('Exception: ', '')}", isError: true);
                // On met à jour l'état de chargement localement si l'erreur survient (et que le dialogue est toujours là)
                setStateLocal(() => isLoading = false);
              }
            }


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
                      // 💡 Les champs utilisent maintenant les contrôleurs
                      _buildInputField('Nom Complet', nomController, hint: 'Ex: Niakale Diakité'),
                      _buildInputField('Email', emailController, hint: 'Ex: diakitetenin99@gmail.com', keyboardType: TextInputType.emailAddress),
                      _buildInputField('Téléphone', phoneController, hint: 'Ex: 78787878', keyboardType: TextInputType.phone),
                      _buildInputField('Lien de parenté', lienController, hint: 'Ex: sœur, frère'),

                      const SizedBox(height: 30),

                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          Expanded(
                            child: OutlinedButton(
                              onPressed: isLoading ? null : () => Navigator.of(context).pop(),
                              style: OutlinedButton.styleFrom(
                                side: const BorderSide(color: Colors.grey),
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 15),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
                              ),
                              child: const Text('Annuler', style: TextStyle(color: _cardTextColor, fontSize: 14)),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: ElevatedButton(
                              onPressed: isLoading ? null : submit, // 💡 Appel à la fonction submit
                              style: ElevatedButton.styleFrom(
                                backgroundColor: _mainAccentColor,
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 15),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
                              ),
                              child: isLoading
                                  ? const SizedBox(
                                width: 15, height: 15,
                                child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                              )
                                  : const Text('Envoyer l\'invitation', style: TextStyle(color: Colors.white, fontSize: 14)),
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
      },
    );
  }

  // --- Widgets de formulaire mis à jour pour prendre un TextEditingController ---

  Widget _buildInputField(String label, TextEditingController controller, {required String hint, TextInputType keyboardType = TextInputType.text}) {
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
              controller: controller, // 💡 Contrôleur ajouté ici
              keyboardType: keyboardType, // 💡 Ajouté pour une meilleure UX (ex: email, phone)
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

  Widget _buildDescriptionField(String label, TextEditingController controller, {required String hint}) {
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
              controller: controller, // 💡 Contrôleur ajouté ici
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
