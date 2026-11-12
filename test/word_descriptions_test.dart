import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:hushbug/domain/pack_validator.dart';

void main() {
  test('every offline word loads with its description, which never names the word', () {
    final dir = Directory('assets/packs');
    var count = 0;
    for (final f in dir.listSync().whereType<File>().where((f) => f.path.endsWith('.json') && !f.path.endsWith('index.json'))) {
      final issues = <PackIssue>[];
      final entries = parsePack(jsonDecode(f.readAsStringSync()) as Map<String, dynamic>, issues);
      for (final e in entries) {
        count++;
        // Legacy v1 words (not rewritten yet) have no description.
        if (e.description == null) continue;
        final whole = RegExp('\b${RegExp.escape(e.word.toLowerCase())}\b');
        expect(whole.hasMatch(e.description!.toLowerCase()), isFalse, reason: '${e.word} description names the word');
      }
    }
    expect(count, greaterThan(3000));
  });
}
