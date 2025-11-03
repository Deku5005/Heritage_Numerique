import 'package:flutter/material.dart';
// Import du service de stockage sécurisé
import 'package:heritage_numerique/Service/token-storage-service.dart';
import 'package:heritage_numerique/Service/Auth-service.dart';
import 'package:heritage_numerique/Service/InvitationService.dart';
import 'package:heritage_numerique/model/dashboard-models.dart';
import 'CreateFamilyAccountScreen.dart';
import 'HomeDashboardScreen.dart';

// NOUVEL IMPORT: Nécessaire pour décoder le JWT et extraire l'ID utilisateur de manière dynamique
import 'dart:convert'; // Required for JWT decoding

// --- Constantes de Couleurs ---
const Color _mainAccentColor = Color(0xFFAA7311);
const Color _buttonOpacityColor = Color(0x87D9D9D9);
const Color _backgroundColor = Colors.white;
const Color _cardTextColor = Color(0xFF2E2E2E);


class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  // Services
  final TokenStorageService _storageService = TokenStorageService(); // Instance du service de stockage de jeton

  // Services API initialisés dynamiquement après récupération du jeton
  late AuthService _authService;
  late InvitationService _invitationService;

  // Future qui contiendra les données du dashboard
  late Future<DashboardPersonnelResponse> _dashboardData;

  // Stocke l'ID de l'utilisateur connecté pour la vérification du rôle.
  int? _currentUserId;
  String? _authToken;

  // NOUVEAU: Stocke les données du tableau de bord après le premier fetch pour les mises à jour locales.
  DashboardPersonnelResponse? _currentDashboardData;

  // NOUVEAU FLAG: Indique que le token et l'ID sont prêts, et que le service est initialisé.
  bool _isSessionReady = false;
  String? _sessionError;

  @override
  void initState() {
    super.initState();
    // Lance le chargement de la session utilisateur de manière asynchrone et dynamique
    _loadUserSession();
  }

  // Méthode utilitaire pour formater les dates (J/M/AAAA)
  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  // --- NOUVELLE MÉTHODE: Extraction de l'ID utilisateur à partir du JWT ---
  // Note: Cette implémentation est basique et suppose que votre JWT est standard.
  // Vous devriez utiliser une librairie comme `dart_jsonwebtoken` pour une production sérieuse.
  int? _decodeJwtGetUserId(String token) {
    if (token.isEmpty) return null;

    try {
      final parts = token.split('.');
      if (parts.length != 3) return null;

      // Décodage du payload (partie 2 du JWT)
      // Base64Url sans padding est courant pour les JWT
      String payload = parts[1].replaceAll('-', '+').replaceAll('_', '/');
      while (payload.length % 4 != 0) {
        payload += '=';
      }
      final decodedPayload = utf8.decode(base64Url.decode(payload));
      final Map<String, dynamic> payloadMap = jsonDecode(decodedPayload);

      // Assurez-vous que la clé 'userId' ou 'sub' correspond à votre structure JWT
      // Nous cherchons 'userId' ou une autre clé contenant l'ID (généralement 'sub' ou 'id')
      if (payloadMap.containsKey('userId')) {
        // Tente de convertir en int, si c'est un String
        return payloadMap['userId'] is String ? int.tryParse(payloadMap['userId']) : payloadMap['userId'] as int?;
      }
      if (payloadMap.containsKey('sub')) {
        // Tente de convertir le champ 'subject'
        return payloadMap['sub'] is String ? int.tryParse(payloadMap['sub']) : payloadMap['sub'] as int?;
      }
      return null;
    } catch (e) {
      print("Erreur de décodage JWT: $e");
      return null;
    }
  }

  // ----------------------------------------------------------------------
  // --- CHARGEMENT DYNAMIQUE DE LA SESSION UTILISATEUR ---
  // ----------------------------------------------------------------------
  Future<void> _loadUserSession() async {
    try {
      // 1. Récupération dynamique du jeton depuis le service de stockage sécurisé
      final String? token = await _storageService.getAuthToken();

      if (mounted) {
        // 2. Initialisation des variables de session
        _authToken = token;
        _currentDashboardData = null; // Réinitialiser les données locales au chargement de session

        // 4. Initialisation dynamique des services API avec le jeton récupéré
        if (_authToken != null && _authToken!.isNotEmpty) {
          // --- DYNAMIQUE: Extraction de l'ID à partir du jeton ---
          _currentUserId = _decodeJwtGetUserId(_authToken!);

          // 3. Vérification de la validité
          if (_currentUserId != null) {

            // 4. Initialisation dynamique des services API (Le constructeur d'AuthService est maintenant corrigé)
            _authService = AuthService(authToken: _authToken!);
            _invitationService = InvitationService(_authToken!);

            // 5. Lancement du fetch du dashboard
            _dashboardData = _authService.fetchPersonnelDashboard();

            setState(() {
              _isSessionReady = true;
            });
          } else {
            // Jeton présent mais invalide/indécodable (pas d'ID)
            setState(() {
              _sessionError = "Jeton d'authentification invalide ou ID utilisateur introuvable.";
              _isSessionReady = true;
            });
          }
        } else {
          // Gérer le cas où le jeton est manquant (utilisateur déconnecté, session expirée)
          setState(() {
            _sessionError = "Jeton d'authentification manquant. Veuillez vous connecter ou la session a expiré.";
            _isSessionReady = true;
          });
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _sessionError = "Erreur lors du chargement de la session: ${e.toString()}";
          _isSessionReady = true;
        });
      }
    }
  }


  // ----------------------------------------------------------------------
  // --- GESTION DES INVITATIONS (Modifiée pour mise à jour locale) ---
  // ----------------------------------------------------------------------
  void _acceptInvitation(String invitationId) async {
    // Vérification de sécurité avant l'appel API et des données locales
    if (_authToken == null || !_isSessionReady || _currentDashboardData == null) {
      _showSnackbar("Session non valide ou données manquantes. Veuillez vous reconnecter.", color: Colors.red);
      return;
    }

    _showSnackbar('Acceptation de l\'invitation en cours...', color: Colors.blue.shade400);

    try {
      await _invitationService.acceptInvitation(invitationId: invitationId);

      if (mounted) {
        ScaffoldMessenger.of(context).hideCurrentSnackBar();
        _showSnackbar('Invitation acceptée avec succès ! Vous êtes maintenant membre.', color: Colors.green);

        // MISE À JOUR LOCALE
        setState(() {
          final invitationIndex = _currentDashboardData!.invitationsEnAttente.indexWhere(
                (inv) => inv.id.toString() == invitationId,
          );

          if (invitationIndex != -1) {
            // Si le modèle 'Invitation' a un copyWith, l'utiliser pour mettre à jour
            final updatedInvitation = _currentDashboardData!.invitationsEnAttente[invitationIndex].copyWith(
              statut: 'ACCEPTEE',
            );

            // Mise à jour de l'objet dans la liste existante
            _currentDashboardData!.invitationsEnAttente[invitationIndex] = updatedInvitation;

            // Mise à jour du compteur pour les statistiques (si l'API ne le gère pas après la réponse)
            _currentDashboardData = _currentDashboardData!.copyWith(
              nombreInvitationsEnAttente: _currentDashboardData!.nombreInvitationsEnAttente - 1,
              nombreFamillesAppartenance: _currentDashboardData!.nombreFamillesAppartenance + 1,
            );
          }
          // L'UI se mettra à jour grâce au setState et utilisera le nouveau statut de l'invitation
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).hideCurrentSnackBar();
        _showSnackbar(e.toString().replaceFirst('Exception: ', ''), color: Colors.red);
      }
    }
  }

  void _refuseInvitation(String invitationId) async {
    // Vérification de sécurité avant l'appel API et des données locales
    if (_authToken == null || !_isSessionReady || _currentDashboardData == null) {
      _showSnackbar("Session non valide ou données manquantes. Veuillez vous reconnecter.", color: Colors.red);
      return;
    }

    _showSnackbar('Refus de l\'invitation en cours...', color: Colors.blueGrey);

    try {
      await _invitationService.refuseInvitation(invitationId: invitationId);

      if (mounted) {
        ScaffoldMessenger.of(context).hideCurrentSnackBar();
        _showSnackbar('Invitation refusée.', color: Colors.orange);

        // MISE À JOUR LOCALE
        setState(() {
          final invitationIndex = _currentDashboardData!.invitationsEnAttente.indexWhere(
                (inv) => inv.id.toString() == invitationId,
          );

          if (invitationIndex != -1) {
            // Si le modèle 'Invitation' a un copyWith, l'utiliser pour mettre à jour
            final updatedInvitation = _currentDashboardData!.invitationsEnAttente[invitationIndex].copyWith(
              statut: 'REFUSEE',
            );

            // Mise à jour de l'objet dans la liste existante
            _currentDashboardData!.invitationsEnAttente[invitationIndex] = updatedInvitation;

            // Mise à jour du compteur pour les statistiques
            _currentDashboardData = _currentDashboardData!.copyWith(
              nombreInvitationsEnAttente: _currentDashboardData!.nombreInvitationsEnAttente - 1,
            );
          }
          // L'UI se mettra à jour
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).hideCurrentSnackBar();
        _showSnackbar('Erreur lors du refus : ${e.toString().replaceFirst('Exception: ', '')}', color: Colors.red);
      }
    }
  }

  /// Fonction utilitaire pour afficher les messages (succès ou erreur)
  void _showSnackbar(String message, {required Color color}) {
    ScaffoldMessenger.of(context).hideCurrentSnackBar();

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: color,
        duration: const Duration(seconds: 5),
      ),
    );
  }


  @override
  Widget build(BuildContext context) {
    // 1. AFFICHAGE DE CHARGEMENT INITIAL (Session)
    if (!_isSessionReady) {
      return const Scaffold(
        backgroundColor: _backgroundColor,
        body: Center(
          child: CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(_mainAccentColor),
          ),
        ),
      );
    }

    // 2. AFFICHAGE DE L'ERREUR DE SESSION (si le token est manquant)
    if (_sessionError != null) {
      return Scaffold(
        backgroundColor: _backgroundColor,
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(32.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.security_update_warning, color: Colors.deepOrange, size: 50),
                const SizedBox(height: 20),
                const Text(
                  'Erreur de Session',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.deepOrange),
                ),
                const SizedBox(height: 10),
                Text(
                  _sessionError!,
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: _cardTextColor, fontSize: 16),
                ),
                const SizedBox(height: 20),
                // Bouton de déconnexion/reconnexion
                ElevatedButton(
                  onPressed: () {
                    // ⚠️ Logique de déconnexion/redirection ici
                    _storageService.deleteAuthToken(); // Nettoyage du token
                    // Normalement, vous navigueriez vers l'écran de connexion ici.
                  },
                  style: ElevatedButton.styleFrom(backgroundColor: _mainAccentColor),
                  child: const Text('Aller à la Connexion', style: TextStyle(color: Colors.white)),
                )
              ],
            ),
          ),
        ),
      );
    }

    // 3. Utilisation d'un FutureBuilder pour gérer l'état de la requête API (Dashboard)
    return FutureBuilder<DashboardPersonnelResponse>(
      future: _dashboardData,
      builder: (context, snapshot) {

        // État de Chargement du Dashboard
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            backgroundColor: _backgroundColor,
            body: Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(_mainAccentColor),
              ),
            ),
          );
        }

        // État d'Erreur (Erreur d'API après authentification)
        if (snapshot.hasError) {
          return Scaffold(
            backgroundColor: _backgroundColor,
            appBar: AppBar(
              title: const Text('Erreur de Chargement', style: TextStyle(color: _cardTextColor)),
              backgroundColor: _backgroundColor,
              elevation: 0,
            ),
            body: Center(
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.error_outline, color: Colors.red, size: 50),
                    const SizedBox(height: 10),
                    Text(
                      // Afficher l'erreur retournée par l'API
                      'Erreur de chargement: ${snapshot.error.toString().replaceFirst('Exception: ', '')}',
                      textAlign: TextAlign.center,
                      style: const TextStyle(color: Colors.red),
                    ),
                    const SizedBox(height: 20),
                    // Bouton pour réessayer
                    ElevatedButton(
                      onPressed: () {
                        setState(() {
                          // On réutilise _authService qui a été initialisé avec le jeton
                          // IMPORTANT: On réinitialise _currentDashboardData pour forcer l'utilisation de la nouvelle donnée
                          _currentDashboardData = null;
                          _dashboardData = _authService.fetchPersonnelDashboard();
                        });
                      },
                      style: ElevatedButton.styleFrom(backgroundColor: _mainAccentColor),
                      child: const Text('Réessayer', style: TextStyle(color: Colors.white)),
                    )
                  ],
                ),
              ),
            ),
          );
        }

        // État de Succès (Données disponibles)
        if (snapshot.hasData) {
          // Utiliser les données du snapshot pour la première fois, puis utiliser la variable d'état locale
          if (_currentDashboardData == null) {
            _currentDashboardData = snapshot.data!;
          }

          final data = _currentDashboardData!; // Utiliser la variable d'état pour le rendu

          return Scaffold(
            backgroundColor: _backgroundColor,
            body: RefreshIndicator(
              color: _mainAccentColor,
              onRefresh: () async {
                setState(() {
                  // Déclencher un nouvel appel API et réinitialiser les données locales
                  _dashboardData = _authService.fetchPersonnelDashboard();
                  _currentDashboardData = null; // Assure que le snapshot est utilisé à nouveau
                });
                await _dashboardData;
              },
              child: SingleChildScrollView(
                padding: EdgeInsets.only(top: MediaQuery.of(context).padding.top + 20),
                child: Column(
                  children: [
                    _buildProfileCircle(),
                    const SizedBox(height: 20),
                    _buildWelcomeContainer(data.prenom),
                    const SizedBox(height: 30),
                    _buildStatsContainer(
                        context,
                        data.nombreFamillesAppartenance,
                        data.nombreQuizCrees,
                        data.invitationsEnAttente.length // Utiliser la longueur de la liste mise à jour
                    ),
                    const SizedBox(height: 30),
                    _buildSectionTitle('Famille (${data.nombreFamillesAppartenance})'),
                    const SizedBox(height: 15),
                    _buildFamilyGrid(context, data.familles),
                    const SizedBox(height: 30),
                    _buildSectionTitle('Invitation (${data.invitationsEnAttente.length})'), // Utiliser la longueur de la liste mise à jour
                    const SizedBox(height: 15),
                    _buildInvitationGrid(context, data.invitationsEnAttente),
                    const SizedBox(height: 30),
                    _buildActionContainer(context),
                    const SizedBox(height: 30),
                  ],
                ),
              ),
            ),
          );
        }

        return const Scaffold(
          backgroundColor: _backgroundColor,
          body: Center(child: Text('Initialisation du Dashboard...')),
        );
      },
    );
  }

  // ----------------------------------------------------------------------
  // --- MÉTHODES DE CONSTRUCTION DE L'UI ---
  // ----------------------------------------------------------------------

  Widget _buildFamilyGrid(BuildContext context, List<Famille> familles) {
    return GridView.builder(
      physics: const NeverScrollableScrollPhysics(),
      shrinkWrap: true,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      itemCount: familles.length + 1,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 10,
        mainAxisSpacing: 10,
        childAspectRatio: 0.7,
      ),
      itemBuilder: (context, index) {
        if (index < familles.length) {
          return _buildFamilyCard(context, familles[index]);
        } else {
          return _buildAddFamilyCard(context);
        }
      },
    );
  }

  Widget _buildFamilyCard(BuildContext context, Famille famille) {
    // Vérification dynamique de l'ID utilisateur
    final bool isAdmin = famille.idCreateur == _currentUserId;

    return GestureDetector(
      onTap: () {
        // CORRECTION APPLIQUÉE : Passage obligatoire de familyId
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => HomeDashboardScreen(familyId: famille.id),
          ),
        );
      },
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 5,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            const Icon(Icons.group, color: _mainAccentColor, size: 30),
            Text(
                famille.nom,
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(fontWeight: FontWeight.bold, color: _cardTextColor)
            ),
            _buildFamilyDetailRow('Admin:', isAdmin ? 'Oui' : 'Non', isLast: false),
            _buildFamilyDetailRow('Membres:', famille.nombreMembres.toString(), isLast: false),
            _buildFamilyDetailRow('Créé le:', _formatDate(famille.dateCreation), isLast: true),
            InkWell(
              onTap: () {
                // Action pour Gérer ou Quitter
              },
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(5),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 3,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Text(
                  isAdmin ? 'Gérer' : 'Quitter',
                  style: const TextStyle(fontSize: 10, color: _mainAccentColor, fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAddFamilyCard(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const CreateFamilyAccountScreen()),
        );
      },
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: _mainAccentColor.withOpacity(0.5), style: BorderStyle.solid),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 5,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: const Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.add_circle_outline, color: _mainAccentColor, size: 35),
            SizedBox(height: 5),
            Text(
              'Créer/Ajouter',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: _mainAccentColor),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWelcomeContainer(String prenom) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: _mainAccentColor, width: 1.5),
      ),
      child: Text(
        'Bienvenue, $prenom !',
        style: const TextStyle(
          color: _mainAccentColor,
          fontWeight: FontWeight.bold,
          fontSize: 16,
        ),
      ),
    );
  }

  Widget _buildStatsContainer(BuildContext context, int familyCount, int quizCount, int invitationCount) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: const Color(0xFFF7F2E8),
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildStatItem('Famille', Icons.group, familyCount),
          _buildStatItem('Quiz', Icons.quiz, quizCount),
          _buildStatItem('Invitations', Icons.send, invitationCount),
        ],
      ),
    );
  }

  Widget _buildStatItem(String title, IconData icon, int count) {
    return Column(
      children: [
        Icon(icon, color: _mainAccentColor, size: 30),
        const SizedBox(height: 8),
        Text(
          title,
          style: const TextStyle(
            color: _cardTextColor,
            fontWeight: FontWeight.bold,
            fontSize: 14,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          width: 60,
          height: 30,
          decoration: BoxDecoration(
            color: _buttonOpacityColor,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Center(
            child: Text(
              count.toString(),
              style: const TextStyle(
                color: _cardTextColor,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Align(
        alignment: Alignment.centerLeft,
        child: Text(
          title,
          style: const TextStyle(
            color: _cardTextColor,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  Widget _buildFamilyDetailRow(String label, String value, {required bool isLast}) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(fontSize: 8, color: Colors.black),
          ),
          Text(
            value,
            style: const TextStyle(fontSize: 8, color: _cardTextColor),
          ),
        ],
      ),
    );
  }

  Widget _buildInvitationGrid(BuildContext context, List<Invitation> invitationsEnAttente) {
    final itemCount = invitationsEnAttente.isEmpty ? 1 : invitationsEnAttente.length;

    return GridView.builder(
      physics: const NeverScrollableScrollPhysics(),
      shrinkWrap: true,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      itemCount: itemCount,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 10,
        mainAxisSpacing: 10,
        childAspectRatio: 0.7,
      ),
      itemBuilder: (context, index) {
        if (invitationsEnAttente.isEmpty) {
          return _buildEmptyInvitationCard();
        }
        return _buildInvitationCard(context, invitationsEnAttente[index]);
      },
    );
  }

  Widget _buildInvitationCard(BuildContext context, Invitation invitation) {
    // Si l'invitation n'est plus en attente, les boutons sont remplacés par un statut visuel
    final bool isPending = invitation.statut == 'EN_ATTENTE';
    IconData statusIcon = Icons.access_time;
    Color statusColor = Colors.orange;

    if (invitation.statut == 'ACCEPTEE') {
      statusIcon = Icons.check_circle_outline;
      statusColor = Colors.green.shade700;
    } else if (invitation.statut == 'REFUSEE') {
      statusIcon = Icons.cancel_outlined;
      statusColor = Colors.red;
    }

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 5,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          Icon(isPending ? Icons.send : statusIcon, color: _mainAccentColor, size: 30),
          Text(
              invitation.nomFamille,
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontWeight: FontWeight.bold, color: _cardTextColor)
          ),
          _buildFamilyDetailRow('De:', invitation.nomEmetteur, isLast: false),
          _buildFamilyDetailRow('Lien:', invitation.lienParente, isLast: false),
          _buildFamilyDetailRow('Statut:', invitation.statut, isLast: false),
          _buildFamilyDetailRow('Expire le:', _formatDate(invitation.dateExpiration), isLast: true),
          const SizedBox(height: 5), // Espace ajouté pour l'alignement
          isPending
              ? _buildPendingInvitationButtons(invitation.id.toString())
              : _buildActionCircle(statusIcon, statusColor), // Afficher le statut accepté/refusé
          const SizedBox(height: 5), // Espace ajouté pour l'alignement
        ],
      ),
    );
  }

  Widget _buildEmptyInvitationCard() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.grey.withOpacity(0.5), width: 1.0),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 5,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: const Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.mail_outline, color: Colors.grey, size: 35),
          SizedBox(height: 5),
          Text(
            'Aucune invitation en attente',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 10, color: Colors.grey),
          ),
        ],
      ),
    );
  }

  Widget _buildProfileCircle() {
    return Container(
      width: 60,
      height: 60,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: _mainAccentColor, width: 2),
        image: const DecorationImage(
          image: AssetImage('assets/images/Acceuil1.png'),
          fit: BoxFit.cover,
        ),
      ),
    );
  }

  Widget _buildPendingInvitationButtons(String invitationId) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        // Bouton Refuser
        InkWell(
          onTap: () => _refuseInvitation(invitationId),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(5),
              border: Border.all(color: _cardTextColor.withOpacity(0.2)),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 3,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: const Text('Refuser', style: TextStyle(fontSize: 10, color: _cardTextColor, fontWeight: FontWeight.bold)),
          ),
        ),

        // Bouton Accepter
        InkWell(
          onTap: () => _acceptInvitation(invitationId),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
            decoration: BoxDecoration(
              color: _mainAccentColor,
              borderRadius: BorderRadius.circular(5),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 3,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: const Text('Accepter', style: TextStyle(fontSize: 10, color: Colors.white, fontWeight: FontWeight.bold)),
          ),
        ),
      ],
    );
  }

  Widget _buildActionCircle(IconData icon, Color iconColor) {
    return Container(
      width: 30,
      height: 30,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: iconColor.withOpacity(0.1), // Rendre le cercle un peu transparent
      ),
      child: Icon(icon, color: iconColor, size: 20),
    );
  }

  Widget _buildActionContainer(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Container(
        padding: const EdgeInsets.all(16.0),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(15),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 10,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Column(
          children: [
            // Ajouter d'autres actions ici
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Déconnexion',
                  style: TextStyle(
                    color: _cardTextColor,
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.logout, color: Colors.redAccent),
                  onPressed: () {
                    _storageService.deleteAuthToken();
                    _showSnackbar('Déconnexion réussie. Veuillez vous reconnecter.', color: Colors.redAccent);
                    // Redirection vers l'écran de connexion (à implémenter dans votre navigation principale)
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
