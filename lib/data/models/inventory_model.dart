class InventoryModel {
  final String id;
  final String userId;
  final String itemName;
  final int quantity;
  final double costPerUnit;
  final String? supplierName;
  final int lowStockLimit;
  final DateTime updatedAt;

  InventoryModel({
    required this.id,
    required this.userId,
    required this.itemName,
    required this.quantity,
    required this.costPerUnit,
    this.supplierName,
    this.lowStockLimit = 5,
    required this.updatedAt,
  });

  factory InventoryModel.fromJson(Map<String, dynamic> json) {
    return InventoryModel(
      id: json['id'],
      userId: json['user_id'],
      itemName: json['item_name'],
      quantity: json['quantity'],
      costPerUnit: (json['cost_per_unit'] as num).toDouble(),
      supplierName: json['supplier_name'],
      lowStockLimit: json['low_stock_limit'] ?? 5,
      updatedAt: DateTime.parse(json['updated_at']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'item_name': itemName,
      'quantity': quantity,
      'cost_per_unit': costPerUnit,
      'supplier_name': supplierName,
      'low_stock_limit': lowStockLimit,
    };
  }
}
