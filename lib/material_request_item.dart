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
