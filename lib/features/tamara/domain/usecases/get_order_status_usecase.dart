import 'package:tamara_payment/core/result.dart';
import 'package:tamara_payment/core/tamara_failure.dart';
import '../entities/checkout_request.dart';
import '../repositories/tamara_repository.dart';

class GetOrderStatusUseCase {
  final TamaraRepository _repository;
  const GetOrderStatusUseCase(this._repository);

  Future<Result<TamaraFailure, OrderStatusResult>> call(String orderId) {
    return _repository.getOrderStatus(orderId);
  }
}
