import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import 'add_project_page.dart';
import 'request_materials_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  bool showMenu = false;
  List<Map<String, dynamic>> projects = [];
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

  Widget _buildLatestProjectCard() {
    final latestProject = projects.isNotEmpty ? projects.last : null;

    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 2,
      margin: const EdgeInsets.only(bottom: 20),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            Icon(
              latestProject == null ? Icons.info_outline : Icons.task_alt,
              color: latestProject == null ? Colors.grey : Colors.green,
              size: 28,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                latestProject == null
                    ? 'Aucun projet ajouté pour l’instant.'
                    : 'Dernier projet ajouté : ${latestProject['name']}',
                style: TextStyle(
                  fontSize: 16,
                  color:
                      latestProject == null ? Colors.black54 : Colors.black87,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProjectList() {
    return projects.isEmpty
        ? const SizedBox()
        : Expanded(
            child: ListView.builder(
              itemCount: projects.length,
              itemBuilder: (context, index) {
                final project = projects[index];
                return Card(
                  margin: const EdgeInsets.symmetric(vertical: 6),
                  child: ListTile(
                    leading: const Icon(Icons.business),
                    title: Text(project['name']),
                    subtitle: Text(project['description'] ?? ''),
                    trailing: Text('${project['materials'].length} matériaux'),
                  ),
                );
              },
            ),
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
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const RequestMaterialsPage()),
              );
            },
          ),
          const SizedBox(height: 20),
          const Text(
            'Résumé de votre dernière demande :',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 10),
          projects.isEmpty
              ? const Text(
                  'Aucune demande enregistrée.',
                  style: TextStyle(color: Colors.black54),
                )
              : Card(
                  margin: const EdgeInsets.only(top: 8),
                  child: Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Projet : ${projects.last['name']}',
                          style: const TextStyle(fontWeight: FontWeight.w600),
                        ),
                        const SizedBox(height: 6),
                        Text('Description : ${projects.last['description'] ?? 'N/A'}'),
                        const SizedBox(height: 6),
                        Text(
                          'Matériaux demandés : ${projects.last['materials']?.length ?? 0}',
                        ),
                      ],
                    ),
                  ),
                ),
        ],
      );
    }

    if (roles.contains('Acheteur/financier')) {
      return Column(
        children: [
          _buildFeatureCard(
            icon: Icons.apartment,
            iconBgColor: Colors.blue.shade50,
            iconColor: Colors.blue.shade800,
            title: 'Ajouter un Projet',
            description: 'Gérez les projets de construction.',
            buttonColor: Colors.blue,
            onPressed: () async {
              final result = await Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const AddProjectPage()),
              );
              if (result != null && result is Map<String, dynamic>) {
                setState(() {
                  projects.add(result);
                });
              }
            },
          ),
          _buildFeatureCard(
            icon: Icons.build,
            iconBgColor: Colors.orange.shade50,
            iconColor: Colors.orange,
            title: 'Demander des Matériaux',
            description: 'Commandez les matériaux requis.',
            buttonColor: Colors.orange,
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const RequestMaterialsPage()),
              );
            },
          ),
        ],
      );
    }

    return const Center(child: Text("Aucun rôle défini."));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 245, 242, 242),
      body: Stack(
        children: [
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
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
                  _buildLatestProjectCard(),
                  buildRoleBasedContent(),
                  const SizedBox(height: 16),
                  _buildProjectList(),
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
                      title: const Text("Profil", style: TextStyle(color: Colors.white)),
                      onTap: toggleMenu,
                    ),
                    ListTile(
                      leading: const Icon(Icons.shopping_cart, color: Colors.white),
                      title: const Text("Commandes", style: TextStyle(color: Colors.white)),
                      onTap: toggleMenu,
                    ),
                    const Spacer(),
                    ListTile(
                      leading: const Icon(Icons.logout, color: Colors.white),
                      title: const Text("Déconnexion", style: TextStyle(color: Colors.white)),
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
