import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:open_file/open_file.dart';
import 'package:share_plus/share_plus.dart';
import 'package:flutter/foundation.dart';

Future<void> downloadFileBytes(List<int> bytes, String filename) async {
  try {
    final directory = await getApplicationDocumentsDirectory();
    final file = File('${directory.path}/$filename');
    await file.writeAsBytes(bytes);
    
    debugPrint('File saved to: ${file.path}');

    // On mobile, try to open the file first
    final result = await OpenFile.open(file.path);
    
    if (result.type != ResultType.done) {
      // If opening fails, fallback to sharing
      await SharePlus.instance.share(
        ShareParams(
          files: [XFile(file.path)],
          text: filename,
        ),
      );
    }
  } catch (e) {
    debugPrint('Error saving/opening file: $e');
    // Final fallback attempt for sharing
    try {
      final directory = await getApplicationDocumentsDirectory();
      final file = File('${directory.path}/$filename');
      if (await file.exists()) {
        await SharePlus.instance.share(
          ShareParams(
            files: [XFile(file.path)],
            text: filename,
          ),
        );
      }
    } catch (innerE) {
      debugPrint('Fallback sharing failed: $innerE');
    }
  }
}
