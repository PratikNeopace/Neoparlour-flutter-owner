import 'dart:io';

void main() async {
  final dir = Directory('lib');
  final files = dir.listSync(recursive: true).whereType<File>().where((f) => f.path.endsWith('.dart'));

  for (final file in files) {
    if (file.path.contains('custom_refresh_indicator.dart')) continue;

    String content = await file.readAsString();
    if (content.contains('RefreshIndicator(')) {
      stdout.writeln('Updating ${file.path}...');
      
      content = content.replaceAll('RefreshIndicator(', 'CustomRefreshIndicator(');

      if (!content.contains('package:neo_parlour_owner/widgets/custom_refresh_indicator.dart')) {
        final lines = content.split('\n');
        int lastImportIdx = -1;
        for (int i = 0; i < lines.length; i++) {
          if (lines[i].startsWith('import ')) {
            lastImportIdx = i;
          }
        }
        
        if (lastImportIdx != -1) {
          lines.insert(lastImportIdx + 1, "import 'package:neo_parlour_owner/widgets/custom_refresh_indicator.dart';");
          content = lines.join('\n');
        }
      }

      await file.writeAsString(content);
    }
  }
}
