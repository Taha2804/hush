import 'package:flutter_test/flutter_test.dart';
import 'package:hushbug/domain/models/word_entry.dart';
import 'package:hushbug/domain/word_source.dart';

class FakeSource extends WordSource {
  FakeSource(this.id, {this.available = true, this.words = 0, this.throws = false});

  @override
  final String id;
  final bool available;
  final int words;
  final bool throws;
  int calls = 0;

  @override
  String get name => id;
  @override
  bool get requiresInternet => false;
  @override
  Future<bool> isAvailable() async => available;
  @override
  Future<List<String>> categories() async => ['Food', 'Animals'];
  @override
  Future<List<WordEntry>> fetchWords(String category, int count) async {
    calls++;
    if (throws) throw Exception('network');
    return [
      for (var i = 0; i < words; i++)
        WordEntry(id: '$id:$category:$i', category: category, word: 'W$i', source: id),
    ];
  }
}

void main() {
  test('online with enough words is used directly', () async {
    final r = await resolveWords(
      primary: FakeSource('online', words: 10),
      cache: FakeSource('cache', words: 10),
      fallback: FakeSource('offline', words: 10),
      categories: ['Food'],
    );
    expect(r.sourceUsed, 'online');
    expect(r.notice, isNull);
  });

  test('offline device -> cache', () async {
    final cache = FakeSource('cache', words: 10);
    final r = await resolveWords(
      primary: FakeSource('online', available: false),
      cache: cache,
      fallback: FakeSource('offline', words: 10),
      categories: ['Food'],
    );
    expect(r.sourceUsed, 'cache');
    expect(r.notice, 'offline_using_cache');
  });

  test('network error and empty cache -> offline packs', () async {
    final r = await resolveWords(
      primary: FakeSource('online', throws: true),
      cache: FakeSource('cache', words: 2),
      fallback: FakeSource('offline', words: 10),
      categories: ['Food'],
    );
    expect(r.sourceUsed, 'offline');
    expect(r.notice, 'offline_using_packs');
    expect(r.total, 10);
  });

  test('too few online words -> cache -> packs order', () async {
    final online = FakeSource('online', words: 1);
    final cache = FakeSource('cache', words: 1);
    final offline = FakeSource('offline', words: 7);
    final r = await resolveWords(
        primary: online, cache: cache, fallback: offline, categories: ['Food']);
    expect([online.calls, cache.calls, offline.calls], [1, 1, 1]);
    expect(r.sourceUsed, 'offline');
  });
}
