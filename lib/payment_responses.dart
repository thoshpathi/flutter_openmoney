abstract class PaymentResponse {}

class PaymentSuccessResponse extends PaymentResponse {
  final String? paymentId;
  final String? paymentTokenId;

  PaymentSuccessResponse(this.paymentId, this.paymentTokenId);

  PaymentSuccessResponse.fromMap(Map<dynamic, dynamic> map)
      : paymentId = map["paymentId"] as String?,
        paymentTokenId = map["paymentTokenId"] as String?;
}

class PaymentFailureResponse extends PaymentResponse {
  final int? code;
  final String? message;

  PaymentFailureResponse(this.code, this.message);

  PaymentFailureResponse.fromMap(Map<dynamic, dynamic> map)
      : code = map["code"] as int?,
        message = map["message"] as String?;
}