import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:http/http.dart' as http;

class PayWithStripe {
  //creating payment method

  var paymentIntent;

  makeAPayment() async {
    try {
      paymentIntent = await createPaymentIntent('100', 'USD');
      await Stripe.instance
          .initPaymentSheet(
              paymentSheetParameters: SetupPaymentSheetParameters(
                  paymentIntentClientSecret: paymentIntent['client_secret'],
                  style: ThemeMode.light,
                  merchantDisplayName: 'WaqasAliAnjum'))
          .then((value) {});

      showPaymentSheet();
    } on StripeException catch (e) {
      print(e);
    }
  }

  Future<Map<String, dynamic>> createPaymentIntent(
      String amount, String currency) async {
    try {
      Map<String, dynamic> body = {'amount': amount, 'currency': currency};
      var response = await http.post(
          Uri.parse('https://api.stripe.com/v1/payment_intents'),
          headers: {
            'Authorization': 'Bearer ${dotenv.env['STRIPE_SECRET_KEY']}',
            'Content-Type': 'application/x-www-form-urlencoded'
          },
          body: body);
      print(response.body);
      return jsonDecode(response.body);
    } on StripeException catch (e) {
      print(e);
      return {'error': e.error.message};
    }
  }

  showPaymentSheet() async {
    try {
      await Stripe.instance.presentPaymentSheet().then((value) {
        paymentIntent == null;
        print('Payment Successfully');
      }).onError((error, stackTrace) {
        print(error);
      });
    } on StripeException catch (e) {
      print(e.error.message.toString());
    }
  }
}
