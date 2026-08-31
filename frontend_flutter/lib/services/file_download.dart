import 'dart:typed_data';
import 'file_download_stub.dart'
    if (dart.library.html) 'file_download_web.dart' as implementation;

void downloadBytes(Uint8List bytes, String fileName, String mimeType) {
  implementation.downloadBytes(bytes, fileName, mimeType);
}

void openPrintableHtml(String htmlContent) {
  implementation.openPrintableHtml(htmlContent);
}
