import 'package:tamara_payment/core/result.dart';
import 'package:tamara_payment/core/tamara_failure.dart';

import '../entities/checkout_request.dart';
import '../entities/checkout_session.dart';
import '../repositories/tamara_repository.dart';

class CreateCheckoutSessionUseCase {
  final TamaraRepository _repository;
  const CreateCheckoutSessionUseCase(this._repository);

  Future<Result<TamaraFailure, CheckoutSession>> call(
    CheckoutRequest request,
  ) {
    return _repository.createCheckoutSession(request);
  }
}
