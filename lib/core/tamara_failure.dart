sealed class TamaraFailure {
  final String message;
  const TamaraFailure(this.message);
}

class NetworkFailure extends TamaraFailure {
  const NetworkFailure([super.message = 'Network error. Please check your connection.']);
}

class ServerFailure extends TamaraFailure {
  final int? statusCode;
  const ServerFailure(super.message, {this.statusCode});
}

class CheckoutFailure extends TamaraFailure {
  const CheckoutFailure(super.message);
}

class CheckoutCanceled extends TamaraFailure {
  const CheckoutCanceled([super.message = 'Payment was canceled by the user.']);
}

class UnknownFailure extends TamaraFailure {
  const UnknownFailure([super.message = 'Something went wrong.']);
}
