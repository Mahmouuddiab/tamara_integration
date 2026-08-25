import 'package:tamara_payment/core/tamara_failure.dart';
import '../../domain/entities/checkout_session.dart';

enum CheckoutStatus { idle, creatingSession, ready, succeeded, failed, canceled }

class CheckoutState {
  final CheckoutStatus status;
  final CheckoutSession? session;
  final TamaraFailure? failure;

  const CheckoutState({
    this.status = CheckoutStatus.idle,
    this.session,
    this.failure,
  });

  CheckoutState copyWith({
    CheckoutStatus? status,
    CheckoutSession? session,
    TamaraFailure? failure,
  }) {
    return CheckoutState(
      status: status ?? this.status,
      session: session ?? this.session,
      failure: failure,
    );
  }
}
