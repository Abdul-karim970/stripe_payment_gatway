import 'package:flutter/material.dart';
import 'package:jazzcash_flutter/jazzcash_flutter.dart';
import 'package:stripe_payment_gatway/jazzcash_product.dart';

Future<void> makePaymentViaJazzCash(
    BuildContext context, Product product) async {
  String integritySalt = "z30wu8c1ew";
  String merchantID = "MC59242";
  String merchantPassword = "vy0c59sve9";
  String transactionUrl = "www.ak.com";
  try {
    JazzCashFlutter jazzCashFlutter = JazzCashFlutter(
        merchantId: merchantID,
        merchantPassword: merchantPassword,
        integritySalt: integritySalt,
        isSandbox: true);
    DateTime date = DateTime.now();

    JazzCashPaymentDataModelV1 cashPaymentDataModelV1 = JazzCashPaymentDataModelV1(
        ppAmount: product.price,
        ppBillReference:
            'ref${date.year}${date.month}${date.day}${date.hour}${date.millisecond}',
        ppDescription:
            'My First Payment on: ${product.name} with ${product.price} price.',
        ppMerchantID: merchantID,
        ppPassword: merchantPassword,
        ppReturnURL: transactionUrl);

    String response = await jazzCashFlutter.startPayment(
        paymentDataModelV1: cashPaymentDataModelV1, context: context);
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text('Response: $response')));
  } catch (e) {
    print('Error: ${e.toString()}');
  }
}
