/// What the domain layer needs to drive the checkout widget.
/// This is built from your backend's response, not from Tamara's SDK
/// models directly — keeps the domain layer independent of the SDK.
class CheckoutSession {
  final String orderId;
  final String checkoutUrl;
  final String successUrl;
  final String failedUrl;
  final String canceledUrl;

  const CheckoutSession({
    required this.orderId,
    required this.checkoutUrl,
    required this.successUrl,
    required this.failedUrl,
    required this.canceledUrl,
  });
}
