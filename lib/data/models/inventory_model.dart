enum UnitType {
  PIECE,
  ML,
  LITER,
  KG,
  GRAM,
  BOTTLE,
}

enum ProductType {
  consumable,
  tool,
  equipment,
  chemical,
  cosmetic,
  accessory,
  retail,
  supply,
}

class InventoryRequest {
  final String name;
  final ProductType? category;
  final ProductType? productType;
  final int currentStock;
  final int? reorderLevel;
  final double costPrice;
  final UnitType unitType;
  final double? unitSize;
  final String? unitLabel;
  final String? imageBase64;

  InventoryRequest({
    required this.name,
    this.category,
    this.productType,
    required this.currentStock,
    this.reorderLevel,
    required this.costPrice,
    required this.unitType,
    this.unitSize,
    this.unitLabel,
    this.imageBase64,
  });

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'category': category?.name,
      'productType': productType?.name,
      'currentStock': currentStock,
      'reorderLevel': reorderLevel,
      'costPrice': costPrice,
      'unitType': unitType.name,
      'unitSize': unitSize,
      'unitLabel': unitLabel,
      'imageBase64': imageBase64,
    };
  }
}

class InventoryResponse {
  final int id;
  final int? salonId;
  final String name;
  final ProductType? category;
  final ProductType? productType;
  final int currentStock;
  final int? reorderLevel;
  final double costPrice;
  final UnitType unitType;
  final double? unitSize;
  final String? unitLabel;
  final double? totalConsumed;
  final String? imageBase64;
  final DateTime? createdAt;

  InventoryResponse({
    required this.id,
    this.salonId,
    required this.name,
    this.category,
    this.productType,
    required this.currentStock,
    this.reorderLevel,
    required this.costPrice,
    required this.unitType,
    this.unitSize,
    this.unitLabel,
    this.totalConsumed,
    this.imageBase64,
    this.createdAt,
  });

  InventoryResponse copyWith({
    int? id,
    int? salonId,
    String? name,
    ProductType? category,
    ProductType? productType,
    int? currentStock,
    int? reorderLevel,
    double? costPrice,
    UnitType? unitType,
    double? unitSize,
    String? unitLabel,
    double? totalConsumed,
    String? imageBase64,
    DateTime? createdAt,
  }) {
    return InventoryResponse(
      id: id ?? this.id,
      salonId: salonId ?? this.salonId,
      name: name ?? this.name,
      category: category ?? this.category,
      productType: productType ?? this.productType,
      currentStock: currentStock ?? this.currentStock,
      reorderLevel: reorderLevel ?? this.reorderLevel,
      costPrice: costPrice ?? this.costPrice,
      unitType: unitType ?? this.unitType,
      unitSize: unitSize ?? this.unitSize,
      unitLabel: unitLabel ?? this.unitLabel,
      totalConsumed: totalConsumed ?? this.totalConsumed,
      imageBase64: imageBase64 ?? this.imageBase64,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  factory InventoryResponse.fromJson(Map<String, dynamic> json) {
    return InventoryResponse(
      id: json['id'],
      salonId: json['salonId'],
      name: json['name'],
      category: json['category'] != null
          ? ProductType.values.firstWhere(
              (e) => e.name == json['category'],
              orElse: () => ProductType.consumable,
            )
          : null,
      productType: json['productType'] != null
          ? ProductType.values.firstWhere(
              (e) => e.name == json['productType'],
              orElse: () => ProductType.consumable,
            )
          : null,
      currentStock: json['currentStock'],
      reorderLevel: json['reorderLevel'],
      costPrice: (json['costPrice'] as num).toDouble(),
      unitType: UnitType.values.firstWhere(
        (e) => e.name == json['unitType'],
        orElse: () => UnitType.PIECE,
      ),
      unitSize: json['unitSize'] != null ? (json['unitSize'] as num).toDouble() : null,
      unitLabel: json['unitLabel'],
      totalConsumed: json['totalConsumed'] != null ? (json['totalConsumed'] as num).toDouble() : null,
      imageBase64: json['imageBase64'],
      createdAt: json['createdAt'] != null ? DateTime.parse(json['createdAt']) : null,
    );
  }
}

class StaffInventoryRequest {
  final int staffId;
  final int inventoryId;
  final double allocatedQuantity;
  final String assignedBy;
  final String? notes;

  StaffInventoryRequest({
    required this.staffId,
    required this.inventoryId,
    required this.allocatedQuantity,
    this.assignedBy = 'Owner',
    this.notes,
  });

  Map<String, dynamic> toJson() {
    return {
      'staffId': staffId,
      'inventoryId': inventoryId,
      'allocatedQuantity': allocatedQuantity,
      'assignedBy': assignedBy,
      'notes': notes,
    };
  }
}

class StaffInventoryResponse {
  final int id;
  final int staffId;
  final String? staffName;
  final int inventoryId;
  final String? inventoryName;
  final double allocatedQuantity;
  final double? remainingQuantity;
  final DateTime? assignedAt;
  final String? assignedBy;
  final String? notes;
  final double? usedQuantity;
  final int? appointmentCount;

  StaffInventoryResponse({
    required this.id,
    required this.staffId,
    this.staffName,
    required this.inventoryId,
    this.inventoryName,
    required this.allocatedQuantity,
    this.remainingQuantity,
    this.assignedAt,
    this.assignedBy,
    this.notes,
    this.usedQuantity,
    this.appointmentCount,
  });

  factory StaffInventoryResponse.fromJson(Map<String, dynamic> json) {
    return StaffInventoryResponse(
      id: json['id'],
      staffId: json['staffId'],
      staffName: json['staffName'],
      inventoryId: json['inventoryId'],
      inventoryName: json['inventoryName'],
      allocatedQuantity: (json['allocatedQuantity'] as num).toDouble(),
      remainingQuantity: json['remainingQuantity'] != null ? (json['remainingQuantity'] as num).toDouble() : null,
      assignedAt: json['assignedAt'] != null ? DateTime.parse(json['assignedAt']) : null,
      assignedBy: json['assignedBy'],
      notes: json['notes'],
      usedQuantity: json['usedQuantity'] != null ? (json['usedQuantity'] as num).toDouble() : null,
      appointmentCount: json['appointmentCount'] ?? 0,
    );
  }
}

class StaffOpenInventoryResponse {
  final int id;
  final int inventoryId;
  final String? inventoryName;
  final int staffId;
  final String? staffName;
  final double openedQuantity;
  final DateTime? openedAt;
  final DateTime? finishedAt;
  final bool isFinished;
  final String? notes;
  final int? appointmentCount;

  StaffOpenInventoryResponse({
    required this.id,
    required this.inventoryId,
    this.inventoryName,
    required this.staffId,
    this.staffName,
    required this.openedQuantity,
    this.openedAt,
    this.finishedAt,
    required this.isFinished,
    this.notes,
    this.appointmentCount,
  });

  factory StaffOpenInventoryResponse.fromJson(Map<String, dynamic> json) {
    return StaffOpenInventoryResponse(
      id: json['id'],
      inventoryId: json['inventoryId'],
      inventoryName: json['inventoryName'],
      staffId: json['staffId'],
      staffName: json['staffName'],
      openedQuantity: (json['openedQuantity'] as num).toDouble(),
      openedAt: json['openedAt'] != null ? DateTime.parse(json['openedAt']) : null,
      finishedAt: json['finishedAt'] != null ? DateTime.parse(json['finishedAt']) : null,
      isFinished: json['isFinished'] ?? false,
      notes: json['notes'],
      appointmentCount: json['appointmentCount'] ?? 0,
    );
  }
}

class InventorySwapRequestModel {
  final int id;
  final int? salonId;
  final String? productName;
  final String? toStaff;
  final double quantity;
  final String status;
  final DateTime? requestedAt;
  final DateTime? approvedAt;
  final String? requestedBy;
  final String? approvedBy;
  final String? notes;

  InventorySwapRequestModel({
    required this.id,
    this.salonId,
    this.productName,
    this.toStaff,
    required this.quantity,
    required this.status,
    this.requestedAt,
    this.approvedAt,
    this.requestedBy,
    this.approvedBy,
    this.notes,
  });

  factory InventorySwapRequestModel.fromJson(Map<String, dynamic> json) {
    return InventorySwapRequestModel(
      id: json['id'],
      salonId: json['salonId'],
      productName: json['productName'],
      toStaff: json['toStaff'],
      quantity: (json['quantity'] as num).toDouble(),
      status: json['status'] ?? 'PENDING',
      requestedAt: json['requestedAt'] != null ? DateTime.parse(json['requestedAt']) : null,
      approvedAt: json['approvedAt'] != null ? DateTime.parse(json['approvedAt']) : null,
      requestedBy: json['requestedBy'],
      approvedBy: json['approvedBy'],
      notes: json['notes'],
    );
  }
}
