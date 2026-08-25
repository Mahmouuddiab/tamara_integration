import 'package:tamara_payment/core/result.dart';
import 'package:tamara_payment/core/tamara_failure.dart';

import '../entities/checkout_request.dart';
import '../entities/checkout_session.dart';

/// Contract the domain layer depends on. The impl lives in the data
/// layer and is the only piece that knows about Dio or the Tamara SDK.
abstract class TamaraRepository {
  /// Asks YOUR backend to create the order with Tamara and return the
  /// checkout/success/failed/canceled URLs. Never call Tamara's
  /// server-side order-creation API directly from the app — that
  /// requires your secret key, which must stay server-side.
  Future<Result<TamaraFailure, CheckoutSession>> createCheckoutSession(
    CheckoutRequest request,
  );

  /// Server-side source of truth for the final order status. Always
  /// confirm through this after the widget reports success — don't
  /// trust the client-side callback alone, since webhooks/backend
  /// verification are what's authoritative.
  Future<Result<TamaraFailure, OrderStatusResult>> getOrderStatus(
    String orderId,
  );
}
