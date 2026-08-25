class OrderItem {
  final String name;
  final String sku;
  final int quantity;
  final double unitPrice;

  const OrderItem({
    required this.name,
    required this.sku,
    required this.quantity,
    required this.unitPrice,
  });
}

/// What the UI collects before asking the backend to open a Tamara
/// checkout session. Currency/country should match what your Tamara
/// merchant account is configured for (e.g. SAR / SA).
class CheckoutRequest {
  final String referenceOrderId;
  final double totalAmount;
  final String currency;
  final String countryCode;
  final List<OrderItem> items;
  final String customerFirstName;
  final String customerLastName;
  final String customerPhone;
  final String customerEmail;

  const CheckoutRequest({
    required this.referenceOrderId,
    required this.totalAmount,
    required this.currency,
    required this.countryCode,
    required this.items,
    required this.customerFirstName,
    required this.customerLastName,
    required this.customerPhone,
    required this.customerEmail,
  });
}

enum OrderStatus { approved, declined, expired, canceled, pending, unknown }

class OrderStatusResult {
  final String orderId;
  final OrderStatus status;

  const OrderStatusResult({required this.orderId, required this.status});
}
