import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import 'request_materials_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  bool showMenu = false;
  List<Map<String, dynamic>> projects = [];
  List<Map<String, dynamic>> demandes = [];

  String? username;
  List<String> roles = [];
  String? userData;

  void toggleMenu() {
    setState(() {
      showMenu = !showMenu;
    });
  }

  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
    Navigator.pushReplacementNamed(context, '/login');
  }

  Future<void> loadUserInfo() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');
    final name = prefs.getString('username');
    final roleList = prefs.getStringList('roles');

    if (token == null) {
      logout();
      return;
    }

    setState(() {
      username = name ?? "Utilisateur";
      roles = roleList ?? [];
    });

    try {
      final response = await http.get(
        Uri.parse('http://10.0.2.2:8080/api/test/pdg'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        setState(() {
          userData = response.body;
        });
      } else {
        setState(() {
          userData = 'Accès non autorisé ou erreur de serveur.';
        });
      }
    } catch (e) {
      setState(() {
        userData = 'Erreur de connexion à l’API sécurisée.';
      });
    }
  }

  @override
  void initState() {
    super.initState();
    loadUserInfo();
  }

  void saveDemande(Map<String, dynamic> demande) {
    setState(() {
      demandes.add(demande);
    });
  }

  void toggleApproval(int index) {
    setState(() {
      final currentStatus = demandes[index]['approved'] ?? false;
      demandes[index]['approved'] = !currentStatus;
    });
  }

  bool get isValidator {
    return roles.any((r) =>
        r.contains("Directeur des achats") || r.contains("Responsable des achats"));
  }

  Widget _buildDemandeList() {
    if (demandes.isEmpty) return const SizedBox();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 30),
        const Text(
          'Demandes en cours :',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 10),
        ...demandes.map((demande) => Card(
          child: ListTile(
            leading: const Icon(Icons.hourglass_top, color: Colors.orange),
            title: Text('Projet : ${demande['projectName']}'),
            subtitle: Text(
              'Demandé par : ${demande['requestedBy'] ?? ''}\n'
              'Matériaux : ${(demande['items'] as List).map((item) => '${item['materialName']} (${item['quantity']} ${item['unit']})').join(', ')}\n'
              'Statut : ${demande['status'] ?? 'En cours de traitement'}',
            ),
          ),
        )),
      ],
    );
  }

  Widget buildRoleBasedContent() {
    if (roles.contains('PDG')) {
      return Column(
        children: [
          const SizedBox(height: 20),
          Text(
            'Bienvenue, PDG 👑',
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 10),
          Text(userData ?? 'Chargement des données...'),
        ],
      );
    }

    if (roles.contains('DEMANDEUR')) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildFeatureCard(
            icon: Icons.build,
            iconBgColor: Colors.orange.shade50,
            iconColor: Colors.orange,
            title: 'Demander des Matériaux',
            description: 'Commandez facilement les matériaux nécessaires.',
            buttonColor: Colors.orange,
            onPressed: () async {
              final result = await Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => const RequestMaterialsPage()),
              );
              print('Returned result: $result'); // <-- Add this line
              if (result != null && result is Map<String, dynamic>) {
                setState(() {
                  demandes.add(result);
                });
              }
            },
          ),
          // Add the summary/resume list here for Demandeur
          _buildDemandeList(),
        ],
      );
    }

    return const SizedBox();
  }

  Widget _buildFeatureCard({
    required IconData icon,
    required Color iconBgColor,
    required Color iconColor,
    required String title,
    required String description,
    required Color buttonColor,
    required VoidCallback onPressed,
  }) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 4,
      margin: const EdgeInsets.only(bottom: 20),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  decoration: BoxDecoration(
                    color: iconBgColor,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  padding: const EdgeInsets.all(8),
                  child: Icon(icon, color: iconColor, size: 24),
                ),
                const SizedBox(width: 12),
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              description,
              style: const TextStyle(
                color: Colors.black54,
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: buttonColor,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                onPressed: onPressed,
                child: const Text(
                  'Commencer',
                  style: TextStyle(color: Colors.white),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 245, 242, 242),
      body: Stack(
        children: [
          SafeArea(
            child: Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 16.0, vertical: 20.0),
              child: ListView(
                children: [
                  const SizedBox(height: 50),
                  Text(
                    'Bienvenue, ${username ?? "..."} 👷‍♂️',
                    style: const TextStyle(
                      color: Colors.black87,
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  if (roles.isNotEmpty)
                    Text(
                      'Rôle : ${roles.join(", ")}',
                      style: const TextStyle(
                        color: Colors.black54,
                        fontSize: 14,
                      ),
                    ),
                  const SizedBox(height: 30),
                  buildRoleBasedContent(),
                ],
              ),
            ),
          ),
          if (showMenu)
            Positioned(
              top: 0,
              left: 0,
              bottom: 0,
              child: Container(
                width: 200,
                color: Colors.black.withOpacity(0.7),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 120),
                    ListTile(
                      leading: const Icon(Icons.person, color: Colors.white),
                      title: const Text("Profil",
                          style: TextStyle(color: Colors.white)),
                      onTap: toggleMenu,
                    ),
                    ListTile(
                      leading: const Icon(Icons.logout, color: Colors.white),
                      title: const Text("Déconnexion",
                          style: TextStyle(color: Colors.white)),
                      onTap: logout,
                    ),
                  ],
                ),
              ),
            ),
          Positioned(
            top: 20,
            left: 16,
            child: SafeArea(
              child: GestureDetector(
                onTap: toggleMenu,
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: const BoxDecoration(
                    color: Colors.white70,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.menu,
                    color: Colors.black87,
                    size: 28,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
