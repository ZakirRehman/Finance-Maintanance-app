class OrderModel {
  final String id;
  final String userId;
  final String customerName;
  final String? customerPhone;
  final String orderType;
  final String? description;
  final String? customInstructions;
  final double totalPrice;
  final double advancePayment;
  final double remainingPayment;
  final String status;
  final DateTime? deliveryDate;
  final DateTime createdAt;

  OrderModel({
    required this.id,
    required this.userId,
    required this.customerName,
    this.customerPhone,
    required this.orderType,
    this.description,
    this.customInstructions,
    required this.totalPrice,
    this.advancePayment = 0,
    required this.remainingPayment,
    required this.status,
    this.deliveryDate,
    required this.createdAt,
  });

  factory OrderModel.fromJson(Map<String, dynamic> json) {
    return OrderModel(
      id: json['id'],
      userId: json['user_id'],
      customerName: json['customer_name'],
      customerPhone: json['customer_phone'],
      orderType: json['order_type'],
      description: json['description'],
      customInstructions: json['custom_instructions'],
      totalPrice: (json['total_price'] as num).toDouble(),
      advancePayment: (json['advance_payment'] as num).toDouble(),
      remainingPayment: (json['remaining_payment'] as num).toDouble(),
      status: json['status'],
      deliveryDate: json['delivery_date'] != null ? DateTime.parse(json['delivery_date']) : null,
      createdAt: DateTime.parse(json['created_at']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'customer_name': customerName,
      'customer_phone': customerPhone,
      'order_type': orderType,
      'description': description,
      'custom_instructions': customInstructions,
      'total_price': totalPrice,
      'advance_payment': advancePayment,
      'remaining_payment': remainingPayment,
      'status': status,
      'delivery_date': deliveryDate?.toIso8601String(),
    };
  }
}
