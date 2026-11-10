import 'package:drift/drift.dart';

import '../../domain/state_store.dart';

part 'app_db.g.dart';

/// Generic key/value rows: shuffle bags, recent history, hint/fake usage.
class KvRows extends Table {
  TextColumn get key => text()();
  TextColumn get value => text()();

  @override
  Set<Column> get primaryKey => {key};
}

/// Online-source cache of candidate and enriched words.
class CachedWords extends Table {
  TextColumn get id => text()();
  TextColumn get category => text()();
  TextColumn get word => text()();
  TextColumn get hintsJson => text().withDefault(const Constant('[]'))();
  TextColumn get fakesJson => text().withDefault(const Constant('[]'))();
  RealColumn get rank => real().withDefault(const Constant(0))();
  IntColumn get fetchedAt => integer()();
  BoolColumn get enriched => boolean().withDefault(const Constant(false))();
  BoolColumn get rejected => boolean().withDefault(const Constant(false))();
  BoolColumn get used => boolean().withDefault(const Constant(false))();

  @override
  Set<Column> get primaryKey => {id};
}

/// Negative cache for failed/empty network lookups.
class NegativeCache extends Table {
  TextColumn get key => text()();
  IntColumn get at => integer()();

  @override
  Set<Column> get primaryKey => {key};
}

class CustomPacks extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get name => text()();
  IntColumn get createdAt => integer()();
}

class CustomWords extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get packId =>
      integer().references(CustomPacks, #id, onDelete: KeyAction.cascade)();
  TextColumn get word => text()();
  TextColumn get hintsJson => text().withDefault(const Constant('[]'))();
  TextColumn get fakesJson => text().withDefault(const Constant('[]'))();
}

@DriftDatabase(tables: [KvRows, CachedWords, NegativeCache, CustomPacks, CustomWords])
class AppDb extends _$AppDb {
  AppDb(super.e);

  @override
  int get schemaVersion => 1;

  @override
  MigrationStrategy get migration => MigrationStrategy(
        beforeOpen: (details) async {
          await customStatement('PRAGMA foreign_keys = ON');
        },
      );
}

/// [KeyValueStore] implemented on the [KvRows] table.
class DriftKeyValueStore implements KeyValueStore {
  DriftKeyValueStore(this.db);
  final AppDb db;

  @override
  Future<String?> read(String key) async {
    final row = await (db.select(db.kvRows)..where((t) => t.key.equals(key)))
        .getSingleOrNull();
    return row?.value;
  }

  @override
  Future<void> write(String key, String value) => db
      .into(db.kvRows)
      .insertOnConflictUpdate(KvRowsCompanion.insert(key: key, value: value));

  @override
  Future<void> deletePrefix(String prefix) =>
      (db.delete(db.kvRows)..where((t) => t.key.like('$prefix%'))).go();
}
