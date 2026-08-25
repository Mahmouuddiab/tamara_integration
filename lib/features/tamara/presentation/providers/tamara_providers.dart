import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:tamara_payment/core/tamara_failure.dart';
import '../../data/datasources/tamara_remote_datasource.dart';
import '../../data/repositories/tamara_repository_impl.dart';
import '../../domain/entities/checkout_request.dart';
import '../../domain/repositories/tamara_repository.dart';
import '../../domain/usecases/create_checkout_session_usecase.dart';
import '../../domain/usecases/get_order_status_usecase.dart';
import '../state/checkout_state.dart';

/// Swap this for wherever your app already provides a configured Dio
/// instance (base URL, auth headers, interceptors, etc.) — e.g. the
/// same one you wired up for Paymob.
final dioProvider = Provider<Dio>((ref) {
  return Dio(BaseOptions(baseUrl: 'https://your-backend.example.com/api'));
});

final tamaraRemoteDataSourceProvider = Provider<TamaraRemoteDataSource>((ref) {
  return TamaraRemoteDataSourceImpl(ref.watch(dioProvider));
});

final tamaraRepositoryProvider = Provider<TamaraRepository>((ref) {
  return TamaraRepositoryImpl(ref.watch(tamaraRemoteDataSourceProvider));
});

final createCheckoutSessionUseCaseProvider =
    Provider<CreateCheckoutSessionUseCase>((ref) {
  return CreateCheckoutSessionUseCase(ref.watch(tamaraRepositoryProvider));
});

final getOrderStatusUseCaseProvider = Provider<GetOrderStatusUseCase>((ref) {
  return GetOrderStatusUseCase(ref.watch(tamaraRepositoryProvider));
});

final checkoutNotifierProvider =
    StateNotifierProvider<CheckoutNotifier, CheckoutState>((ref) {
  return CheckoutNotifier(
    createSession: ref.watch(createCheckoutSessionUseCaseProvider),
    getStatus: ref.watch(getOrderStatusUseCaseProvider),
  );
});

/// Owns the whole checkout lifecycle. Every entry point (button tap,
/// SDK callback) goes through here so only one checkout flow can be
/// in flight at a time — this is what sidesteps the SDK's known
/// concurrency crash when multiple native calls overlap.
class CheckoutNotifier extends StateNotifier<CheckoutState> {
  final CreateCheckoutSessionUseCase _createSession;
  final GetOrderStatusUseCase _getStatus;
  bool _isBusy = false;

  CheckoutNotifier({
    required CreateCheckoutSessionUseCase createSession,
    required GetOrderStatusUseCase getStatus,
  })  : _createSession = createSession,
        _getStatus = getStatus,
        super(const CheckoutState());

  Future<void> startCheckout(CheckoutRequest request) async {
    if (_isBusy) return; // guards against double-tap / overlapping calls
    _isBusy = true;
    state = state.copyWith(status: CheckoutStatus.creatingSession);

    final result = await _createSession(request);

    result.when(
      failure: (f) {
        state = state.copyWith(status: CheckoutStatus.failed, failure: f);
      },
      success: (session) {
        state = state.copyWith(status: CheckoutStatus.ready, session: session);
      },
    );
    _isBusy = false;
  }

  /// Call this from the widget's onPaymentSuccess callback. The
  /// client-side callback only means the user finished the flow —
  /// this confirms the real outcome against your backend.
  Future<void> confirmOrderStatus() async {
    final orderId = state.session?.orderId;
    if (orderId == null || _isBusy) return;
    _isBusy = true;

    final result = await _getStatus(orderId);

    result.when(
      failure: (f) {
        state = state.copyWith(status: CheckoutStatus.failed, failure: f);
      },
      success: (statusResult) {
        state = state.copyWith(
          status: statusResult.status == OrderStatus.approved
              ? CheckoutStatus.succeeded
              : CheckoutStatus.failed,
          failure: statusResult.status == OrderStatus.approved
              ? null
              : const CheckoutFailure('Order was not approved.'),
        );
      },
    );
    _isBusy = false;
  }

  void markFailed() {
    state = state.copyWith(
      status: CheckoutStatus.failed,
      failure: const CheckoutFailure('Payment failed.'),
    );
  }

  void markCanceled() {
    state = state.copyWith(
      status: CheckoutStatus.canceled,
      failure: const CheckoutCanceled(),
    );
  }

  void reset() => state = const CheckoutState();
}
