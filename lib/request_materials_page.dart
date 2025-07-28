import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class MaterialRequestItem {
  final String materialName;
  final int quantity;
  final String unit;

  MaterialRequestItem({
    required this.materialName,
    required this.quantity,
    required this.unit,
  });

  Map<String, dynamic> toJson() {
    return {
      'materialName': materialName,
      'quantity': quantity,
      'unit': unit,
    };
  }
}

class MaterialRequest {
  final String projectName;
  final bool approved;
  final String requestedBy;
  final List<MaterialRequestItem> items;

  MaterialRequest({
    required this.projectName,
    required this.requestedBy,
    required this.items,
    this.approved = false,
  });

  Map<String, dynamic> toJson() {
    return {
      'projectName': projectName,
      'approved': approved,
      'requestedBy': requestedBy,
      'items': items.map((item) => item.toJson()).toList(),
    };
  }
}

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
  final TextEditingController requestedByController = TextEditingController();

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
                  decoration: const InputDecoration(labelText: "Nom du matériau"),
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

  Future<void> _handleSubmit() async {
    final projectName = projectNameController.text.trim();
    final requestedBy = requestedByController.text.trim();

    if (projectName.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Veuillez entrer un nom de projet.")),
      );
      return;
    }

    if (requestedBy.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Veuillez entrer le nom du demandeur.")),
      );
      return;
    }

    final selectedItems = quantities.entries
        .where((entry) => entry.value > 0)
        .map((entry) => MaterialRequestItem(
              materialName: entry.key,
              quantity: entry.value,
              unit: units[entry.key] ?? '',
            ))
        .toList();

    if (selectedItems.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Veuillez sélectionner au moins un matériau.")),
      );
      return;
    }

    final materialRequest = MaterialRequest(
      projectName: projectName,
      requestedBy: requestedBy,
      approved: false,
      items: selectedItems,
    );

    try {
      final response = await http.post(
        Uri.parse('http://10.0.2.2:8080/api/material-requests'), // Replace with your IP
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(materialRequest.toJson()),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final summary = {
          'projectName': projectName,
          'requestedBy': requestedBy,
          'items': selectedItems.map((item) => {
            'materialName': item.materialName,
            'quantity': item.quantity,
            'unit': item.unit,
          }).toList(),
          'status': 'En cours de traitement',
        };
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Demande envoyée avec succès.")),
        );
        Navigator.pop(context, summary); // Return summary to HomePage
      } else {
        print("Erreur ${response.statusCode}: ${response.body}");
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Erreur: ${response.statusCode}")),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Erreur lors de l'envoi: $e")),
      );
    }
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

              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: const [
                      Icon(Icons.inventory),
                      SizedBox(width: 8),
                      Text(
                        "Matériaux Disponibles",
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
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

              ...quantities.keys.map((material) {
                return Card(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
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
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(entry.key,
                                        style: const TextStyle(
                                            fontWeight: FontWeight.w500)),
                                    Text("${entry.value} ${units[entry.key] ?? ''}"),
                                  ],
                                ))
                            .toList(),
                      );
                    },
                  ),
                ),
              ),

              const SizedBox(height: 20),

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
              const SizedBox(height: 10),
              TextField(
                controller: requestedByController,
                decoration: InputDecoration(
                  labelText: "Nom du Demandeur",
                  hintText: "Ex: John Doe",
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),

              const SizedBox(height: 20),

              ElevatedButton(
                onPressed: _handleSubmit,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.lightBlueAccent,
                  minimumSize: const Size.fromHeight(48),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
                child: const Text(
                  "Envoyer la Demande",
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
