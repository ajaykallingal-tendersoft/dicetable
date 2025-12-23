// lib/src/purchase/utils/payload_viewer_dialog.dart

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Shows a dialog with the iOS verification payload for debugging
class PayloadViewerDialog {
  static void show(BuildContext context, Map<String, dynamic> payload) {
    final buffer = StringBuffer();

    // Create formatted text
    buffer.writeln('iOS Verification Payload\n');
    buffer.writeln('Platform: ${payload['platform']}');
    buffer.writeln('Product ID: ${payload['product_id']}');
    buffer.writeln('Transaction ID: ${payload['transaction_id']}');
    buffer.writeln('Original TX: ${payload['original_transaction_id']}');
    buffer.writeln('Order ID: ${payload['order_id']}');
    buffer.writeln('Status: ${payload['status']}\n');

    final receiptData = payload['receipt_data']?.toString() ?? '';
    buffer.writeln('Receipt Data Length: ${receiptData.length}');

    if (receiptData.length > 200) {
      buffer.writeln('Receipt Preview (first 100 chars):');
      buffer.writeln(receiptData.substring(0, 100));
      buffer.writeln('...');
      buffer.writeln('\nReceipt Preview (last 100 chars):');
      buffer.writeln('...');
      buffer.writeln(receiptData.substring(receiptData.length - 100));
    } else {
      buffer.writeln('Receipt Data:\n$receiptData');
    }

    showDialog(
      context: context,
      builder:
          (ctx) => AlertDialog(
            title: const Text('🍎 iOS Payload Debug'),
            content: SingleChildScrollView(
              child: SelectableText(
                buffer.toString(),
                style: const TextStyle(fontFamily: 'monospace', fontSize: 12),
              ),
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Clipboard.setData(ClipboardData(text: buffer.toString()));
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Payload copied to clipboard'),
                    ),
                  );
                },
                child: const Text('Copy'),
              ),
              TextButton(
                onPressed: () {
                  // Copy full receipt data
                  Clipboard.setData(ClipboardData(text: receiptData));
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Receipt data copied')),
                  );
                },
                child: const Text('Copy Receipt'),
              ),
              TextButton(
                onPressed: () => Navigator.of(ctx).pop(),
                child: const Text('Close'),
              ),
            ],
          ),
    );
  }
}
