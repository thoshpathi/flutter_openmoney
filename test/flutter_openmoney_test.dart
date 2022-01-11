import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_openmoney/flutter_openmoney.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group("$FlutterOpenmoney", () {
    const MethodChannel channel = MethodChannel('flutter_openmoney');

    final log = <MethodCall>[];

    late FlutterOpenmoney flutterOpenmoney;

    setUp(() {
      channel.setMockMethodCallHandler((call) async {
        log.add(call);
        return {};
      });

      flutterOpenmoney = FlutterOpenmoney();
      log.clear();

      channel.setMockMethodCallHandler((MethodCall methodCall) async {
        return '42';
      });
    });

    group("#platformVersion", () {
      test('getPlatformVersion', () async {
        expect(await FlutterOpenmoney.platformVersion, '42');
      });
    });

    group("#initPayment", () {
      setUp(() {
        flutterOpenmoney.clear();
      });

      test('passes options correctly', () async {
        final options = PaymentOptions('xxxxxxxx', 'xxxxxx');
        flutterOpenmoney.initPayment(options);

        expect(log, <Matcher>[isMethodCall('initPayment', arguments: options)]);
      });

      test('throw error if options incorrect', () async {
        final options = PaymentOptions('', '');

        final errorHandler = (PaymentFailureResponse response) {
          expect(response.code, equals(FlutterOpenmoney.invalidOptions));
        };

        flutterOpenmoney.on(FlutterOpenmoney.eventPaymentError,
            expectAsync1(errorHandler, count: 1));
        flutterOpenmoney.initPayment(options);
      });
    });

    tearDown(() {
      channel.setMockMethodCallHandler(null);
    });
  });
}
