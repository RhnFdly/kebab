import 'package:cloud_firestore/cloud_firestore.dart';
import 'cart_item_model.dart';

enum OrderStatus {
  pending,
  process,
  delivered,
  cancelled,
}

class Order {
  final String id;
  final String userId;
  final List<CartItem> items;
  final double totalPrice;
  final String address;
  final String phoneNumber;
  final String paymentMethod;
  final OrderStatus status;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final String? trackingNumber;

  Order({
    required this.id,
    required this.userId,
    required this.items,
    required this.totalPrice,
    required this.address,
    required this.phoneNumber,
    required this.paymentMethod,
    required this.status,
    required this.createdAt,
    this.updatedAt,
    this.trackingNumber,
  });

  String get statusString {
    switch (status) {
      case OrderStatus.pending:
        return 'Pending';
      case OrderStatus.process:
        return 'Processing';
      case OrderStatus.delivered:
        return 'Delivered';
      case OrderStatus.cancelled:
        return 'Cancelled';
    }
  }

  factory Order.fromJson(Map<String, dynamic> json) {
    DateTime parseDate(dynamic value) {
      if (value == null) return DateTime.now();
      if (value is Timestamp) return value.toDate();
      if (value is String) return DateTime.parse(value);
      if (value is DateTime) return value;
      return DateTime.now();
    }

    return Order(
      id: json['id'] ?? '',
      userId: json['userId'] ?? '',
      items: (json['items'] as List<dynamic>?)
              ?.map((item) => CartItem.fromJson(item))
              .toList() ??
          [],
      totalPrice: (json['totalPrice'] ?? 0).toDouble(),
      address: json['address'] ?? '',
      phoneNumber: json['phoneNumber'] ?? '',
      paymentMethod: json['paymentMethod'] ?? '',
      status: OrderStatus.values.firstWhere(
        (e) => e.toString().split('.').last == json['status'],
        orElse: () => OrderStatus.pending,
      ),
      createdAt: parseDate(json['createdAt']),
      updatedAt: json['updatedAt'] != null ? parseDate(json['updatedAt']) : null,
      trackingNumber: json['trackingNumber'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'items': items.map((item) => item.toJson()).toList(),
      'totalPrice': totalPrice,
      'ahoneNumber': phoneNumber,
      'pddress': address,
      'paymentMethod': paymentMethod,
      'status': status.toString().split('.').last,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': updatedAt != null ? Timestamp.fromDate(updatedAt!) : null,
      'trackingNumber': trackingNumber,
    };
  }
}
