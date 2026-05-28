class OrderItemModel {
  final int id;
  final int productId;
  final String productName;
  final int quantity;
  final double price;

  OrderItemModel({
    required this.id,
    required this.productId,
    required this.productName,
    required this.quantity,
    required this.price,
  });

  factory OrderItemModel.fromJson(Map<String, dynamic> json) {
    return OrderItemModel(
      id: json['id'] ?? 0,
      productId: json['productId'] ?? 0,
      productName: json['productName'] ?? '',
      quantity: json['quantity'] ?? 0,
      price: (json['price'] ?? 0.0).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'productId': productId,
      'productName': productName,
      'quantity': quantity,
      'price': price,
    };
  }
}

class OrderModel {
  final int id;
  final String createdAt;
  final int customerId;
  final String customerMobile;
  final String customerName;
  final List<OrderItemModel> items;
  final int salonId;
  final String status;
  final double totalAmount;

  OrderModel({
    required this.id,
    required this.createdAt,
    required this.customerId,
    required this.customerMobile,
    required this.customerName,
    required this.items,
    required this.salonId,
    required this.status,
    required this.totalAmount,
  });

  factory OrderModel.fromJson(Map<String, dynamic> json) {
    return OrderModel(
      id: json['id'] ?? 0,
      createdAt: json['createdAt'] ?? '',
      customerId: json['customerId'] ?? 0,
      customerMobile: json['customerMobile'] ?? '',
      customerName: json['customerName'] ?? '',
      items: (json['items'] as List?)
              ?.map((item) => OrderItemModel.fromJson(item))
              .toList() ??
          [],
      salonId: json['salonId'] ?? 0,
      status: json['status'] ?? 'pending',
      totalAmount: (json['totalAmount'] ?? 0.0).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'createdAt': createdAt,
      'customerId': customerId,
      'customerMobile': customerMobile,
      'customerName': customerName,
      'items': items.map((item) => item.toJson()).toList(),
      'salonId': salonId,
      'status': status,
      'totalAmount': totalAmount,
    };
  }
}
