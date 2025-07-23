import 'package:flutter/material.dart';
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

  void toggleMenu() {
    setState(() {
      showMenu = !showMenu;
    });
  }

  // You can replace this with your actual logout logic (e.g. clear token, etc.)
  void logout() {
    // TODO: Clear stored token/session here if you use one
    Navigator.pushReplacementNamed(context, '/login');
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
                  'Get Started',
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
                  color: latestProject == null ? Colors.black54 : Colors.black87,
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
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 50),
                  const Text(
                    'bienvenue à ChantierGO!',
                    style: TextStyle(
                      color: Colors.black87,
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 30),

                  _buildLatestProjectCard(),

                  _buildFeatureCard(
                    icon: Icons.apartment,
                    iconBgColor: Colors.blue.shade50,
                    iconColor: Colors.blue.shade800,
                    title: 'Ajouter un Projet',
                    description:
                        'Créez un nouveau projet de construction et gérez tous les aspects de votre chantier en un seul endroit.',
                    buttonColor: Colors.blue,
                    onPressed: () async {
                      final result = await Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => const AddProjectPage()),
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
                    description:
                        'Commandez facilement les matériaux de construction dont vous avez besoin pour vos projets.',
                    buttonColor: Colors.orange,
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => const RequestMaterialsPage()),
                      );
                    },
                  ),

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
                      title:
                          const Text("Profile", style: TextStyle(color: Colors.white)),
                      onTap: toggleMenu,
                    ),
                    ListTile(
                      leading: const Icon(Icons.shopping_cart, color: Colors.white),
                      title: const Text("Ongoing Orders",
                          style: TextStyle(color: Colors.white)),
                      onTap: toggleMenu,
                    ),
                    const Spacer(),
                    ListTile(
                      leading: const Icon(Icons.logout, color: Colors.white),
                      title: const Text("Logout", style: TextStyle(color: Colors.white)),
                      onTap: () {
                        logout();
                      },
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
                  decoration: BoxDecoration(
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