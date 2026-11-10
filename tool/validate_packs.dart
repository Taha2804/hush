// Validates every bundled Offline Pack against the schema, duplicate,
// hint-quality and fake-word rules. Exits with code 1 on any error.
//
// Usage: dart run tool/validate_packs.dart
import 'dart:convert';
import 'dart:io';

import 'package:hushbug/domain/blocklist.dart';
import 'package:hushbug/domain/models/word_entry.dart';
import 'package:hushbug/domain/pack_validator.dart';

void main() {
  final bl = Blocklist.fromText(
    blocked: File('assets/blocklist.txt').readAsStringSync(),
    brands: File('assets/brands.txt').readAsStringSync(),
  );
  final dir = Directory('assets/packs');
  final files = dir
      .listSync()
      .whereType<File>()
      .where((f) => f.path.endsWith('.json') && !f.path.endsWith('index.json'))
      .toList()
    ..sort((a, b) => a.path.compareTo(b.path));

  final all = <PackIssue>[];
  final packs = <String, List<WordEntry>>{};
  var words = 0;
  for (final f in files) {
    final issues = <PackIssue>[];
    Map<String, dynamic> json;
    try {
      json = jsonDecode(f.readAsStringSync()) as Map<String, dynamic>;
    } catch (e) {
      all.add(PackIssue(f.path, '-', 'invalid JSON: $e'));
      continue;
    }
    final entries = parsePack(json, issues);
    final id = json['id'] as String? ?? f.path;
    issues.addAll(validatePack(id, entries, bl));
    packs[id] = entries;
    words += entries.length;
    all.addAll(issues);
    stdout.writeln('${id.padRight(22)} ${entries.length.toString().padLeft(4)} words  '
        '${issues.where((i) => !i.warning).length} errors');
  }
  all.addAll(crossPackDuplicates(packs));

  final errors = all.where((i) => !i.warning).toList();
  final warnings = all.where((i) => i.warning).toList();
  for (final w in warnings) {
    stdout.writeln(w);
  }
  for (final e in errors) {
    stderr.writeln(e);
  }
  stdout.writeln('\n${packs.length} packs, $words words, '
      '${errors.length} errors, ${warnings.length} warnings.');
  if (packs.length < 20) {
    stderr.writeln('ERROR: need at least 20 packs, found ${packs.length}.');
    exit(1);
  }
  if (errors.isNotEmpty) {
    stderr.writeln('PACK VALIDATION FAILED.');
    exit(1);
  }
  stdout.writeln('All packs valid.');
}
