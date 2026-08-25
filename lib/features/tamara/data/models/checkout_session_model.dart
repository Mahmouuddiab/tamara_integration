import '../../domain/entities/checkout_session.dart';

/// Shape of the response from YOUR backend endpoint that wraps
/// Tamara's Checkout API (e.g. POST /payments/tamara/checkout-session).
/// Adjust field names to match whatever your backend actually returns.
class CheckoutSessionModel extends CheckoutSession {
  const CheckoutSessionModel({
    required super.orderId,
    required super.checkoutUrl,
    required super.successUrl,
    required super.failedUrl,
    required super.canceledUrl,
  });

  factory CheckoutSessionModel.fromJson(Map<String, dynamic> json) {
    return CheckoutSessionModel(
      orderId: json['order_id'] as String,
      checkoutUrl: json['checkout_url'] as String,
      successUrl: json['success_url'] as String,
      failedUrl: json['failed_url'] as String,
      canceledUrl: json['canceled_url'] as String,
    );
  }
}
