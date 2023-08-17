import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:http/http.dart' as http;

class StripeHandler {
  late Map<String, dynamic>? paymentIntent;

  Future<void> makePayment(BuildContext context) async {
    try {
      paymentIntent = await createPaymentIntent('10000', 'USD');

      await Stripe.instance
          .initPaymentSheet(
              paymentSheetParameters: SetupPaymentSheetParameters(
                  paymentIntentClientSecret: paymentIntent!['client_secret'],
                  style: ThemeMode.dark,
                  merchantDisplayName: 'AK'))
          .then((value) {});
      if (context.mounted) {
        displayPaymentResult(context);
      }
    } catch (e) {
      print(e.toString());
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

      return jsonDecode(response.body);
    } on StripeException catch (e) {
      print(e);
      return {'error': e.error.message};
    }
  }

  void displayPaymentResult(BuildContext context) async {
    try {
      await Stripe.instance.presentPaymentSheet().then((value) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          behavior: SnackBarBehavior.floating,
          backgroundColor: Colors.green.shade400,
          content: const Text('Payment successful'),
          dismissDirection: DismissDirection.startToEnd,
        ));
      }).onError((error, stackTrace) {
        print(error);
      });
    } catch (e) {
      print(e.toString());
    }
  }
}
