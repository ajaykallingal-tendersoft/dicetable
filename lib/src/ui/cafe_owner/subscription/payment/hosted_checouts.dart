import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:url_launcher/url_launcher.dart';

class HostedCheckoutTestPage extends StatefulWidget {
  const HostedCheckoutTestPage({super.key});

  @override
  State<HostedCheckoutTestPage> createState() => _HostedCheckoutTestPageState();
}

class _HostedCheckoutTestPageState extends State<HostedCheckoutTestPage> {
  bool isLoading = false;
  String? error;

  final String apiKey = 'YOUR_API_KEY_BASE64_ENCODED'; // Replace with Base64 encoded: "apiKey:secret"
  final String merchantId = 'YOUR_MERCHANT_ID'; // Your Ingenico merchant ID

  Future<void> startHostedCheckout() async {
    setState(() {
      isLoading = true;
      error = null;
    });

    try {
      final response = await http.post(
        Uri.parse('https://payment.preprod.online-payments.com/v2/$merchantId/hostedcheckouts'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Basic $apiKey',
        },
        body: json.encode({
          "order": {
            "amountOfMoney": {
              "currencyCode": "USD",
              "amount": 1000 // $10.00
            },
            "customer": {
              "merchantCustomerId": "flutterTestUser"
            }
          },
          "hostedCheckoutSpecificInput": {
            "returnUrl": "https://www.example.com/checkout-result"
          }
        }),
      );

      if (response.statusCode == 201) {
        final body = json.decode(response.body);
        final redirectUrl = body['partialRedirectUrl'];
        final fullRedirectUrl = "https://payment.preprod.online-payments.com$redirectUrl";

        if (await canLaunchUrl(Uri.parse(fullRedirectUrl))) {
          await launchUrl(Uri.parse(fullRedirectUrl), mode: LaunchMode.externalApplication);
        } else {
          setState(() {
            error = "Unable to open hosted checkout page.";
          });
        }
      } else {
        setState(() {
          error = "API Error ${response.statusCode}: ${response.body}";
        });
      }
    } catch (e) {
      setState(() {
        error = "Error: $e";
      });
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  void initState() {
    super.initState();
    startHostedCheckout();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Hosted Checkout Test")),
      body: Center(
        child: isLoading
            ? const CircularProgressIndicator()
            : error != null
            ? Text(error!)
            : const Text("Redirecting to hosted checkout..."),
      ),
    );
  }
}
