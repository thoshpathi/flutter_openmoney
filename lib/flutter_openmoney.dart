import 'package:flutter/services.dart';
import 'package:flutter/foundation.dart';
import 'package:eventify/eventify.dart';

import 'payment_options.dart';
import 'payment_responses.dart';

export 'payment_options.dart';
export 'payment_responses.dart';

class FlutterOpenmoney {
  static const _channelName = 'plugins.flutter.io/openmoney';
  static const _channel = MethodChannel(_channelName);

  static const codePaymentSuccess = 0;
  static const codePaymentError = 1;

  static const invalidOptions = 0;
  static const paymentFailed = 1;
  static const paymentCancelled = 2;
  static const paymmentPending = 3;
  static const unknownError = 100;

  static const eventPaymentSuccess = 'payment.success';
  static const eventPaymentError = 'payment.error';

  // EventEmitter instance used for communication
  late final EventEmitter _eventEmitter;

  FlutterOpenmoney() {
    _eventEmitter = EventEmitter();
  }

  static Future<String?> get platformVersion async {
    final String? version = await _channel.invokeMethod('getPlatformVersion');
    return version;
  }

  PaymentOptionsValidResult _validateOptions(PaymentOptions options) {

    return options.paymentToken == null || options.paymentToken.isEmpty
        ? PaymentOptionsValidResult(false,
            'PaymentToken is required. Please check if `paymentToken` is present in options.')
        : options.accessKey == null || options.accessKey.isEmpty
            ? PaymentOptionsValidResult(false,
                'AccessKey is required. Please check if `accessKey` is present in options.')
            : PaymentOptionsValidResult(true);
  }

  /// Initiate payment from platform
  void initPayment(PaymentOptions options) async {
    final _validationResult = _validateOptions(options);
    if (!_validationResult.isValid) {
      return _handleResult({
        'type': codePaymentError,
        'data': {'code': invalidOptions, 'message': _validationResult.message}
      });
    }

    final response = await _channel.invokeMethod('initPayment', options.toMap());
    _handleResult(response);
  }

  /// Handles checkout response from platform
  void _handleResult(Map<dynamic, dynamic> response) {
	debugPrint('response: $response');
  
    String eventName;
    Map<dynamic, dynamic>? data = response["data"];

    PaymentResponse payload;

    switch (response['type'] as int) {
      case codePaymentSuccess:
        eventName = eventPaymentSuccess;
        payload = PaymentSuccessResponse.fromMap(data!);
        break;

      case codePaymentError:
        eventName = eventPaymentError;
        payload = PaymentFailureResponse.fromMap(data!);
        break;

      default:
        eventName = 'error';
        payload =
            PaymentFailureResponse(unknownError, 'An unknown error occurred.');
    }

    _eventEmitter.emit(eventName, null, payload);
  }

  /// Registers event listeners for payment events
  void on(String event, Function handler) {
    _eventEmitter.on(event, null, (event, cont) {
      handler(event.eventData);
    });
    _resync();
  }

  /// Clears all event listeners
  void clear() {
    _eventEmitter.clear();
  }

  /// Retrieves lost responses from platform
  void _resync() async {
    final response = await _channel.invokeMethod('resync');
    if (response != null) {
      _handleResult(response);
    }
  }
}
