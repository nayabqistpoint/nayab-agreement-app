import 'dart:typed_data';
import 'stamp_file_service.dart';

class StampPdfStateService {
  Uint8List? stampPdfBytes;
  List<Uint8List?> cachedStampPages = [];
  String? loadedPdfFileName;
  bool isLoadingPdf = false;

  void reset() {
    stampPdfBytes = null;
    cachedStampPages = [];
    loadedPdfFileName = null;
    isLoadingPdf = false;
  }

  void setLoadedPdf(Uint8List bytes, String? fileName) {
    stampPdfBytes = bytes;
    loadedPdfFileName = fileName;
  }

  Future<bool> pickAndLoadPdf() async {
    final file = await StampFileService.pickPdfFile();
    if (file != null && file.bytes != null) {
      stampPdfBytes = file.bytes!;
      loadedPdfFileName = file.name;
      await renderPages(stampPdfBytes!);
      return true;
    }
    return false;
  }

  Future<void> renderPages(Uint8List bytes) async {
    isLoadingPdf = true;
    cachedStampPages = await StampFileService.rasterizePdf(bytes);
    isLoadingPdf = false;
  }
}