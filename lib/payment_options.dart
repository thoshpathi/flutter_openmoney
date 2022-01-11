class PaymentOptions {
  final String accessKey;
  final String paymentToken;
  final PaymentMode paymentMode;

  PaymentOptions(
    this.accessKey,
    this.paymentToken, [
    this.paymentMode = PaymentMode.sandbox,
  ]);

  Map<String, String> toMap() => {
        'accessKey': accessKey,
        'paymentToken': paymentToken,
        'paymentMode': PaymentModeExt(paymentMode).value,
      };
}

class PaymentOptionsValidResult {
  final bool isValid;
  final String? message;

  PaymentOptionsValidResult([this.isValid = false, this.message]);
}

enum PaymentMode { sandbox, live }

extension PaymentModeExt on PaymentMode {
  String get value {
    switch (this) {
      case PaymentMode.sandbox:
        return 'SANDBOX';
      case PaymentMode.live:
        return 'LIVE';
    }
  }
}
