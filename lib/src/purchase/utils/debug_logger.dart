// lib/src/purchase/utils/debug_logger.dart

import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';

class PurchaseDebugLogger {
  /// Logs iOS payload to a file in the app's documents directory
  /// This is useful when console logs are not accessible during testing
  static Future<String?> logPayloadToFile(
    Map<String, dynamic> payload, {
    String filename = 'ios_verification_payload.txt',
  }) async {
    if (!kDebugMode) {
      return null; // Only log in debug mode
    }

    try {
      final directory = await getApplicationDocumentsDirectory();
      final file = File('${directory.path}/$filename');

      final timestamp = DateTime.now().toIso8601String();
      final buffer = StringBuffer();

      buffer.writeln('═════════════════════════════════════════════');
      buffer.writeln('iOS VERIFICATION PAYLOAD');
      buffer.writeln('Timestamp: $timestamp');
      buffer.writeln('═════════════════════════════════════════════');
      buffer.writeln('');

      // Write all fields
      payload.forEach((key, value) {
        if (key == 'receipt_data' || key == 'purchase_token') {
          // For receipt data, show first/last 50 chars
          final str = value.toString();
          if (str.length > 100) {
            buffer.writeln('$key:');
            buffer.writeln('  Length: ${str.length} characters');
            buffer.writeln('  First 50 chars: ${str.substring(0, 50)}...');
            buffer.writeln(
              '  Last 50 chars: ...${str.substring(str.length - 50)}',
            );
          } else {
            buffer.writeln('$key: $value');
          }
        } else if (key == 'verification_data' && value is Map) {
          buffer.writeln('$key:');
          value.forEach((subKey, subValue) {
            if (subKey == 'local_verification_data' ||
                subKey == 'server_verification_data') {
              final str = subValue.toString();
              buffer.writeln('  $subKey: [${str.length} chars]');
            } else {
              buffer.writeln('  $subKey: $subValue');
            }
          });
        } else {
          buffer.writeln('$key: $value');
        }
      });

      buffer.writeln('');
      buffer.writeln('═════════════════════════════════════════════');
      buffer.writeln('File location: ${file.path}');
      buffer.writeln('═════════════════════════════════════════════');

      // Append to file (keeps history)
      await file.writeAsString(
        '\n\n${buffer.toString()}',
        mode: FileMode.append,
      );

      return file.path;
    } catch (e) {
      return null;
    }
  }

  /// Creates a user-friendly summary of the payload
  static String createPayloadSummary(Map<String, dynamic> payload) {
    final buffer = StringBuffer();

    buffer.writeln('iOS Verification Payload Summary:');
    buffer.writeln('');
    buffer.writeln('Platform: ${payload['platform'] ?? 'N/A'}');
    buffer.writeln('Product ID: ${payload['product_id'] ?? 'N/A'}');
    buffer.writeln('Transaction ID: ${payload['transaction_id'] ?? 'N/A'}');
    buffer.writeln(
      'Original TX ID: ${payload['original_transaction_id'] ?? 'N/A'}',
    );

    final receiptData = payload['receipt_data']?.toString() ?? '';
    buffer.writeln('');
    buffer.writeln('Receipt Data:');
    buffer.writeln('  Length: ${receiptData.length} chars');
    buffer.writeln('  Has Data: ${receiptData.isNotEmpty}');

    if (receiptData.length > 50) {
      buffer.writeln('  Preview: ${receiptData.substring(0, 50)}...');
    }

    return buffer.toString();
  }
}
