import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:http/http.dart' as http;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  Stripe.publishableKey =
      'pk_test_51NfwprH1I6B7cP4lQGiRkc9f99HnTfJtoKcgFBECsxQ5jjscvxWKqNtI5gqjZKfpg3IaLJptbZlNq50YwtpElEWB00XHsKwXG0';

  await dotenv.load(fileName: 'lib/assets/.env');
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const StripePaymentGateway(title: 'Stripe'),
    );
  }
}

class StripePaymentGateway extends StatefulWidget {
  const StripePaymentGateway({super.key, required this.title});

  final String title;

  @override
  State<StripePaymentGateway> createState() => _StripePaymentGatewayState();
}

class _StripePaymentGatewayState extends State<StripePaymentGateway> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            ElevatedButton(
                onPressed: () => makePayment(context),
                child: const Text('Pay \$1000'))
          ],
        ),
      ),
    );
  }
}

Future<void> makePayment(BuildContext context) async {
  try {
    var paymentIntent = await createPaymentIntent('10000', 'USD');

    Stripe.instance.initPaymentSheet(
        paymentSheetParameters: SetupPaymentSheetParameters(
            paymentIntentClientSecret: paymentIntent['client_secret'],
            style: ThemeMode.light,
            merchantDisplayName: 'AK'));
    displayPaymentResult(context);
  } on StripeException catch (e) {
    print(e.toString());
  }
}

createPaymentIntent(String amount, String currency) async {
  try {
    Map<String, dynamic> body = {'amount': amount, 'currency': currency};

    var response =
        await http.post(Uri.parse('https://api.stripe.com/v1/payment_intents'),
            headers: {
              'Authorization':
                  'Bearer sk_test_51NfwprH1I6B7cP4lgRDUgETZ4OwmUkKNRC9aOqwgV7DmFYTr1NoelYQmWKX4WTw0mOxa97w8FiYM4RShlivbO21G00BQ84nfQh',
              'Content-Type': 'application/x-www-form-urlencoded'
            },
            body: body);

    return jsonDecode(response.body);
  } catch (e) {
    print(e.toString());
  }
}

void displayPaymentResult(BuildContext context) {
  try {
    Stripe.instance.presentPaymentSheet().then((value) {
      String displayMessage = value == null ? 'Failed' : value.label;
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(displayMessage)));
    });
  } catch (e) {
    print(e.toString());
  }
}


/**Response body
{
  "id": "pi_3NfzMlH1I6B7cP4l1IvEEZuc",
  "object": "payment_intent",
  "amount": 10000,
  "amount_capturable": 0,
  "amount_details": {
    "tip": {
    }
  },
  "amount_received": 0,
  "application": null,
  "application_fee_amount": null,
  "automatic_payment_methods": {
    "allow_redirects": "always",
    "enabled": true
  },
  "canceled_at": null,
  "cancellation_reason": null,
  "capture_method": "automatic",
  "client_secret": "pi_3N**********************_******_*********************JO5m",
  "confirmation_method": "automatic",
  "created": 1692252451,
  "currency": "usd",
  "customer": null,
  "description": null,
  "invoice": null,
  "last_payment_error": null,
  "latest_charge": null,
  "livemode": false,
  "metadata": {
  },
  "next_action": null,
  "on_behalf_of": null,
  "payment_method": null,
  "payment_method_options": {
    "card": {
      "installments": null,
      "mandate_options": null,
      "network": null,
      "request_three_d_secure": "automatic"
    }
  },
  "payment_method_types": [
    "card"
  ],
  "processing": null,
  "receipt_email": null,
  "review": null,
  "setup_future_usage": null,
  "shipping": null,
  "source": null,
  "statement_descriptor": null,
  "statement_descriptor_suffix": null,
  "status": "requires_payment_method",
  "transfer_data": null,
  "transfer_group": null
} */