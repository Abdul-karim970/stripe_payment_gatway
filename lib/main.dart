import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:stripe_payment_gatway/stripe_handler.dart';

import 'jazzcash_handler.dart';
import 'jazzcash_product.dart';

void initializePayment() async {
  WidgetsFlutterBinding.ensureInitialized();
  Stripe.publishableKey =
      'pk_test_51NfwprH1I6B7cP4lQGiRkc9f99HnTfJtoKcgFBECsxQ5jjscvxWKqNtI5gqjZKfpg3IaLJptbZlNq50YwtpElEWB00XHsKwXG0';

  await dotenv.load(fileName: 'lib/assets/.env');
}

void main() {
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
  Product product = Product(name: 'AK', price: '10');
  @override
  void initState() {
    super.initState();
    initializePayment();
  }

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
                onPressed: () => StripeHandler().makePayment(context),
                child: const Text('Pay \$1000')),
            ElevatedButton(
                onPressed: () async {
                  try {
                    makePaymentViaJazzCash(context, product);
                  } catch (e) {
                    ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Payment canceled!\n$e')));
                  }
                },
                child: const Text('Pay via Jazzcash'))
          ],
        ),
      ),
    );
  }
}

// Jazzcash package owner github:

// https://github.com/DigiX-Technologies/jazzcash_flutter