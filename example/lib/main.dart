import 'package:flutter/material.dart';
import 'package:flutter_openmoney/flutter_openmoney.dart';
import 'package:fluttertoast/fluttertoast.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  late final FlutterOpenmoney flutterOpenmoney;

  @override
  void initState() {
    super.initState();

    flutterOpenmoney = FlutterOpenmoney();
    flutterOpenmoney.on(
        FlutterOpenmoney.eventPaymentSuccess, _handlePaymentSuccess);
    flutterOpenmoney.on(
        FlutterOpenmoney.eventPaymentError, _handlePaymentError);
  }

  void _initPayment() async {
    /// get from openmoney dashboard
    const accessKey = '3d751720-594a-11eb-96fc-cfd6fc92bd19';

    /// Generated using openmoney create token api in server
    /// refer https://docs.bankopen.com/reference/generate-token
    const paymentToken = 'sb_pt_BUFJpEalhWmO6cm';
    final options = PaymentOptions(accessKey, paymentToken);

    try {
      flutterOpenmoney.initPayment(options);
    } catch (e) {
      debugPrint('Error: e');
    }
  }

  void _handlePaymentSuccess(PaymentSuccessResponse response) {
    Fluttertoast.showToast(
        msg: "SUCCESS: " + response.paymentId!,
        toastLength: Toast.LENGTH_LONG);
  }

  void _handlePaymentError(PaymentFailureResponse response) {
    Fluttertoast.showToast(
        msg: "ERROR: " + response.code.toString() + " - " + (response.message ?? ''),
        toastLength: Toast.LENGTH_LONG);
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('FlutterOpenmoney Plugin example app'),
        ),
        body: Center(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              ElevatedButton(
                  onPressed: _initPayment, child: const Text('initPayment'))
            ],
          ),
        ),
      ),
    );
  }
}
