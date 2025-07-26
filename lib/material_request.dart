import 'material_request_item.dart';

class MaterialRequest {
  final String projectName;
  final bool approved;
  final List<MaterialRequestItem> items;

  MaterialRequest({
    required this.projectName,
    required this.items,
    this.approved = false,
  });

  Map<String, dynamic> toJson() {
    return {
      'projectName': projectName,
      'approved': approved,
      'items': items.map((item) => item.toJson()).toList(),
    };
  }
}
