import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:heritage_numerique/Service/token-storage-service.dart';
import 'package:heritage_numerique/Service/Auth-service.dart';
import 'package:heritage_numerique/Service/InvitationService.dart';
import 'package:heritage_numerique/model/dashboard-models.dart';
import 'package:heritage_numerique/screens/home_screen.dart';
import 'package:heritage_numerique/screens/splash_screen.dart';
import 'CreateFamilyAccountScreen.dart';
import 'HomeDashboardScreen.dart';
import 'login_screen.dart';

// --- Constantes de Couleurs ---
const Color _mainAccentColor = Color(0xFFAA7311);
const Color _buttonOpacityColor = Color(0x87D9D9D9);
const Color _backgroundColor = Colors.white;
const Color _cardTextColor = Color(0xFF2E2E2E);
const Color _chocolateColor = Color(0xFF8B4513);

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  final TokenStorageService _storageService = TokenStorageService();
  late AuthService _authService;
  late InvitationService _invitationService;
  late Future<DashboardPersonnelResponse> _dashboardData;
  int? _currentUserId;
  String? _authToken;
  DashboardPersonnelResponse? _currentDashboardData;
  bool _isSessionReady = false;
  String? _sessionError;

  @override
  void initState() {
    super.initState();
    _loadUserSession();
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  int? _decodeJwtGetUserId(String token) {
    if (token.isEmpty) return null;
    try {
      final parts = token.split('.');
      if (parts.length != 3) return null;
      String payload = parts[1].replaceAll('-', '+').replaceAll('_', '/');
      while (payload.length % 4 != 0) payload += '=';
      final decodedPayload = utf8.decode(base64Url.decode(payload));
      final Map<String, dynamic> payloadMap = jsonDecode(decodedPayload);
      if (payloadMap.containsKey('userId')) {
        return payloadMap['userId'] is String
            ? int.tryParse(payloadMap['userId'])
            : payloadMap['userId'] as int?;
      }
      if (payloadMap.containsKey('sub')) {
        return payloadMap['sub'] is String
            ? int.tryParse(payloadMap['sub'])
            : payloadMap['sub'] as int?;
      }
      return null;
    } catch (e) {
      print("Erreur de décodage JWT: $e");
      return null;
    }
  }

  Future<void> _loadUserSession() async {
    try {
      final String? token = await _storageService.getAuthToken();
      if (mounted) {
        _authToken = token;
        _currentDashboardData = null;
        if (_authToken != null && _authToken!.isNotEmpty) {
          _currentUserId = _decodeJwtGetUserId(_authToken!);
          if (_currentUserId != null) {
            _authService = AuthService(authToken: _authToken!);
            _invitationService = InvitationService(_authToken!);
            _dashboardData = _authService.fetchPersonnelDashboard();
            setState(() => _isSessionReady = true);
          } else {
            setState(() {
              _sessionError = "Jeton invalide ou ID utilisateur manquant.";
              _isSessionReady = true;
            });
          }
        } else {
          setState(() {
            _sessionError = "Jeton manquant. Veuillez vous connecter.";
            _isSessionReady = true;
          });
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _sessionError = "Erreur de session: ${e.toString()}";
          _isSessionReady = true;
        });
      }
    }
  }

  void _acceptInvitation(String invitationId) async {
    if (_authToken == null || !_isSessionReady || _currentDashboardData == null) {
      _showSnackbar("Session invalide.", color: Colors.red);
      return;
    }
    _showSnackbar('Acceptation en cours...', color: Colors.blue.shade400);
    try {
      await _invitationService.acceptInvitation(invitationId: invitationId);
      if (mounted) {
        ScaffoldMessenger.of(context).hideCurrentSnackBar();
        _showSnackbar('Invitation acceptée !', color: Colors.green);
        setState(() {
          final idx = _currentDashboardData!.invitationsEnAttente.indexWhere((inv) => inv.id.toString() == invitationId);
          if (idx != -1) {
            final updated = _currentDashboardData!.invitationsEnAttente[idx].copyWith(statut: 'ACCEPTEE');
            _currentDashboardData!.invitationsEnAttente[idx] = updated;
            _currentDashboardData = _currentDashboardData!.copyWith(
              nombreInvitationsEnAttente: _currentDashboardData!.nombreInvitationsEnAttente - 1,
              nombreFamillesAppartenance: _currentDashboardData!.nombreFamillesAppartenance + 1,
            );
          }
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
    if (_authToken == null || !_isSessionReady || _currentDashboardData == null) {
      _showSnackbar("Session invalide.", color: Colors.red);
      return;
    }
    _showSnackbar('Refus en cours...', color: Colors.blueGrey);
    try {
      await _invitationService.refuseInvitation(invitationId: invitationId);
      if (mounted) {
        ScaffoldMessenger.of(context).hideCurrentSnackBar();
        _showSnackbar('Invitation refusée.', color: Colors.orange);
        setState(() {
          final idx = _currentDashboardData!.invitationsEnAttente.indexWhere((inv) => inv.id.toString() == invitationId);
          if (idx != -1) {
            final updated = _currentDashboardData!.invitationsEnAttente[idx].copyWith(statut: 'REFUSEE');
            _currentDashboardData!.invitationsEnAttente[idx] = updated;
            _currentDashboardData = _currentDashboardData!.copyWith(
              nombreInvitationsEnAttente: _currentDashboardData!.nombreInvitationsEnAttente - 1,
            );
          }
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).hideCurrentSnackBar();
        _showSnackbar('Erreur : ${e.toString().replaceFirst('Exception: ', '')}', color: Colors.red);
      }
    }
  }

  void _showSnackbar(String message, {required Color color}) {
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: color, duration: const Duration(seconds: 5)),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (!_isSessionReady) {
      return const Scaffold(
        backgroundColor: _backgroundColor,
        body: Center(child: CircularProgressIndicator(valueColor: AlwaysStoppedAnimation<Color>(_mainAccentColor))),
      );
    }

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
                const Text('Erreur de Session', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.deepOrange)),
                const SizedBox(height: 10),
                Text(_sessionError!, textAlign: TextAlign.center, style: const TextStyle(color: _cardTextColor, fontSize: 16)),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () async {
                    await AuthService().logout();
                    if (mounted) {
                      Navigator.of(context).pushAndRemoveUntil(
                        MaterialPageRoute(builder: (context) => const SplashScreen()),
                            (route) => false,
                      );
                    }
                  },
                  style: ElevatedButton.styleFrom(backgroundColor: _mainAccentColor),
                  child: const Text('Aller à la Connexion', style: TextStyle(color: Colors.white)),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return FutureBuilder<DashboardPersonnelResponse>(
      future: _dashboardData,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            backgroundColor: _backgroundColor,
            body: Center(child: CircularProgressIndicator(valueColor: AlwaysStoppedAnimation<Color>(_mainAccentColor))),
          );
        }

        if (snapshot.hasError) {
          return Scaffold(
            backgroundColor: _backgroundColor,
            appBar: AppBar(title: const Text('Erreur'), backgroundColor: _backgroundColor, elevation: 0),
            body: Center(
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.error_outline, color: Colors.red, size: 50),
                    const SizedBox(height: 10),
                    Text('Erreur: ${snapshot.error.toString().replaceFirst('Exception: ', '')}', textAlign: TextAlign.center, style: const TextStyle(color: Colors.red)),
                    const SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: () => setState(() {
                        _currentDashboardData = null;
                        _dashboardData = _authService.fetchPersonnelDashboard();
                      }),
                      style: ElevatedButton.styleFrom(backgroundColor: _mainAccentColor),
                      child: const Text('Réessayer', style: TextStyle(color: Colors.white)),
                    ),
                  ],
                ),
              ),
            ),
          );
        }

        if (snapshot.hasData) {
          if (_currentDashboardData == null) _currentDashboardData = snapshot.data!;
          final data = _currentDashboardData!;

          return Scaffold(
            backgroundColor: _backgroundColor,
            body: RefreshIndicator(
              color: _mainAccentColor,
              onRefresh: () async {
                setState(() {
                  _dashboardData = _authService.fetchPersonnelDashboard();
                  _currentDashboardData = null;
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
                    // NOUVEAU CONTAINER BLANC SANS QUIZ
                    _buildStatsContainer(context, data.nombreFamillesAppartenance, data.invitationsEnAttente.length),
                    const SizedBox(height: 30),
                    _buildSectionTitle('Famille (${data.nombreFamillesAppartenance})'),
                    const SizedBox(height: 15),
                    _buildFamilyGrid(context, data.familles),
                    const SizedBox(height: 30),
                    _buildSectionTitle('Invitation (${data.invitationsEnAttente.length})'),
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

        return const Scaffold(backgroundColor: _backgroundColor, body: Center(child: Text('Initialisation...')));
      },
    );
  }

  // ================== FAMILLE CARD (INCHANGÉE) ==================
  Widget _buildFamilyGrid(BuildContext context, List<Famille> familles) {
    return GridView.builder(
      physics: const NeverScrollableScrollPhysics(),
      shrinkWrap: true,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      itemCount: familles.length + 1,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 0.75,
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
    final bool isAdmin = famille.idCreateur == _currentUserId;

    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => HomeDashboardScreen(familyId: famille.id)),
      ),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.08), blurRadius: 8, offset: const Offset(0, 4))],
        ),
        child: Column(
          children: [
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: _mainAccentColor, width: 2),
                image: const DecorationImage(image: AssetImage('assets/images/Acceuil1.png'), fit: BoxFit.cover),
              ),
            ),
            const SizedBox(height: 12),
            Text(
              famille.nom,
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: _cardTextColor),
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text('Admin : ', style: TextStyle(fontSize: 12, color: Colors.grey[700])),
                Text(
                  isAdmin ? 'Oui' : 'Non',
                  style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: isAdmin ? Colors.green.shade700 : Colors.orange.shade700),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAddFamilyCard(BuildContext context) {
    return GestureDetector(
      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const CreateFamilyAccountScreen())),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: _mainAccentColor.withOpacity(0.5), width: 1.5),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.08), blurRadius: 8, offset: const Offset(0, 4))],
        ),
        child: const Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.add_circle_outline, color: _mainAccentColor, size: 40),
            SizedBox(height: 8),
            Text('Créer/Ajouter', textAlign: TextAlign.center, style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: _mainAccentColor)),
          ],
        ),
      ),
    );
  }

  // ================== NOUVEAU STATS CONTAINER (SANS QUIZ) ==================
  Widget _buildStatsContainer(BuildContext context, int familyCount, int invitationCount) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(20.0),
      decoration: BoxDecoration(
        color: Colors.white, // Fond blanc
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.08), blurRadius: 12, offset: const Offset(0, 6)),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _buildStatItem('Famille', Icons.group, familyCount),
          _buildStatItem('Invitations', Icons.send, invitationCount),
        ],
      ),
    );
  }

  Widget _buildStatItem(String title, IconData icon, int count) {
    return Column(
      children: [
        Icon(icon, color: _mainAccentColor, size: 36),
        const SizedBox(height: 10),
        Text(title, style: const TextStyle(color: _cardTextColor, fontWeight: FontWeight.bold, fontSize: 16)),
        const SizedBox(height: 10),
        Container(
          width: 70,
          height: 70,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: _mainAccentColor.withOpacity(0.1),
            border: Border.all(color: _mainAccentColor, width: 2),
          ),
          child: Center(
            child: Text(
              count.toString(),
              style: const TextStyle(color: _cardTextColor, fontWeight: FontWeight.bold, fontSize: 18),
            ),
          ),
        ),
      ],
    );
  }

  // ================== AUTRES WIDGETS (INCHANGÉS) ==================
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
        style: const TextStyle(color: _mainAccentColor, fontWeight: FontWeight.bold, fontSize: 16),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Align(
        alignment: Alignment.centerLeft,
        child: Text(title, style: const TextStyle(color: _cardTextColor, fontSize: 20, fontWeight: FontWeight.bold)),
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
        if (invitationsEnAttente.isEmpty) return _buildEmptyInvitationCard();
        return _buildInvitationCard(context, invitationsEnAttente[index]);
      },
    );
  }

  Widget _buildInvitationCard(BuildContext context, Invitation invitation) {
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
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 5, offset: const Offset(0, 3))],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          Icon(isPending ? Icons.send : statusIcon, color: _mainAccentColor, size: 30),
          Text(invitation.nomFamille, textAlign: TextAlign.center, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontWeight: FontWeight.bold, color: _cardTextColor)),
          _buildFamilyDetailRow('De:', invitation.nomEmetteur, isLast: false),
          _buildFamilyDetailRow('Lien:', invitation.lienParente, isLast: false),
          _buildFamilyDetailRow('Statut:', invitation.statut, isLast: false),
          _buildFamilyDetailRow('Expire le:', _formatDate(invitation.dateExpiration), isLast: true),
          const SizedBox(height: 5),
          isPending ? _buildPendingInvitationButtons(invitation.id.toString()) : _buildActionCircle(statusIcon, statusColor),
          const SizedBox(height: 5),
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
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 5, offset: const Offset(0, 3))],
      ),
      child: const Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.mail_outline, color: Colors.grey, size: 35),
          SizedBox(height: 5),
          Text('Aucune invitation en attente', textAlign: TextAlign.center, style: TextStyle(fontSize: 10, color: Colors.grey)),
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
        image: const DecorationImage(image: AssetImage('assets/images/Acceuil1.png'), fit: BoxFit.cover),
      ),
    );
  }

  Widget _buildPendingInvitationButtons(String invitationId) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        InkWell(
          onTap: () => _refuseInvitation(invitationId),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(5),
              border: Border.all(color: _cardTextColor.withOpacity(0.2)),
              boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 3, offset: const Offset(0, 2))],
            ),
            child: const Text('Refuser', style: TextStyle(fontSize: 10, color: _cardTextColor, fontWeight: FontWeight.bold)),
          ),
        ),
        InkWell(
          onTap: () => _acceptInvitation(invitationId),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
            decoration: BoxDecoration(
              color: _mainAccentColor,
              borderRadius: BorderRadius.circular(5),
              boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 3, offset: const Offset(0, 2))],
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
      decoration: BoxDecoration(shape: BoxShape.circle, color: iconColor.withOpacity(0.1)),
      child: Center(child: Icon(icon, size: 20, color: iconColor)),
    );
  }

  Widget _buildFamilyDetailRow(String label, String value, {required bool isLast}) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(fontSize: 8, color: Colors.black)),
          Text(value, style: const TextStyle(fontSize: 8, color: _cardTextColor)),
        ],
      ),
    );
  }

  Widget _buildActionContainer(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Row(
        children: [
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(right: 8.0),
              child: ElevatedButton.icon(
                onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const HomeScreen())),
                icon: const Icon(Icons.public, size: 20, color: Colors.white),
                label: const Text('Découvrir le Patrimoine', style: TextStyle(color: Colors.white, fontSize: 14)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: _chocolateColor,
                  padding: const EdgeInsets.symmetric(vertical: 15),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  elevation: 4,
                ),
              ),
            ),
          ),
          SizedBox(
            width: 150,
            child: ElevatedButton.icon(
              onPressed: () async {
                await AuthService().logout();
                if (mounted) {
                  Navigator.of(context).pushAndRemoveUntil(
                    MaterialPageRoute(builder: (context) => const SplashScreen()),
                        (route) => false,
                  );
                }
              },
              icon: const Icon(Icons.logout, size: 20, color: _mainAccentColor),
              label: const Text('Déconnexion', style: TextStyle(color: _mainAccentColor, fontSize: 14)),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 15),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                  side: const BorderSide(color: _mainAccentColor, width: 1.5),
                ),
                elevation: 4,
              ),
            ),
          ),
        ],
      ),
    );
  }
}