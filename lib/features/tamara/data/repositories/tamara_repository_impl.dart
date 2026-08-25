import 'package:dio/dio.dart';
import 'package:tamara_payment/core/result.dart';
import 'package:tamara_payment/core/tamara_failure.dart';
import '../../domain/entities/checkout_request.dart';
import '../../domain/entities/checkout_session.dart';
import '../../domain/repositories/tamara_repository.dart';
import '../datasources/tamara_remote_datasource.dart';

class TamaraRepositoryImpl implements TamaraRepository {
  final TamaraRemoteDataSource _remote;
  const TamaraRepositoryImpl(this._remote);

  @override
  Future<Result<TamaraFailure, CheckoutSession>> createCheckoutSession(
    CheckoutRequest request,
  ) async {
    try {
      final session = await _remote.createCheckoutSession(request);
      return Success(session);
    } on DioException catch (e) {
      return Failure(_mapDioError(e));
    } catch (_) {
      return const Failure(UnknownFailure());
    }
  }

  @override
  Future<Result<TamaraFailure, OrderStatusResult>> getOrderStatus(
    String orderId,
  ) async {
    try {
      final status = await _remote.getOrderStatus(orderId);
      return Success(status);
    } on DioException catch (e) {
      return Failure(_mapDioError(e));
    } catch (_) {
      return const Failure(UnknownFailure());
    }
  }

  TamaraFailure _mapDioError(DioException e) {
    if (e.type == DioExceptionType.connectionTimeout ||
        e.type == DioExceptionType.receiveTimeout ||
        e.type == DioExceptionType.connectionError) {
      return const NetworkFailure();
    }
    final statusCode = e.response?.statusCode;
    final message = e.response?.data is Map
        ? (e.response?.data['message']?.toString() ?? 'Checkout request failed.')
        : 'Checkout request failed.';
    return ServerFailure(message, statusCode: statusCode);
  }
}
