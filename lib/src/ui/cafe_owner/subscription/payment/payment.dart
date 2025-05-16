import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:online_payments_sdk/online_payments_sdk.dart';
import 'dart:developer' as developer;

class PaymentHome extends StatefulWidget {
  const PaymentHome({super.key});

  @override
  State<PaymentHome> createState() => _PaymentHomeState();
}

class _PaymentHomeState extends State<PaymentHome> {
  Session? session;
  late PaymentContext paymentContext;

  List<BasicPaymentProduct> products = [];
  BasicPaymentProduct? selectedProduct;
  PaymentProduct? enrichedProduct;

  bool isLoading = true;
  String? errorMessage;
  Map<String, String> userInput = {};

  @override
  void initState() {
    super.initState();
    initPaymentFlow();
  }

  // --- SESSION MANAGEMENT ---

  Future<void> fetchNewSessionFromBackend() async {
    // TODO: Replace with your real backend call!
    // Simulate fetching a new session from your backend.
    // This must be a secure call to your backend, which in turn calls Ingenico's server API.
    developer.log('Fetching new session from backend...');
    await Future.delayed(const Duration(seconds: 1));
    // Replace these with values returned from your backend.
    session = Session(
      "c3db48b22dc547479938c06abce0d56b", // clientSessionId
      "2af772b0fe91474f8d883e34aaffc890", // customerId
      "https://payment.preprod.direct.ingenico.com", // clientApiUrl
      "https://assets.test.cdn.v-psp.com/s2s/1e345f13032ad7402fc6", // assetUrl
      isEnvironmentProduction: false,
      loggingEnabled: true,
    );
    developer.log('New session initialized');
  }

  bool _isSessionExpiredError(dynamic e) {
    if (e == null) return false;
    final msg = e.toString().toLowerCase();
    // Adjust these checks based on actual SDK/API error messages
    return msg.contains("session expired") ||
        msg.contains("401") ||
        msg.contains("invalid session") ||
        msg.contains("expired");
  }

  // --- PAYMENT FLOW LOGIC WITH SESSION RENEWAL ---

  Future<void> initPaymentFlow() async {
    setState(() {
      isLoading = true;
      errorMessage = null;
      products = [];
      selectedProduct = null;
      enrichedProduct = null;
      userInput.clear();
    });

    try {
      await fetchNewSessionFromBackend();
      final amount = AmountOfMoney(1298, "EUR");
      paymentContext = PaymentContext(amount, "NL", false);

      await _fetchPaymentProductsWithSessionRetry();
    } catch (e) {
      developer.log('Initialization failed', error: e);
      setState(() {
        isLoading = false;
        errorMessage = "Initialization failed: $e";
      });
    }
  }

  Future<void> _fetchPaymentProductsWithSessionRetry() async {
    try {
      await session!.getBasicPaymentProducts(
        request: BasicPaymentProductsRequest(paymentContext: paymentContext),
        listener: BasicPaymentProductsResponseListener(
          onSuccess: (response) {
            developer.log('Successfully fetched ${response.basicPaymentProducts.length} payment products');
            setState(() {
              products = response.basicPaymentProducts;
              isLoading = false;
              if (products.isNotEmpty) {
                selectedProduct = products.first;
                developer.log('Selected first product: ${selectedProduct!.id}');
                loadEnrichedProductWithSessionRetry(selectedProduct!.id);
              } else {
                developer.log('No payment products available');
              }
            });
          },
          onError: (e) async {
            developer.log('Error fetching products: ${e?.message}', error: e);
            if (_isSessionExpiredError(e)) {
              await fetchNewSessionFromBackend();
              await _fetchPaymentProductsWithSessionRetry();
            } else {
              setState(() {
                isLoading = false;
                errorMessage = "Error fetching products: ${e?.message}";
              });
            }
          },
          onException: (e) async {
            developer.log('Exception fetching products', error: e);
            if (_isSessionExpiredError(e)) {
              await fetchNewSessionFromBackend();
              await _fetchPaymentProductsWithSessionRetry();
            } else {
              setState(() {
                isLoading = false;
                errorMessage = "Exception fetching products: $e";
              });
            }
          },
        ),
      );
    } catch (e) {
      developer.log('Exception in products fetch', error: e);
      setState(() {
        isLoading = false;
        errorMessage = "Exception in products fetch: $e";
      });
    }
  }

  void loadEnrichedProductWithSessionRetry(String productId) async {
    try {
      await session!.getPaymentProduct(
        request: PaymentProductRequest(
          productId: productId,
          paymentContext: paymentContext,
        ),
        listener: PaymentProductResponseListener(
          onSuccess: (productResponse) {
            developer.log('Successfully loaded enriched product: ${productResponse.id}');
            setState(() {
              enrichedProduct = productResponse;
              userInput.clear();
            });
          },
          onError: (e) async {
            developer.log('Error loading product: ${e?.message}', error: e);
            if (_isSessionExpiredError(e)) {
              await fetchNewSessionFromBackend();
              loadEnrichedProductWithSessionRetry(productId);
            } else {
              setState(() {
                errorMessage = "Error loading product: ${e?.message}";
              });
            }
          },
          onException: (e) async {
            developer.log('Exception loading product', error: e);
            if (_isSessionExpiredError(e)) {
              await fetchNewSessionFromBackend();
              loadEnrichedProductWithSessionRetry(productId);
            } else {
              setState(() {
                errorMessage = "Exception loading product: $e";
              });
            }
          },
        ),
      );
    } catch (e) {
      developer.log('Exception in product enrichment', error: e);
      setState(() {
        errorMessage = "Exception in product enrichment: $e";
      });
    }
  }

  void preparePaymentRequestFromUI() async {
    if (enrichedProduct == null) return;

    developer.log('Preparing payment request for product: ${enrichedProduct!.id}');

    final request = PaymentRequest(
      paymentProduct: enrichedProduct!,
      tokenize: false,
    );

    for (var entry in userInput.entries) {
      developer.log('Setting field value: ${entry.key}');
      request.setValue(entry.key, entry.value);
    }

    await _preparePaymentRequestWithSessionRetry(request);
  }

  Future<void> _preparePaymentRequestWithSessionRetry(PaymentRequest request) async {
    try {
      await session!.preparePaymentRequest(
        request: SdkPreparePaymentRequest(request),
        listener: PaymentRequestPreparedListener(
          onSuccess: (prepared) {
            developer.log('Payment request prepared successfully');
            showDialog(
              context: context,
              builder: (_) => AlertDialog(
                title: const Text("Encrypted Fields"),
                content: Text(prepared.encryptedFields),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text("OK"),
                  ),
                ],
              ),
            );
          },
          onError: (e) async {
            developer.log('Error preparing payment: ${e?.message}', error: e);
            if (_isSessionExpiredError(e)) {
              await fetchNewSessionFromBackend();
              await _preparePaymentRequestWithSessionRetry(request);
            } else {
              showError("Encryption error: ${e?.message}");
            }
          },
          onException: (e) async {
            developer.log('Exception preparing payment', error: e);
            if (_isSessionExpiredError(e)) {
              await fetchNewSessionFromBackend();
              await _preparePaymentRequestWithSessionRetry(request);
            } else {
              showError("Encryption exception: $e");
            }
          },
        ),
      );
    } catch (e) {
      developer.log('Exception in payment preparation', error: e);
      showError("Exception in payment preparation: $e");
    }
  }

  void showError(String msg) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Error"),
        content: Text(msg),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("OK")),
        ],
      ),
    );
  }

  // --- UI ---

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Payment Test App')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: isLoading
            ? const Center(child: CircularProgressIndicator())
            : errorMessage != null
            ? Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(errorMessage!, style: const TextStyle(color: Colors.red)),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () {
                  setState(() {
                    isLoading = true;
                    errorMessage = null;
                  });
                  initPaymentFlow();
                },
                child: const Text('Retry'),
              ),
            ],
          ),
        )
            : SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text("Select Payment Method:", style: TextStyle(fontSize: 18)),
              const SizedBox(height: 8),
              DropdownButton<BasicPaymentProduct>(
                value: selectedProduct,
                hint: const Text("Choose a product"),
                isExpanded: true,
                items: products.map((product) {
                  final label = product.displayHintsList.first.label;
                  return DropdownMenuItem(
                    value: product,
                    child: Text(label),
                  );
                }).toList(),
                onChanged: (product) {
                  setState(() {
                    selectedProduct = product;
                    enrichedProduct = null;
                  });
                  if (product != null) loadEnrichedProductWithSessionRetry(product.id);
                },
              ),
              const SizedBox(height: 16),
              if (enrichedProduct != null) ...[
                const Text("Enter Details:", style: TextStyle(fontSize: 16)),
                const SizedBox(height: 8),
                ...enrichedProduct!.fields.map((field) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 6),
                    child: TextField(
                      decoration: InputDecoration(
                        labelText: field.displayHints?.label,
                        border: const OutlineInputBorder(),
                      ),
                      onChanged: (value) {
                        userInput[field.id] = value;
                      },
                    ),
                  );
                }).toList(),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: preparePaymentRequestFromUI,
                  child: const Text("Encrypt & Pay"),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

// --- API TESTER CLASS (unchanged, for completeness) ---

class PaymentApiTester {
  final String apiUrl;
  final String clientSessionId;
  final String customerId;

  PaymentApiTester({
    required this.apiUrl,
    required this.clientSessionId,
    required this.customerId,
  });

  Future<void> testApiConnection() async {
    try {
      final uri = Uri.parse('$apiUrl/client/v1/$customerId/products');

      final response = await http.get(
        uri.replace(queryParameters: {
          'countryCode': 'NL',
          'amount': '1298',
          'isRecurring': 'false',
          'currencyCode': 'EUR',
          'hide': 'fields',
          'cacheBuster': DateTime.now().millisecondsSinceEpoch.toString(),
        }),
        headers: {
          'Authorization': 'GCS v1Client:$clientSessionId',
          'X-GCS-ClientMetaInfo': _getClientMetaInfo(),
        },
      );

      developer.log('API Test Response Status: ${response.statusCode}');
      developer.log('API Test Response Body: ${response.body}');

      if (response.statusCode == 200) {
        try {
          final jsonResponse = jsonDecode(response.body);
          developer.log('API Test Parsed Response: $jsonResponse');
        } catch (e) {
          developer.log('API Test JSON Parse Error', error: e);
        }
      } else {
        developer.log('API Test Error: HTTP ${response.statusCode}');
      }
    } catch (e) {
      developer.log('API Test Exception', error: e);
    }
  }

  String _getClientMetaInfo() {
    final metaInfo = jsonEncode({
      'platformIdentifier': 'Android/${Platform.operatingSystemVersion}',
      'appIdentifier': 'flutter//flutter//TestApp',
      'sdkIdentifier': 'FlutterClientSDK/v1.2.1',
      'sdkCreator': 'OnlinePayments',
      'screenSize': '1080x1920',
      'deviceBrand': Platform.isAndroid ? 'android' : 'apple',
      'deviceType': Platform.isAndroid ? 'Android' : 'iOS',
    });

    return base64Encode(utf8.encode(metaInfo));
  }
}
