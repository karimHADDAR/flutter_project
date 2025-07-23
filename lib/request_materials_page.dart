import 'package:flutter/material.dart';

class RequestMaterialsPage extends StatefulWidget {
  const RequestMaterialsPage({super.key});

  @override
  State<RequestMaterialsPage> createState() => _RequestMaterialsPageState();
}

class _RequestMaterialsPageState extends State<RequestMaterialsPage> {
  final Map<String, int> quantities = {
    "Ciment": 0,
    "Briques": 0,
    "Sable": 0,
    "Gravier": 0,
    "Fer à béton": 0,
    "Planches de bois": 0,
  };

  final Map<String, String> units = {
    "Ciment": "sac de 25kg",
    "Briques": "par unité",
    "Sable": "tonne",
    "Gravier": "tonne",
    "Fer à béton": "barre 6m",
    "Planches de bois": "m²",
  };

  final TextEditingController projectNameController = TextEditingController();

  void increment(String material) {
    setState(() {
      quantities[material] = quantities[material]! + 1;
    });
  }

  void decrement(String material) {
    setState(() {
      if (quantities[material]! > 0) {
        quantities[material] = quantities[material]! - 1;
      }
    });
  }

  void _showAddMaterialDialog() {
    final nameController = TextEditingController();
    final unitController = TextEditingController();
    final quantityController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Ajouter un matériau"),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: nameController,
                  decoration:
                      const InputDecoration(labelText: "Nom du matériau"),
                ),
                TextField(
                  controller: unitController,
                  decoration: const InputDecoration(labelText: "Unité"),
                ),
                TextField(
                  controller: quantityController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(labelText: "Quantité initiale"),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Annuler"),
            ),
            ElevatedButton(
              onPressed: () {
                final name = nameController.text.trim();
                final unit = unitController.text.trim();
                final quantity = int.tryParse(quantityController.text) ?? 0;

                if (name.isNotEmpty && unit.isNotEmpty) {
                  setState(() {
                    quantities[name] = quantity;
                    units[name] = unit;
                  });
                  Navigator.pop(context);
                }
              },
              child: const Text("Ajouter"),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFB),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: ListView(
            children: [
              /// Header
              Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back),
                    onPressed: () => Navigator.pop(context),
                  ),
                  const SizedBox(width: 8),
                  const Text(
                    "Demander des Matériaux",
                    style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              const Text(
                "Sélectionnez les matériaux nécessaires pour votre projet",
                style: TextStyle(color: Colors.grey),
              ),
              const SizedBox(height: 20),

              /// Materials title + Add button
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: const [
                      Icon(Icons.inventory),
                      SizedBox(width: 8),
                      Text(
                        "Matériaux Disponibles",
                        style: TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 16),
                      ),
                    ],
                  ),
                  TextButton.icon(
                    onPressed: _showAddMaterialDialog,
                    icon: const Icon(Icons.add),
                    label: const Text("Ajouter"),
                  ),
                ],
              ),
              const SizedBox(height: 8),

              /// Material cards
              ...quantities.keys.map((material) {
                return Card(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 8),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(material,
                            style: const TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 16)),
                        Text(units[material] ?? '',
                            style: const TextStyle(color: Colors.grey)),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                IconButton(
                                  onPressed: () => decrement(material),
                                  icon: const Icon(Icons.remove),
                                ),
                                Text(
                                  '${quantities[material]}',
                                  style: const TextStyle(fontSize: 18),
                                ),
                                IconButton(
                                  onPressed: () => increment(material),
                                  icon: const Icon(Icons.add),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              }),

              const SizedBox(height: 20),

              /// Résumé section
              const Text(
                "Résumé Sélection",
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              const SizedBox(height: 10),
              Card(
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
                color: Colors.grey.shade100,
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Builder(
                    builder: (context) {
                      final selectedItems = quantities.entries
                          .where((entry) => entry.value > 0)
                          .toList();

                      if (selectedItems.isEmpty) {
                        return const Text(
                          "Aucun matériau sélectionné",
                          style: TextStyle(color: Colors.grey),
                        );
                      }

                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: selectedItems
                            .map((entry) => Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      entry.key,
                                      style: const TextStyle(
                                          fontWeight: FontWeight.w500),
                                    ),
                                    Text(
                                        "${entry.value} ${units[entry.key] ?? ''}"),
                                  ],
                                ))
                            .toList(),
                      );
                    },
                  ),
                ),
              ),

              const SizedBox(height: 20),

              /// Project info
              const Text(
                "Informations Projet",
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: projectNameController,
                decoration: InputDecoration(
                  labelText: "Nom du Projet",
                  hintText: "Ex: Rénovation maison",
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),

              const SizedBox(height: 20),

              /// Submit
              ElevatedButton(
                onPressed: () {
                  // TODO: handle submission
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.lightBlueAccent,
                  minimumSize: const Size.fromHeight(48),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
                child: const Text("Envoyer la Demande",
                    style: TextStyle(color: Colors.white)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}