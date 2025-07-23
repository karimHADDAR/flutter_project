import 'package:flutter/material.dart';

class AddProjectPage extends StatefulWidget {
  const AddProjectPage({super.key});

  @override
  State<AddProjectPage> createState() => _AddProjectPageState();
}

class _AddProjectPageState extends State<AddProjectPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController projectNameController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();

  List<String> materials = [];

  void _submitProject() {
    if (_formKey.currentState!.validate()) {
      final project = {
        'name': projectNameController.text,
        'description': descriptionController.text,
        'materials': materials,
      };

      Navigator.pop(context, project); // Return data to HomePage
    }
  }

  void _addMaterial() async {
    final TextEditingController materialController = TextEditingController();

    await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Ajouter un Matériau'),
          content: TextField(
            controller: materialController,
            decoration: const InputDecoration(hintText: "Nom du matériau"),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Annuler"),
            ),
            ElevatedButton(
              onPressed: () {
                if (materialController.text.trim().isNotEmpty) {
                  setState(() {
                    materials.add(materialController.text.trim());
                  });
                }
                Navigator.pop(context);
              },
              child: const Text("Ajouter"),
            ),
          ],
        );
      },
    );
  }

  @override
  void dispose() {
    projectNameController.dispose();
    descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 2,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black87),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          "ChantierGO",
          style: TextStyle(color: Colors.black87, fontWeight: FontWeight.bold),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text("Ajouter un Projet", style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
              const SizedBox(height: 12),
              const Text("Créez un nouveau projet et organisez vos matériaux", style: TextStyle(color: Colors.grey)),
              const SizedBox(height: 24),

              // Project details card
              Card(
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                elevation: 3,
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text("Détails du Projet", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 16),
                      const Text("Nom du Projet *"),
                      const SizedBox(height: 6),
                      TextFormField(
                        controller: projectNameController,
                        validator: (value) => value!.isEmpty ? "Nom requis" : null,
                        decoration: InputDecoration(
                          hintText: "Ex: Routes de Oyem",
                          filled: true,
                          fillColor: const Color(0xFFF1F3F5),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide.none),
                        ),
                      ),
                      const SizedBox(height: 16),
                      const Text("Description"),
                      const SizedBox(height: 6),
                      TextFormField(
                        controller: descriptionController,
                        maxLines: 4,
                        decoration: InputDecoration(
                          hintText: "Décrivez brièvement votre projet...",
                          filled: true,
                          fillColor: const Color(0xFFF1F3F5),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide.none),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // Material section
              Card(
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                elevation: 3,
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          const Expanded(
                            child: Text("Demandes de Matériaux", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                          ),
                          ElevatedButton.icon(
                            icon: const Icon(Icons.add, size: 16),
                            label: const Text("Ajouter Matériau"),
                            onPressed: _addMaterial,
                            style: ElevatedButton.styleFrom(
                              foregroundColor: Colors.white,
                              backgroundColor: Colors.blue.shade700,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      if (materials.isEmpty)
                        const Text('Aucune demande de matériau.', style: TextStyle(color: Colors.grey))
                      else
                        Column(
                          children: materials
                              .map((mat) => ListTile(
                                    title: Text(mat),
                                    trailing: IconButton(
                                      icon: const Icon(Icons.delete),
                                      onPressed: () {
                                        setState(() {
                                          materials.remove(mat);
                                        });
                                      },
                                    ),
                                  ))
                              .toList(),
                        ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  OutlinedButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text("Annuler"),
                  ),
                  const SizedBox(width: 16),
                  ElevatedButton(
                    onPressed: _submitProject,
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.blue),
                    child: const Text("Créer le Projet"),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}