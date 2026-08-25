import 'package:dio/dio.dart';

import '../../domain/entities/checkout_request.dart';
import '../models/checkout_session_model.dart';
import '../models/order_status_model.dart';

/// Talks to YOUR backend, never to Tamara's server-side API directly.
/// The secret key that authenticates with Tamara stays on your server.
abstract class TamaraRemoteDataSource {
  Future<CheckoutSessionModel> createCheckoutSession(CheckoutRequest request);
  Future<OrderStatusModel> getOrderStatus(String orderId);
}

class TamaraRemoteDataSourceImpl implements TamaraRemoteDataSource {
  final Dio _dio;
  const TamaraRemoteDataSourceImpl(this._dio);

  @override
  Future<CheckoutSessionModel> createCheckoutSession(
    CheckoutRequest request,
  ) async {
    final response = await _dio.post(
      '/payments/tamara/checkout-session',
      data: {
        'reference_order_id': request.referenceOrderId,
        'total_amount': request.totalAmount,
        'currency': request.currency,
        'country_code': request.countryCode,
        'items': request.items
            .map((i) => {
                  'name': i.name,
                  'sku': i.sku,
                  'quantity': i.quantity,
                  'unit_price': i.unitPrice,
                })
            .toList(),
        'customer': {
          'first_name': request.customerFirstName,
          'last_name': request.customerLastName,
          'phone': request.customerPhone,
          'email': request.customerEmail,
        },
      },
    );
    return CheckoutSessionModel.fromJson(response.data as Map<String, dynamic>);
  }

  @override
  Future<OrderStatusModel> getOrderStatus(String orderId) async {
    final response = await _dio.get('/payments/tamara/orders/$orderId/status');
    return OrderStatusModel.fromJson(response.data as Map<String, dynamic>);
  }
}
