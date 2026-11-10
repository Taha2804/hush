import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:hushbug/data/sources/offline_source.dart';
import 'package:hushbug/domain/blocklist.dart';
import 'package:hushbug/domain/pack_validator.dart';

/// Runs the same checks as `dart run tool/validate_packs.dart` so CI fails
/// on any invalid bundled pack.
void main() {
  final bl = Blocklist.fromText(
    blocked: File('assets/blocklist.txt').readAsStringSync(),
    brands: File('assets/brands.txt').readAsStringSync(),
  );

  test('all bundled packs are valid (20+ packs, 150+ words each)', () {
    final files = Directory('assets/packs')
        .listSync()
        .whereType<File>()
        .where((f) => f.path.endsWith('.json') && !f.path.endsWith('index.json'))
        .toList();
    expect(files.length, greaterThanOrEqualTo(20));
    final errors = <PackIssue>[];
    for (final f in files) {
      final issues = <PackIssue>[];
      final json = jsonDecode(f.readAsStringSync()) as Map<String, dynamic>;
      final entries = parsePack(json, issues);
      issues.addAll(validatePack(json['id'] as String, entries, bl));
      errors.addAll(issues.where((i) => !i.warning));
    }
    expect(errors, isEmpty, reason: errors.take(20).join('\n'));
  });

  test('OfflinePackSource loads index and packs via the asset loader', () async {
    final src = OfflinePackSource((p) async => File(p).readAsStringSync());
    final cats = await src.categories();
    expect(cats, contains('animals'));
    final words = await src.fetchWords('animals', 999);
    expect(words.length, greaterThanOrEqualTo(150));
    expect(words.first.hints.length, 6);
    expect(await src.categoryName('fruits_vegetables'), 'Fruits & Vegetables');
  });
}
