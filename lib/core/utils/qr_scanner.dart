import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

class QrScanner {
  static Future<String?> scan(BuildContext context, {String title = 'بارکوڈ / QR اسکین کریں'}) async {
    return await Navigator.push<String>(
      context,
      MaterialPageRoute(
        builder: (_) => FullScreenScannerPage(title: title),
      ),
    );
  }
}

class FullScreenScannerPage extends StatefulWidget {
  final String title;
  const FullScreenScannerPage({super.key, required this.title});

  @override
  State<FullScreenScannerPage> createState() => _FullScreenScannerPageState();
}

class _FullScreenScannerPageState extends State<FullScreenScannerPage> {
  final MobileScannerController _controller = MobileScannerController();
  final ImagePicker _picker = ImagePicker();
  bool _isTorchOn = false;

  Future<void> _pickImageFromGallery() async {
    try {
      final XFile? file = await _picker.pickImage(source: ImageSource.gallery);
      if (file == null) return;

      final BarcodeCapture? barcodes = await _controller.analyzeImage(file.path);
      if (barcodes != null && barcodes.barcodes.isNotEmpty) {
        final val = barcodes.barcodes.first.rawValue;
        if (mounted && val != null && val.isNotEmpty) {
          Navigator.pop(context, val);
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('منتخب کردہ تصویر میں کوئی بارکوڈ یا QR کوڈ نہیں ملا'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      debugPrint('Gallery barcode scan error: $e');
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: Colors.black,
        appBar: AppBar(
          backgroundColor: Colors.black,
          foregroundColor: Colors.white,
          title: Text(
            widget.title,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          actions: [
            // گیلری بٹن
            IconButton(
              icon: const Icon(Icons.photo_library_outlined),
              tooltip: 'گیلری سے تصویر منتخب کریں',
              onPressed: _pickImageFromGallery,
            ),
            // ٹارچ بٹن
            IconButton(
              icon: Icon(_isTorchOn ? Icons.flash_on : Icons.flash_off),
              tooltip: 'ٹارچ',
              onPressed: () {
                _controller.toggleTorch();
                setState(() => _isTorchOn = !_isTorchOn);
              },
            ),
            // کیمرہ سوئچ (Front / Back)
            IconButton(
              icon: const Icon(Icons.flip_camera_ios),
              tooltip: 'کیمرہ بدلیں',
              onPressed: () => _controller.switchCamera(),
            ),
          ],
        ),
        body: Stack(
          alignment: Alignment.center,
          children: [
            MobileScanner(
              controller: _controller,
              onDetect: (capture) {
                final barcodes = capture.barcodes;
                if (barcodes.isNotEmpty) {
                  final String? val = barcodes.first.rawValue;
                  if (val != null && val.trim().isNotEmpty) {
                    Navigator.pop(context, val.trim());
                  }
                }
              },
            ),
            // ویژول گائیڈ فریم
            Container(
              width: 260,
              height: 260,
              decoration: BoxDecoration(
                border: Border.all(color: Colors.white70, width: 2),
                borderRadius: BorderRadius.circular(16),
              ),
            ),
          ],
        ),
      ),
    );
  }
}