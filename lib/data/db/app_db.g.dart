// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_db.dart';

// ignore_for_file: type=lint
class $KvRowsTable extends KvRows with TableInfo<$KvRowsTable, KvRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $KvRowsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _keyMeta = const VerificationMeta('key');
  @override
  late final GeneratedColumn<String> key = GeneratedColumn<String>(
    'key',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _valueMeta = const VerificationMeta('value');
  @override
  late final GeneratedColumn<String> value = GeneratedColumn<String>(
    'value',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [key, value];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'kv_rows';
  @override
  VerificationContext validateIntegrity(
    Insertable<KvRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('key')) {
      context.handle(
        _keyMeta,
        key.isAcceptableOrUnknown(data['key']!, _keyMeta),
      );
    } else if (isInserting) {
      context.missing(_keyMeta);
    }
    if (data.containsKey('value')) {
      context.handle(
        _valueMeta,
        value.isAcceptableOrUnknown(data['value']!, _valueMeta),
      );
    } else if (isInserting) {
      context.missing(_valueMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {key};
  @override
  KvRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return KvRow(
      key: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}key'],
      )!,
      value: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}value'],
      )!,
    );
  }

  @override
  $KvRowsTable createAlias(String alias) {
    return $KvRowsTable(attachedDatabase, alias);
  }
}

class KvRow extends DataClass implements Insertable<KvRow> {
  final String key;
  final String value;
  const KvRow({required this.key, required this.value});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['key'] = Variable<String>(key);
    map['value'] = Variable<String>(value);
    return map;
  }

  KvRowsCompanion toCompanion(bool nullToAbsent) {
    return KvRowsCompanion(key: Value(key), value: Value(value));
  }

  factory KvRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return KvRow(
      key: serializer.fromJson<String>(json['key']),
      value: serializer.fromJson<String>(json['value']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'key': serializer.toJson<String>(key),
      'value': serializer.toJson<String>(value),
    };
  }

  KvRow copyWith({String? key, String? value}) =>
      KvRow(key: key ?? this.key, value: value ?? this.value);
  KvRow copyWithCompanion(KvRowsCompanion data) {
    return KvRow(
      key: data.key.present ? data.key.value : this.key,
      value: data.value.present ? data.value.value : this.value,
    );
  }

  @override
  String toString() {
    return (StringBuffer('KvRow(')
          ..write('key: $key, ')
          ..write('value: $value')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(key, value);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is KvRow && other.key == this.key && other.value == this.value);
}

class KvRowsCompanion extends UpdateCompanion<KvRow> {
  final Value<String> key;
  final Value<String> value;
  final Value<int> rowid;
  const KvRowsCompanion({
    this.key = const Value.absent(),
    this.value = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  KvRowsCompanion.insert({
    required String key,
    required String value,
    this.rowid = const Value.absent(),
  }) : key = Value(key),
       value = Value(value);
  static Insertable<KvRow> custom({
    Expression<String>? key,
    Expression<String>? value,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (key != null) 'key': key,
      if (value != null) 'value': value,
      if (rowid != null) 'rowid': rowid,
    });
  }

  KvRowsCompanion copyWith({
    Value<String>? key,
    Value<String>? value,
    Value<int>? rowid,
  }) {
    return KvRowsCompanion(
      key: key ?? this.key,
      value: value ?? this.value,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (key.present) {
      map['key'] = Variable<String>(key.value);
    }
    if (value.present) {
      map['value'] = Variable<String>(value.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('KvRowsCompanion(')
          ..write('key: $key, ')
          ..write('value: $value, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $CachedWordsTable extends CachedWords
    with TableInfo<$CachedWordsTable, CachedWord> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $CachedWordsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _categoryMeta = const VerificationMeta(
    'category',
  );
  @override
  late final GeneratedColumn<String> category = GeneratedColumn<String>(
    'category',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _wordMeta = const VerificationMeta('word');
  @override
  late final GeneratedColumn<String> word = GeneratedColumn<String>(
    'word',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _hintsJsonMeta = const VerificationMeta(
    'hintsJson',
  );
  @override
  late final GeneratedColumn<String> hintsJson = GeneratedColumn<String>(
    'hints_json',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('[]'),
  );
  static const VerificationMeta _fakesJsonMeta = const VerificationMeta(
    'fakesJson',
  );
  @override
  late final GeneratedColumn<String> fakesJson = GeneratedColumn<String>(
    'fakes_json',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('[]'),
  );
  static const VerificationMeta _rankMeta = const VerificationMeta('rank');
  @override
  late final GeneratedColumn<double> rank = GeneratedColumn<double>(
    'rank',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _fetchedAtMeta = const VerificationMeta(
    'fetchedAt',
  );
  @override
  late final GeneratedColumn<int> fetchedAt = GeneratedColumn<int>(
    'fetched_at',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _enrichedMeta = const VerificationMeta(
    'enriched',
  );
  @override
  late final GeneratedColumn<bool> enriched = GeneratedColumn<bool>(
    'enriched',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("enriched" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _rejectedMeta = const VerificationMeta(
    'rejected',
  );
  @override
  late final GeneratedColumn<bool> rejected = GeneratedColumn<bool>(
    'rejected',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("rejected" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _usedMeta = const VerificationMeta('used');
  @override
  late final GeneratedColumn<bool> used = GeneratedColumn<bool>(
    'used',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("used" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    category,
    word,
    hintsJson,
    fakesJson,
    rank,
    fetchedAt,
    enriched,
    rejected,
    used,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'cached_words';
  @override
  VerificationContext validateIntegrity(
    Insertable<CachedWord> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('category')) {
      context.handle(
        _categoryMeta,
        category.isAcceptableOrUnknown(data['category']!, _categoryMeta),
      );
    } else if (isInserting) {
      context.missing(_categoryMeta);
    }
    if (data.containsKey('word')) {
      context.handle(
        _wordMeta,
        word.isAcceptableOrUnknown(data['word']!, _wordMeta),
      );
    } else if (isInserting) {
      context.missing(_wordMeta);
    }
    if (data.containsKey('hints_json')) {
      context.handle(
        _hintsJsonMeta,
        hintsJson.isAcceptableOrUnknown(data['hints_json']!, _hintsJsonMeta),
      );
    }
    if (data.containsKey('fakes_json')) {
      context.handle(
        _fakesJsonMeta,
        fakesJson.isAcceptableOrUnknown(data['fakes_json']!, _fakesJsonMeta),
      );
    }
    if (data.containsKey('rank')) {
      context.handle(
        _rankMeta,
        rank.isAcceptableOrUnknown(data['rank']!, _rankMeta),
      );
    }
    if (data.containsKey('fetched_at')) {
      context.handle(
        _fetchedAtMeta,
        fetchedAt.isAcceptableOrUnknown(data['fetched_at']!, _fetchedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_fetchedAtMeta);
    }
    if (data.containsKey('enriched')) {
      context.handle(
        _enrichedMeta,
        enriched.isAcceptableOrUnknown(data['enriched']!, _enrichedMeta),
      );
    }
    if (data.containsKey('rejected')) {
      context.handle(
        _rejectedMeta,
        rejected.isAcceptableOrUnknown(data['rejected']!, _rejectedMeta),
      );
    }
    if (data.containsKey('used')) {
      context.handle(
        _usedMeta,
        used.isAcceptableOrUnknown(data['used']!, _usedMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  CachedWord map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return CachedWord(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      category: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}category'],
      )!,
      word: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}word'],
      )!,
      hintsJson: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}hints_json'],
      )!,
      fakesJson: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}fakes_json'],
      )!,
      rank: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}rank'],
      )!,
      fetchedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}fetched_at'],
      )!,
      enriched: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}enriched'],
      )!,
      rejected: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}rejected'],
      )!,
      used: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}used'],
      )!,
    );
  }

  @override
  $CachedWordsTable createAlias(String alias) {
    return $CachedWordsTable(attachedDatabase, alias);
  }
}

class CachedWord extends DataClass implements Insertable<CachedWord> {
  final String id;
  final String category;
  final String word;
  final String hintsJson;
  final String fakesJson;
  final double rank;
  final int fetchedAt;
  final bool enriched;
  final bool rejected;
  final bool used;
  const CachedWord({
    required this.id,
    required this.category,
    required this.word,
    required this.hintsJson,
    required this.fakesJson,
    required this.rank,
    required this.fetchedAt,
    required this.enriched,
    required this.rejected,
    required this.used,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['category'] = Variable<String>(category);
    map['word'] = Variable<String>(word);
    map['hints_json'] = Variable<String>(hintsJson);
    map['fakes_json'] = Variable<String>(fakesJson);
    map['rank'] = Variable<double>(rank);
    map['fetched_at'] = Variable<int>(fetchedAt);
    map['enriched'] = Variable<bool>(enriched);
    map['rejected'] = Variable<bool>(rejected);
    map['used'] = Variable<bool>(used);
    return map;
  }

  CachedWordsCompanion toCompanion(bool nullToAbsent) {
    return CachedWordsCompanion(
      id: Value(id),
      category: Value(category),
      word: Value(word),
      hintsJson: Value(hintsJson),
      fakesJson: Value(fakesJson),
      rank: Value(rank),
      fetchedAt: Value(fetchedAt),
      enriched: Value(enriched),
      rejected: Value(rejected),
      used: Value(used),
    );
  }

  factory CachedWord.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return CachedWord(
      id: serializer.fromJson<String>(json['id']),
      category: serializer.fromJson<String>(json['category']),
      word: serializer.fromJson<String>(json['word']),
      hintsJson: serializer.fromJson<String>(json['hintsJson']),
      fakesJson: serializer.fromJson<String>(json['fakesJson']),
      rank: serializer.fromJson<double>(json['rank']),
      fetchedAt: serializer.fromJson<int>(json['fetchedAt']),
      enriched: serializer.fromJson<bool>(json['enriched']),
      rejected: serializer.fromJson<bool>(json['rejected']),
      used: serializer.fromJson<bool>(json['used']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'category': serializer.toJson<String>(category),
      'word': serializer.toJson<String>(word),
      'hintsJson': serializer.toJson<String>(hintsJson),
      'fakesJson': serializer.toJson<String>(fakesJson),
      'rank': serializer.toJson<double>(rank),
      'fetchedAt': serializer.toJson<int>(fetchedAt),
      'enriched': serializer.toJson<bool>(enriched),
      'rejected': serializer.toJson<bool>(rejected),
      'used': serializer.toJson<bool>(used),
    };
  }

  CachedWord copyWith({
    String? id,
    String? category,
    String? word,
    String? hintsJson,
    String? fakesJson,
    double? rank,
    int? fetchedAt,
    bool? enriched,
    bool? rejected,
    bool? used,
  }) => CachedWord(
    id: id ?? this.id,
    category: category ?? this.category,
    word: word ?? this.word,
    hintsJson: hintsJson ?? this.hintsJson,
    fakesJson: fakesJson ?? this.fakesJson,
    rank: rank ?? this.rank,
    fetchedAt: fetchedAt ?? this.fetchedAt,
    enriched: enriched ?? this.enriched,
    rejected: rejected ?? this.rejected,
    used: used ?? this.used,
  );
  CachedWord copyWithCompanion(CachedWordsCompanion data) {
    return CachedWord(
      id: data.id.present ? data.id.value : this.id,
      category: data.category.present ? data.category.value : this.category,
      word: data.word.present ? data.word.value : this.word,
      hintsJson: data.hintsJson.present ? data.hintsJson.value : this.hintsJson,
      fakesJson: data.fakesJson.present ? data.fakesJson.value : this.fakesJson,
      rank: data.rank.present ? data.rank.value : this.rank,
      fetchedAt: data.fetchedAt.present ? data.fetchedAt.value : this.fetchedAt,
      enriched: data.enriched.present ? data.enriched.value : this.enriched,
      rejected: data.rejected.present ? data.rejected.value : this.rejected,
      used: data.used.present ? data.used.value : this.used,
    );
  }

  @override
  String toString() {
    return (StringBuffer('CachedWord(')
          ..write('id: $id, ')
          ..write('category: $category, ')
          ..write('word: $word, ')
          ..write('hintsJson: $hintsJson, ')
          ..write('fakesJson: $fakesJson, ')
          ..write('rank: $rank, ')
          ..write('fetchedAt: $fetchedAt, ')
          ..write('enriched: $enriched, ')
          ..write('rejected: $rejected, ')
          ..write('used: $used')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    category,
    word,
    hintsJson,
    fakesJson,
    rank,
    fetchedAt,
    enriched,
    rejected,
    used,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is CachedWord &&
          other.id == this.id &&
          other.category == this.category &&
          other.word == this.word &&
          other.hintsJson == this.hintsJson &&
          other.fakesJson == this.fakesJson &&
          other.rank == this.rank &&
          other.fetchedAt == this.fetchedAt &&
          other.enriched == this.enriched &&
          other.rejected == this.rejected &&
          other.used == this.used);
}

class CachedWordsCompanion extends UpdateCompanion<CachedWord> {
  final Value<String> id;
  final Value<String> category;
  final Value<String> word;
  final Value<String> hintsJson;
  final Value<String> fakesJson;
  final Value<double> rank;
  final Value<int> fetchedAt;
  final Value<bool> enriched;
  final Value<bool> rejected;
  final Value<bool> used;
  final Value<int> rowid;
  const CachedWordsCompanion({
    this.id = const Value.absent(),
    this.category = const Value.absent(),
    this.word = const Value.absent(),
    this.hintsJson = const Value.absent(),
    this.fakesJson = const Value.absent(),
    this.rank = const Value.absent(),
    this.fetchedAt = const Value.absent(),
    this.enriched = const Value.absent(),
    this.rejected = const Value.absent(),
    this.used = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  CachedWordsCompanion.insert({
    required String id,
    required String category,
    required String word,
    this.hintsJson = const Value.absent(),
    this.fakesJson = const Value.absent(),
    this.rank = const Value.absent(),
    required int fetchedAt,
    this.enriched = const Value.absent(),
    this.rejected = const Value.absent(),
    this.used = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       category = Value(category),
       word = Value(word),
       fetchedAt = Value(fetchedAt);
  static Insertable<CachedWord> custom({
    Expression<String>? id,
    Expression<String>? category,
    Expression<String>? word,
    Expression<String>? hintsJson,
    Expression<String>? fakesJson,
    Expression<double>? rank,
    Expression<int>? fetchedAt,
    Expression<bool>? enriched,
    Expression<bool>? rejected,
    Expression<bool>? used,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (category != null) 'category': category,
      if (word != null) 'word': word,
      if (hintsJson != null) 'hints_json': hintsJson,
      if (fakesJson != null) 'fakes_json': fakesJson,
      if (rank != null) 'rank': rank,
      if (fetchedAt != null) 'fetched_at': fetchedAt,
      if (enriched != null) 'enriched': enriched,
      if (rejected != null) 'rejected': rejected,
      if (used != null) 'used': used,
      if (rowid != null) 'rowid': rowid,
    });
  }

  CachedWordsCompanion copyWith({
    Value<String>? id,
    Value<String>? category,
    Value<String>? word,
    Value<String>? hintsJson,
    Value<String>? fakesJson,
    Value<double>? rank,
    Value<int>? fetchedAt,
    Value<bool>? enriched,
    Value<bool>? rejected,
    Value<bool>? used,
    Value<int>? rowid,
  }) {
    return CachedWordsCompanion(
      id: id ?? this.id,
      category: category ?? this.category,
      word: word ?? this.word,
      hintsJson: hintsJson ?? this.hintsJson,
      fakesJson: fakesJson ?? this.fakesJson,
      rank: rank ?? this.rank,
      fetchedAt: fetchedAt ?? this.fetchedAt,
      enriched: enriched ?? this.enriched,
      rejected: rejected ?? this.rejected,
      used: used ?? this.used,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (category.present) {
      map['category'] = Variable<String>(category.value);
    }
    if (word.present) {
      map['word'] = Variable<String>(word.value);
    }
    if (hintsJson.present) {
      map['hints_json'] = Variable<String>(hintsJson.value);
    }
    if (fakesJson.present) {
      map['fakes_json'] = Variable<String>(fakesJson.value);
    }
    if (rank.present) {
      map['rank'] = Variable<double>(rank.value);
    }
    if (fetchedAt.present) {
      map['fetched_at'] = Variable<int>(fetchedAt.value);
    }
    if (enriched.present) {
      map['enriched'] = Variable<bool>(enriched.value);
    }
    if (rejected.present) {
      map['rejected'] = Variable<bool>(rejected.value);
    }
    if (used.present) {
      map['used'] = Variable<bool>(used.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('CachedWordsCompanion(')
          ..write('id: $id, ')
          ..write('category: $category, ')
          ..write('word: $word, ')
          ..write('hintsJson: $hintsJson, ')
          ..write('fakesJson: $fakesJson, ')
          ..write('rank: $rank, ')
          ..write('fetchedAt: $fetchedAt, ')
          ..write('enriched: $enriched, ')
          ..write('rejected: $rejected, ')
          ..write('used: $used, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $NegativeCacheTable extends NegativeCache
    with TableInfo<$NegativeCacheTable, NegativeCacheData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $NegativeCacheTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _keyMeta = const VerificationMeta('key');
  @override
  late final GeneratedColumn<String> key = GeneratedColumn<String>(
    'key',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _atMeta = const VerificationMeta('at');
  @override
  late final GeneratedColumn<int> at = GeneratedColumn<int>(
    'at',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [key, at];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'negative_cache';
  @override
  VerificationContext validateIntegrity(
    Insertable<NegativeCacheData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('key')) {
      context.handle(
        _keyMeta,
        key.isAcceptableOrUnknown(data['key']!, _keyMeta),
      );
    } else if (isInserting) {
      context.missing(_keyMeta);
    }
    if (data.containsKey('at')) {
      context.handle(_atMeta, at.isAcceptableOrUnknown(data['at']!, _atMeta));
    } else if (isInserting) {
      context.missing(_atMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {key};
  @override
  NegativeCacheData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return NegativeCacheData(
      key: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}key'],
      )!,
      at: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}at'],
      )!,
    );
  }

  @override
  $NegativeCacheTable createAlias(String alias) {
    return $NegativeCacheTable(attachedDatabase, alias);
  }
}

class NegativeCacheData extends DataClass
    implements Insertable<NegativeCacheData> {
  final String key;
  final int at;
  const NegativeCacheData({required this.key, required this.at});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['key'] = Variable<String>(key);
    map['at'] = Variable<int>(at);
    return map;
  }

  NegativeCacheCompanion toCompanion(bool nullToAbsent) {
    return NegativeCacheCompanion(key: Value(key), at: Value(at));
  }

  factory NegativeCacheData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return NegativeCacheData(
      key: serializer.fromJson<String>(json['key']),
      at: serializer.fromJson<int>(json['at']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'key': serializer.toJson<String>(key),
      'at': serializer.toJson<int>(at),
    };
  }

  NegativeCacheData copyWith({String? key, int? at}) =>
      NegativeCacheData(key: key ?? this.key, at: at ?? this.at);
  NegativeCacheData copyWithCompanion(NegativeCacheCompanion data) {
    return NegativeCacheData(
      key: data.key.present ? data.key.value : this.key,
      at: data.at.present ? data.at.value : this.at,
    );
  }

  @override
  String toString() {
    return (StringBuffer('NegativeCacheData(')
          ..write('key: $key, ')
          ..write('at: $at')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(key, at);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is NegativeCacheData &&
          other.key == this.key &&
          other.at == this.at);
}

class NegativeCacheCompanion extends UpdateCompanion<NegativeCacheData> {
  final Value<String> key;
  final Value<int> at;
  final Value<int> rowid;
  const NegativeCacheCompanion({
    this.key = const Value.absent(),
    this.at = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  NegativeCacheCompanion.insert({
    required String key,
    required int at,
    this.rowid = const Value.absent(),
  }) : key = Value(key),
       at = Value(at);
  static Insertable<NegativeCacheData> custom({
    Expression<String>? key,
    Expression<int>? at,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (key != null) 'key': key,
      if (at != null) 'at': at,
      if (rowid != null) 'rowid': rowid,
    });
  }

  NegativeCacheCompanion copyWith({
    Value<String>? key,
    Value<int>? at,
    Value<int>? rowid,
  }) {
    return NegativeCacheCompanion(
      key: key ?? this.key,
      at: at ?? this.at,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (key.present) {
      map['key'] = Variable<String>(key.value);
    }
    if (at.present) {
      map['at'] = Variable<int>(at.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('NegativeCacheCompanion(')
          ..write('key: $key, ')
          ..write('at: $at, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $CustomPacksTable extends CustomPacks
    with TableInfo<$CustomPacksTable, CustomPack> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $CustomPacksTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<int> createdAt = GeneratedColumn<int>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [id, name, createdAt];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'custom_packs';
  @override
  VerificationContext validateIntegrity(
    Insertable<CustomPack> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  CustomPack map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return CustomPack(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}created_at'],
      )!,
    );
  }

  @override
  $CustomPacksTable createAlias(String alias) {
    return $CustomPacksTable(attachedDatabase, alias);
  }
}

class CustomPack extends DataClass implements Insertable<CustomPack> {
  final int id;
  final String name;
  final int createdAt;
  const CustomPack({
    required this.id,
    required this.name,
    required this.createdAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['name'] = Variable<String>(name);
    map['created_at'] = Variable<int>(createdAt);
    return map;
  }

  CustomPacksCompanion toCompanion(bool nullToAbsent) {
    return CustomPacksCompanion(
      id: Value(id),
      name: Value(name),
      createdAt: Value(createdAt),
    );
  }

  factory CustomPack.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return CustomPack(
      id: serializer.fromJson<int>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      createdAt: serializer.fromJson<int>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'name': serializer.toJson<String>(name),
      'createdAt': serializer.toJson<int>(createdAt),
    };
  }

  CustomPack copyWith({int? id, String? name, int? createdAt}) => CustomPack(
    id: id ?? this.id,
    name: name ?? this.name,
    createdAt: createdAt ?? this.createdAt,
  );
  CustomPack copyWithCompanion(CustomPacksCompanion data) {
    return CustomPack(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('CustomPack(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, name, createdAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is CustomPack &&
          other.id == this.id &&
          other.name == this.name &&
          other.createdAt == this.createdAt);
}

class CustomPacksCompanion extends UpdateCompanion<CustomPack> {
  final Value<int> id;
  final Value<String> name;
  final Value<int> createdAt;
  const CustomPacksCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.createdAt = const Value.absent(),
  });
  CustomPacksCompanion.insert({
    this.id = const Value.absent(),
    required String name,
    required int createdAt,
  }) : name = Value(name),
       createdAt = Value(createdAt);
  static Insertable<CustomPack> custom({
    Expression<int>? id,
    Expression<String>? name,
    Expression<int>? createdAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (createdAt != null) 'created_at': createdAt,
    });
  }

  CustomPacksCompanion copyWith({
    Value<int>? id,
    Value<String>? name,
    Value<int>? createdAt,
  }) {
    return CustomPacksCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<int>(createdAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('CustomPacksCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }
}

class $CustomWordsTable extends CustomWords
    with TableInfo<$CustomWordsTable, CustomWord> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $CustomWordsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _packIdMeta = const VerificationMeta('packId');
  @override
  late final GeneratedColumn<int> packId = GeneratedColumn<int>(
    'pack_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES custom_packs (id) ON DELETE CASCADE',
    ),
  );
  static const VerificationMeta _wordMeta = const VerificationMeta('word');
  @override
  late final GeneratedColumn<String> word = GeneratedColumn<String>(
    'word',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _hintsJsonMeta = const VerificationMeta(
    'hintsJson',
  );
  @override
  late final GeneratedColumn<String> hintsJson = GeneratedColumn<String>(
    'hints_json',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('[]'),
  );
  static const VerificationMeta _fakesJsonMeta = const VerificationMeta(
    'fakesJson',
  );
  @override
  late final GeneratedColumn<String> fakesJson = GeneratedColumn<String>(
    'fakes_json',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('[]'),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    packId,
    word,
    hintsJson,
    fakesJson,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'custom_words';
  @override
  VerificationContext validateIntegrity(
    Insertable<CustomWord> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('pack_id')) {
      context.handle(
        _packIdMeta,
        packId.isAcceptableOrUnknown(data['pack_id']!, _packIdMeta),
      );
    } else if (isInserting) {
      context.missing(_packIdMeta);
    }
    if (data.containsKey('word')) {
      context.handle(
        _wordMeta,
        word.isAcceptableOrUnknown(data['word']!, _wordMeta),
      );
    } else if (isInserting) {
      context.missing(_wordMeta);
    }
    if (data.containsKey('hints_json')) {
      context.handle(
        _hintsJsonMeta,
        hintsJson.isAcceptableOrUnknown(data['hints_json']!, _hintsJsonMeta),
      );
    }
    if (data.containsKey('fakes_json')) {
      context.handle(
        _fakesJsonMeta,
        fakesJson.isAcceptableOrUnknown(data['fakes_json']!, _fakesJsonMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  CustomWord map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return CustomWord(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      packId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}pack_id'],
      )!,
      word: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}word'],
      )!,
      hintsJson: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}hints_json'],
      )!,
      fakesJson: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}fakes_json'],
      )!,
    );
  }

  @override
  $CustomWordsTable createAlias(String alias) {
    return $CustomWordsTable(attachedDatabase, alias);
  }
}

class CustomWord extends DataClass implements Insertable<CustomWord> {
  final int id;
  final int packId;
  final String word;
  final String hintsJson;
  final String fakesJson;
  const CustomWord({
    required this.id,
    required this.packId,
    required this.word,
    required this.hintsJson,
    required this.fakesJson,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['pack_id'] = Variable<int>(packId);
    map['word'] = Variable<String>(word);
    map['hints_json'] = Variable<String>(hintsJson);
    map['fakes_json'] = Variable<String>(fakesJson);
    return map;
  }

  CustomWordsCompanion toCompanion(bool nullToAbsent) {
    return CustomWordsCompanion(
      id: Value(id),
      packId: Value(packId),
      word: Value(word),
      hintsJson: Value(hintsJson),
      fakesJson: Value(fakesJson),
    );
  }

  factory CustomWord.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return CustomWord(
      id: serializer.fromJson<int>(json['id']),
      packId: serializer.fromJson<int>(json['packId']),
      word: serializer.fromJson<String>(json['word']),
      hintsJson: serializer.fromJson<String>(json['hintsJson']),
      fakesJson: serializer.fromJson<String>(json['fakesJson']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'packId': serializer.toJson<int>(packId),
      'word': serializer.toJson<String>(word),
      'hintsJson': serializer.toJson<String>(hintsJson),
      'fakesJson': serializer.toJson<String>(fakesJson),
    };
  }

  CustomWord copyWith({
    int? id,
    int? packId,
    String? word,
    String? hintsJson,
    String? fakesJson,
  }) => CustomWord(
    id: id ?? this.id,
    packId: packId ?? this.packId,
    word: word ?? this.word,
    hintsJson: hintsJson ?? this.hintsJson,
    fakesJson: fakesJson ?? this.fakesJson,
  );
  CustomWord copyWithCompanion(CustomWordsCompanion data) {
    return CustomWord(
      id: data.id.present ? data.id.value : this.id,
      packId: data.packId.present ? data.packId.value : this.packId,
      word: data.word.present ? data.word.value : this.word,
      hintsJson: data.hintsJson.present ? data.hintsJson.value : this.hintsJson,
      fakesJson: data.fakesJson.present ? data.fakesJson.value : this.fakesJson,
    );
  }

  @override
  String toString() {
    return (StringBuffer('CustomWord(')
          ..write('id: $id, ')
          ..write('packId: $packId, ')
          ..write('word: $word, ')
          ..write('hintsJson: $hintsJson, ')
          ..write('fakesJson: $fakesJson')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, packId, word, hintsJson, fakesJson);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is CustomWord &&
          other.id == this.id &&
          other.packId == this.packId &&
          other.word == this.word &&
          other.hintsJson == this.hintsJson &&
          other.fakesJson == this.fakesJson);
}

class CustomWordsCompanion extends UpdateCompanion<CustomWord> {
  final Value<int> id;
  final Value<int> packId;
  final Value<String> word;
  final Value<String> hintsJson;
  final Value<String> fakesJson;
  const CustomWordsCompanion({
    this.id = const Value.absent(),
    this.packId = const Value.absent(),
    this.word = const Value.absent(),
    this.hintsJson = const Value.absent(),
    this.fakesJson = const Value.absent(),
  });
  CustomWordsCompanion.insert({
    this.id = const Value.absent(),
    required int packId,
    required String word,
    this.hintsJson = const Value.absent(),
    this.fakesJson = const Value.absent(),
  }) : packId = Value(packId),
       word = Value(word);
  static Insertable<CustomWord> custom({
    Expression<int>? id,
    Expression<int>? packId,
    Expression<String>? word,
    Expression<String>? hintsJson,
    Expression<String>? fakesJson,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (packId != null) 'pack_id': packId,
      if (word != null) 'word': word,
      if (hintsJson != null) 'hints_json': hintsJson,
      if (fakesJson != null) 'fakes_json': fakesJson,
    });
  }

  CustomWordsCompanion copyWith({
    Value<int>? id,
    Value<int>? packId,
    Value<String>? word,
    Value<String>? hintsJson,
    Value<String>? fakesJson,
  }) {
    return CustomWordsCompanion(
      id: id ?? this.id,
      packId: packId ?? this.packId,
      word: word ?? this.word,
      hintsJson: hintsJson ?? this.hintsJson,
      fakesJson: fakesJson ?? this.fakesJson,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (packId.present) {
      map['pack_id'] = Variable<int>(packId.value);
    }
    if (word.present) {
      map['word'] = Variable<String>(word.value);
    }
    if (hintsJson.present) {
      map['hints_json'] = Variable<String>(hintsJson.value);
    }
    if (fakesJson.present) {
      map['fakes_json'] = Variable<String>(fakesJson.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('CustomWordsCompanion(')
          ..write('id: $id, ')
          ..write('packId: $packId, ')
          ..write('word: $word, ')
          ..write('hintsJson: $hintsJson, ')
          ..write('fakesJson: $fakesJson')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDb extends GeneratedDatabase {
  _$AppDb(QueryExecutor e) : super(e);
  $AppDbManager get managers => $AppDbManager(this);
  late final $KvRowsTable kvRows = $KvRowsTable(this);
  late final $CachedWordsTable cachedWords = $CachedWordsTable(this);
  late final $NegativeCacheTable negativeCache = $NegativeCacheTable(this);
  late final $CustomPacksTable customPacks = $CustomPacksTable(this);
  late final $CustomWordsTable customWords = $CustomWordsTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
    kvRows,
    cachedWords,
    negativeCache,
    customPacks,
    customWords,
  ];
  @override
  StreamQueryUpdateRules get streamUpdateRules => const StreamQueryUpdateRules([
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'custom_packs',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('custom_words', kind: UpdateKind.delete)],
    ),
  ]);
}

typedef $$KvRowsTableCreateCompanionBuilder = KvRowsCompanion Function({
  required String key,
  required String value,
  Value<int> rowid,
});
typedef $$KvRowsTableUpdateCompanionBuilder = KvRowsCompanion Function({
  Value<String> key,
  Value<String> value,
  Value<int> rowid,
});

class $$KvRowsTableFilterComposer extends Composer<_$AppDb, $KvRowsTable> {
  $$KvRowsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get key => $composableBuilder(
    column: $table.key,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get value => $composableBuilder(
    column: $table.value,
    builder: (column) => ColumnFilters(column),
  );
}

class $$KvRowsTableOrderingComposer extends Composer<_$AppDb, $KvRowsTable> {
  $$KvRowsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get key => $composableBuilder(
    column: $table.key,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get value => $composableBuilder(
    column: $table.value,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$KvRowsTableAnnotationComposer extends Composer<_$AppDb, $KvRowsTable> {
  $$KvRowsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get key =>
      $composableBuilder(column: $table.key, builder: (column) => column);

  GeneratedColumn<String> get value =>
      $composableBuilder(column: $table.value, builder: (column) => column);
}

class $$KvRowsTableTableManager
    extends
        RootTableManager<
          _$AppDb,
          $KvRowsTable,
          KvRow,
          $$KvRowsTableFilterComposer,
          $$KvRowsTableOrderingComposer,
          $$KvRowsTableAnnotationComposer,
          $$KvRowsTableCreateCompanionBuilder,
          $$KvRowsTableUpdateCompanionBuilder,
          (KvRow, BaseReferences<_$AppDb, $KvRowsTable, KvRow>),
          KvRow,
          PrefetchHooks Function()
        > {
  $$KvRowsTableTableManager(_$AppDb db, $KvRowsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$KvRowsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$KvRowsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$KvRowsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> key = const Value.absent(),
            Value<String> value = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) => KvRowsCompanion(key: key, value: value, rowid: rowid),
          createCompanionCallback: ({
            required String key,
            required String value,
            Value<int> rowid = const Value.absent(),
          }) => KvRowsCompanion.insert(key: key, value: value, rowid: rowid),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$KvRowsTable, KvRow>(table),
                  BaseReferences<_$AppDb, $KvRowsTable, KvRow>(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$KvRowsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDb,
      $KvRowsTable,
      KvRow,
      $$KvRowsTableFilterComposer,
      $$KvRowsTableOrderingComposer,
      $$KvRowsTableAnnotationComposer,
      $$KvRowsTableCreateCompanionBuilder,
      $$KvRowsTableUpdateCompanionBuilder,
      (KvRow, BaseReferences<_$AppDb, $KvRowsTable, KvRow>),
      KvRow,
      PrefetchHooks Function()
    >;
typedef $$CachedWordsTableCreateCompanionBuilder =
    CachedWordsCompanion Function({
      required String id,
      required String category,
      required String word,
      Value<String> hintsJson,
      Value<String> fakesJson,
      Value<double> rank,
      required int fetchedAt,
      Value<bool> enriched,
      Value<bool> rejected,
      Value<bool> used,
      Value<int> rowid,
    });
typedef $$CachedWordsTableUpdateCompanionBuilder =
    CachedWordsCompanion Function({
      Value<String> id,
      Value<String> category,
      Value<String> word,
      Value<String> hintsJson,
      Value<String> fakesJson,
      Value<double> rank,
      Value<int> fetchedAt,
      Value<bool> enriched,
      Value<bool> rejected,
      Value<bool> used,
      Value<int> rowid,
    });

class $$CachedWordsTableFilterComposer
    extends Composer<_$AppDb, $CachedWordsTable> {
  $$CachedWordsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get category => $composableBuilder(
    column: $table.category,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get word => $composableBuilder(
    column: $table.word,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get hintsJson => $composableBuilder(
    column: $table.hintsJson,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get fakesJson => $composableBuilder(
    column: $table.fakesJson,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get rank => $composableBuilder(
    column: $table.rank,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get fetchedAt => $composableBuilder(
    column: $table.fetchedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get enriched => $composableBuilder(
    column: $table.enriched,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get rejected => $composableBuilder(
    column: $table.rejected,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get used => $composableBuilder(
    column: $table.used,
    builder: (column) => ColumnFilters(column),
  );
}

class $$CachedWordsTableOrderingComposer
    extends Composer<_$AppDb, $CachedWordsTable> {
  $$CachedWordsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get category => $composableBuilder(
    column: $table.category,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get word => $composableBuilder(
    column: $table.word,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get hintsJson => $composableBuilder(
    column: $table.hintsJson,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get fakesJson => $composableBuilder(
    column: $table.fakesJson,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get rank => $composableBuilder(
    column: $table.rank,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get fetchedAt => $composableBuilder(
    column: $table.fetchedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get enriched => $composableBuilder(
    column: $table.enriched,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get rejected => $composableBuilder(
    column: $table.rejected,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get used => $composableBuilder(
    column: $table.used,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$CachedWordsTableAnnotationComposer
    extends Composer<_$AppDb, $CachedWordsTable> {
  $$CachedWordsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get category =>
      $composableBuilder(column: $table.category, builder: (column) => column);

  GeneratedColumn<String> get word =>
      $composableBuilder(column: $table.word, builder: (column) => column);

  GeneratedColumn<String> get hintsJson =>
      $composableBuilder(column: $table.hintsJson, builder: (column) => column);

  GeneratedColumn<String> get fakesJson =>
      $composableBuilder(column: $table.fakesJson, builder: (column) => column);

  GeneratedColumn<double> get rank =>
      $composableBuilder(column: $table.rank, builder: (column) => column);

  GeneratedColumn<int> get fetchedAt =>
      $composableBuilder(column: $table.fetchedAt, builder: (column) => column);

  GeneratedColumn<bool> get enriched =>
      $composableBuilder(column: $table.enriched, builder: (column) => column);

  GeneratedColumn<bool> get rejected =>
      $composableBuilder(column: $table.rejected, builder: (column) => column);

  GeneratedColumn<bool> get used =>
      $composableBuilder(column: $table.used, builder: (column) => column);
}

class $$CachedWordsTableTableManager
    extends
        RootTableManager<
          _$AppDb,
          $CachedWordsTable,
          CachedWord,
          $$CachedWordsTableFilterComposer,
          $$CachedWordsTableOrderingComposer,
          $$CachedWordsTableAnnotationComposer,
          $$CachedWordsTableCreateCompanionBuilder,
          $$CachedWordsTableUpdateCompanionBuilder,
          (CachedWord, BaseReferences<_$AppDb, $CachedWordsTable, CachedWord>),
          CachedWord,
          PrefetchHooks Function()
        > {
  $$CachedWordsTableTableManager(_$AppDb db, $CachedWordsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$CachedWordsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$CachedWordsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$CachedWordsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> category = const Value.absent(),
                Value<String> word = const Value.absent(),
                Value<String> hintsJson = const Value.absent(),
                Value<String> fakesJson = const Value.absent(),
                Value<double> rank = const Value.absent(),
                Value<int> fetchedAt = const Value.absent(),
                Value<bool> enriched = const Value.absent(),
                Value<bool> rejected = const Value.absent(),
                Value<bool> used = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => CachedWordsCompanion(
                id: id,
                category: category,
                word: word,
                hintsJson: hintsJson,
                fakesJson: fakesJson,
                rank: rank,
                fetchedAt: fetchedAt,
                enriched: enriched,
                rejected: rejected,
                used: used,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String category,
                required String word,
                Value<String> hintsJson = const Value.absent(),
                Value<String> fakesJson = const Value.absent(),
                Value<double> rank = const Value.absent(),
                required int fetchedAt,
                Value<bool> enriched = const Value.absent(),
                Value<bool> rejected = const Value.absent(),
                Value<bool> used = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => CachedWordsCompanion.insert(
                id: id,
                category: category,
                word: word,
                hintsJson: hintsJson,
                fakesJson: fakesJson,
                rank: rank,
                fetchedAt: fetchedAt,
                enriched: enriched,
                rejected: rejected,
                used: used,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$CachedWordsTable, CachedWord>(table),
                  BaseReferences<_$AppDb, $CachedWordsTable, CachedWord>(
                    db,
                    table,
                    e,
                  ),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$CachedWordsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDb,
      $CachedWordsTable,
      CachedWord,
      $$CachedWordsTableFilterComposer,
      $$CachedWordsTableOrderingComposer,
      $$CachedWordsTableAnnotationComposer,
      $$CachedWordsTableCreateCompanionBuilder,
      $$CachedWordsTableUpdateCompanionBuilder,
      (CachedWord, BaseReferences<_$AppDb, $CachedWordsTable, CachedWord>),
      CachedWord,
      PrefetchHooks Function()
    >;
typedef $$NegativeCacheTableCreateCompanionBuilder =
    NegativeCacheCompanion Function({
      required String key,
      required int at,
      Value<int> rowid,
    });
typedef $$NegativeCacheTableUpdateCompanionBuilder =
    NegativeCacheCompanion Function({
      Value<String> key,
      Value<int> at,
      Value<int> rowid,
    });

class $$NegativeCacheTableFilterComposer
    extends Composer<_$AppDb, $NegativeCacheTable> {
  $$NegativeCacheTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get key => $composableBuilder(
    column: $table.key,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get at => $composableBuilder(
    column: $table.at,
    builder: (column) => ColumnFilters(column),
  );
}

class $$NegativeCacheTableOrderingComposer
    extends Composer<_$AppDb, $NegativeCacheTable> {
  $$NegativeCacheTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get key => $composableBuilder(
    column: $table.key,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get at => $composableBuilder(
    column: $table.at,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$NegativeCacheTableAnnotationComposer
    extends Composer<_$AppDb, $NegativeCacheTable> {
  $$NegativeCacheTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get key =>
      $composableBuilder(column: $table.key, builder: (column) => column);

  GeneratedColumn<int> get at =>
      $composableBuilder(column: $table.at, builder: (column) => column);
}

class $$NegativeCacheTableTableManager
    extends
        RootTableManager<
          _$AppDb,
          $NegativeCacheTable,
          NegativeCacheData,
          $$NegativeCacheTableFilterComposer,
          $$NegativeCacheTableOrderingComposer,
          $$NegativeCacheTableAnnotationComposer,
          $$NegativeCacheTableCreateCompanionBuilder,
          $$NegativeCacheTableUpdateCompanionBuilder,
          (
            NegativeCacheData,
            BaseReferences<_$AppDb, $NegativeCacheTable, NegativeCacheData>,
          ),
          NegativeCacheData,
          PrefetchHooks Function()
        > {
  $$NegativeCacheTableTableManager(_$AppDb db, $NegativeCacheTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$NegativeCacheTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$NegativeCacheTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$NegativeCacheTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> key = const Value.absent(),
            Value<int> at = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) => NegativeCacheCompanion(key: key, at: at, rowid: rowid),
          createCompanionCallback: ({
            required String key,
            required int at,
            Value<int> rowid = const Value.absent(),
          }) => NegativeCacheCompanion.insert(key: key, at: at, rowid: rowid),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$NegativeCacheTable, NegativeCacheData>(table),
                  BaseReferences<
                    _$AppDb,
                    $NegativeCacheTable,
                    NegativeCacheData
                  >(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$NegativeCacheTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDb,
      $NegativeCacheTable,
      NegativeCacheData,
      $$NegativeCacheTableFilterComposer,
      $$NegativeCacheTableOrderingComposer,
      $$NegativeCacheTableAnnotationComposer,
      $$NegativeCacheTableCreateCompanionBuilder,
      $$NegativeCacheTableUpdateCompanionBuilder,
      (
        NegativeCacheData,
        BaseReferences<_$AppDb, $NegativeCacheTable, NegativeCacheData>,
      ),
      NegativeCacheData,
      PrefetchHooks Function()
    >;
typedef $$CustomPacksTableCreateCompanionBuilder =
    CustomPacksCompanion Function({
      Value<int> id,
      required String name,
      required int createdAt,
    });
typedef $$CustomPacksTableUpdateCompanionBuilder =
    CustomPacksCompanion Function({
      Value<int> id,
      Value<String> name,
      Value<int> createdAt,
    });

final class $$CustomPacksTableReferences
    extends BaseReferences<_$AppDb, $CustomPacksTable, CustomPack> {
  $$CustomPacksTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static MultiTypedResultKey<$CustomWordsTable, List<CustomWord>>
  _customWordsRefsTable(_$AppDb db) => MultiTypedResultKey.fromTable(
    db.customWords,
    aliasName: 'custom_packs__id__custom_words__pack_id',
  );

  $$CustomWordsTableProcessedTableManager get customWordsRefs {
    final manager = $$CustomWordsTableTableManager(
      $_db,
      $_db.customWords,
    ).filter((f) => f.packId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_customWordsRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$CustomPacksTableFilterComposer
    extends Composer<_$AppDb, $CustomPacksTable> {
  $$CustomPacksTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  Expression<bool> customWordsRefs(
    Expression<bool> Function($$CustomWordsTableFilterComposer f) f,
  ) {
    final $$CustomWordsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.customWords,
      getReferencedColumn: (t) => t.packId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CustomWordsTableFilterComposer(
            $db: $db,
            $table: $db.customWords,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$CustomPacksTableOrderingComposer
    extends Composer<_$AppDb, $CustomPacksTable> {
  $$CustomPacksTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$CustomPacksTableAnnotationComposer
    extends Composer<_$AppDb, $CustomPacksTable> {
  $$CustomPacksTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<int> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  Expression<T> customWordsRefs<T extends Object>(
    Expression<T> Function($$CustomWordsTableAnnotationComposer a) f,
  ) {
    final $$CustomWordsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.customWords,
      getReferencedColumn: (t) => t.packId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CustomWordsTableAnnotationComposer(
            $db: $db,
            $table: $db.customWords,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$CustomPacksTableTableManager
    extends
        RootTableManager<
          _$AppDb,
          $CustomPacksTable,
          CustomPack,
          $$CustomPacksTableFilterComposer,
          $$CustomPacksTableOrderingComposer,
          $$CustomPacksTableAnnotationComposer,
          $$CustomPacksTableCreateCompanionBuilder,
          $$CustomPacksTableUpdateCompanionBuilder,
          (CustomPack, $$CustomPacksTableReferences),
          CustomPack,
          PrefetchHooks Function({bool customWordsRefs})
        > {
  $$CustomPacksTableTableManager(_$AppDb db, $CustomPacksTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$CustomPacksTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$CustomPacksTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$CustomPacksTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<int> id = const Value.absent(),
            Value<String> name = const Value.absent(),
            Value<int> createdAt = const Value.absent(),
          }) => CustomPacksCompanion(id: id, name: name, createdAt: createdAt),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String name,
                required int createdAt,
              }) => CustomPacksCompanion.insert(
                id: id,
                name: name,
                createdAt: createdAt,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$CustomPacksTable, CustomPack>(table),
                  $$CustomPacksTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({customWordsRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [if (customWordsRefs) db.customWords],
              addJoins: null,
              getPrefetchedDataCallback: (items) async {
                return [
                  if (customWordsRefs)
                    await $_getPrefetchedDataByColumns<
                      CustomPack,
                      $CustomPacksTable,
                      CustomWord,
                      $CustomWordsTable
                    >(
                      currentTable: table,
                      referencedTable: $$CustomPacksTableReferences
                          ._customWordsRefsTable(db),
                      managerFromTypedResult: (p0) =>
                          $$CustomPacksTableReferences(
                            db,
                            table,
                            p0,
                          ).customWordsRefs,
                      currentColumn: 'id',
                      referencedColumn: 'pack_id',
                      typedResults: items,
                    ),
                ];
              },
            );
          },
        ),
      );
}

typedef $$CustomPacksTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDb,
      $CustomPacksTable,
      CustomPack,
      $$CustomPacksTableFilterComposer,
      $$CustomPacksTableOrderingComposer,
      $$CustomPacksTableAnnotationComposer,
      $$CustomPacksTableCreateCompanionBuilder,
      $$CustomPacksTableUpdateCompanionBuilder,
      (CustomPack, $$CustomPacksTableReferences),
      CustomPack,
      PrefetchHooks Function({bool customWordsRefs})
    >;
typedef $$CustomWordsTableCreateCompanionBuilder =
    CustomWordsCompanion Function({
      Value<int> id,
      required int packId,
      required String word,
      Value<String> hintsJson,
      Value<String> fakesJson,
    });
typedef $$CustomWordsTableUpdateCompanionBuilder =
    CustomWordsCompanion Function({
      Value<int> id,
      Value<int> packId,
      Value<String> word,
      Value<String> hintsJson,
      Value<String> fakesJson,
    });

final class $$CustomWordsTableReferences
    extends BaseReferences<_$AppDb, $CustomWordsTable, CustomWord> {
  $$CustomWordsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $CustomPacksTable _packIdTable(_$AppDb db) =>
      db.customPacks.createAlias('custom_words__pack_id__custom_packs__id');

  $$CustomPacksTableProcessedTableManager get packId {
    final $_column = $_itemColumn<int>('pack_id')!;

    final manager = $$CustomPacksTableTableManager(
      $_db,
      $_db.customPacks,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_packIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$CustomWordsTableFilterComposer
    extends Composer<_$AppDb, $CustomWordsTable> {
  $$CustomWordsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get word => $composableBuilder(
    column: $table.word,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get hintsJson => $composableBuilder(
    column: $table.hintsJson,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get fakesJson => $composableBuilder(
    column: $table.fakesJson,
    builder: (column) => ColumnFilters(column),
  );

  $$CustomPacksTableFilterComposer get packId {
    final $$CustomPacksTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.packId,
      referencedTable: $db.customPacks,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CustomPacksTableFilterComposer(
            $db: $db,
            $table: $db.customPacks,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$CustomWordsTableOrderingComposer
    extends Composer<_$AppDb, $CustomWordsTable> {
  $$CustomWordsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get word => $composableBuilder(
    column: $table.word,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get hintsJson => $composableBuilder(
    column: $table.hintsJson,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get fakesJson => $composableBuilder(
    column: $table.fakesJson,
    builder: (column) => ColumnOrderings(column),
  );

  $$CustomPacksTableOrderingComposer get packId {
    final $$CustomPacksTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.packId,
      referencedTable: $db.customPacks,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CustomPacksTableOrderingComposer(
            $db: $db,
            $table: $db.customPacks,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$CustomWordsTableAnnotationComposer
    extends Composer<_$AppDb, $CustomWordsTable> {
  $$CustomWordsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get word =>
      $composableBuilder(column: $table.word, builder: (column) => column);

  GeneratedColumn<String> get hintsJson =>
      $composableBuilder(column: $table.hintsJson, builder: (column) => column);

  GeneratedColumn<String> get fakesJson =>
      $composableBuilder(column: $table.fakesJson, builder: (column) => column);

  $$CustomPacksTableAnnotationComposer get packId {
    final $$CustomPacksTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.packId,
      referencedTable: $db.customPacks,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CustomPacksTableAnnotationComposer(
            $db: $db,
            $table: $db.customPacks,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$CustomWordsTableTableManager
    extends
        RootTableManager<
          _$AppDb,
          $CustomWordsTable,
          CustomWord,
          $$CustomWordsTableFilterComposer,
          $$CustomWordsTableOrderingComposer,
          $$CustomWordsTableAnnotationComposer,
          $$CustomWordsTableCreateCompanionBuilder,
          $$CustomWordsTableUpdateCompanionBuilder,
          (CustomWord, $$CustomWordsTableReferences),
          CustomWord,
          PrefetchHooks Function({bool packId})
        > {
  $$CustomWordsTableTableManager(_$AppDb db, $CustomWordsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$CustomWordsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$CustomWordsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$CustomWordsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int> packId = const Value.absent(),
                Value<String> word = const Value.absent(),
                Value<String> hintsJson = const Value.absent(),
                Value<String> fakesJson = const Value.absent(),
              }) => CustomWordsCompanion(
                id: id,
                packId: packId,
                word: word,
                hintsJson: hintsJson,
                fakesJson: fakesJson,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required int packId,
                required String word,
                Value<String> hintsJson = const Value.absent(),
                Value<String> fakesJson = const Value.absent(),
              }) => CustomWordsCompanion.insert(
                id: id,
                packId: packId,
                word: word,
                hintsJson: hintsJson,
                fakesJson: fakesJson,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$CustomWordsTable, CustomWord>(table),
                  $$CustomWordsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({packId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (packId) {
                      state = state.withJoin(
                        currentTable: table,
                        currentColumn: table.packId,
                        referencedTable: $$CustomWordsTableReferences
                            ._packIdTable(db),
                        referencedColumn: $$CustomWordsTableReferences
                            ._packIdTable(db)
                            .id,
                      ) as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$CustomWordsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDb,
      $CustomWordsTable,
      CustomWord,
      $$CustomWordsTableFilterComposer,
      $$CustomWordsTableOrderingComposer,
      $$CustomWordsTableAnnotationComposer,
      $$CustomWordsTableCreateCompanionBuilder,
      $$CustomWordsTableUpdateCompanionBuilder,
      (CustomWord, $$CustomWordsTableReferences),
      CustomWord,
      PrefetchHooks Function({bool packId})
    >;

class $AppDbManager {
  final _$AppDb _db;
  $AppDbManager(this._db);
  $$KvRowsTableTableManager get kvRows =>
      $$KvRowsTableTableManager(_db, _db.kvRows);
  $$CachedWordsTableTableManager get cachedWords =>
      $$CachedWordsTableTableManager(_db, _db.cachedWords);
  $$NegativeCacheTableTableManager get negativeCache =>
      $$NegativeCacheTableTableManager(_db, _db.negativeCache);
  $$CustomPacksTableTableManager get customPacks =>
      $$CustomPacksTableTableManager(_db, _db.customPacks);
  $$CustomWordsTableTableManager get customWords =>
      $$CustomWordsTableTableManager(_db, _db.customWords);
}
