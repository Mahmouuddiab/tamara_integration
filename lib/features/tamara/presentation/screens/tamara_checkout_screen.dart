import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tamara_flutter_sdk/tamara_checkout.dart';

import '../../domain/entities/checkout_request.dart';
import '../providers/tamara_providers.dart';
import '../state/checkout_state.dart';

class TamaraCheckoutScreen extends ConsumerStatefulWidget {
  final CheckoutRequest request;
  const TamaraCheckoutScreen({super.key, required this.request});

  @override
  ConsumerState<TamaraCheckoutScreen> createState() =>
      _TamaraCheckoutScreenState();
}

class _TamaraCheckoutScreenState extends ConsumerState<TamaraCheckoutScreen> {
  @override
  void initState() {
    super.initState();
    // Kick off session creation once, on entry — not on every rebuild.
    Future.microtask(() {
      ref.read(checkoutNotifierProvider.notifier).startCheckout(widget.request);
    });
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(checkoutNotifierProvider);

    ref.listen<CheckoutState>(checkoutNotifierProvider, (previous, next) {
      if (next.status == CheckoutStatus.succeeded) {
        Navigator.of(context).pushReplacementNamed('/payment-success');
      } else if (next.status == CheckoutStatus.failed) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(next.failure?.message ?? 'Payment failed.')),
        );
      } else if (next.status == CheckoutStatus.canceled) {
        Navigator.of(context).pop();
      }
    });

    return Scaffold(
      appBar: AppBar(title: const Text('Pay with Tamara')),
      body: switch (state.status) {
        CheckoutStatus.idle ||
        CheckoutStatus.creatingSession =>
          const Center(child: CircularProgressIndicator()),
        CheckoutStatus.ready => _buildCheckoutWidget(state),
        CheckoutStatus.failed => Center(
            child: Text(state.failure?.message ?? 'Something went wrong.'),
          ),
        CheckoutStatus.succeeded => const Center(child: Text('Payment confirmed.')),
        CheckoutStatus.canceled => const Center(child: Text('Payment canceled.')),
      },
    );
  }

  Widget _buildCheckoutWidget(CheckoutState state) {
    final session = state.session!;
    return TamaraCheckout(
      session.checkoutUrl,
      session.successUrl,
      session.failedUrl,
      session.canceledUrl,
      onPaymentSuccess: () {
        // Don't trust this alone — confirm against the backend.
        ref.read(checkoutNotifierProvider.notifier).confirmOrderStatus();
      },
      onPaymentFailed: () {
        ref.read(checkoutNotifierProvider.notifier).markFailed();
      },
      onPaymentCanceled: () {
        ref.read(checkoutNotifierProvider.notifier).markCanceled();
      },
    );
  }
}
