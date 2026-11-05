import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
// ignore: avoid_web_libraries_in_flutter, deprecated_member_use
import 'dart:html' as html;

class QrScannerService {
  static Future<String?> scanQrCode(BuildContext context) async {
    return await Navigator.push<String>(
      context,
      MaterialPageRoute(builder: (context) => const _QrScannerView()),
    );
  }
}

class _QrScannerView extends StatefulWidget {
  const _QrScannerView();

  @override
  State<_QrScannerView> createState() => _QrScannerViewState();
}

class _QrScannerViewState extends State<_QrScannerView> {
  final MobileScannerController _controller = MobileScannerController(
    facing: CameraFacing.back,
    torchEnabled: false,
  );
  bool _scanned = false;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  // ویب یا ڈیوائس سے کیو آر تصویر چننا
  void _pickQrImageFromGallery() {
    if (kIsWeb) {
      final input = html.FileUploadInputElement()..accept = 'image/*';
      input.click();

      input.onChange.listen((event) {
        final files = input.files;
        if (files == null || files.isEmpty) return;

        final file = files.first;
        final reader = html.FileReader();

        reader.onLoadEnd.listen((e) async {
          final blobUrl = html.Url.createObjectUrlFromBlob(file);
          try {
            final barcodeCapture = await _controller.analyzeImage(blobUrl);
            if (barcodeCapture != null && barcodeCapture.barcodes.isNotEmpty) {
              final code = barcodeCapture.barcodes.first.rawValue;
              if (code != null && !_scanned && mounted) {
                _scanned = true;
                Navigator.pop(context, code);
              }
            } else {
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('اس تصویر میں سے کوئی کیو آر کوڈ نہیں ملا!')),
                );
              }
            }
          } catch (err) {
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('کیو آر کوڈ پڑھنے میں مسئلہ: $err')),
              );
            }
          } finally {
            html.Url.revokeObjectUrl(blobUrl);
          }
        });

        reader.readAsArrayBuffer(file);
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('گیلری فیچر فی الحال ویب پر لائیو ٹیسٹ ہو رہا ہے۔')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text('کیو آر کوڈ سکین کریں', style: TextStyle(fontSize: 18)),
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        actions: [
          // 1. گیلری سے تصویر چننے کا بٹن
          IconButton(
            icon: const Icon(Icons.photo_library_outlined),
            tooltip: 'گیلری سے تصویر منتخب کریں',
            onPressed: _pickQrImageFromGallery,
          ),
          // 2. کیمرے کا رخ بدلنا (بیک / فرنٹ)
          IconButton(
            icon: const Icon(Icons.flip_camera_ios_outlined),
            tooltip: 'کیمرے کا رخ بدلیں',
            onPressed: () => _controller.switchCamera(),
          ),
          // 3. ٹارچ آن / آف
          IconButton(
            icon: const Icon(Icons.flash_on_outlined),
            tooltip: 'ٹارچ آن / آف',
            onPressed: () => _controller.toggleTorch(),
          ),
        ],
      ),
      body: Stack(
        alignment: Alignment.center,
        children: [
          MobileScanner(
            controller: _controller,
            onDetect: (capture) {
              if (_scanned) return;
              final barcodes = capture.barcodes;
              for (final barcode in barcodes) {
                if (barcode.rawValue != null) {
                  _scanned = true;
                  Navigator.pop(context, barcode.rawValue);
                  break;
                }
              }
            },
          ),
          // کیمرے کے درمیان اسکیننگ فریم (Overlay)
          Container(
            width: 260,
            height: 260,
            decoration: BoxDecoration(
              border: Border.all(color: Colors.tealAccent, width: 2.5),
              borderRadius: BorderRadius.circular(16),
            ),
          ),
          const Positioned(
            bottom: 40,
            child: Text(
              'کیو آر کوڈ کو فریم کے سامنے لائیں یا اوپر سے تصویر منتخب کریں',
              style: TextStyle(color: Colors.white70, fontSize: 14),
            ),
          ),
        ],
      ),
    );
  }
}