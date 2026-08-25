import '../../domain/entities/checkout_request.dart';

class OrderStatusModel extends OrderStatusResult {
  const OrderStatusModel({required super.orderId, required super.status});

  factory OrderStatusModel.fromJson(Map<String, dynamic> json) {
    return OrderStatusModel(
      orderId: json['order_id'] as String,
      status: _parseStatus(json['status'] as String? ?? ''),
    );
  }

  static OrderStatus _parseStatus(String raw) {
    switch (raw.toLowerCase()) {
      case 'approved':
        return OrderStatus.approved;
      case 'declined':
        return OrderStatus.declined;
      case 'expired':
        return OrderStatus.expired;
      case 'canceled':
      case 'cancelled':
        return OrderStatus.canceled;
      case 'pending':
      case 'authorised':
      case 'authorized':
        return OrderStatus.pending;
      default:
        return OrderStatus.unknown;
    }
  }
}
