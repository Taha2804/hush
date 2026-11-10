// Generates assets/packs/*.json from the compact authoring files in
// tool/packs_src/*.txt.
//
// Line format (one word per line, `#` starts a comment, blank lines ignored):
//   Word | L1 hint; L1 hint | L2 hint; L2 hint | L3 hint; L3 hint | fake; fake; fake
// Header lines:
//   @id animals
//   @name Animals
//
// Usage: dart run tool/build_packs.dart
import 'dart:convert';
import 'dart:io';

void main() {
  final srcDir = Directory('tool/packs_src');
  final outDir = Directory('assets/packs')..createSync(recursive: true);
  final packs = <String, Map<String, dynamic>>{};
  final files = srcDir.listSync().whereType<File>().where((f) => f.path.endsWith('.txt')).toList()
    ..sort((a, b) => a.path.compareTo(b.path));
  var errors = 0;

  for (final file in files) {
    String? id;
    String? name;
    final lines = file.readAsLinesSync();
    for (var i = 0; i < lines.length; i++) {
      final line = lines[i].trim();
      if (line.isEmpty || line.startsWith('#')) continue;
      if (line.startsWith('@id ')) {
        id = line.substring(4).trim();
        continue;
      }
      if (line.startsWith('@name ')) {
        name = line.substring(6).trim();
        continue;
      }
      if (id == null || name == null) {
        stderr.writeln('${file.path}:${i + 1}: @id/@name must come first');
        errors++;
        continue;
      }
      final parts = line.split('|').map((p) => p.trim()).toList();
      if (parts.length != 5) {
        stderr.writeln('${file.path}:${i + 1}: expected 5 fields, got ${parts.length}: $line');
        errors++;
        continue;
      }
      List<String> split(String s) =>
          s.split(';').map((x) => x.trim()).where((x) => x.isNotEmpty).toList();
      final hints = <Map<String, dynamic>>[
        for (var lvl = 1; lvl <= 3; lvl++)
          for (final h in split(parts[lvl])) {'text': h, 'level': lvl},
      ];
      final pack = packs.putIfAbsent(id, () => {'id': id, 'name': name, 'words': <Map<String, dynamic>>[]});
      (pack['words'] as List).add({'word': parts[0], 'hints': hints, 'fakes': split(parts[4])});
    }
  }

  const encoder = JsonEncoder.withIndent(' ');
  final index = <Map<String, dynamic>>[];
  for (final entry in packs.entries) {
    File('${outDir.path}/${entry.key}.json').writeAsStringSync(encoder.convert(entry.value));
    final count = (entry.value['words'] as List).length;
    index.add({'id': entry.key, 'name': entry.value['name'], 'count': count});
    stdout.writeln('${entry.key.padRight(22)} $count words');
  }
  index.sort((a, b) => (a['name'] as String).compareTo(b['name'] as String));
  File('${outDir.path}/index.json').writeAsStringSync(encoder.convert(index));
  if (errors > 0) {
    stderr.writeln('$errors parse error(s).');
    exit(1);
  }
}
