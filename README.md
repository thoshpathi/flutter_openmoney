# Flutter OpenMoney

Flutter plugin for OpenMoney SDK.


* [Getting Started](#getting-started)
* [Installation](#installation)
* [Usage](#usage)
* [API](#api)
* [Example App](https://github.com/thoshpathi/flutter_openmoney/tree/master/example)

## Getting Started

This flutter plugin is a wrapper around openmoney Android SDK.

The following documentation is only focused on the wrapper around native Android SDK. To know more about our SDKs and how to link them within the projects, refer to the following documentation:

**Android**: [https://github.com/eshantmittal/open-payment-android-aar](https://github.com/eshantmittal/open-payment-android-aar)

To initiate payment `paymentToken` and `accessKey` are mandatory variables.
`paymentToken` - Generated in server side. [Know more](https://docs.bankopen.com/reference/generate-token)
`accessKey` - Get from openmoney dashboard


## Installation

This plugin is available on Pub: [https://pub.dev/packages/flutter_openmoney](https://pub.dev/packages/flutter_openmoney)

Add this to `dependencies` in your app's `pubspec.yaml`

```yaml
flutter_openmoney: ^0.0.1
```

**Note for Android**: Make sure that the minimum API level for your app is 19 or higher.

## Usage

Sample code to integrate can be found in [example/lib/main.dart](example/lib/main.dart).

#### Import package

```dart
import 'package:flutter_openmoney/flutter_openmoney.dart';
```

#### Create FlutterOpenmoney instance

```dart
_flutterOpenmoney = FlutterOpenmoney();
```

#### Attach event listeners

The plugin uses event-based communication, and emits events when payment fails or succeeds.

The event names are exposed via the constants `eventPaymentSuccess`, `eventPaymentError` from the `FlutterOpenmoney` class.

Use the `on(String event, Function handler)` method on the `FlutterOpenmoney` instance to attach event listeners.

```dart

_flutterOpenmoney.on(FlutterOpenmoney.eventPaymentSuccess, _handlePaymentSuccess);
_flutterOpenmoney.on(FlutterOpenmoney.eventPaymentError, _handlePaymentError);
```

The handlers would be defined somewhere as

```dart

void _handlePaymentSuccess(PaymentSuccessResponse response) {
  // Do something when payment succeeds
}

void _handlePaymentError(PaymentFailureResponse response) {
  // Do something when payment fails
}
```

To clear event listeners, use the `clear` method on the `FlutterOpenmoney` instance.

```dart
_flutterOpenmoney.clear(); // Removes all listeners
```

#### Setup options

```dart
var options = PaymentOptions('<ACCESS_KEY_HERE>', '<PAYMENT_TOKEN_HERE>', PaymentMode.sandbox);
```


#### Checkout

```dart
_flutterOpenmoney.initPayment(options.toMap());
```

## API

#### initPayment(Map<String, String> options)

The `options` is instance of `PaymentOptions` class 
The `options` has `paymentToken` and `accessKey` as a required property
Convert `options` to Map object using `options.toMap()` method 


#### on(String eventName, Function listener)

Register event listeners for payment events.

- `eventName`: The name of the event.
- `listener`: The function to be called. The listener should accept a single argument of the following type:
  - [`PaymentSuccessResponse`](#paymentsuccessresponse) for `eventPaymentSuccess`
  - [`PaymentFailureResponse`](#paymentfailureresponse) for `eventPaymentError`

#### clear()

Clear all event listeners.


#### Error Codes

The error codes have been exposed as integers by the `FlutterOpenmoney` class.

The error code is available as the `code` field of the `PaymentFailureResponse` instance passed to the callback.

| Error Code        | Description                                                          |
| ----------------- | -------------------------------------------------------------------- |
| invalidOptions   | An issue with options passed in `FlutterOpenmoney.initPayment`                      |
| paymentCancelled | User cancelled the payment                                           |
| paymentFailed    | Payment process failed                      |
| unknownError     | An unknown error occurred.                                           |


#### Event names

The event names have also been exposed as Strings by the `Razorpay` class.

| Event Name            | Description                      |
| --------------------- | -------------------------------- |
| eventPaymentSuccess | The payment was successful.      |
| eventPaymentError   | The payment was not successful.  |


### PaymentSuccessResponse

| Field Name | Type   | Description                                                                                  |
| ---------- | ------ | -------------------------------------------------------------------------------------------- |
| paymentId  | String | The ID for the payment.                                                                      |
| paymentTokenId | String | The payment token id.                              |

To confirm payment details refer this link [https://docs.bankopen.com/reference/status-check-api-with-token-id](https://docs.bankopen.com/reference/status-check-api-with-token-id)

### PaymentFailureResponse

| Field Name | Type   | Description        |
| ---------- | ------ | ------------------ |
| code       | int    | The error code.    |
| message    | String | The error message. |

